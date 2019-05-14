//
//  PixivAPIManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/27.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivAPIManager.h"
#import "PixivLoginUserManager.h"
#import "PixivGeneralManager.h"

@implementation PixivAPIManager

+ (void)callPixivApiWithURL:(NSString *)url success:(void (^)(NSURLSessionDataTask * _Nullable, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    NSDictionary *defaultHeaders = @{@"Referer": @"http://spapi.pixiv.net/",
                                     @"User-Agent": @"PixivIOSApp/5.1.1",
                                     @"Content-Type": @"application/x-www-form-urlencoded"};
    
//    NSString *request_url = @"https://app-api.pixiv.net/v1/user/following";
//    NSString *url_params = [PixivGeneralManager encodeDictionary:@{@"user_id": @(6826008), @"restrict": @"public"}];
//    if (url_params) {
//        request_url = [NSString stringWithFormat:@"%@?%@", request_url, url_params];
//    }
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    request.timeoutInterval = 15;
    for (NSString *key in defaultHeaders) {
        [request setValue:defaultHeaders[key] forHTTPHeaderField:key];
    }
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [[PixivLoginUserManager sharedManager] getAccessToken]] forHTTPHeaderField:@"Authorization"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:NULL downloadProgress:NULL completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(nil, error);
            }
        } else {
            if (success) {
                success(nil, responseObject);
            }
        }
    }];
    [task resume];
}



@end
