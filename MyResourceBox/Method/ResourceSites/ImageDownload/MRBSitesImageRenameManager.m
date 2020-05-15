//
//  MRBSitesImageRenameManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/05/15.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageRenameManager.h"

@implementation MRBSitesImageRenameManager

- (void)chooseDownloadedFiles {
    [[MRBLogManager defaultManager] showLogWithFormat:@"重命名上一阶段下载的图片，流程开始"];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择包含下载图片上层文件夹的目录"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择的根目录：%@", panel.URLs.firstObject);
                
                NSString *rootFolder = [panel.URLs.firstObject.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                rootFolder = [rootFolder stringByRemovingPercentEncoding];
                [self checkRootFolderIsValid:rootFolder];
            });
        }
    }];
}

- (void)checkRootFolderIsValid:(NSString *)rootFolder {
    if (![@[@"动漫", @"游戏", @"H", @"h"] containsObject:rootFolder.lastPathComponent]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"选择的父文件夹路径不规范，规范路径: xxxx/Gelbooru[Rule34|Rule 34]/动漫[游戏|H|h]"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"重命名上一阶段下载的图片，流程结束"];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", rootFolder.stringByDeletingLastPathComponent.lastPathComponent];
    NSArray *filtered = [@[@"gelbooru", @"rule34", @"rule 34"] filteredArrayUsingPredicate:predicate];
    if (filtered.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"选择的父文件夹路径不规范，规范路径: xxxx/Gelbooru[Rule34|Rule 34]/动漫[游戏|H|h]"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"重命名上一阶段下载的图片，流程结束"];
        return;
    }
    
    [self renameFilesInFolder:rootFolder];
}

- (void)renameFilesInFolder:(NSString *)rootFolder {
    NSArray *filePaths = [[MRBFileManager defaultManager] getSubFilePathsInFolder:rootFolder];
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        NSString *fileNameAndExt = filePath.lastPathComponent;
        NSString *folder = filePath.stringByDeletingLastPathComponent.lastPathComponent;
        NSString *newFilePath = [rootFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@", folder, fileNameAndExt]];
        
        [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:newFilePath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"重命名上一阶段下载的图片，流程结束"];
}

@end
