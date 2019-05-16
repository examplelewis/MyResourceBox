//
//  MRBUtilityManager.h
//  SJYH
//
//  Created by 龚宇 on 15/1/20.
//  Copyright (c) 2015年 设易. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "AppDelegate.h"

@interface MRBUtilityManager : NSObject

#pragma mark - 写入读取文本文件
+ (void)exportString:(NSString *)string atPath:(NSString *)path;
+ (void)exportArray:(NSArray *)array atPath:(NSString *)path;
+ (void)exportArray:(NSArray *)array atPlistPath:(NSString *)plistPath;
+ (void)exportDictionary:(NSDictionary *)dictionary atPath:(NSString *)path;
+ (void)exportDictionary:(NSDictionary *)dictionary atPlistPath:(NSString *)plistPath;

#pragma mark - 辅助方法
+ (NSString *)readFileAtPath:(NSString *)path;
+ (NSColor *)colorWithHexString:(NSString *)stringToConvert;
+ (NSString *)convertResultArray:(NSArray *)contentArray;
+ (NSString *)convertResultDict:(NSDictionary *)contentDict;

@end
