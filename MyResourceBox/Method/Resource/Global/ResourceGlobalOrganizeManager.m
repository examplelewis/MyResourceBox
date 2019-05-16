//
//  ResourceGlobalOrganizeManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/13.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ResourceGlobalOrganizeManager.h"

@interface ResourceGlobalOrganizeManager () {
    NSString *plistFilePath;
    NSString *rootFolderPath;
}

@end

@implementation ResourceGlobalOrganizeManager

- (instancetype)initWithPlistFilePath:(NSString *)filePath targetFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        plistFilePath = filePath;
        rootFolderPath = folderPath;
    }
    
    return self;
}

- (void)startOrganizing {
    [[MRBLogManager defaultManager] showLogWithFormat:@"整理 %@ 内的图片, 流程开始", rootFolderPath.lastPathComponent];
    
    if (![[MRBFileManager defaultManager] isContentExistAtPath:plistFilePath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 不存在，请检查下载文件夹", plistFilePath.lastPathComponent];
        [[MRBLogManager defaultManager] showLogWithFormat:@"整理下载的动漫图片, 流程结束"];
        
        if (self.finishBlock) {
            self.finishBlock();
        }
        
        return;
    }
    
    NSDictionary *renameInfo = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    for (NSInteger i = 0; i < renameInfo.allKeys.count; i++) {
        NSString *key = renameInfo.allKeys[i]; // key 是下载好的文件名
        NSString *value = renameInfo[key];
        value = [value stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@":" withString:@" "];
        NSString *downloadPath = [NSString stringWithFormat:@"%@%@", rootFolderPath, key];
        NSString *targetPath = [NSString stringWithFormat:@"%@%@", rootFolderPath, value];
        
        NSError *error = nil;
        [[MRBFileManager defaultManager] moveItemAtPath:downloadPath toDestPath:targetPath error:&error];
        // 文件如果已经存在，那么删除源文件，说明之前已经下载的相同的图片了
        if (error && error.code == NSFileWriteFileExistsError) {
            NSDate *creationDate = [[MRBFileManager defaultManager] getSpecificAttributeOfItemAtPath:targetPath attribute:NSFileCreationDate];
            NSString *creationDateStr = [creationDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"文件: %@ 在 %@ 下载过，将被删除", downloadPath, creationDateStr];
            [[MRBFileManager defaultManager] trashFileAtPath:downloadPath resultItemURL:nil];
        }
    }
    
    [[MRBFileManager defaultManager] trashFileAtPath:plistFilePath resultItemURL:nil];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"整理 %@ 内的图片, 流程结束", rootFolderPath.lastPathComponent];
    
    if (self.finishBlock) {
        self.finishBlock();
    }
}

@end
