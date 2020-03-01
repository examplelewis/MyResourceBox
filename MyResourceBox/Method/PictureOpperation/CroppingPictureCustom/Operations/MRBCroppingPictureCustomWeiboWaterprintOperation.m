//
//  MRBCroppingPictureCustomWeiboWaterprintOperation.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/02.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureCustomWeiboWaterprintOperation.h"

@interface MRBCroppingPictureCustomWeiboWaterprintOperation ()

@property (copy) NSString *fromPath;
@property (copy) NSString *toPath;
@property (assign) CGFloat percent;
@property (assign) NSInteger currentIndex;

@end

@implementation MRBCroppingPictureCustomWeiboWaterprintOperation

+ (instancetype)operationWithFrom:(NSString *)from to:(NSString *)to percent:(CGFloat)percent index:(NSInteger)index {
    MRBCroppingPictureCustomWeiboWaterprintOperation *operation = [MRBCroppingPictureCustomWeiboWaterprintOperation new];
    operation.fromPath = from;
    operation.toPath = to;
    operation.percent = percent;
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
        CGRect croppedRect = CGRectMake(0, 0, CGImageGetWidth(imageRef), ceilf(CGImageGetHeight(imageRef) - CGImageGetWidth(imageRef) * self.percent / 100.0f));
        [[MRBLogManager defaultManager] showLogWithFormat:@"图片：%@\n图片尺寸：%@\n裁剪后的尺寸：%@", self.fromPath, NSStringFromSize(originalSize), NSStringFromRect(croppedRect)];
        
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
