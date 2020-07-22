//
//  MRBGenerate32BitMD5NameManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/23.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBGenerate32BitMD5NameManager.h"
#import "MRBMD5Generator.h"

@implementation MRBGenerate32BitMD5NameManager

// 按照父文件夹给文件重命名
- (void)startGenerateFileNamesByFolderWithRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要生成名称的文件根目录"];
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
                [self _startGenerateFileNamesByFolderWithRootFolder:rootFolder];
            });
        }
    }];
}
- (void)_startGenerateFileNamesByFolderWithRootFolder:(NSString *)rootFolder {
    [[MRBLogManager defaultManager] showLogWithFormat:@"\n为图片等文件生成32位的随机名称, 流程开始, 选择的根目录: %@", rootFolder];
    
    NSArray *allNeededFilePaths = [[MRBFileManager defaultManager] getSubFilePathsInFolder:rootFolder];
    for (NSInteger i = 0; i < allNeededFilePaths.count; i++) {
        NSString *filePath = allNeededFilePaths[i];
        
        NSString *folderPath = filePath.stringByDeletingLastPathComponent;
        NSDate *folderCreationDate = [[MRBFileManager defaultManager] getSpecificAttributeOfItemAtPath:folderPath attribute:NSFileCreationDate];
        NSString *folderDesc = [NSString stringWithFormat:@"%@%@", folderPath.lastPathComponent, folderCreationDate];
        NSString *folderMD5Desc = [MRBMD5Generator md5EncryptMiddleWithString:folderDesc];
        
        NSDate *fileCreationDate = [[MRBFileManager defaultManager] getSpecificAttributeOfItemAtPath:filePath attribute:NSFileCreationDate];
        NSString *fileDesc = [NSString stringWithFormat:@"%@%@", filePath.lastPathComponent, fileCreationDate];
        NSString *fileMD5Desc = [MRBMD5Generator md5EncryptMiddleWithString:fileDesc];
        
        NSString *newFilePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.%@", folderMD5Desc, fileMD5Desc, filePath.pathExtension]];
        
        [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:newFilePath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"\n重命名前:\t\t%@/%@\n重命名后:\t\t%@/%@", filePath.stringByDeletingLastPathComponent.lastPathComponent, filePath.lastPathComponent, newFilePath.stringByDeletingLastPathComponent.lastPathComponent, newFilePath.lastPathComponent];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"\n为图片等文件生成32位的随机名称, 流程结束, 选择的根目录: %@", rootFolder];
}

// 按照单个文件重命名
- (void)startGenerateFileNamesByFileWithRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要生成名称的文件父目录"];
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
                [self _startGenerateFileNamesByFileWithRootFolder:rootFolder];
            });
        }
    }];
}
- (void)_startGenerateFileNamesByFileWithRootFolder:(NSString *)rootFolder {
    [[MRBLogManager defaultManager] showLogWithFormat:@"\n为图片等文件生成32位的随机名称, 流程开始, 选择的父目录: %@", rootFolder];
    [[MRBLogManager defaultManager] showLogWithFormat:@"注意：本操作不会递归所有子文件夹"];
    
    NSArray *allNeededFilePaths = [[MRBFileManager defaultManager] getFilePathsInFolder:rootFolder];
    for (NSInteger i = 0; i < allNeededFilePaths.count; i++) {
        NSString *filePath = allNeededFilePaths[i];
        NSString *folderPath = filePath.stringByDeletingLastPathComponent;
        
        NSDate *fileCreationDate = [[MRBFileManager defaultManager] getSpecificAttributeOfItemAtPath:filePath attribute:NSFileCreationDate];
        NSString *filePathDesc = [MRBMD5Generator md5EncryptMiddleWithString:filePath.lastPathComponent];
        NSString *fileCreationDateDesc = [MRBMD5Generator md5EncryptMiddleWithString:fileCreationDate.description];
        
        NSString *newFilePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.%@", filePathDesc, fileCreationDateDesc, filePath.pathExtension]];
        
        [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:newFilePath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"\n重命名前:\t\t%@/%@\n重命名后:\t\t%@/%@", filePath.stringByDeletingLastPathComponent.lastPathComponent, filePath.lastPathComponent, newFilePath.stringByDeletingLastPathComponent.lastPathComponent, newFilePath.lastPathComponent];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"\n为图片等文件生成32位的随机名称, 流程结束, 选择的根目录: %@", rootFolder];
}

@end
