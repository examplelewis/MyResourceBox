//
//  ImageManager.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ImageManager.h"
//#import "FileManager.h"

@interface ImageManager () {
    
}

@end

@implementation ImageManager

#pragma mark -- 生命周期方法 --
/**
 *  单例模式方法
 */
static ImageManager *inputInstance;
+ (ImageManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inputInstance = [[ImageManager alloc] init];
    });
    
    return inputInstance;
}

#pragma mark -- 逻辑方法 --
/**
 *  获取一张图片的真实尺寸(使用)
 *
 *  @param photoPath 图片路径
 *
 *  @return 返回图片的真是尺寸
 */
- (NSSize)getActualImageSizeWithPhotoAtPath:(NSString *)photoPath {
    NSImageRep *imageRep = [NSImageRep imageRepWithContentsOfFile:photoPath];
    
    return NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh);
}

@end
