//
//  PixivLoginUserManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/27.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixivLoginUserManager : NSObject

/**
 * @brief 获取单例
 */
+ (PixivLoginUserManager *)sharedManager;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(nonnull void (^)(void))success failure:(nonnull void (^)(NSError * _Nonnull error))failure;

- (NSString *)getAccessToken;

@end

NS_ASSUME_NONNULL_END
