//
//  HttpRequest.m
//  SJYH
//
//  Created by 张旭东 on 15/1/19.
//  Copyright (c) 2015年 设易. All rights reserved.
//

#import "HttpRequest.h"
#import "XMLReader.h"

@interface HttpRequest ()

@end

@implementation HttpRequest

static HttpRequest *request;
+ (HttpRequest *)shareIndex {
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        request = [[HttpRequest alloc] init];
    });
    
    return request;
}

#pragma mark -- 微博相关 --
// OAuth2 请求 token
- (void)getWeiboTokenWithStart:(void(^)(void))start
                       success:(void(^)(NSDictionary *dic))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/oauth2/access_token";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"client_id"] = @"587160380";
    parameters[@"client_secret"] = @"5cdf1dc7f9eb3ad62a68aef8bdb395c7";
    parameters[@"redirect_uri"] = @"myresourcebox://success.html";
    parameters[@"grant_type"] = @"authorization_code";
    parameters[@"code"] = [UserInfo defaultUser].weibo_code;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
    
    if(start){
        start();
    }
}
// OAuth2 查询 token
- (void)getWeiboTokenInfoWithStart:(void(^)(void))start
                           success:(void(^)(NSDictionary *dic))success
                            failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/oauth2/get_token_info";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"access_token"] = [UserInfo defaultUser].weibo_token;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
    
    if(start){
        start();
    }
}
// OAuth2 查询 token 的 limit
- (void)getWeiboLimitInfoWithStart:(void(^)(void))start
                           success:(void(^)(NSDictionary *dic))success
                            failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/2/account/rate_limit_status.json";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"access_token"] = [UserInfo defaultUser].weibo_token;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
    
    if(start){
        start();
    }
}
// 获取微博收藏列表
- (void)getWeiboFavoritesWithPage:(NSInteger)page
                            start:(void(^)(void))start
                          success:(void(^)(NSDictionary *dic))success
                           failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/2/favorites.json";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"access_token"] = [UserInfo defaultUser].weibo_token;
    parameters[@"count"] = @(50);
    parameters[@"page"] = @(page);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error) { // 如果解析出现错误
            if (failed) {
                failed(@"数据解析发生错误", [error localizedDescription]);
            }
        } else {
            if (success) {
                success(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failed) {
            failed(@"服务器通讯发生错误", [error localizedDescription]);
        }
    }];
    
    if(start){
        start();
    }
}

#pragma mark - Gelbooru
// Posts
- (void)getGelbooruPostsWithPage:(NSInteger)page
                        progress:(void(^)(NSProgress *downloadProgress))progress
                         success:(void(^)(NSArray *array))success
                          failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://gelbooru.com/index.php?page=dapi&s=post&q=index"
      parameters:@{@"pid":@(page)}
        progress:progress
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSString *xmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSError *error = nil;
             NSDictionary *xmlDict = [XMLReader dictionaryForXMLString:xmlString error:&error];
             
             if (error) { // 如果解析出现错误
                 if (failed) {
                     failed(@"数据解析发生错误", [error localizedDescription]);
                 }
             } else {
                 if (!xmlDict[@"posts"]) {
                     if (failed) {
                         failed(@"接口返回数据异常", xmlDict[@"response"][@"reason"]);
                     }
                 } else {
                     NSArray *array = [NSArray arrayWithArray:xmlDict[@"posts"][@"post"]];
                     if (success) {
                         success(array);
                     }
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (failed) {
                 failed(@"服务器通讯发生错误", [error localizedDescription]);
             }
         }
     ];
}
// Tags
- (void)getGelbooruTagsWithPid:(NSInteger)pid
                       success:(void(^)(NSArray *array))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://gelbooru.com/index.php?page=dapi&s=tag&q=index"
      parameters:@{@"pid":@(pid), @"order":@"name", @"limit":@(1000)}
        progress:NULL
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSString *xmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSError *error = nil;
             NSDictionary *xmlDict = [XMLReader dictionaryForXMLString:xmlString error:&error];
             
             if (error) { // 如果解析出现错误
                 if (failed) {
                     failed(@"数据解析发生错误", [error localizedDescription]);
                 }
             } else {
                 if (!xmlDict[@"tags"]) {
                     //                    if (failed) {
                     //                        failed(@"接口返回数据异常", xmlDict[@"response"][@"reason"]);
                     //                    }
                     
                     // 没有 tags 字段说明已经下载完成了
                     if (success) {
                         success(@[]);
                     }
                 } else {
                     NSArray *array = [NSArray arrayWithArray:xmlDict[@"tags"][@"tag"]];
                     if (success) {
                         success(array);
                     }
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (failed) {
                 failed(@"服务器通讯发生错误", [error localizedDescription]);
             }
         }
     ];
}
// Specific Tag
- (void)getSpecificTagPicFromGelbooruTag:(NSString *)tag
                                    page:(NSInteger)page
                                progress:(void(^)(NSProgress *downloadProgress))progress
                                 success:(void(^)(NSArray *array))success
                                  failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager GET:@"https://gelbooru.com/index.php?page=dapi&s=post&q=index"
      parameters:@{@"pid":@(page), @"tags": tag}
        progress:NULL
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSString *xmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSError *error = nil;
             NSDictionary *xmlDict = [XMLReader dictionaryForXMLString:xmlString error:&error];

             if (error) { // 如果解析出现错误
                 if (failed) {
                     failed(@"数据解析发生错误", [error localizedDescription]);
                 }
             } else {
                 if (!xmlDict[@"posts"]) {
                     if (failed) {
                         failed(@"接口返回数据异常", xmlDict[@"response"][@"reason"]);
                     }
                 } else {
                     NSArray *array = [NSArray arrayWithArray:xmlDict[@"posts"][@"post"]];
                     if (success) {
                         success(array);
                     }
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (failed) {
                 failed(@"服务器通讯发生错误", [error localizedDescription]);
             }
         }
     ];
}


@end
