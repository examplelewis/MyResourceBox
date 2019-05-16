//
//  UtilityFile.m
//  SJYH
//
//  Created by 龚宇 on 15/1/20.
//  Copyright (c) 2015年 设易. All rights reserved.
//

#import "UtilityFile.h"

@implementation UtilityFile

#pragma mark - 写入读取文本文件
+ (void)exportString:(NSString *)string atPath:(NSString *)path {
    NSError *error;
    BOOL success = [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", path];
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
        [[MRBLogManager defaultManager] showLogWithFormat:@"导出结果文件出错：%@", [error localizedDescription]];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"结果文件导出成功，请查看：%@", path];
    }
}
+ (void)exportDictionary:(NSDictionary *)dictionary atPath:(NSString *)path {
    NSError *error;
    NSString *content = [UtilityFile convertResultDict:dictionary];
    
    BOOL success = [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", path];
    }
}
+ (void)exportArray:(NSArray *)array atPlistPath:(NSString *)plistPath {
    NSError *error;
    
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:array format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    BOOL success = [plistData writeToFile:plistPath atomically:YES];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", plistPath];
    }
}
+ (void)exportDictionary:(NSDictionary *)dictionary atPlistPath:(NSString *)plistPath {
    NSError *error;
    
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    BOOL success = [plistData writeToFile:plistPath atomically:YES];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"导出结果文件出错：%@\n", [error localizedDescription]];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"结果文件导出成功，请查看：%@\n", plistPath];
    }
}

#pragma mark - 辅助方法
+ (NSString *)readFileAtPath:(NSString *)path {
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"文件路径：%@", path];
        [[MRBLogManager defaultManager] showLogWithFormat:@"读取文件时出现错误：%@", [error localizedDescription]];
        return @"########读取文件错误########";
    } else {
        return content;
    }
}
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
