//
//  MRBAddSubFolderNameWithFolderNameManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/09/05.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBAddSubFolderNameWithFolderNameManager.h"

@implementation MRBAddSubFolderNameWithFolderNameManager

- (void)start {
    [self chooseRootFolder];
}

- (void)chooseRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要将所有子文件夹前加上父文件夹名称的根文件夹【可多选】"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = YES;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSInteger i = 0; i < panel.URLs.count; i++) {
                    NSString *folderPath = panel.URLs[i].absoluteString;
                    folderPath = [folderPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
                    folderPath = [folderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    folderPath = [folderPath stringByRemovingPercentEncoding];
                    
                    DDLogInfo(@"已选择需要将所有子文件夹前加上父文件夹名称的根文件夹：%@", folderPath);
                    [[MRBLogManager defaultManager] showLogWithFormat:@"已选择需要将所有子文件夹前加上父文件夹名称的根文件夹：%@", folderPath];
                    
                    [self startAddSubFolderNameWithFolderNameWithRootFolderPath:folderPath];
                }
            });
        }
    }];
}

- (void)startAddSubFolderNameWithFolderNameWithRootFolderPath:(NSString *)rootFolderPath {
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始将所有子文件夹前加上父文件夹名称 %@ 的文件夹", rootFolderPath];
    
    NSArray *folderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:rootFolderPath];
    NSArray *filePaths = [[MRBFileManager defaultManager] getFilePathsInFolder:rootFolderPath];
    
    // 满足条件：文件夹的只有子文件夹，没有文件
    if (folderPaths.count == 0) {
        return;
    }
    if (filePaths.count != 0) {
        return;
    }
    
    // 重命名
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSString *newFolderName = [NSString stringWithFormat:@"%@ %@", rootFolderPath.lastPathComponent, folderPath.lastPathComponent];
        NSString *destFolderPath = [folderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newFolderName];
        [[MRBFileManager defaultManager] moveItemAtPath:folderPath toDestPath:destFolderPath];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"将: %@", folderPath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"重命名为: %@", destFolderPath];
    }
    
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"完成将所有子文件夹前加上父文件夹名称 %@ 的文件夹", rootFolderPath];
}

@end
