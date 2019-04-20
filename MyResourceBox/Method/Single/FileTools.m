//
//  FileTools.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/10/17.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "FileTools.h"

@implementation FileTools

- (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1:
            [self organizingExportPhotos];
            break;
        case 2: {
            NSOpenPanel *panel = [NSOpenPanel openPanel];
            [panel setMessage:@"请选择需要复制层级的文件夹"];
            panel.prompt = @"确定";
            panel.canChooseDirectories = YES;
            panel.canCreateDirectories = NO;
            panel.canChooseFiles = NO;
            panel.allowsMultipleSelection = NO;
            
            [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
                if (result == NSFileHandlingPanelOKButton) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogInfo(@"已选择需要复制层级的文件夹：%@", panel.URLs);
                        
                        [self copyFolderClass:panel.URL.absoluteString];
                    });
                }
            }];
        }
            
            break;
        default:
            break;
    }
}

- (void)organizingExportPhotos {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的图片：流程准备开始"];
    
    // Cosplay 文件夹
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的Cosplay图片：流程准备开始"];
    NSString *cosplayFolder = @"/Users/Mercury/Downloads/Cosplay";
    if ([[FileManager defaultManager] isContentExistAtPath:cosplayFolder]) {
        NSArray *originalFilePaths = [[FileManager defaultManager] getFilePathsInFolder:cosplayFolder];
        
        for (NSInteger i = 0; i < originalFilePaths.count; i++) {
            NSString *originalFilePath = originalFilePaths[i];
            NSString *destFilePath = [originalFilePath stringByReplacingOccurrencesOfString:cosplayFolder withString:@"/User/Mercury/CloudStation/网络图片/Cosplay"];
            
            [[FileManager defaultManager] moveItemAtPath:originalFilePath toDestPath:destFilePath];
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的Cosplay图片：流程已经结束"];
    
    // 真人 文件夹
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的真人图片：流程准备开始"];
    NSString *zhenrenFolder = @"/Users/Mercury/Downloads/真人";
    if ([[FileManager defaultManager] isContentExistAtPath:zhenrenFolder]) {
        NSArray *originalFilePaths = [[FileManager defaultManager] getFilePathsInFolder:zhenrenFolder];
        
        for (NSInteger i = 0; i < originalFilePaths.count; i++) {
            NSString *originalFilePath = originalFilePaths[i];
            NSString *destFilePath = [originalFilePath stringByReplacingOccurrencesOfString:zhenrenFolder withString:@"/User/Mercury/CloudStation/网络图片/真人"];
            
            [[FileManager defaultManager] moveItemAtPath:originalFilePath toDestPath:destFilePath];
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的真人图片：流程已经结束"];
    
    // ACG 文件夹
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的ACG图片：流程准备开始"];
    NSString *acgFolder = @"/Users/Mercury/CloudStation/网络图片/ACG";
    NSArray *acgFolders = [[FileManager defaultManager] getFolderPathsInFolder:acgFolder];
    for (NSInteger i = 0; i < acgFolders.count; i++) {
        NSString *destACGFolder = acgFolders[i];
        NSString *originACGFolder = [destACGFolder stringByReplacingOccurrencesOfString:acgFolder withString:@"/Users/Mercury/Downloads"];
        
        if ([[FileManager defaultManager] isContentExistAtPath:originACGFolder]) {
            NSArray *originalFilePaths = [[FileManager defaultManager] getFilePathsInFolder:originACGFolder];
            
            for (NSInteger j = 0; j < originalFilePaths.count; j++) {
                NSString *originalFilePath = originalFilePaths[j];
                NSString *destFilePath = [originalFilePath stringByReplacingOccurrencesOfString:originACGFolder withString:destACGFolder];
                
                [[FileManager defaultManager] moveItemAtPath:originalFilePath toDestPath:destFilePath];
            }
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的ACG图片：流程已经结束"];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的图片：流程已经结束"];
}
- (void)copyFolderClass:(NSString *)rootFolderPath {
    if ([rootFolderPath hasPrefix:@"file://"]) {
        rootFolderPath = [rootFolderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    rootFolderPath = [rootFolderPath stringByRemovingPercentEncoding];
    [[UtilityFile sharedInstance] showLogWithFormat:@"复制文件夹的层级, 流程开始"];
    
    NSString *targetFolderPath = rootFolderPath;
    if ([targetFolderPath hasSuffix:@"/"]) {
        targetFolderPath = [targetFolderPath substringToIndex:targetFolderPath.length - 1];
    }
    targetFolderPath = [targetFolderPath stringByAppendingString:@" 复制/"];
    [[FileManager defaultManager] createFolderAtPathIfNotExist:targetFolderPath];
    
    NSArray *subFolders = [[FileManager defaultManager] getSubFoldersPathInFolder:rootFolderPath];
    for (NSInteger i = 0; i < subFolders.count; i++) {
        NSString *subFolder = subFolders[i];
        NSString *targetSubFolder = [subFolder stringByReplacingOccurrencesOfString:rootFolderPath withString:targetFolderPath];
        
        [[FileManager defaultManager] createFolderAtPathIfNotExist:targetSubFolder];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"复制文件夹的层级, 流程结束"];
}

@end
