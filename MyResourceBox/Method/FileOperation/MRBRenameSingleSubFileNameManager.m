//
//  MRBRenameSingleSubFileNameManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/09/06.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBRenameSingleSubFileNameManager.h"

@implementation MRBRenameSingleSubFileNameManager

- (void)start {
    [self chooseRootFolder];
}

- (void)chooseRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要重新命名的根文件夹【可多选】"];
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
                    
                    DDLogInfo(@"已选择需要重新命名的根文件夹：%@", folderPath);
                    [[MRBLogManager defaultManager] showLogWithFormat:@"已选择需要重新命名的根文件夹：%@", folderPath];
                    
                    [self startRenameWithRootFolderPath:folderPath];
                }
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
        
        // 满足条件：文件夹的子文件只有一个，没有文件夹
        if (subFolderPaths.count != 0) {
            continue;
        }
        if (subFilesPaths.count != 1) {
            continue;
        }
        
        // 重命名
        NSString *subFilePath = subFilesPaths.firstObject;
        NSString *newFileName = @"";
        // 如果文件夹的带文件格式，那么判断一下和文件的格式是否一样，一样的话就不用添加了
        if ([folderPath.lastPathComponent.pathExtension caseInsensitiveCompare:subFilePath.pathExtension] == NSOrderedSame) {
            newFileName = [NSString stringWithFormat:@"%@.%@", folderPath.lastPathComponent.stringByDeletingPathExtension, subFilePath.pathExtension];
        } else {
            newFileName = [NSString stringWithFormat:@"%@.%@", folderPath.lastPathComponent, subFilePath.pathExtension];
        }
        
        NSString *destFilePath = [subFilePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newFileName];
        [[MRBFileManager defaultManager] moveItemAtPath:subFilePath toDestPath:destFilePath];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"将: %@", subFilePath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"重命名为: %@", destFilePath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"完成重新命名 %@ 的文件夹", rootFolderPath];
}

@end
