//
//  MRBExtraceUnzipFolderManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/09/05.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBExtraceUnzipFolderManager.h"

@interface MRBExtraceUnzipFolderManager ()

@property (copy) NSString *rootFolderPath;

@end

@implementation MRBExtraceUnzipFolderManager

- (void)start {
    [self chooseRootFolder];
}

- (void)chooseRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要提取的根文件夹"];
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
                
                DDLogInfo(@"已选择需要分离的根文件夹：%@", folderPath);
                [[MRBLogManager defaultManager] showLogWithFormat:@"已选择需要分离的根文件夹：%@", folderPath];
                
                [self startExtractingWithRootFolderPath:folderPath];
            });
        }
    }];
}

- (void)startExtractingWithRootFolderPath:(NSString *)rootFolderPath {
    self.rootFolderPath = rootFolderPath;
    NSString *extractRootFolderPath = [rootFolderPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Extract", rootFolderPath.lastPathComponent]];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始提取 %@ 的文件夹", rootFolderPath];
    
    NSArray *folderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:rootFolderPath];
    for (NSInteger i = 0; i < folderPaths.count; i++) {
        NSString *folderPath = folderPaths[i];
        NSArray *subFolderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:folderPath];
        NSArray *subFilesPaths = [[MRBFileManager defaultManager] getFilePathsInFolder:folderPath];
        
        // 满足条件：文件夹的子文件夹只有一个，没有文件，且子文件夹的名称和文件夹的名称相同
        if (subFolderPaths.count != 1) {
            continue;
        }
        if (subFilesPaths.count != 0) {
            continue;
        }
        NSString *subFolderPath = subFolderPaths.firstObject;
        if (![subFolderPath.lastPathComponent isEqualToString:folderPath.lastPathComponent]) {
            continue;
        }
        
        // 先创建提取的根文件夹
        [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:extractRootFolderPath];
        
        // 移动
        NSString *destFolderPath = [extractRootFolderPath stringByAppendingPathComponent:folderPath.lastPathComponent];
        [[MRBFileManager defaultManager] moveItemAtPath:subFolderPath toDestPath:destFolderPath];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"提取: %@", subFolderPath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"至: %@", destFolderPath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"完成提取 %@ 的文件夹", rootFolderPath];
}

@end
