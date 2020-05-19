//
//  MRBSQLiteFMDBManager.m
//  iOSLearningBox
//
//  Created by 龚宇 on 15/07/30.
//  Copyright (c) 2015年 softweare. All rights reserved.
//

#import "MRBSQLiteFMDBManager.h"

@implementation MRBSQLiteFMDBManager

#pragma mark - 单例模式
static MRBSQLiteFMDBManager *_sharedDBManager;
+ (MRBSQLiteFMDBManager *)defaultDBManager {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedDBManager = [[MRBSQLiteFMDBManager alloc] init];
    });
    
    return _sharedDBManager;
}

#pragma mark - 创建数据库
- (void)createDatabase {
    db = [FMDatabase databaseWithPath:[[MRBDeviceManager defaultManager].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
}

#pragma mark - BCYLink
- (BOOL)isDuplicateFromDatabaseWithBCYLink:(NSString *)urlString {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"从数据表:bcyLink中查询数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", urlString];
        
        return NO;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select * from bcyLink where url = ?", urlString];
    while ([rs next]) {
        NSString *result = [rs stringForColumn:@"url"];
        
        [array addObject:result];
    }
    [rs close];
    [db close];
    
    return array.count != 0;
}
- (void)insertLinkIntoDatabase:(NSString *)urlString {
    //获取当前时间
    NSString *time = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:bcyLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", urlString];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"INSERT INTO bcyLink (id, url, time) values(?, ?, ?)", NULL, urlString, time];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:bcyLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", urlString];
    }
    
    [db close];
}
- (void)removeDuplicateLinksFromDatabase {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"DELETE FROM bcyLink WHERE id NOT IN(SELECT max(id) id from bcyLink group by url)"];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
    }
    
    [db close];
}

#pragma mark - BCYImageLink
- (BOOL)isDuplicateFromDatabaseWithBCYImageLink:(NSString *)urlString {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"从数据表:bcyImageLink中查询数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", urlString];
        
        return NO;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select * from bcyImageLink where url = ?", urlString];
    while ([rs next]) {
        NSString *result = [rs stringForColumn:@"url"];
        
        [array addObject:result];
    }
    [rs close];
    [db close];
    
    return array.count != 0;
}
- (void)insertImageLinkIntoDatabase:(NSString *)urlString {
    //获取当前时间
    NSString *time = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:bcyImageLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", urlString];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"INSERT INTO bcyImageLink (id, url, time) values(?, ?, ?)", NULL, urlString, time];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:bcyImageLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", urlString];
    }
    
    [db close];
}
- (void)removeDuplicateImagesFromDatabase {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"DELETE FROM bcyImageLink WHERE id NOT IN(SELECT max(id) id from bcyImageLink group by url)"];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
    }
    
    [db close];
}

#pragma mark - Pixiv
- (void)cleanPixivFollowingUserTable {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixivFollowingUser 所有数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    BOOL deleteSuccess = [db executeUpdate:@"DELETE FROM pixivFollowingUser"];
    if (deleteSuccess) {
        BOOL resetSeqSuccess = [db executeUpdate:@"UPDATE sqlite_sequence SET seq = 0 where name = 'pixivFollowingUser'"];
        if (resetSeqSuccess) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixivFollowingUser 所有数据成功"];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixivFollowingUser 所有数据时发生错误：%@", [db lastErrorMessage]];
        }
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"删除 pixivFollowingUser 所有数据时发生错误：%@", [db lastErrorMessage]];
    }
}
- (void)insertPixivFollowingUserInfoIntoDatabase:(NSArray *)MRBUserManager {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivFollowingUser中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < MRBUserManager.count; i++) {
            NSDictionary *info = MRBUserManager[i];
            
            BOOL success = [db executeUpdate:@"INSERT INTO pixivFollowingUser (id, member_id, user_name) values(?, ?, ?)", NULL, info[@"id"], info[@"name"]];
            if (!success) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivFollowingUser中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", info];
            }
        }
    } @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    } @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    
    [db close];
}
- (NSString *)getLastPixivFollowingUserIdFromDatabase {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"从数据表:pixivFollowingUser中查询数据时发生错误：%@", [db lastErrorMessage]];
        
        return nil;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSString *last_member_id;
    FMResultSet *rs = [db executeQuery:@"select member_id from pixivFollowingUser order by id desc limit 1"];
    while ([rs next]) {
        last_member_id = [rs stringForColumn:@"member_id"];
    }
    [rs close];
    [db close];
    
    return last_member_id;
}
- (void)insertPixivBlockUserInfoIntoDatabase:(NSArray *)MRBUserManager {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivBlockUser中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < MRBUserManager.count; i++) {
            NSDictionary *info = MRBUserManager[i];
            
            BOOL success = [db executeUpdate:@"INSERT INTO pixivBlockUser (id, member_id, user_name, block_level) values(?, ?, ?, ?)", NULL, info[@"userId"], info[@"userName"], @(0)];
            if (!success) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivBlockUser中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", info];
            }
        }
    } @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    } @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    
    [db close];
}

#pragma mark - 图片整理
- (NSArray *)readPhotoOrganDest {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据库打开失败：%@", [db lastErrorMessage]];
        
        return @[];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *acgResult = [NSMutableArray array];
    FMResultSet *acgRS = [db executeQuery:@"select * from photoOrganACGDest"];
    while ([acgRS next]) {
        NSString *copyright = [acgRS stringForColumn:@"copyright"];
        NSString *destination = [acgRS stringForColumn:@"destination"];
        
        [acgResult addObject:@{@"copyright": copyright, @"destination": destination}];
    }
    
    NSMutableArray *cosplayResult = [NSMutableArray array];
    FMResultSet *cosplayRS = [db executeQuery:@"select * from photoOrganCosplayDest"];
    while ([cosplayRS next]) {
        NSString *copyright = [cosplayRS stringForColumn:@"copyright"];
        NSString *destination = [cosplayRS stringForColumn:@"destination"];
        
        [cosplayResult addObject:@{@"copyright": copyright, @"destination": destination}];
    }
    
    NSMutableArray *zhenrenResult = [NSMutableArray array];
    FMResultSet *zhenrenRS = [db executeQuery:@"select * from photoOrganZhenrenDest"];
    while ([zhenrenRS next]) {
        NSString *copyright = [zhenrenRS stringForColumn:@"copyright"];
        NSString *destination = [zhenrenRS stringForColumn:@"destination"];
        
        [zhenrenResult addObject:@{@"copyright": copyright, @"destination": destination}];
    }
    
    [acgRS close];
    [cosplayRS close];
    [zhenrenRS close];
    
    [db close];
    
    return @[[acgResult copy], [cosplayResult copy], [zhenrenResult copy]];
}
- (NSArray *)readPhotoOrganDownload {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据库打开失败：%@", [db lastErrorMessage]];
        
        return @[];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *acgResult = [NSMutableArray array];
    FMResultSet *acgRS = [db executeQuery:@"select * from photoOrganACGDownload"];
    while ([acgRS next]) {
        NSString *copyright = [acgRS stringForColumn:@"copyright"];
        NSString *folder = [acgRS stringForColumn:@"folder"];
        
        [acgResult addObject:@{@"copyright": copyright, @"folder": folder}];
    }
    
    NSMutableArray *cosplayResult = [NSMutableArray array];
    FMResultSet *cosplayRS = [db executeQuery:@"select * from photoOrganCosplayDownload"];
    while ([cosplayRS next]) {
        NSString *copyright = [cosplayRS stringForColumn:@"copyright"];
        NSString *folder = [cosplayRS stringForColumn:@"folder"];
        
        [cosplayResult addObject:@{@"copyright": copyright, @"folder": folder}];
    }
    
    NSMutableArray *zhenrenResult = [NSMutableArray array];
    FMResultSet *zhenrenRS = [db executeQuery:@"select * from photoOrganZhenrenDownload"];
    while ([zhenrenRS next]) {
        NSString *copyright = [zhenrenRS stringForColumn:@"copyright"];
        NSString *folder = [zhenrenRS stringForColumn:@"folder"];
        
        [zhenrenResult addObject:@{@"copyright": copyright, @"folder": folder}];
    }
    
    [acgRS close];
    [cosplayRS close];
    [zhenrenRS close];
    
    [db close];
    
    return @[[acgResult copy], [cosplayResult copy], [zhenrenResult copy]];
}
- (void)deleteAllPhotoOrganTotal {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据库打开失败：%@", [db lastErrorMessage]];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL acgSuccess = [db executeUpdate:@"delete from photoOrganACGTotal"];
    if (!acgSuccess) {
        NSLog(@"从数据表: photoOrganACGTotal 中删除所有数据时发生错误: %@", [db lastErrorMessage]);
    }
    BOOL cosplaySuccess = [db executeUpdate:@"delete from photoOrganCosplayTotal"];
    if (!cosplaySuccess) {
        NSLog(@"从数据表: photoOrganCosplayTotal 中删除所有数据时发生错误: %@", [db lastErrorMessage]);
    }
    BOOL zhenrenSuccess = [db executeUpdate:@"delete from photoOrganZhenrenTotal"];
    if (!zhenrenSuccess) {
        NSLog(@"从数据表: photoOrganZhenrenTotal 中删除所有数据时发生错误: %@", [db lastErrorMessage]);
    }
    
    [db close];
}
- (void)insertSinglePhotoOrganTotal:(NSString *)folder dest:(NSString *)destination inTable:(NSString *)table {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据库打开失败：%@", [db lastErrorMessage]];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSString *update = [NSString stringWithFormat:@"INSERT INTO %@ (folder, destination) values('%@', '%@');", table, folder, destination];
    BOOL success = [db executeUpdate:update];
    if (!success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表: %@ 中插入数据时发生错误：%@", table, [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：folder: %@, destination: %@", folder, destination];
    }
    
    [db close];
}
- (NSArray *)readPhotoOrganTotal {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据库打开失败：%@", [db lastErrorMessage]];
        
        return @[];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *acgResult = [NSMutableArray array];
    FMResultSet *acgRS = [db executeQuery:@"select * from photoOrganACGTotal"];
    while ([acgRS next]) {
        NSString *destination = [acgRS stringForColumn:@"destination"];
        NSString *folder = [acgRS stringForColumn:@"folder"];
        
        [acgResult addObject:@{@"destination": destination, @"folder": folder}];
    }
    
    NSMutableArray *cosplayResult = [NSMutableArray array];
    FMResultSet *cosplayRS = [db executeQuery:@"select * from photoOrganCosplayTotal"];
    while ([cosplayRS next]) {
        NSString *destination = [cosplayRS stringForColumn:@"destination"];
        NSString *folder = [cosplayRS stringForColumn:@"folder"];
        
        [cosplayResult addObject:@{@"destination": destination, @"folder": folder}];
    }
    
    NSMutableArray *zhenrenResult = [NSMutableArray array];
    FMResultSet *zhenrenRS = [db executeQuery:@"select * from photoOrganZhenrenTotal"];
    while ([zhenrenRS next]) {
        NSString *destination = [zhenrenRS stringForColumn:@"destination"];
        NSString *folder = [zhenrenRS stringForColumn:@"folder"];
        
        [zhenrenResult addObject:@{@"destination": destination, @"folder": folder}];
    }
    
    [acgRS close];
    [cosplayRS close];
    [zhenrenRS close];
    
    [db close];
    
    return @[[acgResult copy], [cosplayResult copy], [zhenrenResult copy]];
}
- (NSString *)readOrganRootFolder {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据库打开失败：%@", [db lastErrorMessage]];
        
        return @"";
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSString *root = @"";
    FMResultSet *rs = [db executeQuery:@"select value from sysConst where type = 2"];
    while ([rs next]) {
        root = [rs stringForColumn:@"value"];
    }
    [rs close];
    [db close];
    
    return root;
}

#pragma mark - WeiboStatus
- (BOOL)isDuplicateFromDatabaseWithWeiboStatusId:(NSString *)weiboStatusId {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"从数据表:weiboStatus中查询数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", weiboStatusId];
        
        return NO;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select * from weiboStatus where weibo_id = ?", weiboStatusId];
    while ([rs next]) {
        NSString *result = [rs stringForColumn:@"weibo_id"];
        
        [array addObject:result];
    }
    [rs close];
    [db close];
    
    return array.count != 0;
}
- (void)insertWeiboStatusIntoDatabase:(NSArray *)weiboObjects {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:pixivFollowingUser中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < weiboObjects.count; i++) {
            WeiboStatusObject *object = weiboObjects[i];
            
            BOOL weiboStatusSuccess = [db executeUpdate:@"INSERT INTO weiboStatus (id, weibo_id, author_id, author_name, text, publish_time, fetch_time) values(?, ?, ?, ?, ?, ?, ?)", NULL, object.id_str, object.user_id_str, object.user_screen_name, object.text, object.created_at_sqlite_str, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
            if (!weiboStatusSuccess) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboStatus中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", object];
            }
            
            for (NSInteger j = 0; j < object.img_urls.count; j++) {
                BOOL weiboImageSuccess = [db executeUpdate:@"INSERT INTO weiboImage (id, weibo_id, image_url) values(?, ?, ?)", NULL, object.id_str, object.img_urls[j]];
                if (!weiboImageSuccess) {
                    [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboImage中插入数据时发生错误：%@", [db lastErrorMessage]];
                    [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", object];
                }
            }
        }
    } @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    } @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    
    [db close];
}

#pragma mark - WeiboFetchedUser
/**
 * @brief 将已筛选的微博用户存入数据库
 * @param status 0: 未关注，未筛选，未拉黑; 1: 已筛选/已下载; 2: 已关注; 3: 已拉黑
 */
- (void)insertWeiboFetchedUserIntoDatabase:(NSArray *)weiboUsers status:(NSInteger)status {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < weiboUsers.count; i++) {
            NSDictionary *weiboUser = weiboUsers[i];
            
            BOOL weiboUserSuccess = [db executeUpdate:@"INSERT INTO weiboUsers (id, screen_name, user_url, add_time, status) values(?, ?, ?, ?, ?)", NULL, weiboUser[@"screenName"], weiboUser[@"userUrl"], [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"], @(status)];
            if (!weiboUserSuccess) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", weiboUser];
            }
        }
    } @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    } @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    
    [db close];
}
- (void)updateFetchedUserStatus:(NSArray *)weiboUserScreenNames status:(NSInteger)status {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < weiboUserScreenNames.count; i++) {
            NSString *weiboUserScreenName = weiboUserScreenNames[i];
            
            NSString *sqliteStr = [NSString stringWithFormat:@"UPDATE weiboUsers SET status = %ld WHERE screen_name = %@", status, weiboUserScreenName];
            BOOL weiboUserSuccess = [db executeUpdate:sqliteStr];
            if (!weiboUserSuccess) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboUsers中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", weiboUserScreenName];
            }
        }
    } @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    } @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    
    [db close];
}

#pragma mark - WeiboRecommendArtists
- (void)insertSingleWeiboRecommendArtistWithWeiboStatus:(MRBWeiboStatusRecommendArtisModel *)model {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboRecommendArtists中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < model.recommendSites.count; i++) {
            NSDictionary *site = model.recommendSites[i];
            
            NSString *url = @"";
            if ([site.allKeys[0] isEqualToString:@"twitter"]) {
                url = [NSString stringWithFormat:@"https://twitter.com/%@", site.allValues[0]];
            }
            
            BOOL success = [db executeUpdate:@"INSERT INTO weiboRecommendArtists (id, weiboUserId, weiboUser, weiboStatus, recommendSite, recommendAccount, recommendUrl, recordTime) values(?, ?, ?, ?, ?, ?, ?, ?)", NULL, model.user_id_str, model.user_screen_name, model.text, site.allKeys[0], site.allValues[0], url, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
            if (!success) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"往数据表:weiboRecommendArtists中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", model];
            }
        }
    } @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    } @finally {
        if (!isRollBack) {
            [db commit];
        }
    }
    
    [db close];
}
- (BOOL)isExistingWeiboRecommendArtist:(MRBWeiboStatusRecommendArtisModel *)model {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"从数据表:weiboRecommendArtists中查询数据时发生错误：%@", [db lastErrorMessage]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"数据：%@", model];
        
        return NO;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSInteger foundCount = 0;
    for (NSInteger i = 0; i < model.recommendSites.count; i++) {
        NSDictionary *site = model.recommendSites[i];
        
        FMResultSet *rs = [db executeQuery:@"select * from weiboRecommendArtists where recommendSite = ? and recommendAccount = ?", site.allKeys[0], site.allValues[0]];
        while ([rs next]) {
            foundCount += 1;
        }
        [rs close];
    }
    
    [db close];
    
    return foundCount != 0;
}

@end
