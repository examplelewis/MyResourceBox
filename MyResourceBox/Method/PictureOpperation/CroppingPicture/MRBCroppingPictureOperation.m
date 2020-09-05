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

@property (strong) NSImage *originalImage;

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
        
        NSInteger width = 0;
        NSInteger height = 0;
        NSArray *imageReps = [NSBitmapImageRep imageRepsWithContentsOfFile:self.fromPath];
        for (NSImageRep *imageRep in imageReps) {
            if ([imageRep pixelsWide] > width) {
                width = [imageRep pixelsWide];
            }
            if ([imageRep pixelsHigh] > height) {
                height = [imageRep pixelsHigh];
            }
        }
        self.originalImage = [[NSImage alloc] initWithSize:NSMakeSize((CGFloat)width, (CGFloat)height)];
        [self.originalImage addRepresentations:imageReps];
        
        // Cropping
        NSRect croppedRect = [self croppedRect];
        [[MRBLogManager defaultManager] showLogWithFormat:@"图片：%@\n设置参数：%@\n图片尺寸：%@\n计算后的尺寸：%@", self.fromPath, self.edgeInsets, NSStringFromSize(self.originalImage.size), NSStringFromRect(croppedRect)];
        NSImage *croppedImage = [[NSImage alloc] initWithSize:NSMakeSize(croppedRect.size.width, croppedRect.size.height)];
        [croppedImage lockFocus];
        [self.originalImage drawInRect:CGRectMake(0, 0, croppedRect.size.width, croppedRect.size.height) fromRect:croppedRect operation:NSCompositingOperationCopy fraction:1.0f];
        [croppedImage unlockFocus];
        
        // Export
        NSBitmapImageRep *croppedBitmapImageRep = [[NSBitmapImageRep alloc] initWithData:croppedImage.TIFFRepresentation];
        if ([self.fromPath.pathExtension caseInsensitiveCompare:@"png"] == NSOrderedSame) {
            NSData *croppedImageData = [croppedBitmapImageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
            [croppedImageData writeToFile:self.toPath atomically:YES];
        } else if ([self.fromPath.pathExtension caseInsensitiveCompare:@"tiff"] == NSOrderedSame) {
            NSData *croppedImageData = [croppedBitmapImageRep representationUsingType:NSBitmapImageFileTypeTIFF properties:@{NSImageCompressionFactor: @(1.0)}];
            [croppedImageData writeToFile:self.toPath atomically:YES];
        } else {
            NSData *croppedImageData = [croppedBitmapImageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:@{NSImageCompressionFactor: @(1.0)}];
            [croppedImageData writeToFile:self.toPath atomically:YES];
        }
    }
}

// 计算裁剪后的 Rect
- (CGRect)croppedRect {
    NSSize size = self.originalImage.size;
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    // 计算
    // NSImage 左下角为 {0, 0}
    if (self.edgeInsets.bottom.enabled) {
        if (self.edgeInsets.bottom.unit == 1) {
            y = ceil(size.height * self.edgeInsets.bottom.value / 100.0f);
        } else {
            y = ceil(self.edgeInsets.bottom.value);
        }
    }
    
    if (self.edgeInsets.left.enabled) {
        if (self.edgeInsets.left.unit == 1) {
            x = ceil(size.width * self.edgeInsets.left.value / 100.0f);
        } else {
            x = ceil(self.edgeInsets.left.value);
        }
    }
    
    if (self.edgeInsets.top.enabled) {
        CGFloat paddingTop = 0;
        if (self.edgeInsets.top.unit == 1) {
            paddingTop = ceil(size.height * self.edgeInsets.top.value / 100.0f);
        } else {
            paddingTop = ceil(self.edgeInsets.top.value);
        }
        
        height = size.height - y - paddingTop;
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
