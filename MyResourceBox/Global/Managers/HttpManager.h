//
//  HttpManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/10/05.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpManager : NSObject

+ (HttpManager *)sharedManager;

#pragma mark - Weibo
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
                         success:(void(^)(NSArray *array))success
                          failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// Tags
- (void)getGelbooruTagsWithPid:(NSInteger)pid
                       success:(void(^)(NSArray *array))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// Specific Tag
- (void)getSpecificTagPicFromGelbooruTag:(NSString *)tag
                                    page:(NSInteger)page
                                 success:(void(^)(NSArray *array))success
                                  failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;

#pragma mark - Rule34
// Posts
- (void)getRule34PostsWithPage:(NSInteger)page
                       success:(void(^)(NSArray *array))success
                        failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// Tags
- (void)getRule34TagsWithPid:(NSInteger)pid
                     success:(void(^)(NSArray *array))success
                      failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;
// Specific Tag
- (void)getSpecificTagPicFromRule34Tag:(NSString *)tag
                                  page:(NSInteger)page
                               success:(void(^)(NSArray *array))success
                                failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;

#pragma mark - ExHentai
- (void)getExHentaiPostDetailWithUrl:(NSString *)url
                             success:(void(^)(NSDictionary *result))success
                              failed:(void(^)(NSString *errorTitle, NSString *errorMsg))failed;

@end
