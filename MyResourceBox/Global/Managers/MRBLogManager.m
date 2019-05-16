//
//  MRBLogManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/16.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "MRBLogManager.h"

static NSString * const kTitleKey = @"kTitleKey";
static NSString * const kAppendLogKey = @"kAppendLogKey";
static NSString * const kShowTimeKey = @"kShowTimeKey";

@interface MRBLogManager () {
    NSString *lastLog;
}

@end

@implementation MRBLogManager

#pragma mark - Lifecycle
+ (MRBLogManager *)defaultManager {
    static dispatch_once_t onceToken;
    static MRBLogManager *_defaultManager;
    
    dispatch_once(&onceToken, ^{
        _defaultManager = [MRBLogManager new];
    });
    
    return _defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        lastLog = @"";
    }
    
    return self;
}

#pragma mark - 在界面控制台上显示/清除信息
- (void)showLogWithFormat:(NSString *)alertFormat, ... {
    // 解析 alertFormat
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@", alertString);
    
    [self showLogWithParameters:nil andAlertString:alertString];
}
- (void)showLogWithTitle:(NSString *)alertTitle andFormat:(NSString *)alertFormat, ... {
    // 解析 alertFormat
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@", alertString);
    
    [self showLogWithParameters:@{kTitleKey: alertTitle} andAlertString:alertString];
}
- (void)showNotAppendLogWithFormat:(NSString *)alertFormat, ... {
    // 解析 alertFormat
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@", alertString);
    
    [self showLogWithParameters:@{kAppendLogKey: @(NO)} andAlertString:alertString];
}
- (void)showNotShowTimeLogWithFormat:(NSString *)alertFormat, ... {
    // 解析 alertFormat
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@", alertString);
    
    [self showLogWithParameters:@{kShowTimeKey: @(NO)} andAlertString:alertString];
}

#pragma mark - 显示 Log 的具体实现方法
- (void)showLogWithParameters:(NSDictionary *)parameters andAlertString:(NSString *)alertString {
    // 从 parameters 中获取必要参数
    NSString *logTitle = @"";
    BOOL showLogTitle = NO;
    BOOL showLogTime = YES;
    BOOL appendLastLog = YES;
    if (parameters) {
        if (parameters[kShowTimeKey]) {
            showLogTime = [parameters[kShowTimeKey] boolValue];
        }
        if (parameters[kTitleKey]) {
            logTitle = parameters[kTitleKey];
            showLogTitle = YES;
        }
        if (parameters[kAppendLogKey]) {
            appendLastLog = [parameters[kAppendLogKey] boolValue];
        }
    }
    
    // 获取当前日期
    NSString *dateString = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *now = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:now];
    NSString *timeDiffString = [MRBLogManager convertTimeDifferenceToString:timeDiff];
    
    // 拼接一条 logEntry
    NSString *aLogEntry = @"";
    if (showLogTime) {
        aLogEntry = [aLogEntry stringByAppendingFormat:@"%@ | %@", dateString, timeDiffString]; // 添加时间
        // 根据是否显示标题，加特定的内容；显示时间的话，内容前面要加上 \n 或者 \t
        if (showLogTitle) {
            aLogEntry = [aLogEntry stringByAppendingFormat:@"\n%@\n%@\n", logTitle, alertString];
        } else {
            aLogEntry = [aLogEntry stringByAppendingFormat:@"\t\t%@\n", alertString];
        }
    } else {
        // 根据是否显示标题，加特定的内容；不显示时间的话，内容前面不加 \n 和 \t
        if (showLogTitle) {
            aLogEntry = [aLogEntry stringByAppendingFormat:@"%@\n%@\n", logTitle, alertString];
        } else {
            aLogEntry = [aLogEntry stringByAppendingFormat:@"%@\n", alertString];
        }
    }
    
    // 在 logTextView 上显示 log
    if (appendLastLog) {
        lastLog = aLogEntry;
        
        ViewController *rootVC = [AppDelegate defaultVC];
        dispatch_main_sync_safe((^() {
            rootVC.logTextView.string = [rootVC.logTextView.string stringByAppendingString:aLogEntry];
            [rootVC scrollLogTextViewToBottom];
        }));
    } else {
        ViewController *rootVC = [AppDelegate defaultVC];
        dispatch_main_sync_safe((^() {
            NSString *logContent = rootVC.logTextView.string;
            logContent = [logContent stringByReplacingOccurrencesOfString:self->lastLog withString:@""];
            self->lastLog = aLogEntry;
            logContent = [logContent stringByAppendingString:aLogEntry];
            rootVC.logTextView.string = logContent;
        }));
    }
}

#pragma mark - 辅助方法
- (void)cleanLog {
    lastLog = @"";
    ViewController *rootVC = [AppDelegate defaultVC];
    dispatch_main_sync_safe(^() {
        rootVC.logTextView.string = @"";
    });
}
+ (void)resetCurrentDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"currentDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [AppDelegate defaultVC].logTextView.string = @"";
    [[MRBLogManager defaultManager] showNotShowTimeLogWithFormat:@"---------------------------------------------------------------------------------"];
}
+ (NSString *)convertTimeDifferenceToString:(NSTimeInterval)timeDiff {
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeDiff sinceDate:date1];
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    
    NSString *string = [NSString stringWithFormat:@"%02ld:%02ld.%03ld", [breakdownInfo minute], [breakdownInfo second], (NSInteger)roundf([breakdownInfo nanosecond] / 1000000.0f)];
    
    return string;
}

@end
