//
//  PixivLoginUserManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/27.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivLoginUserManager.h"
#import "PixivHttpSessionManager.h"
#import "PixivGeneralManager.h"

@interface PixivLoginUserManager () {
    
}

@property (nonatomic, assign, readonly) BOOL isLogin;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, copy, readonly) NSString *accessToken;
@property (nonatomic, copy, readonly) NSString *session;
@property (nonatomic, assign, readonly) NSInteger userId;

@end

@implementation PixivLoginUserManager

#pragma mark - Lifecycle
+ (PixivLoginUserManager *)sharedManager {
    static PixivLoginUserManager *_sharedManager;
    static dispatch_once_t yxzUserManagerOnce;
    dispatch_once(&yxzUserManagerOnce, ^{
        _sharedManager = [[PixivLoginUserManager alloc] init];
    });
    
    return _sharedManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(nonnull void (^)(void))success failure:(nonnull void (^)(NSError * _Nonnull error))failure {
    _username = username;
    _password = password;
    
    NSDictionary *defaultHeaders = @{@"Referer": @"http://spapi.pixiv.net/",
                                     @"User-Agent": @"PixivIOSApp/5.1.1",
                                     @"Content-Type": @"application/x-www-form-urlencoded"};
    NSDictionary *body = @{@"client_id": @"bYGKuGVw91e0NMfPGp44euvGt59s",
                           @"client_secret": @"HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK",
//                           @"get_secure_url": @(1),
                           @"grant_type": @"password",
                           @"username": username,
                           @"password": password};
    NSString *bodyString = [PixivGeneralManager encodeDictionary:body];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://oauth.secure.pixiv.net/auth/token" parameters:nil error:nil];
    request.timeoutInterval = 15;
    for (NSString *key in defaultHeaders) {
        [request setValue:defaultHeaders[key] forHTTPHeaderField:key];
    }
    [request setValue:@"http://www.pixiv.net/" forHTTPHeaderField:@"Referer"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:NULL downloadProgress:NULL completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            self->_accessToken = responseObject[@"response"][@"access_token"];
            self->_userId = [responseObject[@"response"][@"user"][@"id"] integerValue];
            
            if (success) {
                success();
            }
        }
    }];
    [task resume];
}

- (NSString *)getAccessToken {
    return _accessToken;
}
- (BOOL)isLogin {
    return _accessToken && _accessToken.length > 0;
}

@end
