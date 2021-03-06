//
//  FOFilteredImageManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "FOFilteredImageManager.h"
#import "MRBSQLiteFMDBManager.h"

@implementation FOFilteredImageManager

+ (void)organizingDatabase {
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始整理数据表"];
    
    NSArray *downloads = [[MRBSQLiteFMDBManager defaultDBManager] readPhotoOrganDownload];
    NSArray *acgDownloads = downloads[0];
    NSArray *cosplayDownloads = downloads[1];
    NSArray *zhenrenDownloads = downloads[2];
    
    NSArray *dests = [[MRBSQLiteFMDBManager defaultDBManager] readPhotoOrganDest];
    NSArray *acgDests = dests[0];
    NSArray *cosplayDests = dests[1];
    NSArray *zhenrenDests = dests[2];
    
    NSString *root = [[MRBSQLiteFMDBManager defaultDBManager] readOrganRootFolder];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始删除已有的数据"];
    [[MRBSQLiteFMDBManager defaultDBManager] deleteAllPhotoOrganTotal];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始添加ACG新的数据"];
    for (NSInteger i = 0; i < acgDownloads.count; i++) {
        NSDictionary *download = [NSDictionary dictionaryWithDictionary:acgDownloads[i]];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"copyright = %@", download[@"copyright"]];
        NSArray *filter = [acgDests filteredArrayUsingPredicate:predicate];
        if (filter.count == 0) {
            continue;
        }
        NSDictionary *dest = [NSDictionary dictionaryWithDictionary:filter.firstObject];

        [[MRBSQLiteFMDBManager defaultDBManager] insertSinglePhotoOrganTotal:download[@"folder"] dest:[root stringByAppendingPathComponent:dest[@"destination"]] inTable:@"photoOrganACGTotal"];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始添加Cosplay新的数据"];
    for (NSInteger i = 0; i < cosplayDownloads.count; i++) {
        NSDictionary *download = [NSDictionary dictionaryWithDictionary:cosplayDownloads[i]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"copyright = %@", download[@"copyright"]];
        NSArray *filter = [cosplayDests filteredArrayUsingPredicate:predicate];
        if (filter.count == 0) {
            continue;
        }
        NSDictionary *dest = [NSDictionary dictionaryWithDictionary:filter.firstObject];
        
        [[MRBSQLiteFMDBManager defaultDBManager] insertSinglePhotoOrganTotal:download[@"folder"] dest:[root stringByAppendingPathComponent:dest[@"destination"]] inTable:@"photoOrganCosplayTotal"];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始添加真人新的数据"];
    for (NSInteger i = 0; i < zhenrenDownloads.count; i++) {
        NSDictionary *download = [NSDictionary dictionaryWithDictionary:zhenrenDownloads[i]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"copyright = %@", download[@"copyright"]];
        NSArray *filter = [zhenrenDests filteredArrayUsingPredicate:predicate];
        if (filter.count == 0) {
            continue;
        }
        NSDictionary *dest = [NSDictionary dictionaryWithDictionary:filter.firstObject];
        
        [[MRBSQLiteFMDBManager defaultDBManager] insertSinglePhotoOrganTotal:download[@"folder"] dest:[root stringByAppendingPathComponent:dest[@"destination"]] inTable:@"photoOrganZhenrenTotal"];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"整理数据表完成"];
}

+ (void)prepareOrganizingPhotos {
//    MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
//    [alert setMessage:@"下载文件夹完整度" infomation:@"该项操作必须保证下载文件夹内只包含需要整理的资源，是否确认？"];
//    [alert setButtonTitle:@"取消操作" keyEquivalent:[NSString stringWithFormat:@"%C", 0x1b]];
//    [alert setButtonTitle:@"确认操作" keyEquivalent:@"\r"];
//    [alert showAlertAtMainWindowWithCompletionHandler:^(NSModalResponse returnCode) {
//        if (returnCode == NSAlertSecondButtonReturn) {
//            [self organizingPhotos];
//        }
//    }];
    
    [self organizingPhotos];
}
+ (void)organizingPhotos {
    [[MRBLogManager defaultManager] showLogWithFormat:@"移动整理筛选好的图片开始"];
    
    NSArray *total = [[MRBSQLiteFMDBManager defaultDBManager] readPhotoOrganTotal];
    [self organizingPhotosWithRootFolder:@"/Users/Mercury/Downloads/ACG" totalData:total[0]];
    [self organizingPhotosWithRootFolder:@"/Users/Mercury/Downloads/Cosplay" totalData:total[1]];
    [self organizingPhotosWithRootFolder:@"/Users/Mercury/Downloads/真人" totalData:total[2]];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"移动整理筛选好的图片结束"];
}
+ (void)organizingPhotosWithRootFolder:(NSString *)rootFolder totalData:(NSArray *)total {
    if (![[MRBFileManager defaultManager] isContentExistAtPath:rootFolder]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 文件夹不存在，无法移动文件夹里的内容", rootFolder];
        
        return;
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"开始移动 %@ 文件夹里的内容", rootFolder];
    
    NSArray *subFolderPaths = [[MRBFileManager defaultManager] getFolderPathsInFolder:rootFolder];
    for (NSInteger i = 0; i < subFolderPaths.count; i++) {
        // 取得下载文件夹中源文件夹的路径和名字
        NSString *subFolderPath = subFolderPaths[i];
        NSString *subFolderName = subFolderPath.lastPathComponent;
        
        if ([subFolderName hasPrefix:@"."]) {
            continue; // .开头的文件夹都是隐藏文件夹，忽略
        }
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"整理图片: %@", subFolderName];
        
        // 根据文件夹的名字筛选出 dest 的对象，再获取到需要移动的文件夹的路径
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject[@"folder"] caseInsensitiveCompare:subFolderName] == NSOrderedSame;
        }];
        NSArray *filter = [total filteredArrayUsingPredicate:predicate];
        if (filter.count == 0) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 里没有 %@ 的目标记录", rootFolder, subFolderName];
            
            continue; // 如果筛选没有结果，说明文件夹的名字在数据库中没有记录，那么跳过这个文件夹
        }
        NSDictionary *destObj = (NSDictionary *)filter.firstObject;
        NSString *destFolderPath = destObj[@"destination"];
        
        // 遍历源文件夹中的内容，并把内容移动到目标文件夹中
        NSArray *filePaths = [[MRBFileManager defaultManager] getFilePathsInFolder:subFolderPath];
        for (NSInteger j = 0; j < filePaths.count; j++) {
            NSString *filePath = filePaths[j]; // 源文件路径
            NSString *fileName = filePath.lastPathComponent; // 源文件名
            NSString *destPath = [destFolderPath stringByAppendingPathComponent:fileName]; // 目标文件路径
            
            [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
        }
        
        // 判断文件夹内是否还有内容：如果有的话，那就不删除文件夹；没有内容的话，就将源文件夹移动到废纸篓中
        NSArray *leftFiles = [[MRBFileManager defaultManager] getFilePathsInFolder:subFolderPath];
        if (leftFiles.count == 0) {
            [[MRBFileManager defaultManager] trashFileAtPath:subFolderPath resultItemURL:nil];
        }
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"完成整理图片: %@", subFolderName];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"结束移动 %@ 文件夹里的内容", rootFolder];
}

@end
