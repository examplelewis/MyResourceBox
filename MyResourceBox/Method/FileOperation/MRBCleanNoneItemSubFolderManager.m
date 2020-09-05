//
//  MRBCleanNoneItemSubFolderManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/09/05.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCleanNoneItemSubFolderManager.h"

@interface MRBCleanNoneItemSubFolderManager ()

@property (copy) NSString *rootFolderPath;

@end

@implementation MRBCleanNoneItemSubFolderManager

- (void)start {
    [self chooseRootFolder];
}

- (void)chooseRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要清空没有项目的根文件夹"];
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
                
                DDLogInfo(@"已选择需要清空没有项目的根文件夹：%@", folderPath);
                [[MRBLogManager defaultManager] showLogWithFormat:@"已选择需要清空没有项目的根文件夹：%@", folderPath];
                
                [self startClearNoneItemFolderWithRootFolderPath:folderPath];
            });
        }
    }];
}

- (void)startClearNoneItemFolderWithRootFolderPath:(NSString *)rootFolderPath {
    self.rootFolderPath = rootFolderPath;
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始清空没有项目 %@ 的文件夹", rootFolderPath];
    
    NSArray *folderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSArray *subFolderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:folderPath];
        NSArray *subFilesPaths = [[MRBFileManager defaultManager] getFilePathsInFolder:folderPath];
        
        // 满足条件：文件夹的没有子文件夹，没有文件
        if (subFolderPaths.count != 0) {
            continue;
        }
        if (subFilesPaths.count != 0) {
            continue;
        }
        
        // 删除文件夹
        [[MRBFileManager defaultManager] trashFilesAtPaths:@[[NSURL fileURLWithPath:folderPath]]];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"移动到废纸篓: %@", folderPath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"完成清空没有项目 %@ 的文件夹", rootFolderPath];
}
// 清空没有项目的子文件夹

@end
