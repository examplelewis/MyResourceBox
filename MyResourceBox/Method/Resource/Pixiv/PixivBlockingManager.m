//
//  PixivBlockingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivBlockingManager.h"
#import <FMDB.h>
#import "PixivAPIManager.h"
#import "MRBSQLiteManager.h"
#import "MRBSQLiteFMDBManager.h"

@interface PixivBlockingManager () {
    FMDatabase *db;
    NSMutableArray *fetchedBlocks;
}

@end

@implementation PixivBlockingManager

- (void)fetchPixivBlacklist {
    NSString *txtFilePath = @"/Users/Mercury/Downloads/PixivBlock.txt";
    
    if (![[MRBFileManager defaultManager] isContentExistAtPath:txtFilePath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"下载文件夹中没有 PixivBlock.txt 文件"];
        return;
    }
    
    fetchedBlocks = [NSMutableArray array];
    
    NSString *allBlockStr = [[NSString alloc] initWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *allBlockComp = [allBlockStr componentsSeparatedByString:@"\n"];
    
    for (NSInteger i = 0; i < allBlockComp.count; i++) {
        NSString *blockStr = allBlockComp[i];
        NSArray *blockComp = [blockStr componentsSeparatedByString:@"\t"];
        [fetchedBlocks addObject:@{@"userId": blockComp[1], @"userName": blockComp[0]}];
    }
    
    // 拉黑的等级：0. 未判断; 1. 确定拉黑; 2. 不确定拉黑
    [[MRBSQLiteFMDBManager defaultDBManager] insertPixivBlockUserInfoIntoDatabase:fetchedBlocks];
    [[MRBLogManager defaultManager] showLogWithFormat:@"已将获取到的 Pixiv 屏蔽用户的信息存到数据库中"];
}
- (void)checkPixivUserHasBlocked {
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    NSMutableArray *block1Exists = [NSMutableArray array]; // blockLevel == 1 存在的地址
    NSMutableArray *notBlock1Exists = [NSMutableArray array]; // blockLevel != 1 存在的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束"];
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
        
        NSInteger blocks1Count = 0;
        FMResultSet *blocks1RS = [db executeQuery:@"select count(member_id) from pixivBlockUser where member_id = ? and block_level = 1", @(userId)];
        while ([blocks1RS next]) {
            blocks1Count = [blocks1RS intForColumnIndex:0];
        }
        [blocks1RS close];
        
        NSInteger notBlocks1Count = 0;
        FMResultSet *notBlocks1RS = [db executeQuery:@"select count(member_id) from pixivBlockUser where member_id = ? and block_level != 1", @(userId)];
        while ([notBlocks1RS next]) {
            notBlocks1Count = [notBlocks1RS intForColumnIndex:0];
        }
        [notBlocks1RS close];
        
        NSInteger existsCount = 0;
        FMResultSet *existsRS = [db executeQuery:@"select count(member_id) from pixivBlockUser where member_id = ?", @(userId)];
        while ([existsRS next]) {
            existsCount = [existsRS intForColumnIndex:0];
        }
        [existsRS close];
        
        if (blocks1Count != 0) {
            [block1Exists addObject:url];
        }
        if (notBlocks1Count != 0) {
            [notBlock1Exists addObject:url];
        }
        if (existsCount == 0) {
            [news addObject:url];
        }
    }
    
    [db close];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束，请查看下载文件夹"];
    if (useless.count > 0) {
        [MRBUtilityManager exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilBlockUseless.txt"];
    }
    if (news.count > 0) {
        [MRBUtilityManager exportArray:news atPath:@"/Users/Mercury/Downloads/PixivUtilBlockNews.txt"];
    }
    if (block1Exists.count > 0) {
        [MRBUtilityManager exportArray:block1Exists atPath:@"/Users/Mercury/Downloads/PixivUtilBlock1Exists.txt"];
    }
    if (notBlock1Exists.count > 0) {
        [MRBUtilityManager exportArray:notBlock1Exists atPath:@"/Users/Mercury/Downloads/PixivUtilNotBlock1Exists.txt"];
    }
}
- (void)updateBlockLevel1PixivUser {
    [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    
    db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv屏蔽用户名单 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程结束"];
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
        
        NSInteger blockLevel = -100; // -100 表示没有从数据库中查找到数据
        FMResultSet *rs = [db executeQuery:@"select * from pixivBlockUser where member_id = ?", @(userId)];
        while ([rs next]) {
            blockLevel = [rs intForColumn:@"block_level"];
        }
        [rs close];
        
        // 如果数据表中没有这个人的记录，那么添加一条记录；如果有记录，并且 block_level 不是 1，即便是 2，也修改成 1
        if (blockLevel == -100) {
            BOOL success = [db executeUpdate:@"INSERT INTO pixivBlockUser (id, member_id, user_name, block_level) values(?, ?, ?, ?)", NULL, @(userId), NULL, @(1)];
            if (!success) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivBlockUser中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：userId: %ld", userId];
            }
        } else {
            if (blockLevel != 1) {
                BOOL success = [db executeUpdate:@"UPDATE pixivBlockUser SET block_level = 1 WHERE member_id = ?", @(userId)];
                if (!success) {
                    [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivBlockUser中更新数据时发生错误：%@", [db lastErrorMessage]];
                    [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", @{@"userId": @(userId), @"blockLevel": @(blockLevel)}];
                }
            }
        }
    }
    
    [db close];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程结束"];
    if (useless.count > 0) {
        [MRBUtilityManager exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilUpdateBlockUseless.txt"];
    }
}
- (void)updateBlockLevel2PixivUser {
    [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv不确定屏蔽用户名单，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv不确定屏蔽用户名单，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    
    db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv不确定屏蔽用户名单 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv不确定屏蔽用户名单，流程结束"];
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
        
        NSInteger blockLevel = -100; // -100 表示没有从数据库中查找到数据
        FMResultSet *rs = [db executeQuery:@"select * from pixivBlockUser where member_id = ?", @(userId)];
        while ([rs next]) {
            blockLevel = [rs intForColumn:@"block_level"];
        }
        [rs close];
        
        // 如果数据表中没有这个人的记录，那么添加一条记录；如果有记录，只有 block_level 是 0，才修改成 1
        if (blockLevel == -100) {
            BOOL success = [db executeUpdate:@"INSERT INTO pixivBlockUser (id, member_id, user_name, block_level) values(?, ?, ?, ?)", NULL, @(userId), NULL, @(2)];
            if (!success) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivBlockUser中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：userId: %ld", userId];
            }
        } else {
            if (blockLevel == 0) {
                BOOL success = [db executeUpdate:@"UPDATE pixivBlockUser SET block_level = 2 WHERE member_id = ?", @(userId)];
                if (!success) {
                    [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivBlockUser中更新数据时发生错误：%@", [db lastErrorMessage]];
                    [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", @{@"userId": @(userId), @"blockLevel": @(blockLevel)}];
                }
            }
        }
    }
    
    [db close];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"更新Pixiv不确定屏蔽用户名单，流程结束"];
    if (useless.count > 0) {
        [MRBUtilityManager exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilUpdateBlockUseless.txt"];
    }
}


@end
