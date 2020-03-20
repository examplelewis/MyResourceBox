//
//  MRBPixivFollowingAndBlockingDuplicateManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBPixivFollowingAndBlockingDuplicateManager.h"
#import <FMDB.h>

@implementation MRBPixivFollowingAndBlockingDuplicateManager

- (void)startSearching {
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询 Pixiv 关注和拉黑的重复名单，流程开始"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询 Pixiv 关注和拉黑的重复名单 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询 Pixiv 关注和拉黑的重复名单，流程结束"];
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *followings = [NSMutableArray array];
    NSMutableArray *blockings = [NSMutableArray array];
    NSMutableArray *duplicates = [NSMutableArray array];
    
    FMResultSet *followingRS = [db executeQuery:@"select member_id from pixivFollowingUser"];
    while ([followingRS next]) {
        [followings addObject:@([followingRS intForColumnIndex:0])];
    }
    [followingRS close];
    
    FMResultSet *blockingRS = [db executeQuery:@"select member_id from pixivBlockUser"];
    while ([blockingRS next]) {
        [blockings addObject:@([blockingRS intForColumnIndex:0])];
    }
    [blockingRS close];
    
    [db close];
    
    for (NSInteger i = 0; i < followings.count; i++) {
        if ([blockings containsObject:followings[i]]) {
            [duplicates addObject:followings[i]];
        }
    }
    
    if (duplicates.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询 Pixiv 关注和拉黑的重复名单，未发现重复名单，流程结束"];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询 Pixiv 关注和拉黑的重复名单，流程结束，请查看下载文件夹"];
        [MRBUtilityManager exportArray:duplicates atPath:@"/Users/Mercury/Downloads/PixivDatabaseDuplicateMemberIDs.txt"];
    }
}

@end
