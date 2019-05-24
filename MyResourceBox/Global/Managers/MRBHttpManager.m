//
//  MRBHttpManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/10/05.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "MRBHttpManager.h"
#import "XMLReader.h"

@implementation MRBHttpManager

+ (MRBHttpManager *)sharedManager {
    static MRBHttpManager *_sharedManager;
    static dispatch_once_t _sharedManagerOnce;
    
    dispatch_once(&_sharedManagerOnce, ^{
        _sharedManager = [[MRBHttpManager alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark -- 微博相关 --
// OAuth2 请求 token
- (void)getWeiboTokenWithStart:(void(^)(void))start
                       success:(void(^)(NSDictionary *dic))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSString *url = @"https://api.weibo.com/oauth2/access_token";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"client_id"] = @"587160380";
    parameters[@"client_secret"] = @"d44d86c3ba2fbabf9a197f4514a67d21";
    parameters[@"redirect_uri"] = @"myresourcebox://success.html";
    parameters[@"grant_type"] = @"authorization_code";
    parameters[@"code"] = [MRBUserManager defaultManager].weibo_code;
    
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
    parameters[@"access_token"] = [MRBUserManager defaultManager].weibo_token;
    
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
    parameters[@"access_token"] = [MRBUserManager defaultManager].weibo_token;
    
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
    parameters[@"access_token"] = [MRBUserManager defaultManager].weibo_token;
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
                         success:(void(^)(NSArray *array))success
                          failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://gelbooru.com/index.php?page=dapi&s=post&q=index"
      parameters:@{@"pid":@(page)}
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
                     id post = xmlDict[@"posts"][@"post"];
                     if (!post) {
                         if (success) {
                             success(@[]);
                         }
                     } else if ([post isKindOfClass:[NSArray class]]) {
                         NSArray *array = [NSArray arrayWithArray:post];
                         if (success) {
                             success(array);
                         }
                     } else if ([post isKindOfClass:[NSDictionary class]]) {
                         if (success) {
                             success(@[post]);
                         }
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
// Tag Count
- (void)getSpecificTagPicCountFromGelbooruTag:(NSString *)tag
                                      success:(void(^)(NSInteger totalCount))success
                                       failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://gelbooru.com/index.php?page=dapi&s=post&q=index"
      parameters:@{@"pid": @(0), @"tags": tag}
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
                     id count = xmlDict[@"posts"][@"count"];
                     if ([count isKindOfClass:[NSNull class]]) {
                         if (success) {
                             success(0);
                         }
                     } else {
                         if (success) {
                             success([count integerValue]);
                         }
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

#pragma mark - Rule34
// Posts
- (void)getRule34PostsWithPage:(NSInteger)page
                       success:(void(^)(NSArray *array))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://rule34.xxx/index.php?page=dapi&s=post&q=index"
      parameters:@{@"pid":@(page)}
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
// Tags
- (void)getRule34TagsWithPid:(NSInteger)pid
                       success:(void(^)(NSArray *array))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://rule34.xxx/index.php?page=dapi&s=tag&q=index"
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
- (void)getSpecificTagPicFromRule34Tag:(NSString *)tag
                                  page:(NSInteger)page
                               success:(void(^)(NSArray *array))success
                                failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://rule34.xxx/index.php?page=dapi&s=post&q=index"
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
                     id post = xmlDict[@"posts"][@"post"];
                     if (!post) {
                         if (success) {
                             success(@[]);
                         }
                     } else if ([post isKindOfClass:[NSArray class]]) {
                         NSArray *array = [NSArray arrayWithArray:post];
                         if (success) {
                             success(array);
                         }
                     } else if ([post isKindOfClass:[NSDictionary class]]) {
                         if (success) {
                             success(@[post]);
                         }
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
// Tag Count
- (void)getSpecificTagPicCountFromRule34Tag:(NSString *)tag
                                    success:(void(^)(NSInteger totalCount))success
                                     failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"https://rule34.xxx/index.php?page=dapi&s=post&q=index"
      parameters:@{@"pid": @(0), @"tags": tag}
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
                     id count = xmlDict[@"posts"][@"count"];
                     if ([count isKindOfClass:[NSNull class]]) {
                         if (success) {
                             success(0);
                         }
                     } else {
                         if (success) {
                             success([count integerValue]);
                         }
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

#pragma mark - ExHentai
- (void)getExHentaiPostDetailWithUrl:(NSString *)url
                             success:(void(^)(NSDictionary *result))success
                              failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed {
    NSArray *urlComps = [[NSURL URLWithString:url] pathComponents];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    
    [manager POST:@"https://api.e-hentai.org/api.php"
      parameters:@{@"method": @"gdata", @"gidlist": @[@[urlComps[2], urlComps[3]]], @"namespace": @(1)}
        progress:NULL
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (!responseObject || ![responseObject isKindOfClass:[NSDictionary class]] || !responseObject[@"gmetadata"] || ![responseObject[@"gmetadata"] isKindOfClass:[NSArray class]] || [responseObject[@"gmetadata"] count] == 0) {
                 if (failed) {
                     failed(@"返回数据出错", @"接口未返回正确格式的数据");
                 }
             } else {
                 NSDictionary *result = [responseObject[@"gmetadata"] firstObject];
                 if (success) {
                     success(result);
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
