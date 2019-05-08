//
//  Rule34FileMoveManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "Rule34FileMoveManager.h"
#import "Rule34Header.h"

@implementation Rule34FileMoveManager

+ (void)moveFilesToDayFolderFromFolder:(NSString *)fromFolder {
    if (![[FileManager defaultManager] isContentExistAtPath:fromFolder]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件夹不存在，无法移动内容到 Day 文件夹中", fromFolder];
        
        return;
    }
    
    NSString *toFolder = [fromFolder stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
    [[FileManager defaultManager] createFolderAtPathIfNotExist:toFolder];
    
    NSArray *fromFiles = [[FileManager defaultManager] getFilePathsInFolder:fromFolder];
    for (NSInteger i = 0; i < fromFiles.count; i++) {
        NSString *fromFile = fromFiles[i];
        NSString *toFile = [fromFile stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
        
        [[FileManager defaultManager] moveItemAtPath:fromFile toDestPath:toFile];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件内所有文件以及移动到 %@ 中", fromFolder, toFolder];
    
    [[FileManager defaultManager] trashFileAtPath:fromFolder resultItemURL:nil];
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件夹已被移动到废纸篓中", fromFolder];
}

@end
