//
//  MRBSearchHiddenFileManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/09/09.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSearchHiddenFileManager.h"

@implementation MRBSearchHiddenFileManager

- (void)start {
    [self chooseRootFolder];
}

- (void)chooseRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要查找隐藏文件的根文件夹"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSInteger i = 0; i < panel.URLs.count; i++) {
                    NSString *folderPath = panel.URLs[i].absoluteString;
                    folderPath = [folderPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
                    folderPath = [folderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    folderPath = [folderPath stringByRemovingPercentEncoding];
                    
                    [[MRBLogManager defaultManager] showLogWithFormat:@"已选择需要查找隐藏文件的根文件夹：%@", folderPath];
                    
                    [self startSearchHiddenFileWithRootFolderPath:folderPath];
                }
            });
        }
    }];
}

- (void)startSearchHiddenFileWithRootFolderPath:(NSString *)folderPath {
    NSMutableArray<NSURL *> *trashURLs = [NSMutableArray array];
    
    NSArray<NSString *> *subFilePaths = [[MRBFileManager defaultManager] getSubFilePathsInFolder:folderPath];
    for (NSInteger i = 0; i < subFilePaths.count; i++) {
        NSString *subFilePath = subFilePaths[i];
        if ([subFilePath.lastPathComponent hasPrefix:@"."]) {
            [trashURLs addObject:[NSURL fileURLWithPath:subFilePath]];
        }
    }
    
    NSArray<NSString *> *subFolderPaths = [[MRBFileManager defaultManager] getSubFoldersPathInFolder:folderPath];
    for (NSInteger i = 0; i < subFolderPaths.count; i++) {
        NSString *subFolderPath = subFolderPaths[i];
        if ([subFolderPath.lastPathComponent hasPrefix:@"."]) {
            [trashURLs addObject:[NSURL fileURLWithPath:subFolderPath]];
        }
    }
    
    if (trashURLs.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未找到隐藏文件"];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"已找到 %ld 个隐藏文件, 即将移动至废纸篓", trashURLs.count];
        [[MRBFileManager defaultManager] trashFilesAtPaths:trashURLs];
    }
}

@end
