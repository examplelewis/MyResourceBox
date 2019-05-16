//
//  WeiboPicCroppingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/14.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "WeiboPicCroppingManager.h"

@interface WeiboPicCroppingManager () {
    CGFloat heightRatio; // 真实裁剪高度的比例
    NSArray *imageFilePaths;
}

@end

@implementation WeiboPicCroppingManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _croppingRatio = WeiboPicCroppingRatioNotSet;
    }
    
    return self;
}

- (void)prepareCropping {
    if (_croppingRatio == WeiboPicCroppingRatioNotSet) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未设置裁剪的高度比"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"批量裁剪微博图片的水印，流程结束"];
        return;
    }
    
    switch (_croppingRatio) {
        case WeiboPicCroppingRatio42: {
            heightRatio = 0.042f;
        }
            break;
        case WeiboPicCroppingRatio45: {
            heightRatio = 0.045f;
        }
            break;
        case WeiboPicCroppingRatio47: {
            heightRatio = 0.047f;
        }
            break;
        case WeiboPicCroppingRatio48: {
            heightRatio = 0.048f;
        }
            break;
        default:
            break;
    }
    
    [self choosingPictrues];
}
- (void)choosingPictrues {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要裁剪的图片"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = NO;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = YES;
    panel.allowedFileTypes = @[@"jpg", @"jpeg", @"png"];
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择需要裁剪的图片: %@", panel.URLs);
                self->imageFilePaths = [[MRBFileManager defaultManager] convertFileURLsArrayToFilePathsArray:panel.URLs];
                
                [self startCropping];
            });
        }
    }];
}
- (void)startCropping {
    [[MRBLogManager defaultManager] showLogWithFormat:@"一共需要裁剪 %ld 张图片", imageFilePaths.count];
    
    for (NSInteger i = 0; i < imageFilePaths.count; i++) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"开始裁剪第 %ld 张图片", i+ 1];
        [self croppingSinglePicture:imageFilePaths[i]];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"批量裁剪微博图片的水印【从底部裁宽度的%.1f%%】，流程结束", heightRatio * 100.0f];
}
- (void)croppingSinglePicture:(NSString *)imageFilePath {
    CFStringRef imageType = NULL;
    if ([imageFilePath.pathExtension isEqualToString:@"jpeg"] || [imageFilePath.pathExtension isEqualToString:@"jpg"]) {
        imageType = kUTTypeJPEG;
    } else if ([imageFilePath.pathExtension isEqualToString:@"png"]) {
        imageType = kUTTypePNG;
    }
    if (imageType == NULL) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"需要裁剪的图片: %@ 类型未知，跳过", imageFilePath];
        return;
    }
    
    // 目标文件以及文件夹的地址
    NSString *imageFolderPath = imageFilePath.stringByDeletingLastPathComponent;
    NSString *imageFolderName = imageFolderPath.lastPathComponent;
    NSString *targetFolderPath = [imageFolderPath stringByReplacingOccurrencesOfString:imageFolderName withString:[NSString stringWithFormat:@"%@ Cropped", imageFolderName]];
    NSString *targetFilePath = [targetFolderPath stringByAppendingPathComponent:imageFilePath.lastPathComponent];
    [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:targetFolderPath];
    
    // 获取当前图片
    CGImageRef imageRef = NULL;
    CFURLRef imageUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:imageFilePath];
    CGImageSourceRef loadRef = CGImageSourceCreateWithURL(imageUrl, NULL);
    if (loadRef != NULL) {
        imageRef = CGImageSourceCreateImageAtIndex(loadRef, 0, NULL);
        CFRelease(loadRef); // Release CGImageSource reference
    }
    
    // 计算裁剪后的高度和 Rect
    CGFloat waterprintHeight = ceil(CGImageGetWidth(imageRef) * heightRatio);
    CGFloat croppedHeight = CGImageGetHeight(imageRef) - waterprintHeight;
    CGRect croppedRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(imageRef), croppedHeight);
    [[MRBLogManager defaultManager] showLogWithFormat:@"图片: %@\nsize: %ld x %ld, ratio: %.3f, waterprint height: %f, croppedHeight: %f", imageFilePath, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), heightRatio, waterprintHeight, croppedHeight];
    
    // 进行裁剪
    CGImageRef croppedImage = CGImageCreateWithImageInRect(imageRef, croppedRect);
    CFURLRef saveUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:targetFilePath];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(saveUrl, imageType, 1, NULL);
    CGImageDestinationAddImage(destination, croppedImage, nil);
    if (!CGImageDestinationFinalize(destination)) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"图片: %@ 裁剪出错，跳过", imageFilePath];
    }
    
    // 手动 Release
    // CFURLRef imageUrl 和 [NSURL fileURLWithPath:] 创建的对象本质上指向的是同一块内存地址，当 NSURL 对象消失后，imageUrl 自然变为 NULL，而 CFRelease 一个 NULL 的对象就会报 野指针(EXC_BAD_ACCESS) 错误
    CFRelease(imageRef);
    CFRelease(croppedImage);
    CFRelease(destination);
}

@end
