//
//  CatchCrashManager.m
//  kewoYouXiangZhuan
//
//  Created by 龚宇 on 18/12/21.
//  Copyright © 2018 kewo. All rights reserved.
//

#import "CatchCrashManager.h"

@implementation CatchCrashManager

//在AppDelegate中注册后，程序崩溃时会执行的方法
void uncaughtExceptionHandler(NSException *exception) {
    NSString *crashTime = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.ssssssZZZ"];
    NSString *exceptionInfo = [NSString stringWithFormat:@"crashTime: %@\nException reason: %@\nException name: %@\nException stack:%@", crashTime, [exception name], [exception reason], [exception callStackSymbols]];
        
    DDLogError(@"【此处出现闪退】-----\n%@", exceptionInfo);
}

@end
