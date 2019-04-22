//
//  CatchCrashManager.h
//  kewoYouXiangZhuan
//
//  Created by 龚宇 on 18/12/21.
//  Copyright © 2018 kewo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CatchCrashManager : NSObject

void uncaughtExceptionHandler(NSException *exception);

@end

NS_ASSUME_NONNULL_END
