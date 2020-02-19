//
//  PixivFollowingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivFollowingManager.h"
#import <FMDB.h>
#import "PixivAPIManager.h"
#import "MRBSQLiteManager.h"
#import "MRBSQLiteFMDBManager.h"

@interface PixivFollowingManager () {
    FMDatabase *db;
    NSMutableArray *fetchedFollowings;
}

@end

@implementation PixivFollowingManager

- (void)updateMyFollowing {
    [self fetchMyFollowings:nil];
}
// 更新关注用户Ids
- (void)fetchMyFollowings:(NSString *)url {
    if (!url) {
        fetchedFollowings = [NSMutableArray array];
        url = @"https://app-api.pixiv.net/v1/user/following?user_id=6826008&restrict=public";
    }
    
    WS(weakSelf);
    [PixivAPIManager callPixivApiWithURL:url success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SS(strongSelf);
        NSString *nextUrl = responseObject[@"next_url"];
        NSArray *userPreviews = responseObject[@"user_previews"];
        NSArray *users = [userPreviews valueForKey:@"user"];
        
        if (users && users.count > 0) {
            [strongSelf->fetchedFollowings addObjectsFromArray:users];
        }
        
        if (strongSelf->fetchedFollowings.count > 0) {
            [MRBUtilityManager exportArray:strongSelf->fetchedFollowings atPlistPath:@"/Users/Mercury/Downloads/PixivFetchedUserIds.plist"];
        }
        
        NSLog(@"nextUrl: %@", nextUrl);
        if (nextUrl && ![nextUrl isEqual:[NSNull null]] && nextUrl.length > 0) {
            [strongSelf fetchMyFollowings:nextUrl];
        } else {
            [strongSelf saveUserIdsIntoDatabase];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"抓取 Pixiv 关注的用户信息时出错: %@", error.localizedDescription];
    }];
}
// 往数据库中存取
- (void)saveUserIdsIntoDatabase {
    if (fetchedFollowings.count == 0) {
        return;
    }
    
    // 数组进行一次 reverse
    NSUInteger i = 0;
    NSUInteger j = fetchedFollowings.count - 1;
    while (i < j) {
        [fetchedFollowings exchangeObjectAtIndex:i withObjectAtIndex:j];
        
        i++;
        j--;
    }
    
    [[MRBSQLiteFMDBManager defaultDBManager] cleanPixivFollowingUserTable];
    [[MRBSQLiteFMDBManager defaultDBManager] insertPixivFollowingUserInfoIntoDatabase:fetchedFollowings];
    [[MRBLogManager defaultManager] showLogWithFormat:@"已将获取到的 Pixiv 关注用户的信息存到数据库中"];
}

// 查询用户是否已经被关注
- (void)checkPixivUserHasFollowed {
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    NSMutableArray *exists = [NSMutableArray array]; // 存在的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注 时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束"];
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
        FMResultSet *rs = [db executeQuery:@"select count(member_id) from pixivFollowingUser where member_id = ?", @(userId)];
        while ([rs next]) {
            totalCount = [rs intForColumnIndex:0];
        }
        [rs close];
        
        if (totalCount == 0) {
            [news addObject:url];
        } else {
            [exists addObject:url];
        }
    }
    
    [db close];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束，请查看下载文件夹"];
    if (useless.count > 0) {
        [MRBUtilityManager exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilFollowUseless.txt"];
    }
    if (news.count > 0) {
        [MRBUtilityManager exportArray:news atPath:@"/Users/Mercury/Downloads/PixivUtilFollowNews.txt"];
    }
    if (exists.count > 0) {
        [MRBUtilityManager exportArray:exists atPath:@"/Users/Mercury/Downloads/PixivUtilFollowExists.txt"];
    }
}

@end
