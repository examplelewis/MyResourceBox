//
//  MRBCroppingPictureOperation.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureOperation.h"

@interface MRBCroppingPictureOperation ()

@property (copy) NSString *fromPath;
@property (copy) NSString *toPath;
@property (strong) MRBCroppingPictureEdgeInsets *edgeInsets;
@property (assign) NSInteger currentIndex;

@end

@implementation MRBCroppingPictureOperation

+ (instancetype)operationWithFrom:(NSString *)from to:(NSString *)to insets:(MRBCroppingPictureEdgeInsets *)insets index:(NSInteger)index {
    MRBCroppingPictureOperation *operation = [MRBCroppingPictureOperation new];
    operation.fromPath = from;
    operation.toPath = to;
    operation.edgeInsets = insets;
    operation.currentIndex = index;
    
    return operation;
}

- (void)main {
    if (!self.isCancelled) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"开始裁剪第 %ld 张图片", _currentIndex];
        
        CFStringRef imageType = NULL;
        if ([_fromPath.pathExtension caseInsensitiveCompare:@"jpeg"] == NSOrderedSame || [_fromPath.pathExtension caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
            imageType = kUTTypeJPEG;
        } else if ([_fromPath.pathExtension caseInsensitiveCompare:@"png"] == NSOrderedSame) {
            imageType = kUTTypePNG;
        }
        if (imageType == NULL) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"需要裁剪的图片: %@ 类型未知，跳过", _fromPath];
            return;
        }
        
        // 获取当前图片
        CGImageRef imageRef = NULL;
        CFURLRef imageUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:_fromPath];
        CGImageSourceRef loadRef = CGImageSourceCreateWithURL(imageUrl, NULL);
        if (loadRef != NULL) {
            imageRef = CGImageSourceCreateImageAtIndex(loadRef, 0, NULL);
            CFRelease(loadRef); // Release CGImageSource reference
        }
        
        // 尺寸
        CGSize originalSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        CGRect croppedRect = [self croppedRectFromOriginalSize:originalSize];
        if (CGRectEqualToRect(croppedRect, CGRectZero)) {
            return;
        }
        [[MRBLogManager defaultManager] showLogWithFormat:@"图片：%@\n设置参数：%@\n图片尺寸：%@\n计算后的尺寸：%@", self.fromPath, self.edgeInsets, NSStringFromSize(originalSize), NSStringFromRect(croppedRect)];
        
        // 进行裁剪
        CGImageRef croppedImage = CGImageCreateWithImageInRect(imageRef, croppedRect);
        CFURLRef saveUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:_toPath];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(saveUrl, imageType, 1, NULL);
        CGImageDestinationAddImage(destination, croppedImage, nil);
        if (!CGImageDestinationFinalize(destination)) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"图片: %@ 裁剪出错，跳过", _fromPath];
        }
        
        // 手动 Release
        // CFURLRef imageUrl 和 [NSURL fileURLWithPath:] 创建的对象本质上指向的是同一块内存地址，当 NSURL 对象消失后，imageUrl 自然变为 NULL，而 CFRelease 一个 NULL 的对象就会报 野指针(EXC_BAD_ACCESS) 错误
        CFRelease(imageRef);
        CFRelease(croppedImage);
        CFRelease(destination);
    }
}

// 计算裁剪后的 Rect
- (CGRect)croppedRectFromOriginalSize:(CGSize)size {
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    // 计算
    if (self.edgeInsets.top.enabled) {
        if (self.edgeInsets.top.unit == 1) {
            y = ceil(size.height * self.edgeInsets.top.value / 100.0f);
        } else {
            y = ceil(self.edgeInsets.top.value);
        }
    }
    
    if (self.edgeInsets.left.enabled) {
        if (self.edgeInsets.left.unit == 1) {
            x = ceil(size.width * self.edgeInsets.left.value / 100.0f);
        } else {
            x = ceil(self.edgeInsets.left.value);
        }
    }
    
    if (self.edgeInsets.bottom.enabled) {
        CGFloat paddingBottom = 0;
        if (self.edgeInsets.bottom.unit == 1) {
            paddingBottom = ceil(size.height * self.edgeInsets.bottom.value / 100.0f);
        } else {
            paddingBottom = ceil(self.edgeInsets.bottom.value);
        }
        
        height = size.height - y - paddingBottom;
    } else {
        height = size.height - y;
    }
    
    if (self.edgeInsets.right.enabled) {
        CGFloat paddingRight = 0;
        if (self.edgeInsets.right.unit == 1) {
            paddingRight = ceil(size.width * self.edgeInsets.right.value / 100.0f);
        } else {
            paddingRight = ceil(self.edgeInsets.right.value);
        }
        
        width = size.width - x - paddingRight;
    } else {
        width = size.width - x;
    }
    
    // 合成 CGRect 结构体
    CGRect rect = CGRectMake(x, y, width, height);
    
    // 判断
    BOOL hIllegal = x < 0 || x >= size.width || width <= 0 || width > size.width || (x + width) <= 0 || (x + width) > size.width;
    BOOL vIlleaal = y < 0 || y >= size.height || height <= 0 || height > size.height || (y + height) <= 0 || (y + height) > size.height;
    if (hIllegal || vIlleaal) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"第 %ld 张图片裁减尺寸出错\n图片：%@\n设置参数：%@\n图片尺寸：%@\n计算后的尺寸：%@", _currentIndex, self.fromPath, self.edgeInsets, NSStringFromSize(size), NSStringFromRect(rect)];
        
        return CGRectZero;
    }
    
    return rect;
}

@end
