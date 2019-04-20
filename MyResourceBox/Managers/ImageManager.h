//
//  ImageManager.h
//  MyComicView
//
//  Created by 龚宇 on 16/08/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface ImageManager : NSObject

/**
 *  单例模式方法
 *
 *  @return 返回一个初始化后的对象
 */
+ (ImageManager *)defaultManager;

/**
 *  获取一张图片的真实尺寸(使用)
 *
 *  @param photoPath 图片路径
 *
 *  @return 返回图片的真是尺寸
 */
- (NSSize)getActualImageSizeWithPhotoAtPath:(NSString *)photoPath;

@end