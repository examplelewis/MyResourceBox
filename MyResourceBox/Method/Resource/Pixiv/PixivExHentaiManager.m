//
//  PixivExHentaiManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/08.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivExHentaiManager.h"
#import "MRBSQLiteFMDBManager.h"

@interface PixivExHentaiManager () {
    NSArray *originalUserUrls;
    NSMutableArray *fixedUserUrls;
}

@end

@implementation PixivExHentaiManager

- (void)startManaging {
    [[MRBLogManager defaultManager] showLogWithFormat:@"整理ExHentai导出的用户，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"整理ExHentai导出的用户，流程结束"];
        return;
    }
    
    NSArray *urls = [input componentsSeparatedByString:@"\n"];
    originalUserUrls = [NSArray arrayWithArray:urls];
    fixedUserUrls = [NSMutableArray arrayWithArray:urls];
    
    [self fixPixivUrls];
    [self duplicateRemoval];
    // 如果全都关注了,那就终止操作
    if ([self checkFollowing]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"所有获取到的用户都被关注了，流程结束"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"整理ExHentai导出的用户，流程结束"];
        return;
    }
    if ([self checkLevel1Blocking]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"所有未关注的用户都确定被拉黑，流程结束"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"整理ExHentai导出的用户，流程结束"];
        return;
    }
    [self checkFetched];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"整理ExHentai导出的用户，流程结束"];
}

// Step 1: 将 url 全部修正成 userId 的格式
- (void)fixPixivUrls {
    NSMutableArray *useless = [NSMutableArray array]; // 无用的
    
    for (NSInteger i = fixedUserUrls.count - 1; i >= 0; i--) {
        NSString *url = fixedUserUrls[i];
        
        NSScanner *scanner = [NSScanner scannerWithString:url];
        NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];

        [scanner scanUpToCharactersFromSet:numberSet intoString:NULL];
        NSString *numberString;
        [scanner scanCharactersFromSet:numberSet intoString:&numberString];
        
        if ([numberString integerValue] == 0) {
            [useless addObject:url];
            [fixedUserUrls removeObjectAtIndex:i];
        } else {
            [fixedUserUrls replaceObjectAtIndex:i withObject:numberString];
        }
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取到 %ld 条记录", fixedUserUrls.count];
    if (useless.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条无用记录", useless.count];
        [MRBUtilityManager exportArray:useless atPath:@"/Users/Mercury/Downloads/ExHentaiParsePixivUselessUrls.txt"];
    }
}

// Step 2: 去重
- (void)duplicateRemoval {
    NSInteger countBefore = fixedUserUrls.count;
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:fixedUserUrls];
    fixedUserUrls = [NSMutableArray arrayWithArray:orderedSet.array];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"共有 %ld 条重复的记录", countBefore - fixedUserUrls.count];
}

// Step 3: 查询是否有关注的记录
// 返回 YES，表明所有用户都被关注了，流程结束；返回 NO，表明还有未关注的用户，流程继续
- (BOOL)checkFollowing {
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注，流程开始"];
    
    NSMutableArray *exists = [NSMutableArray array]; // 存在的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    FMDatabase *db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束"];
        return YES;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    for (NSInteger i = 0; i < fixedUserUrls.count; i++) {
        NSString *userIdString = fixedUserUrls[i];
        NSInteger userId = [userIdString integerValue];
        
        NSInteger totalCount = 0;
        FMResultSet *rs = [db executeQuery:@"select count(member_id) from pixivFollowingUser where member_id = ?", @(userId)];
        while ([rs next]) {
            totalCount = [rs intForColumnIndex:0];
        }
        [rs close];
        
        if (totalCount == 0) {
            [news addObject:userIdString];
        } else {
            [exists addObject:[NSString stringWithFormat:@"https://www.pixiv.net/member_illust.php?id=%ld", userId]];
        }
    }
    
    [db close];
    
    if (exists.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条记录已经关注", exists.count];
        DDLogInfo(@"已关注的用户: %@", [MRBUtilityManager convertResultArray:exists]);
    }
    if (news.count > 0) {
        fixedUserUrls = [NSMutableArray arrayWithArray:news];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束"];
    
    return news.count == 0;
}

// Step 4: 查询是否有被确定拉黑的记录
- (BOOL)checkLevel1Blocking {
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程开始"];
    
    NSMutableArray *block1s = [NSMutableArray array]; // 确定被拉黑的地址
    NSMutableArray *notBlock1s = [NSMutableArray array]; // 不确定被拉黑或者未确定拉黑等级的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    FMDatabase *db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束"];
        return YES;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    for (NSInteger i = 0; i < fixedUserUrls.count; i++) {
        NSString *userIdString = fixedUserUrls[i];
        NSInteger userId = [userIdString integerValue];
        
        NSInteger blockLevel = -1;
        FMResultSet *rs = [db executeQuery:@"select * from pixivBlockUser where member_id = ?", @(userId)];
        while ([rs next]) {
            blockLevel = [rs intForColumn:@"block_level"];
        }
        [rs close];
        
        // 数据库查不到就说明没有记录
        NSString *url = [NSString stringWithFormat:@"https://www.pixiv.net/member_illust.php?id=%ld", userId];
        if (blockLevel == -1) {
            [news addObject:userIdString];
        } else if (blockLevel == 1) {
            [block1s addObject:url];
        } else {
            [notBlock1s addObject:url];
        }
    }
    
    [db close];
    
    if (block1s.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条记录确定被拉黑", block1s.count];
        DDLogInfo(@"确定被拉黑的用户: %@", [MRBUtilityManager convertResultArray:block1s]);
    }
    if (notBlock1s.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条记录不确定被拉黑或者未确定拉黑等级，现已全部导出至 PixivUtilBlockLevelNot1.txt 文件中", notBlock1s.count];
        [MRBUtilityManager exportArray:notBlock1s atPath:@"/Users/Mercury/Downloads/PixivUtilBlockLevelNot1.txt"];
    }
    if (news.count > 0) {
        fixedUserUrls = [NSMutableArray arrayWithArray:news];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束"];
    
    return news == 0;
}

// Step 5: 查询是否有抓取过
- (void)checkFetched {
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程开始"];
    
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
    
    for (NSInteger i = 0; i < fixedUserUrls.count; i++) {
        NSInteger userId = [fixedUserUrls[i] integerValue];
        
        NSInteger totalCount = 0;
        FMResultSet *rs = [db executeQuery:@"select count(image_id) from pixiv_master_image where member_id = ?", @(userId)];
        while ([rs next]) {
            totalCount = [rs intForColumnIndex:0];
        }
        [rs close];
        
        NSString *url = [NSString stringWithFormat:@"https://www.pixiv.net/member_illust.php?id=%ld", userId];
        if (totalCount == 0) {
            [news addObject:url];
        } else {
            [exists addObject:[NSString stringWithFormat:@"%@\t\t\t%ld", url, totalCount]];
        }
    }
    
    [db close];
    
    if (exists.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条记录被抓取，现已全部导出至 PixivUtilFetchExists.txt 文件中", exists.count];
        [MRBUtilityManager exportArray:exists atPath:@"/Users/Mercury/Downloads/PixivUtilFetchExists.txt"];
    }
    if (news.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条记录未被抓取，现已全部导出至 PixivUtilFetchNews.txt 文件中", news.count];
        [MRBUtilityManager exportArray:news atPath:@"/Users/Mercury/Downloads/PixivUtilFetchNews.txt"];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程结束"];
}

@end
