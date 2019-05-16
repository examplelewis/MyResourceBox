//
//  MRBLogManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/16.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "MRBLogManager.h"

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
// 通过变参函数显示需要通过[NSString stringWithFormat:]来构造的log语句
- (void)showLogWithFormat:(NSString *)alertFormat, ... {
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@", alertString);
    
    NSDate *now = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:now];
    NSString *timeDiffString = [MRBLogManager convertTimeDifferenceToString:timeDiff];
    NSString *dateString = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString *string = [NSString stringWithFormat:@"%@ | %@\t\t%@\n", dateString, timeDiffString, alertString];
    lastLog = string;
    ViewController *rootVC = [AppDelegate defaultVC];
    dispatch_async(dispatch_get_main_queue(), ^{
        rootVC.logTextView.string = [rootVC.logTextView.string stringByAppendingString:string];
        [rootVC scrollLogTextViewToBottom];
    });
}
- (void)showLogWithTitle:(NSString *)alertTitle andFormat:(NSString *)alertFormat, ... {
    NSAssert(alertTitle, @"alertTitle 不能为空");
    
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@, %@", alertTitle, alertString);
    
    NSDate *now = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:now];
    NSString *timeDiffString = [MRBLogManager convertTimeDifferenceToString:timeDiff];
    NSString *dateString = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString *string = [NSString stringWithFormat:@"%@ | %@\n%@\n%@\n", dateString, timeDiffString, alertTitle, alertString];
    lastLog = string;
    ViewController *rootVC = [AppDelegate defaultVC];
    dispatch_main_sync_safe((^() {
        rootVC.logTextView.string = [rootVC.logTextView.string stringByAppendingString:string];
        [rootVC scrollLogTextViewToBottom];
    }));
}
- (void)showNotAppendLogWithFormat:(NSString *)alertFormat, ... {
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@", alertString);
    
    NSDate *now = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:now];
    NSString *timeDiffString = [MRBLogManager convertTimeDifferenceToString:timeDiff];
    NSString *dateString = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    ViewController *rootVC = [AppDelegate defaultVC];
    dispatch_main_sync_safe((^() {
        NSString *logContent = rootVC.logTextView.string;
        logContent = [logContent stringByReplacingOccurrencesOfString:self->lastLog withString:@""];
        NSString *string = [NSString stringWithFormat:@"%@ | %@\n%@\n", dateString, timeDiffString, alertString];
        self->lastLog = string;
        logContent = [logContent stringByAppendingString:string];
        rootVC.logTextView.string = logContent;
    }));
}

- (void)cleanLog {
    lastLog = @"";
    ViewController *rootVC = [AppDelegate defaultVC];
    dispatch_async(dispatch_get_main_queue(), ^{
        rootVC.logTextView.string = @"";
    });
}
+ (void)resetCurrentDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"currentDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [AppDelegate defaultVC].logTextView.string = @"";
    [[MRBLogManager defaultManager] showLogWithFormat:@"---------------------------------------------------------------------------------"];
}
+ (NSString *)convertTimeDifferenceToString:(NSTimeInterval)timeDiff {
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeDiff sinceDate:date1];
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    
    NSString *string = [NSString stringWithFormat:@"%02ld:%02ld:%02ld.%03ld", [breakdownInfo hour], [breakdownInfo minute], [breakdownInfo second], (NSInteger)roundf([breakdownInfo nanosecond] / 1000000.0f)];
    
    return string;
}

@end
