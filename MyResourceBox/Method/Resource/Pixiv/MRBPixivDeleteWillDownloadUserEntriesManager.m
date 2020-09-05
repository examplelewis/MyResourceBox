//
//  MRBPixivDeleteWillDownloadUserEntriesManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/09/05.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBPixivDeleteWillDownloadUserEntriesManager.h"
#import <FMDB.h>
#import "PixivAPIManager.h"
#import "MRBSQLiteManager.h"
#import "MRBSQLiteFMDBManager.h"

@implementation MRBPixivDeleteWillDownloadUserEntriesManager

- (void)start {
    [[MRBLogManager defaultManager] showLogWithFormat:@"去除将要下载用户的下载记录，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除将要下载用户的下载记录，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    
    FMDatabase *db = [FMDatabase databaseWithPath:@"/Users/mercury/SynologyDrive/~同步文件夹/Tool/pixivutil/db.sqlite"];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除将要下载用户的下载记录 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除将要下载用户的下载记录，流程结束"];
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSArray *urls = [input componentsSeparatedByString:@"\n"];
    for (NSInteger i = 0; i < urls.count; i++) {
        NSString *url = urls[i];
        NSScanner *scanner = [NSScanner scannerWithString:url];
        NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];

        [scanner scanUpToCharactersFromSet:numberSet intoString:NULL];
        NSString *numberString;
        [scanner scanCharactersFromSet:numberSet intoString:&numberString];
        
        NSInteger userId = [numberString integerValue];
        if (userId == 0) {
            // 没有找到数字，就假定传入有问题，跳过
            [useless addObject:url];
            continue;
        }
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"当前查询用户: %ld", userId];
        
        // 查询 pixiv_master_image
        NSMutableArray *imageIDs = [NSMutableArray array];
        FMResultSet *masterRS = [db executeQuery:@"select image_id from pixiv_master_image where member_id = ?", @(userId)];
        while ([masterRS next]) {
            [imageIDs addObject:@([masterRS intForColumnIndex:0])];
        }
        [masterRS close];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"pixiv_master_image 表中包含 %ld 的图片共有 %ld 个", userId, imageIDs.count];
        if (imageIDs.count == 0) {
            continue;
        }
        
        // 删除 pixiv_manga_image
        for (NSInteger i = 0; i < imageIDs.count; i++) {
            NSInteger imageID = [imageIDs[i] integerValue];
            BOOL success = [db executeUpdate:@"DELETE FROM pixiv_manga_image WHERE image_id = ?", @(imageID)];
            if (success) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixiv_manga_image 表中包含 %ld 的记录成功", imageID];
            } else {
                [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixiv_manga_image 表中包含 %ld 的记录时发生错误：%@", imageID, [db lastErrorMessage]];
            }
        }
        
        // 删除 pixiv_master_image
        BOOL success = [db executeUpdate:@"DELETE FROM pixiv_master_image WHERE member_id = ?", @(userId)];
        if (success) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixiv_master_image 表中包含 %ld 的记录成功", userId];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixiv_master_image 表中包含 %ld 的记录时发生错误：%@", userId, [db lastErrorMessage]];
        }
        
        // 删除 pixiv_master_member
        success = [db executeUpdate:@"DELETE FROM pixiv_master_member WHERE member_id = ?", @(userId)];
        if (success) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixiv_master_member 表中包含 %ld 的记录成功", userId];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixiv_master_member 表中包含 %ld 的记录时发生错误：%@", userId, [db lastErrorMessage]];
        }
    }
    
    [db close];
    
    if (useless.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除将要下载用户的下载记录，流程结束"];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除将要下载用户的下载记录，流程结束，请查看下载文件夹"];
        [MRBUtilityManager exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilFetchUseless.txt"];
    }
}

@end
