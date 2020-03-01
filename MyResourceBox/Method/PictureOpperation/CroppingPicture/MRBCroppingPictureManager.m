//
//  MRBCroppingPictureManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureManager.h"
#import "MRBCroppingPictureHeader.h"
#import "MRBCroppingPictureOperation.h"

@interface MRBCroppingPictureManager () {
    NSMutableArray *imageFilePaths;
    NSMutableArray *croppedImageFilePaths;
}

@property (strong) MRBCroppingPictureEdgeInsets *edgeInsets;
@property (assign) NSInteger selectedMode;
@property (copy) NSArray *selectedPaths;

@end

@implementation MRBCroppingPictureManager

+ (instancetype)managerWithEdgeInsets:(MRBCroppingPictureEdgeInsets *)insets mode:(NSInteger)mode paths:(NSArray *)paths {
    MRBCroppingPictureManager *manager = [MRBCroppingPictureManager new];
    manager.edgeInsets = insets;
    manager.selectedMode = mode;
    manager.selectedPaths = paths;
    
    return manager;
}

- (void)prepareCropping {
    switch (self.selectedMode) {
        case 1: {
            [self getAllPathsFromFilePaths];
        }
            break;
        case 2: {
            [self getAllPathsFromFolderPaths];
        }
            break;
        default: {
            
        }
            break;
    }
}

- (void)getAllPathsFromFilePaths {
    imageFilePaths = [NSMutableArray arrayWithArray:self.selectedPaths];
    croppedImageFilePaths = [NSMutableArray array];
    
    for (NSInteger i = 0; i < imageFilePaths.count; i++) {
        NSString *imageFilePath = imageFilePaths[i];
        NSString *imageFolderPath = imageFilePath.stringByDeletingLastPathComponent;
        NSString *croppedFolderPath = [imageFolderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Cropped", imageFolderPath.lastPathComponent]];
        NSString *croppedFilePath = [croppedFolderPath stringByAppendingPathComponent:imageFilePath.lastPathComponent];
        
        [croppedImageFilePaths addObject:croppedFilePath];
        
        [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:croppedFolderPath];
    }
    
    [self startCropping];
}
- (void)getAllPathsFromFolderPaths {
    imageFilePaths = [NSMutableArray array];
    croppedImageFilePaths = [NSMutableArray array];
    
    NSMutableArray *imageFolderPaths = [NSMutableArray array];
    NSMutableArray *croppedRootFolderPaths = [NSMutableArray array];
    NSMutableArray *croppedImageFolderPaths = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.selectedPaths.count; i++) {
        NSString *rootFolderPath = self.selectedPaths[i];
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
        MRBCroppingPictureOperation *operation = [MRBCroppingPictureOperation operationWithFrom:imageFilePaths[i] to:croppedImageFilePaths[i] insets:self.edgeInsets index:i + 1];
        [completionOperation addDependency:operation];
        [opQueue addOperation:operation];
    }
    
    [opQueue addOperation:completionOperation];
}
- (void)didFinishAllOperations {
    [[MRBLogManager defaultManager] showLogWithFormat:@"批量裁剪图片水印，流程结束"];
}

@end
