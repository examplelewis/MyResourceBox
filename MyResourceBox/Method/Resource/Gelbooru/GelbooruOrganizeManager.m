//
//  GelbooruOrganizeManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruOrganizeManager.h"

@interface GelbooruOrganizeManager () {
    NSString *plistFilePath;
    NSString *rootFolderPath;
}

@end

@implementation GelbooruOrganizeManager

- (instancetype)initWithPlistFilePath:(NSString *)filePath targetFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        plistFilePath = filePath;
        rootFolderPath = folderPath;
    }
    
    return self;
}

- (void)startOrganizing {
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理 %@ 内的图片, 流程开始", rootFolderPath.lastPathComponent];
    
    if (![[FileManager defaultManager] isContentExistAtPath:plistFilePath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 不存在，请检查下载文件夹", plistFilePath.lastPathComponent];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的动漫图片, 流程结束"];
        
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
        
        [[FileManager defaultManager] moveItemAtPath:downloadPath toDestPath:targetPath];
    }
    
    [[FileManager defaultManager] trashFileAtPath:plistFilePath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理 %@ 内的图片, 流程结束", rootFolderPath.lastPathComponent];
    
    if (self.finishBlock) {
        self.finishBlock();
    }
}

@end
