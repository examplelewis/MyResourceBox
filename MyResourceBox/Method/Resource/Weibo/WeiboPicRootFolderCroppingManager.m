//
//  WeiboPicRootFolderCroppingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/02/27.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "WeiboPicRootFolderCroppingManager.h"
#import "WeiboPicRootFolderCroppingOperation.h"
#import <BlocksKit.h>

@interface WeiboPicRootFolderCroppingManager () {
    CGFloat heightRatio; // 真实裁剪高度的比例
    NSArray *rootFolderPaths;
    NSMutableArray *imageFilePaths;
    NSMutableArray *imageFolderPaths;
    
    NSMutableArray *croppedRootFolderPaths;
    NSMutableArray *croppedImageFolderPaths;
    NSMutableArray *croppedImageFilePaths;
}

@end

@implementation WeiboPicRootFolderCroppingManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _croppingRatio = WeiboPicRootFolderCroppingRatioNotSet;
    }
    
    return self;
}

- (void)prepareCropping {
    if (_croppingRatio == WeiboPicRootFolderCroppingRatioNotSet) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未设置裁剪的高度比"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"批量裁剪微博图片的水印，流程结束"];
        return;
    }
    
    switch (_croppingRatio) {
        case WeiboPicRootFolderCroppingRatio42: {
            heightRatio = 0.042f;
        }
            break;
        case WeiboPicRootFolderCroppingRatio45: {
            heightRatio = 0.045f;
        }
            break;
        case WeiboPicRootFolderCroppingRatio47: {
            heightRatio = 0.047f;
        }
            break;
        case WeiboPicRootFolderCroppingRatio48: {
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
    [panel setMessage:@"请选择根文件夹"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = YES;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择根文件夹的地址: %@", panel.URLs);
                self->rootFolderPaths = [[MRBFileManager defaultManager] convertFileURLsArrayToFilePathsArray:panel.URLs];
                
                [self findAllImagePaths];
            });
        }
    }];
}
- (void)findAllImagePaths {
    imageFilePaths = [NSMutableArray array];
    imageFolderPaths = [NSMutableArray array];
    croppedRootFolderPaths = [NSMutableArray array];
    croppedImageFolderPaths = [NSMutableArray array];
    croppedImageFilePaths = [NSMutableArray array];
    
    for (NSInteger i = 0; i < rootFolderPaths.count; i++) {
        NSString *rootFolderPath = rootFolderPaths[i];
        NSString *croppedRootFolderPath = [rootFolderPath stringByAppendingString:@" Cropped"];
        
        NSArray *filePaths = [[MRBFileManager defaultManager] getSubFilePathsInFolder:rootFolderPath];
        NSArray *folderPaths = [[MRBFileManager defaultManager] getSubFoldersPathInFolder:rootFolderPath];
        
        [imageFilePaths addObjectsFromArray:filePaths];
        [imageFolderPaths addObjectsFromArray:folderPaths];
        
        NSArray *croppedFilePaths = [filePaths bk_map:^id(id obj) {
            return [obj stringByReplacingOccurrencesOfString:rootFolderPath withString:croppedRootFolderPath];
        }];
        NSArray *croppedFolderPaths = [folderPaths bk_map:^id(id obj) {
            return [obj stringByReplacingOccurrencesOfString:rootFolderPath withString:croppedRootFolderPath];
        }];
        
        [croppedRootFolderPaths addObject:croppedRootFolderPath];
        [croppedImageFilePaths addObjectsFromArray:croppedFilePaths];
        [croppedImageFolderPaths addObjectsFromArray:croppedFolderPaths];
        
        [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:croppedRootFolderPath];
        [croppedFolderPaths bk_each:^(id obj) {
            [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:obj];
        }];
    }
    
    [self startCropping];
}
- (void)startCropping {
    [[MRBLogManager defaultManager] showLogWithFormat:@"一共需要裁剪 %ld 张图片", imageFilePaths.count];
    
    NSOperationQueue *opQueue = [NSOperationQueue new];
    opQueue.maxConcurrentOperationCount = 1; // 队列中同时能并发执行的最大操作数 = 1时，队列为串行队列，只能串行执行。
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 回到主线程执行，方便更新 UI 等
            [self performSelector:@selector(didFinishAllOperations) withObject:nil afterDelay:0.1f];
        }];
    }];
    
    for (NSInteger i = 0; i < imageFilePaths.count; i++) {
        WeiboPicRootFolderCroppingOperation *operation = [WeiboPicRootFolderCroppingOperation operationWithFrom:imageFilePaths[i] to:croppedImageFilePaths[i] ratio:heightRatio index:i + 1];
        [completionOperation addDependency:operation];
        [opQueue addOperation:operation];
    }
    
    [opQueue addOperation:completionOperation];
}
- (void)didFinishAllOperations {
    [[MRBLogManager defaultManager] showLogWithFormat:@"批量裁剪微博图片的水印【从底部裁宽度的%.1f%%】，流程结束", heightRatio * 100.0f];
}

@end
