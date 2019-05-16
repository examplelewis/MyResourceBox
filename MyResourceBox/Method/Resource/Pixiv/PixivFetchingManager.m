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
#import "SQLiteManager.h"
#import "SQLiteFMDBManager.h"

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
    
    FMDatabase *db = [FMDatabase databaseWithPath:@"/Users/Mercury/Documents/Tool/pixivutil/db.sqlite"];
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
        NSInteger userId = [url integerValue]; // 先看看是否是数字
        
        if (userId == 0) {
            // 既不是数字，也不是包含 pixiv.net 的字符串，判定为非 pixiv 的地址
            if (![url containsString:@"pixiv.net"]) {
                [useless addObject:url];
                continue;
            }
            
            // 如果字符串包含 pixiv.net，那么从字符串中解析 userId
            NSArray *urlComp = [url componentsSeparatedByString:@"="];
            userId = [urlComp[1] integerValue];
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
        [UtilityFile exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilFetchUseless.txt"];
    }
    if (news.count > 0) {
        [UtilityFile exportArray:news atPath:@"/Users/Mercury/Downloads/PixivUtilFetchNews.txt"];
    }
    if (exists.count > 0) {
        [UtilityFile exportArray:exists atPath:@"/Users/Mercury/Downloads/PixivUtilFetchExists.txt"];
    }
}


@end
