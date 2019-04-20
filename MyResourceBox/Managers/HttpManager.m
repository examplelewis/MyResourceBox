//
//  HttpManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/10/05.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "HttpManager.h"

@implementation HttpManager

+ (HttpManager *)sharedManager {
    static HttpManager *_sharedManager;
    static dispatch_once_t _sharedManagerOnce;
    
    dispatch_once(&_sharedManagerOnce, ^{
        _sharedManager = [[HttpManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)getExHentaiPostDetail:(NSString *)url completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSArray *urlComps = [[NSURL URLWithString:url] pathComponents];
    NSDictionary *params = @{@"method": @"gdata", @"gidlist": @[@[urlComps[2], urlComps[3]]], @"namespace": @(1)};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];  // Convert your parameter to NSDATA
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];  // Convert data into string using NSUTF8StringEncoding
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]; //Intialialize AFURLSessionManager
    AFHTTPResponseSerializer *rS = (AFHTTPResponseSerializer *)manager.responseSerializer;
    rS.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://api.e-hentai.org/api.php" parameters:nil error:nil];  // make NSMutableURL req
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:req completionHandler:completionHandler];
    [task resume];
}

@end
