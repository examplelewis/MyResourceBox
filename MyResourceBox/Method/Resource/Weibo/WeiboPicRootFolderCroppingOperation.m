//
//  WeiboPicRootFolderCroppingOperation.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/02/27.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "WeiboPicRootFolderCroppingOperation.h"

@interface WeiboPicRootFolderCroppingOperation ()

@property (copy) NSString *fromPath;
@property (copy) NSString *toPath;
@property (assign) float heightRatio;
@property (assign) NSInteger currentIndex;

@end

@implementation WeiboPicRootFolderCroppingOperation

+ (instancetype)operationWithFrom:(NSString *)from to:(NSString *)to ratio:(float)ratio index:(NSInteger)index {
    WeiboPicRootFolderCroppingOperation *operation = [WeiboPicRootFolderCroppingOperation new];
    operation.fromPath = from;
    operation.toPath = to;
    operation.heightRatio = ratio;
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
        
        // 计算裁剪后的高度和 Rect
        CGFloat waterprintHeight = ceil(CGImageGetWidth(imageRef) * _heightRatio);
        CGFloat croppedHeight = CGImageGetHeight(imageRef) - waterprintHeight;
        CGRect croppedRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(imageRef), croppedHeight);
        [[MRBLogManager defaultManager] showLogWithFormat:@"图片: %@\nsize: %ld x %ld, ratio: %.3f, waterprint height: %f, croppedHeight: %f", _fromPath, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), _heightRatio, waterprintHeight, croppedHeight];
        
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

@end
