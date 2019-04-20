//
//  OrganizingPhotos.m
//  MyResourceBox
//
//  Created by 龚宇 on 18/07/27.
//  Copyright © 2018年 gongyuTest. All rights reserved.
//

#import "OrganizingPhotos.h"
#import "SQLiteFMDBManager.h"

@interface OrganizingPhotos () {
    NSArray *totals;
}

@end

@implementation OrganizingPhotos

- (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1:
            [self organizeDatabase];
            break;
        case 2: {
            MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
            [alert setMessage:@"下载文件夹完整度" infomation:@"该项操作必须保证下载文件夹内只包含需要整理的资源，是否确认？"];
            [alert setButtonTitle:@"取消操作" keyEquivalent:[NSString stringWithFormat:@"%C", 0x1b]];
            [alert setButtonTitle:@"确认操作" keyEquivalent:@"\r"];
            [alert showAlertAtMainWindowWithCompletionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertSecondButtonReturn) {
                    [self organizePhotos];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)organizeDatabase {
    [[UtilityFile sharedInstance] showLogWithFormat:@"开始整理数据表: photoOrganTotal"];
    
    NSArray *downloads = [NSArray arrayWithArray:[[SQLiteFMDBManager defaultDBManager] readPhotoOrganDownload]];
    NSArray *dests = [NSArray arrayWithArray:[[SQLiteFMDBManager defaultDBManager] readPhotoOrganDest]];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"开始删除已有的数据"];
    [[SQLiteFMDBManager defaultDBManager] deleteAllPhotoOrganTotal];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"开始添加新的数据"];
    for (NSInteger i = 0; i < downloads.count; i++) {
        NSDictionary *download = [NSDictionary dictionaryWithDictionary:downloads[i]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"copyright = %@", download[@"copyright"]];
        NSArray *filter = [dests filteredArrayUsingPredicate:predicate];
        if (filter.count == 0) {
            continue;
        }
        NSDictionary *dest = [NSDictionary dictionaryWithDictionary:filter.firstObject];
        
        [[SQLiteFMDBManager defaultDBManager] insertSinglePhotoOrganTotal:download[@"folder"] dest:dest[@"destination"]];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理数据表: photoOrganTotal 完成"];
}

- (void)organizePhotos {
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理图片开始"];
    
    NSArray *total = [NSArray arrayWithArray:[[SQLiteFMDBManager defaultDBManager] readPhotoOrganTotal]];
    NSArray *subFolderPaths = [[FileManager defaultManager] getFolderPathsInFolder:@"/Users/Mercury/Downloads"];
    
    for (NSInteger i = 0; i < subFolderPaths.count; i++) {
        // 取得下载文件夹中源文件夹的路径和名字
        NSString *subFolderPath = subFolderPaths[i];
        NSString *subFolderName = subFolderPath.lastPathComponent;
        
        if ([subFolderName hasPrefix:@"."]) {
            continue; // .开头的文件夹都是隐藏文件夹，忽略
        }
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理图片: %@", subFolderName];
        
        // 根据文件夹的名字筛选出 dest 的对象，再获取到需要移动的文件夹的路径
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {            
            return [evaluatedObject[@"folder"] caseInsensitiveCompare:subFolderName] == NSOrderedSame;
        }];
        NSArray *filter = [total filteredArrayUsingPredicate:predicate];
        if (filter.count == 0) {
            continue; // 如果筛选没有结果，说明文件夹的名字在数据库中没有记录，那么跳过这个文件夹
        }
        NSDictionary *destObj = (NSDictionary *)filter.firstObject;
        NSString *destFolderPath = destObj[@"destination"];
        
        // 遍历源文件夹中的内容，并把内容移动到目标文件夹中
        NSArray *filePaths = [[FileManager defaultManager] getFilePathsInFolder:subFolderPath];
        for (NSInteger j = 0; j < filePaths.count; j++) {
            NSString *filePath = filePaths[j]; // 源文件路径
            NSString *fileName = filePath.lastPathComponent; // 源文件名
            NSString *destPath = [destFolderPath stringByAppendingPathComponent:fileName]; // 目标文件路径
            
            [[FileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
        }
        
        // 所有文件都移动之后，将源文件夹移动到废纸篓中
        [[FileManager defaultManager] trashFileAtPath:subFolderPath resultItemURL:nil];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"完成整理图片: %@", subFolderName];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理图片结束"];
}

@end
