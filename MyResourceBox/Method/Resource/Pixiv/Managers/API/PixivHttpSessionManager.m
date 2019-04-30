//
//  PixivHttpSessionManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/27.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivHttpSessionManager.h"

@interface PixivHttpSessionManager () {
    NSString *username;
    NSString *password;
    NSString *refreshToken;
}

@end

@implementation PixivHttpSessionManager

/**
 * @brief 获取单例
 */
+ (PixivHttpSessionManager *)sharedManager {
    static PixivHttpSessionManager *_sharedManager;
    static dispatch_once_t yxzHTTPSessionManagerOnce;
    dispatch_once(&yxzHTTPSessionManagerOnce, ^{        
        _sharedManager = [[PixivHttpSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://app-api.pixiv.net/"] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _sharedManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        _sharedManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        
        // timeout
        [_sharedManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _sharedManager.requestSerializer.timeoutInterval = 5.0f;
        [_sharedManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        // header
        [_sharedManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_sharedManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [_sharedManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"App-OS"];
        [_sharedManager.requestSerializer setValue:@"9.3.3" forHTTPHeaderField:@"App-OS-Version"];
        [_sharedManager.requestSerializer setValue:@"6.0.9" forHTTPHeaderField:@"App-Version"];
    });
    
    return _sharedManager;
}

/**
 * @brief 生成通用的 HttpSessionManager
 */
+ (AFHTTPSessionManager *)generateAFHTTPSessionManager {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    // timeout
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 5.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    // header
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"App-OS"];
    [manager.requestSerializer setValue:@"9.3.3" forHTTPHeaderField:@"App-OS-Version"];
    [manager.requestSerializer setValue:@"6.0.9" forHTTPHeaderField:@"App-Version"];
    
    return manager;
}

/**
 *  @brief GET请求
 *
 *  @param url          url
 *  @param parameters   body
 *  @param headers      header
 *  @param before       请求前
 *  @param progress     进度
 *  @param success      成功
 *  @param failure      失败
 */
- (NSURLSessionDataTask *)GET:(NSString *)url parameters:(id)parameters headers:(id)headers before:(beforeRequest)before progress:(requestProgress)progress success:(requestSuccess)success failure:(requestFailed)failure {
    if (headers) {
        for (NSString *header in [headers allKeys]) {
            [self.requestSerializer setValue:headers[header] forHTTPHeaderField:header];
        }
        
        [self setupBasicHeader];
    }
    
    if (before) {
        before();
    }
    
    DDLogInfo(@"request.url=%@, params=%@, headers=%@", url, parameters, headers);
    
    return [self GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        //        DDLogInfo(@"request.downloadProgress=%@", downloadProgress);
        
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"request.url=%@, success=%@", task.response.URL.absoluteString, responseObject);
        
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"request.url=%@, failure=%@", task.response.URL.absoluteString, error);
        
        if (failure) {
            failure(task, error);
        }
    }];
}

/**
 *  @brief POST请求
 *
 *  @param url          url
 *  @param parameters   body
 *  @param headers      header
 *  @param before       请求前
 *  @param progress     进度
 *  @param success      成功
 *  @param failure      失败
 */
- (NSURLSessionDataTask *)POST:(NSString *)url parameters:(nullable id)parameters headers:(id)headers before:(beforeRequest)before progress:(requestProgress)progress success:(requestSuccess)success failure:(requestFailed)failure {
    if (headers) {
        for (NSString *header in [headers allKeys]) {
            [self.requestSerializer setValue:headers[header] forHTTPHeaderField:header];
        }
        
        [self setupBasicHeader];
    }
    
    if (before) {
        before();
    }
    
    if (!parameters) {
        parameters = [NSMutableDictionary dictionary];
    }
    
    DDLogInfo(@"request.url=%@, params=%@, headers=%@", url, parameters, headers);
    //    NSLog(@"realUrl: %@", [NSURL URLWithString:url relativeToURL:self.baseURL].absoluteString);
    //    NSLog(@"self.baseURL: %@", self.baseURL);
    
    return [self POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        //        DDLogInfo(@"request.uploadProgress=%@", uploadProgress);
        
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"request.url=%@, success=%@", task.response.URL.absoluteString, responseObject);
        
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"request.url=%@, failure=%@", task.response.URL.absoluteString, error);
        
        if (failure) {
            failure(task, error);
        }
    }];
}

/**
 * @brief 设置基本公共参数
 */
- (void)setupBasicHeader {
//    NSString *userID = @"";
//    NSString *accessToken = @"";
//    if ([YXZUserManager sharedManager].isLogin) {
//        userID = [YXZUserManager sharedManager].loginUser.clientInfo.clientId;
//        accessToken = [YXZUserManager sharedManager].loginUser.token;
//    }
//    
//    [self.requestSerializer setValue:@"1" forHTTPHeaderField:@"osType"];
//    [self.requestSerializer setValue:BFGetAppVersion() forHTTPHeaderField:@"appVersion"];
//    [self.requestSerializer setValue:userID forHTTPHeaderField:@"clientId"];
//    [self.requestSerializer setValue:accessToken forHTTPHeaderField:@"accessToken"];
//    [self.requestSerializer setValue:[[YXZUserManager sharedManager] UUID] forHTTPHeaderField:@"deviceToken"];
//    [self.requestSerializer setValue:[YXZDeviceManager deviceType] forHTTPHeaderField:@"deviceType"];
//    [self.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@", BFOSVersion()] forHTTPHeaderField:@"deviceSystem"];
//    //    [self.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"channel"];
}

/**
 *  @brief GET请求(不需要 progress)
 *
 *  @param url          url
 *  @param parameters   body
 *  @param headers      header
 *  @param before       请求前
 *  @param success      成功
 *  @param failure      失败
 */
- (NSURLSessionDataTask *)GET:(NSString *)url parameters:(id)parameters headers:(id)headers before:(beforeRequest)before success:(requestSuccess)success failure:(requestFailed)failure {
    return [self GET:url parameters:parameters headers:headers before:before progress:NULL success:success failure:failure];
}


/**
 *  @brief POST请求(不需要 progress)
 *
 *  @param url          url
 *  @param parameters   body
 *  @param headers      header
 *  @param before       请求前
 *  @param success      成功
 *  @param failure      失败
 */
- (NSURLSessionDataTask *)POST:(NSString *)url parameters:(nullable id)parameters headers:(id)headers before:(beforeRequest)before  success:(requestSuccess)success failure:(requestFailed)failure {
    return [self POST:url parameters:parameters headers:headers before:before progress:NULL success:success failure:failure];
}

@end
