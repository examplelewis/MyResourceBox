//
//  ResourceGlobalFileMoveManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/13.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ResourceGlobalFileMoveManager.h"

@implementation ResourceGlobalFileMoveManager

+ (void)moveFilesToDayFolderFromFolder:(NSString *)fromFolder {
    if (![[MRBFileManager defaultManager] isContentExistAtPath:fromFolder]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 文件夹不存在，无法移动内容到 Day 文件夹中", fromFolder];
        
        return;
    }
    
    NSString *toFolder = [fromFolder stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
    [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:toFolder];
    
    NSArray *fromFiles = [[MRBFileManager defaultManager] getFilePathsInFolder:fromFolder];
    for (NSInteger i = 0; i < fromFiles.count; i++) {
        NSString *fromFile = fromFiles[i];
        NSString *toFile = [fromFile stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
        
        [[MRBFileManager defaultManager] moveItemAtPath:fromFile toDestPath:toFile];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 文件内所有文件以及移动到 %@ 中", fromFolder, toFolder];
    
    [[MRBFileManager defaultManager] trashFileAtPath:fromFolder resultItemURL:nil];
    [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 文件夹已被移动到废纸篓中", fromFolder];
}

@end
