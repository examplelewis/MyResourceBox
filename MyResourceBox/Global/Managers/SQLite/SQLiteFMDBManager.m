//
//  SQLiteFMDBManager.m
//  iOSLearningBox
//
//  Created by 龚宇 on 15/07/30.
//  Copyright (c) 2015年 softweare. All rights reserved.
//

#import "SQLiteFMDBManager.h"

@implementation SQLiteFMDBManager

#pragma mark - 单例模式
static SQLiteFMDBManager *_sharedDBManager;
+ (SQLiteFMDBManager *)defaultDBManager {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedDBManager = [[SQLiteFMDBManager alloc] init];
    });
    
    return _sharedDBManager;
}

#pragma mark - 创建数据库
- (void)createDatabase {
    db = [FMDatabase databaseWithPath:[[DeviceInfo sharedDevice].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
}

#pragma mark - BCYLink
- (BOOL)isDuplicateFromDatabaseWithBCYLink:(NSString *)urlString {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表:bcyLink中查询数据时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", urlString];
        
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:bcyLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", urlString];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"INSERT INTO bcyLink (id, url, time) values(?, ?, ?)", NULL, urlString, time];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:bcyLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", urlString];
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"DELETE FROM bcyLink WHERE id NOT IN(SELECT max(id) id from bcyLink group by url)"];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表:bcyImageLink中查询数据时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", urlString];
        
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:bcyImageLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", urlString];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"INSERT INTO bcyImageLink (id, url, time) values(?, ?, ?)", NULL, urlString, time];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:bcyImageLink中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", urlString];
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"DELETE FROM bcyImageLink WHERE id NOT IN(SELECT max(id) id from bcyImageLink group by url)"];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"去除数据库中重复的内容时发生错误：%@", [db lastErrorMessage]];
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"删除 pixivFollowingUser 所有数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    BOOL deleteSuccess = [db executeUpdate:@"DELETE FROM pixivFollowingUser"];
    if (deleteSuccess) {
        BOOL resetSeqSuccess = [db executeUpdate:@"UPDATE sqlite_sequence SET seq = 0 where name = 'pixivFollowingUser'"];
        if (resetSeqSuccess) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"删除 pixivFollowingUser 所有数据成功"];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"删除 pixivFollowingUser 所有数据时发生错误：%@", [db lastErrorMessage]];
        }
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"删除 pixivFollowingUser 所有数据时发生错误：%@", [db lastErrorMessage]];
    }
}
- (void)insertPixivFollowingUserInfoIntoDatabase:(NSArray *)userInfo {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:pixivFollowingUser中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < userInfo.count; i++) {
            NSDictionary *info = userInfo[i];
            
            BOOL success = [db executeUpdate:@"INSERT INTO pixivFollowingUser (id, member_id, user_name) values(?, ?, ?)", NULL, info[@"id"], info[@"name"]];
            if (!success) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:pixivFollowingUser中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", info];
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表:pixivFollowingUser中查询数据时发生错误：%@", [db lastErrorMessage]];
        
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
- (void)insertPixivBlockUserInfoIntoDatabase:(NSArray *)userInfo {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:pixivBlockUser中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    
    [db beginTransaction];
    
    BOOL isRollBack = NO;
    
    @try {
        for (NSInteger i = 0; i < userInfo.count; i++) {
            NSDictionary *info = userInfo[i];
            
            BOOL success = [db executeUpdate:@"INSERT INTO pixivBlockUser (id, member_id, user_name, block_level) values(?, ?, ?, ?)", NULL, info[@"userId"], info[@"userName"], @(0)];
            if (!success) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:pixivBlockUser中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[UtilityFile sharedInstance] showLogWithFormat:@"数据：%@", info];
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表: photoOrganDest 中查询数据时发生错误：%@", [db lastErrorMessage]];
        
        return @[];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select * from photoOrganDest"];
    while ([rs next]) {
        NSString *copyright = [rs stringForColumn:@"copyright"];
        NSString *destination = [rs stringForColumn:@"destination"];
        
        [array addObject:@{@"copyright": copyright, @"destination": destination}];
    }
    [rs close];
    [db close];
    
    return [array copy];
}
- (NSArray *)readPhotoOrganDownload {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表: photoOrganDownload 中查询数据时发生错误：%@", [db lastErrorMessage]];
        
        
        return @[];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select * from photoOrganDownload"];
    while ([rs next]) {
        NSString *copyright = [rs stringForColumn:@"copyright"];
        NSString *folder = [rs stringForColumn:@"folder"];
        
        [array addObject:@{@"copyright": copyright, @"folder": folder}];
    }
    [rs close];
    [db close];
    
    return [array copy];
}
- (void)deleteAllPhotoOrganTotal {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表: photoOrganTotal 中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"delete from photoOrganTotal"];
    if (!success) {
        NSLog(@"从数据表: photoOrganTotal 中删除所有数据时发生错误: %@", [db lastErrorMessage]);
    }
    
    [db close];
}
- (void)insertSinglePhotoOrganTotal:(NSString *)folder dest:(NSString *)destination {
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self createDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表: photoOrganTotal 中插入数据时发生错误：%@", [db lastErrorMessage]];
        
        return;
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    BOOL success = [db executeUpdate:@"INSERT INTO photoOrganTotal (folder, destination) values(?, ?)", folder, destination];
    if (!success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表: photoOrganTotal 中插入数据时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"数据：folder: %@, destination: %@", folder, destination];
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"从数据表: photoOrganTotal 中查询数据时发生错误：%@", [db lastErrorMessage]];
        
        return @[];
    }
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select * from photoOrganTotal"];
    while ([rs next]) {
        NSString *destination = [rs stringForColumn:@"destination"];
        NSString *folder = [rs stringForColumn:@"folder"];
        
        [array addObject:@{@"destination": destination, @"folder": folder}];
    }
    [rs close];
    [db close];
    
    return [array copy];
}

@end