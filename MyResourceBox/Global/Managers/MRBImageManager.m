//
//  MRBImageManager.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MRBImageManager.h"
//#import "MRBFileManager.h"

@implementation MRBImageManager

/**
 *  获取一张图片的真实尺寸(使用)
 *
 *  @param photoPath 图片路径
 *
 *  @return 返回图片的真是尺寸
 */
+ (NSSize)getActualImageSizeWithPhotoAtPath:(NSString *)photoPath {
    NSImageRep *imageRep = [NSImageRep imageRepWithContentsOfFile:photoPath];
    
    return NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh);
}

@end
