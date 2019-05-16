//
//  MRBSQLiteManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MRBSQLiteManager.h"
#import "MRBSQLiteFMDBManager.h"

@implementation MRBSQLiteManager

// 备份数据库文件
+ (void)backupDatabaseFile {
    NSString *databaseName = @"data";
    NSString *folderPath = [MRBDeviceManager sharedDevice].path_root_folder;
    NSString *filePath = [[MRBDeviceManager sharedDevice].path_root_folder stringByAppendingPathComponent:@"data.sqlite"];
    NSFileManager *MRBFileManager = [NSFileManager defaultManager];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始备份数据库文件"];
    
    //先查找要备份的文件是否存在
    if ([MRBFileManager fileExistsAtPath:filePath]) {
        //如果文件存在，再查找是否已有备份文件
        NSArray *tempArray = [MRBFileManager contentsOfDirectoryAtPath:folderPath error:nil];
        BOOL hasBackupFile = NO;
        for (NSString *fileName in tempArray) {
            NSString *fullPath = [folderPath stringByAppendingPathComponent:fileName];
            if ([MRBFileManager fileExistsAtPath:fullPath] && [fileName hasPrefix:[NSString stringWithFormat:@"%@_", databaseName]]) {
                hasBackupFile = YES;
                
                NSError *error;
                NSURL *url = [NSURL fileURLWithPath:fullPath];
                if ([[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:nil error:&error]) {
                    [[MRBLogManager defaultManager] showLogWithFormat:@"旧备份文件删除成功"];
                } else {
                    [[MRBLogManager defaultManager] showLogWithTitle:@"旧备份文件删除失败" andFormat:[error localizedDescription]];
                    
                    return;
                }
                
                break;
            }
        }
        if (!hasBackupFile) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"未找到已有的备份文件"];
        }
        
        //最后再复制一份新的
        NSString *dateString = [[NSDate date] formattedDateWithFormat:@"yyyyMMdd"];
        NSString *copyFilePath = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.sqlite", databaseName, dateString]];
        
        NSError *error;
        if ([[NSFileManager defaultManager] copyItemAtPath:filePath toPath:copyFilePath error:&error]) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"文件：%@ 备份成功", copyFilePath];
        } else {
            [[MRBLogManager defaultManager] showLogWithTitle:[NSString stringWithFormat:@"文件：%@ 备份失败", copyFilePath] andFormat:[error localizedDescription]];
        }
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未在指定目录找到需要备份的数据库文件"];
    }
}
// 还原数据库文件
+ (void)restoreDatebaseFile {
    NSString *folderPath = [MRBDeviceManager sharedDevice].path_root_folder;
    NSString *filePath = [[MRBDeviceManager sharedDevice].path_root_folder stringByAppendingPathComponent:@"data.sqlite"];
    NSFileManager *MRBFileManager = [NSFileManager defaultManager];
    
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始还原数据库文件"];
    
    //先查找备份数据库文件是否存在
    NSArray *fileArray = [MRBFileManager contentsOfDirectoryAtPath:folderPath error:nil];
    NSString *foundFileName;
    for (NSString *fileName in fileArray) {
        if ([fileName hasPrefix:@"data_"]) {
            foundFileName = fileName;
            
            break;
        }
    }
    
    if (foundFileName) {
        //再查找原数据库文件是否存在，存在的话就删除
        if ([MRBFileManager fileExistsAtPath:filePath]) {
            NSError *error;
            NSURL *url = [NSURL fileURLWithPath:filePath];
            if ([[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:nil error:&error]) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"原数据库文件删除成功"];
            } else {
                [[MRBLogManager defaultManager] showLogWithTitle:@"原数据库文件删除失败" andFormat:[error localizedDescription]];
                
                return;
            }
        }
        
        //还原备份数据库文件
        NSString *fullPath = [folderPath stringByAppendingPathComponent:foundFileName];
        NSError *error;
        
        if ([[NSFileManager defaultManager] copyItemAtPath:fullPath toPath:filePath error:&error]) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"文件：%@ 还原成功", fullPath];
        } else {
            [[MRBLogManager defaultManager] showLogWithTitle:[NSString stringWithFormat:@"文件：%@ 还原失败", fullPath] andFormat:[error localizedDescription]];
        }
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未在指定目录找到可以还原的数据库文件"];
    }
}
// 去除数据库中重复的内容
+ (void)removeDuplicatesFromDatabase {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"去除数据库中重复的内容：已经准备就绪"];
    
    [[MRBSQLiteFMDBManager defaultDBManager] removeDuplicateLinksFromDatabase];
    [[MRBSQLiteFMDBManager defaultDBManager] removeDuplicateImagesFromDatabase];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"去除数据库中重复的内容：流程已经结束"];
    
    [MRBSQLiteManager backupDatabaseFile];
    [[MRBLogManager defaultManager] showLogWithFormat:@"整个流程已经结束，数据库已备份"];
}

@end
