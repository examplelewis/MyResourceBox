//
//  UtilityFile.m
//  SJYH
//
//  Created by 龚宇 on 15/1/20.
//  Copyright (c) 2015年 设易. All rights reserved.
//

#import "UtilityFile.h"

@interface UtilityFile () {
    NSString *lastLog;
}

@end

@implementation UtilityFile

static UtilityFile *_sharedInstance;

// 单例模式
+ (UtilityFile *)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[UtilityFile alloc] init];
    });
    
    return _sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        lastLog = @"";
    }
    
    return self;
}

+ (void)resetCurrentDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"currentDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [AppDelegate defaultVC].logTextView.string = @"";
    [[UtilityFile sharedInstance] showLogWithFormat:@"------------------------------------------------------------"];
}

// 通过变参函数显示需要通过[NSString stringWithFormat:]来构造的log语句
- (void)showLogWithFormat:(NSString *)alertFormat, ... {
    va_list args;
    va_start(args, alertFormat);
    NSString *alertString = [[NSString alloc] initWithFormat:alertFormat arguments:args];
    va_end(args);
    DDLogInfo(@"%@", alertString);
    
    NSDate *now = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:now];
    NSString *timeDiffString = [UtilityFile convertTimeDifferenceToString:timeDiff];
    NSString *dateString = [[NSDate date] formattedDateWithFormat:@"HH:mm:ss.SSS"];
    
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
    NSString *timeDiffString = [UtilityFile convertTimeDifferenceToString:timeDiff];
    NSString *dateString = [[NSDate date] formattedDateWithFormat:@"HH:mm:ss.SSS"];
    
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
    NSString *timeDiffString = [UtilityFile convertTimeDifferenceToString:timeDiff];
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

// -------------------------------------------------------------------------------
//	写入读取文本文件
// -------------------------------------------------------------------------------
+ (void)exportString:(NSString *)string atPath:(NSString *)path {
    NSError *error;
    BOOL success = [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", path];
    }
}
+ (void)exportArray:(NSArray *)array atPath:(NSString *)path {
    NSError *error;
    NSString *content = [UtilityFile convertResultArray:array];
    if (!content) {
        // 说明转换 array 的时候出了错误，换一种之间的方式
        content = [array componentsJoinedByString:@"\n"];
    }
    
    BOOL success = [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"导出结果文件出错：%@", [error localizedDescription]];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"结果文件导出成功，请查看：%@", path];
    }
}
+ (void)exportDictionary:(NSDictionary *)dictionary atPath:(NSString *)path {
    NSError *error;
    NSString *content = [UtilityFile convertResultDict:dictionary];
    
    BOOL success = [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", path];
    }
}
+ (void)exportArray:(NSArray *)array atPlistPath:(NSString *)plistPath {
    NSError *error;
    
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:array format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    BOOL success = [plistData writeToFile:plistPath atomically:YES];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", plistPath];
    }
}
+ (void)exportDictionary:(NSDictionary *)dictionary atPlistPath:(NSString *)plistPath {
    NSError *error;
    
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    BOOL success = [plistData writeToFile:plistPath atomically:YES];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", plistPath];
    }
}
+ (NSString *)readFileAtPath:(NSString *)path {
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"文件路径：%@", path];
        [[UtilityFile sharedInstance] showLogWithFormat:@"读取文件时出现错误：%@", [error localizedDescription]];
        return @"########读取文件错误########";
    } else {
        return content;
    }
}

// -------------------------------------------------------------------------------
//
// -------------------------------------------------------------------------------
+ (NSString *)convertResultArray:(NSArray *)contentArray {
    if (![contentArray count]) {
        return @"";
    }
    
    //转换成NSString
    NSString *tempStr1 = [[contentArray description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:&error];
    if (error) {
        DDLogInfo(@"将 NSArray 转换成 NSString 的时候出错: %@", error.localizedDescription);
        return nil;
    }
    
    //删除NSString中没有用的符号
    str = [str stringByReplacingOccurrencesOfString:@"(\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"    " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    return str;
}
+ (NSString *)convertResultDict:(NSDictionary *)contentDict {
    if (![contentDict count]) {
        return @"";
    }
    
    //转换成NSString
    NSString *tempStr1 = [[contentDict description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    
    //删除NSString中没有用的符号
    str = [str stringByReplacingOccurrencesOfString:@"    " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"{\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"(\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n}" withString:@""];
    
    return str;
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
+ (NSColor *)colorWithHexString:(NSString *)stringToConvert {
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6) {
        NSLog(@"16位颜色值出错，返回黑色");
        return [NSColor blackColor];
    }
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        NSLog(@"16位颜色值出错，返回黑色");
        return [NSColor blackColor];
    }
    
    unsigned int r, g, b;
    NSString *rString = [cString substringWithRange:NSMakeRange(0, 2)];
    NSString *gString = [cString substringWithRange:NSMakeRange(2, 2)];
    NSString *bString = [cString substringWithRange:NSMakeRange(4, 2)];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [NSColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:1.0f];
}

@end
