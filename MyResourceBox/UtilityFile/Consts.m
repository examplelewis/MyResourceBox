//
//  Consts.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/28.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "Consts.h"

@implementation Consts

+ (NSArray *)simplePhotoType {
    return @[@"jpg", @"jpeg", @"gif", @"png"];
}
+ (NSArray *)allPhotoType {
    return @[@"jpg", @"jpeg", @"gif", @"png", @"raw", @"bmp", @"tiff"];
}
+ (NSArray *)allVideoType {
    return @[@"mkv", @"mp4", @"avi", @"mpg", @"webm", @"ogv", @"m4v", @"rmvb"];
}

@end
