//
//  PixivFetchingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivFetchingManager.h"
#import <FMDB.h>
#import "PixivAPIManager.h"
#import "MRBSQLiteManager.h"
#import "MRBSQLiteFMDBManager.h"

@implementation PixivFetchingManager

// 查询用户是否已经被抓取
+ (void)checkPixivUtilHasFetched {
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    NSMutableArray *exists = [NSMutableArray array]; // 存在的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    FMDatabase *db = [FMDatabase databaseWithPath:@"/Users/mercury/SynologyDrive/~同步文件夹/Tool/pixivutil/db.sqlite"];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被抓取 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程结束"];
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
        
        NSInteger totalCount = 0;
        FMResultSet *rs = [db executeQuery:@"select count(image_id) from pixiv_master_image where member_id = ?", @(userId)];
        while ([rs next]) {
            totalCount = [rs intForColumnIndex:0];
        }
        [rs close];
        
        if (totalCount == 0) {
            [news addObject:url];
        } else {
            [exists addObject:[NSString stringWithFormat:@"%@\t\t\t%ld", url, totalCount]];
        }
    }
    
    [db close];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程结束，请查看下载文件夹"];
    if (useless.count > 0) {
        [MRBUtilityManager exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilFetchUseless.txt"];
    }
    if (news.count > 0) {
        [MRBUtilityManager exportArray:news atPath:@"/Users/Mercury/Downloads/PixivUtilFetchNews.txt"];
    }
    if (exists.count > 0) {
        [MRBUtilityManager exportArray:exists atPath:@"/Users/Mercury/Downloads/PixivUtilFetchExists.txt"];
    }
}


@end
