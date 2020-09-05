//
//  MRBRenameSingleSubFolderNameManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/09/05.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBRenameSingleSubFolderNameManager.h"

@implementation MRBRenameSingleSubFolderNameManager

- (void)start {
    [self chooseRootFolder];
}

- (void)chooseRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要重新命名的根文件夹"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *folderPath = panel.URLs.firstObject.absoluteString;
                folderPath = [folderPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
                folderPath = [folderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                folderPath = [folderPath stringByRemovingPercentEncoding];
                
                DDLogInfo(@"已选择需要重新命名的根文件夹：%@", folderPath);
                [[MRBLogManager defaultManager] showLogWithFormat:@"已选择需要重新命名的根文件夹：%@", folderPath];
                
                [self startRenameWithRootFolderPath:folderPath];
            });
        }
    }];
}

- (void)startRenameWithRootFolderPath:(NSString *)rootFolderPath {
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始重新命名 %@ 的文件夹", rootFolderPath];
    
    NSArray *folderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSArray *subFolderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:folderPath];
        NSArray *subFilesPaths = [[MRBFileManager defaultManager] getFilePathsInFolder:folderPath];
        
        // 满足条件：文件夹的子文件夹只有一个，没有文件
        if (subFolderPaths.count != 1) {
            continue;
        }
        if (subFilesPaths.count != 0) {
            continue;
        }
        
        // 重命名
        NSString *subFolderPath = subFolderPaths.firstObject;
        NSString *destFolderPath = [subFolderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:folderPath.lastPathComponent];
        [[MRBFileManager defaultManager] moveItemAtPath:subFolderPath toDestPath:destFolderPath];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"将: %@", subFolderPath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"重命名为: %@", destFolderPath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"完成重新命名 %@ 的文件夹", rootFolderPath];
}

@end
