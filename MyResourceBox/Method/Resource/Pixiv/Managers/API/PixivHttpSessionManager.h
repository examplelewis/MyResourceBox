//
//  PixivHttpSessionManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/27.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

// 请求之前
typedef void (^ _Nullable beforeRequest)(void);
// 上传进度
typedef void (^ _Nullable requestProgress)(NSProgress *progress);
// 请求结果
typedef void (^requestSuccess)(NSURLSessionDataTask *task, id response);
// 请求结果
typedef void (^requestObjSuccess)(id obj);
// 请求出错
typedef void (^requestFailed)(NSURLSessionDataTask *task, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface PixivHttpSessionManager : AFHTTPSessionManager

/**
 * @brief 获取单例
 */
+ (PixivHttpSessionManager *)sharedManager;
/**
 * @brief 生成通用的 HttpSessionManager
 */
+ (AFHTTPSessionManager *)generateAFHTTPSessionManager;

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
- (NSURLSessionDataTask *)GET:(NSString *)url parameters:(id)parameters headers:(id)headers before:(beforeRequest)before progress:(requestProgress)progress success:(requestSuccess)success failure:(requestFailed)failure;

/**
 *  @brief GET请求
 *
 *  @param url          url
 *  @param parameters   body
 *  @param headers      header
 *  @param before       请求前
 *  @param success      成功
 *  @param failure      失败
 */
- (NSURLSessionDataTask *)GET:(NSString *)url parameters:(id)parameters headers:(id)headers before:(beforeRequest)before success:(requestSuccess)success failure:(requestFailed)failure;

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
- (NSURLSessionDataTask *)POST:(NSString *)url parameters:(nullable id)parameters headers:(id)headers before:(beforeRequest)before progress:(requestProgress)progress success:(requestSuccess)success failure:(requestFailed)failure;

/**
 *  @brief POST请求
 *
 *  @param url          url
 *  @param parameters   body
 *  @param headers      header
 *  @param before       请求前
 *  @param success      成功
 *  @param failure      失败
 */
- (NSURLSessionDataTask *)POST:(NSString *)url parameters:(nullable id)parameters headers:(id)headers before:(beforeRequest)before success:(requestSuccess)success failure:(requestFailed)failure;

@end

NS_ASSUME_NONNULL_END
