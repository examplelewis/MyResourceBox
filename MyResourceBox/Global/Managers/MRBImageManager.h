//
//  MRBImageManager.h
//  MyComicView
//
//  Created by 龚宇 on 16/08/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface MRBImageManager : NSObject

/**
 *  获取一张图片的真实尺寸(使用)
 *
 *  @param photoPath 图片路径
 *
 *  @return 返回图片的真是尺寸
 */
+ (NSSize)getActualImageSizeWithPhotoAtPath:(NSString *)photoPath;

@end
