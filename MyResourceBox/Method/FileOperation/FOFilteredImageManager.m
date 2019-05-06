//
//  FOFilteredImageManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "FOFilteredImageManager.h"
#import "SQLiteFMDBManager.h"

@implementation FOFilteredImageManager

+ (void)organizingDatabase {
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

+ (void)prepareOrganizingPhotos {
    MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
    [alert setMessage:@"下载文件夹完整度" infomation:@"该项操作必须保证下载文件夹内只包含需要整理的资源，是否确认？"];
    [alert setButtonTitle:@"取消操作" keyEquivalent:[NSString stringWithFormat:@"%C", 0x1b]];
    [alert setButtonTitle:@"确认操作" keyEquivalent:@"\r"];
    [alert showAlertAtMainWindowWithCompletionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertSecondButtonReturn) {
            [self organizingPhotos];
        }
    }];
}
+ (void)organizingPhotos {
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

+ (void)organizingExportPhotos {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的图片：流程准备开始"];
    
    // Cosplay 文件夹
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的Cosplay图片：流程准备开始"];
    NSString *cosplayFolder = @"/Users/Mercury/Downloads/Cosplay";
    if ([[FileManager defaultManager] isContentExistAtPath:cosplayFolder]) {
        NSArray *originalFilePaths = [[FileManager defaultManager] getFilePathsInFolder:cosplayFolder];
        
        for (NSInteger i = 0; i < originalFilePaths.count; i++) {
            NSString *originalFilePath = originalFilePaths[i];
            NSString *destFilePath = [originalFilePath stringByReplacingOccurrencesOfString:cosplayFolder withString:@"/User/Mercury/CloudStation/网络图片/Cosplay"];
            
            [[FileManager defaultManager] moveItemAtPath:originalFilePath toDestPath:destFilePath];
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的Cosplay图片：流程已经结束"];
    
    // 真人 文件夹
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的真人图片：流程准备开始"];
    NSString *zhenrenFolder = @"/Users/Mercury/Downloads/真人";
    if ([[FileManager defaultManager] isContentExistAtPath:zhenrenFolder]) {
        NSArray *originalFilePaths = [[FileManager defaultManager] getFilePathsInFolder:zhenrenFolder];
        
        for (NSInteger i = 0; i < originalFilePaths.count; i++) {
            NSString *originalFilePath = originalFilePaths[i];
            NSString *destFilePath = [originalFilePath stringByReplacingOccurrencesOfString:zhenrenFolder withString:@"/User/Mercury/CloudStation/网络图片/真人"];
            
            [[FileManager defaultManager] moveItemAtPath:originalFilePath toDestPath:destFilePath];
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的真人图片：流程已经结束"];
    
    // ACG 文件夹
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的ACG图片：流程准备开始"];
    NSString *acgFolder = @"/Users/Mercury/CloudStation/网络图片/ACG";
    NSArray *acgFolders = [[FileManager defaultManager] getFolderPathsInFolder:acgFolder];
    for (NSInteger i = 0; i < acgFolders.count; i++) {
        NSString *destACGFolder = acgFolders[i];
        NSString *originACGFolder = [destACGFolder stringByReplacingOccurrencesOfString:acgFolder withString:@"/Users/Mercury/Downloads"];
        
        if ([[FileManager defaultManager] isContentExistAtPath:originACGFolder]) {
            NSArray *originalFilePaths = [[FileManager defaultManager] getFilePathsInFolder:originACGFolder];
            
            for (NSInteger j = 0; j < originalFilePaths.count; j++) {
                NSString *originalFilePath = originalFilePaths[j];
                NSString *destFilePath = [originalFilePath stringByReplacingOccurrencesOfString:originACGFolder withString:destACGFolder];
                
                [[FileManager defaultManager] moveItemAtPath:originalFilePath toDestPath:destFilePath];
            }
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的ACG图片：流程已经结束"];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理导出的图片：流程已经结束"];
}

@end
