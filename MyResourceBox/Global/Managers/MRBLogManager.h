//
//  MRBLogManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/16.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBLogManager : NSObject

#pragma mark - Lifecycle
+ (MRBLogManager *)defaultManager;

#pragma mark - 在界面控制台上显示/清除信息
- (void)showLogWithFormat:(NSString *)alertFormat, ...;
- (void)showLogWithTitle:(NSString *)alertTitle andFormat:(NSString *)alertFormat, ...;
- (void)showNotAppendLogWithFormat:(NSString *)alertFormat, ...;

#pragma mark - 辅助方法
+ (void)resetCurrentDate;
- (void)cleanLog;

@end

NS_ASSUME_NONNULL_END
