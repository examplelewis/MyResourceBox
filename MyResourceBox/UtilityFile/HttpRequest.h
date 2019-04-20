//
//  HttpRequest.h
//  SJYH
//
//  Created by 张旭东 on 15/1/19.
//  Copyright (c) 2015年 设易. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface HttpRequest : NSObject

+ (HttpRequest *)shareIndex;

#pragma mark -- 微博相关 --
// OAuth2 请求 token
- (void)getWeiboTokenWithStart:(void(^)(void))start
                       success:(void(^)(NSDictionary *dic))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// OAuth2 查询 token
- (void)getWeiboTokenInfoWithStart:(void(^)(void))start
                           success:(void(^)(NSDictionary *dic))success
                            failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// OAuth2 查询 token 的 limit
- (void)getWeiboLimitInfoWithStart:(void(^)(void))start
                           success:(void(^)(NSDictionary *dic))success
                            failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// 获取微博收藏列表
- (void)getWeiboFavoritesWithPage:(NSInteger)page
                            start:(void(^)(void))start
                          success:(void(^)(NSDictionary *dic))success
                           failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;

#pragma mark - Danbooru
// Posts
- (void)getGelbooruPostsWithPage:(NSInteger)page
                        progress:(void(^)(NSProgress *downloadProgress))progress
                         success:(void(^)(NSArray *array))success
                          failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// Tags
- (void)getGelbooruTagsWithPid:(NSInteger)pid
                       success:(void(^)(NSArray *array))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// Specific Tag
- (void)getSpecificTagPicFromGelbooruTag:(NSString *)tag
                                    page:(NSInteger)page
                                progress:(void(^)(NSProgress *downloadProgress))progress
                                 success:(void(^)(NSArray *array))success
                                  failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;

@end
