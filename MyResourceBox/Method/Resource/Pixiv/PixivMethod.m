//
//  PixivMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/06.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "PixivMethod.h"
#import "PixivUserManager.h"
#import "PixivIllustManager.h"
#import "DownloadQueueManager.h"
#import "PixivDownloadManager.h"
#import <FMDB.h>
#import "PixivLoginUserManager.h"
#import "PixivAPIManager.h"
#import "SQLiteFMDBManager.h"
#import "PixivExHentaiManager.h"

@interface PixivMethod () {
    FMDatabase *db;
    NSMutableArray *fetchedFollowings;
    NSMutableArray *fetchedBlocks;
}

@property (nonatomic, copy) NSMutableArray *users; // 用户
@property (nonatomic, copy) NSMutableArray *illusts; // illusts

@property (nonatomic, copy) NSMutableDictionary *results; // 下载文件夹
@property (nonatomic, copy) NSMutableArray *imgsUrl; // 下载地址
@property (nonatomic, copy) NSMutableArray *failures; // 获取失败的 用户 或者 illust 地址

@end

@implementation PixivMethod

#pragma mark - Lifecycle
static PixivMethod *instance;
+ (PixivMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PixivMethod alloc] init];
    });
    
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _results = [NSMutableDictionary dictionary];
        _failures = [NSMutableArray array];
        _imgsUrl = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Base Method
- (void)configMethod:(NSInteger)cellRow {
    if (cellRow >= 11) {
        [self processOtherMethod:cellRow];
    } else {
        if (_login) {
            [self processMethod:cellRow];
        } else {
            __weak typeof(self) weakSelf = self;
            [[PixivLoginUserManager sharedManager] loginWithUsername:@"examplelewis" password:@"Example163" success:^{
                DDLogInfo(@"Pixiv 登录成功");
                [PixivMethod defaultMethod].login = YES;
                
                [weakSelf processMethod:cellRow];
            } failure:^(NSError * _Nonnull error) {
                DDLogInfo(@"Pixiv 登录失败：%@", error.localizedDescription);
                [PixivMethod defaultMethod].login = NO;
                
                [[UtilityFile sharedInstance] showLogWithFormat:@"Pixiv 登陆失败，无法进行后续操作: %@", error.localizedDescription];
            }];
        }
    }
}
- (void)processMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    [_results removeAllObjects];
    [_failures removeAllObjects];
    [_imgsUrl removeAllObjects];
    
    switch (cellRow) {
        case 1:
            [self getImageFromUserId];
            break;
        case 2:
            [self getImageFromIllustId];
            break;
        case 3:
            [self downloadPixivImage];
            break;
        case 4:
            [self fetchMyFollowings:nil];
            break;
        default:
            break;
    }
}
- (void)processOtherMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 11: {
            [self fetchPixivBlacklist];
        }
            break;
        case 12: {
            [self updateBlockLevel1PixivUser];
        }
            break;
        case 21: {
            [self checkPixivUserHasFollowed];
        }
            break;
        case 22: {
            [self checkPixivUserHasBlocked];
        }
            break;
        case 23: {
            [self checkPixivUtilHasFetched];
        }
            break;
        case 31: {
            [self managePixivUserUrlsUsingExHentaiManager];
        }
            break;
        case 91: {
            [self organizePixivPhotos];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 获取用户的图片地址
// 获取users
- (void)getImageFromUserId {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取Pixiv的User地址：已经准备就绪"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length > 0) {
        _users = [NSMutableArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"从输入框解析到%ld条网页\n", _users.count];
        
        [self fetchUserInfo:NO];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
    }
}
// 获取user
- (void)fetchUserInfo:(BOOL)cleanFirstPage {
    if (cleanFirstPage) {
        [_users removeObjectAtIndex:0];
    }
    if (_users.count == 0) {
        [self startDownloading];
        return;
    }
    
    PixivUserManager *manager = [[PixivUserManager alloc] initWithUserPage:_users.firstObject];
    [manager fetchUserIllusts:^(BOOL success, NSString *errorMsg, NSDictionary *illusts) {
        if (!success) {
            [[UtilityFile sharedInstance] showLogWithFormat:errorMsg];
            [self->_failures addObject:illusts[@"userPage"]];
        } else {
            [self->_results addEntriesFromDictionary:illusts];
            [self->_imgsUrl addObjectsFromArray:[NSArray arrayWithArray:illusts.allValues.firstObject]];
        }
    }];
}

#pragma mark - 通过 IllustId 获取图片
// 获取illusts
- (void)getImageFromIllustId {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取Pixiv的illust地址：已经准备就绪"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length > 0) {
        _illusts = [NSMutableArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"从输入框解析到%ld条网页\n", _illusts.count];
        
        [self fetchIllustInfo:NO];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
    }
}
// 获取illust
- (void)fetchIllustInfo:(BOOL)cleanFirstPage {
    if (cleanFirstPage) {
        [_illusts removeObjectAtIndex:0];
    }
    if (_illusts.count == 0) {
        [self startDownloading];
        return;
    }
    
    PixivIllustManager *manager = [[PixivIllustManager alloc] initWithWebpage:_illusts.firstObject];
    [manager fetchIllusts:^(BOOL success, NSString *errorMsg, NSDictionary *illusts) {
        if (!success) {
            [[UtilityFile sharedInstance] showLogWithFormat:errorMsg];
            [self->_failures addObject:illusts[@"webPage"]];
        } else {
            NSString *key = illusts.allKeys.firstObject;
            if ([self->_results.allKeys containsObject:key]) {
                NSArray *imgs = self->_results[key];
                imgs = [imgs arrayByAddingObjectsFromArray:illusts[key]];
                [self->_results setObject:imgs forKey:key];
            } else {
                [self->_results addEntriesFromDictionary:illusts];
            }
            [self->_imgsUrl addObjectsFromArray:[NSArray arrayWithArray:illusts.allValues.firstObject]];
        }
        
        [self fetchIllustInfo:YES];
    }];
}

#pragma mark - 下载图片
// 下载图片
- (void)downloadPixivImage {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取Pixiv的图片地址：已经准备就绪"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *images = [NSArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
    [[UtilityFile sharedInstance] showLogWithFormat:@"从输入框解析到%ld条图片地址\n", images.count];
    
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:images];
    manager.finishBlock = ^() {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"Pixiv图片资源已下载完成" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
    };
    manager.downloadPath = @"/Users/Mercury/Downloads/Pixiv";
    manager.httpHeaders = PIXIV_DEFAULT_HEADERS;
    [manager startDownload];
}
// 获取完用户信息或者图片信息后开始下载
- (void)startDownloading {
    [UtilityFile exportArray:_imgsUrl atPath:@"/Users/Mercury/Downloads/PixivIllustURLs.txt"];
    [_results writeToFile:@"/Users/Mercury/Downloads/PixivIllustInfo.plist" atomically:YES];
    if (_failures.count > 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld个用户获取失败，请查看错误文件", _failures.count]; //获取失败的页面地址
        [UtilityFile exportArray:_failures atPath:@"/Users/Mercury/Downloads/PixivFailedURLs.txt"];
    }
    
    PixivDownloadManager *manager = [[PixivDownloadManager alloc] initWithResult:_results];
    [manager startDownload];
}

#pragma mark - 我的关注
// 更新关注用户Ids
- (void)fetchMyFollowings:(NSString *)url {
    if (!url) {
        fetchedFollowings = [NSMutableArray array];
        url = @"https://app-api.pixiv.net/v1/user/following?user_id=6826008&restrict=public";
    }
    
    // 获取最新的 Member Id，然后根据这个 Id 截断从接口中获得的用户信息
    NSString *lastMemberId = [[SQLiteFMDBManager defaultDBManager] getLastPixivFollowingUserIdFromDatabase];
    
    WS(weakSelf);
    [PixivAPIManager fetchMyFollowingWithURL:url success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SS(strongSelf);
        NSString *nextUrl = responseObject[@"next_url"];
        NSArray *userPreviews = responseObject[@"user_previews"];
        BOOL reachLast = NO; // 看是否已经到了最后一个Id
        
        if (userPreviews && userPreviews.count > 0) {
            NSArray *userPreviewIds = [userPreviews valueForKeyPath:@"user.id"];
            NSArray *userPreviewNames = [userPreviews valueForKeyPath:@"user.name"];

            for (NSInteger i = 0; i < userPreviewIds.count; i++) {
                NSNumber *userId = userPreviewIds[i];
                NSString *userName = userPreviewNames[i];
                
                if ([userId integerValue] == [lastMemberId integerValue]) {
                    reachLast = YES;
                    break;
                }

                [strongSelf->fetchedFollowings addObject:@{@"userId": userId, @"userName": userName}];
            }
        }

        if (strongSelf->fetchedFollowings.count > 0) {
            [UtilityFile exportArray:strongSelf->fetchedFollowings atPlistPath:@"/Users/Mercury/Downloads/PixivFetchedUserIds.plist"];
        }
        
        // 如果到了最后一个，那么忽略之后的操作，将已有的数据保存至数据库
        if (reachLast) {
            [strongSelf saveUserIdsIntoDatabase];
        } else {
            NSLog(@"nextUrl: %@", nextUrl);
            if (nextUrl && ![nextUrl isEqual:[NSNull null]] && nextUrl.length > 0) {
                [strongSelf fetchMyFollowings:nextUrl];
            } else {
                [strongSelf saveUserIdsIntoDatabase];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

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
    
    [[SQLiteFMDBManager defaultDBManager] insertPixivFollowingUserInfoIntoDatabase:fetchedFollowings];
    [[UtilityFile sharedInstance] showLogWithFormat:@"已将获取到的 Pixiv 关注用户的信息存到数据库中"];
}
// 查询用户是否已经被关注
- (void)checkPixivUserHasFollowed {
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被关注，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    NSMutableArray *exists = [NSMutableArray array]; // 存在的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    db = [FMDatabase databaseWithPath:[[DeviceInfo sharedDevice].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被关注 时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束"];
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
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被关注，流程结束，请查看下载文件夹"];
    if (useless.count > 0) {
        [UtilityFile exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilFollowUseless.txt"];
    }
    if (news.count > 0) {
        [UtilityFile exportArray:news atPath:@"/Users/Mercury/Downloads/PixivUtilFollowNews.txt"];
    }
    if (exists.count > 0) {
        [UtilityFile exportArray:exists atPath:@"/Users/Mercury/Downloads/PixivUtilFollowExists.txt"];
    }
}

#pragma mark - 我的拉黑
- (void)fetchPixivBlacklist {
    NSString *txtFilePath = @"/Users/Mercury/Downloads/PixivBlock.txt";
    
    if (![[FileManager defaultManager] isContentExistAtPath:txtFilePath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"下载文件夹中没有 PixivBlock.txt 文件"];
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
    [[SQLiteFMDBManager defaultDBManager] insertPixivBlockUserInfoIntoDatabase:fetchedBlocks];
    [[UtilityFile sharedInstance] showLogWithFormat:@"已将获取到的 Pixiv 屏蔽用户的信息存到数据库中"];
}
- (void)checkPixivUserHasBlocked {
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    NSMutableArray *exists = [NSMutableArray array]; // 存在的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    db = [FMDatabase databaseWithPath:[[DeviceInfo sharedDevice].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被拉黑 时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束"];
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
        FMResultSet *rs = [db executeQuery:@"select count(member_id) from pixivBlockUser where member_id = ? and block_level = 1", @(userId)];
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
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被拉黑，流程结束，请查看下载文件夹"];
    if (useless.count > 0) {
        [UtilityFile exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilBlockUseless.txt"];
    }
    if (news.count > 0) {
        [UtilityFile exportArray:news atPath:@"/Users/Mercury/Downloads/PixivUtilBlockNews.txt"];
    }
    if (exists.count > 0) {
        [UtilityFile exportArray:exists atPath:@"/Users/Mercury/Downloads/PixivUtilBlockExists.txt"];
    }
}
- (void)updateBlockLevel1PixivUser {
    [[UtilityFile sharedInstance] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    
    db = [FMDatabase databaseWithPath:[[DeviceInfo sharedDevice].path_root_folder stringByAppendingPathComponent:@"data.sqlite"]];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"更新Pixiv屏蔽用户名单 时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程结束"];
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
        
        NSDictionary *user = nil;
        FMResultSet *rs = [db executeQuery:@"select * from pixivBlockUser where member_id = ?", @(userId)];
        while ([rs next]) {
            user = @{@"userId": @([rs intForColumn:@"member_id"]), @"userName": [rs stringForColumn:@"user_name"], @"blockLevel": @([rs intForColumn:@"block_level"])};
        }
        [rs close];
        
        // 如果数据表中没有这个人的记录，那么添加一条记录；如果有记录，并且 block_level 不是 1，即便是 2，也修改成 1
        if (!user) {
            BOOL success = [db executeUpdate:@"INSERT INTO pixivBlockUser (id, member_id, user_name, block_level) values(?, ?, ?, ?)", NULL, @(userId), NULL, @(1)];
            if (!success) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:pixivBlockUser中插入数据时发生错误：%@", [db lastErrorMessage]];
                [[UtilityFile sharedInstance] showLogWithFormat:@"数据：userId: %ld", userId];
            }
        } else {
            if ([user[@"blockLevel"] integerValue] != 1) {
                BOOL success = [db executeUpdate:@"UPDATE pixivBlockUser SET block_level = 1 WHERE member_id = ?", @(userId)];
                if (!success) {
                    [[UtilityFile sharedInstance] showLogWithFormat:@"往数据表:pixivBlockUser中更新数据时发生错误：%@", [db lastErrorMessage]];
                    [[UtilityFile sharedInstance] showLogWithFormat:@"数据：", user];
                }
            }
        }
    }
    
    [db close];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"更新Pixiv屏蔽用户名单，流程结束"];
    if (useless.count > 0) {
        [UtilityFile exportArray:useless atPath:@"/Users/Mercury/Downloads/PixivUtilUpdateBlockUseless.txt"];
    }
}

#pragma mark - PixivUtil
// 查询用户是否已经被抓取
- (void)checkPixivUtilHasFetched {
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程开始"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程结束"];
        return;
    }
    
    NSMutableArray *useless = [NSMutableArray array]; // 非 pixiv 的地址
    NSMutableArray *exists = [NSMutableArray array]; // 存在的地址
    NSMutableArray *news = [NSMutableArray array]; // 不存在的地址
    
    db = [FMDatabase databaseWithPath:@"/Users/Mercury/Documents/Tool/pixivutil/db.sqlite"];
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被抓取 时发生错误：%@", [db lastErrorMessage]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程结束"];
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
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询Pixiv用户是否被抓取，流程结束，请查看下载文件夹"];
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

#pragma mark - PixivExHentaiManager
- (void)managePixivUserUrlsUsingExHentaiManager {
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理ExHentai导出的用户，流程结束"];
        return;
    }
    
    NSArray *urls = [input componentsSeparatedByString:@"\n"];
    PixivExHentaiManager *manager = [[PixivExHentaiManager alloc] initWithOriginalUrls:urls];
    [manager startManaging];
}

#pragma mark - Other
- (void)organizePixivPhotos {
    NSString *folderPath = [AppDelegate defaultVC].inputTextView.string;
    if (folderPath.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"请输入Pixiv用户根目录的文件夹路径"];
        return;
    }
    
    NSArray *filePaths = [[FileManager defaultManager] getFilePathsInFolder:folderPath];
    NSArray *pixivIds = [filePaths bk_map:^id(NSString *filePath) {
        return [filePath.lastPathComponent substringWithRange:NSMakeRange(0, 8)];
    }];
    NSOrderedSet *pixivIdSet = [NSOrderedSet orderedSetWithArray:pixivIds];
    pixivIds = pixivIdSet.array;
    
    for (NSInteger i = 0; i < pixivIds.count; i++) {
        NSString *pixivId = pixivIds[i];
        NSArray *filter = [filePaths bk_select:^BOOL(NSString *filePath) {
            return [filePath containsString:pixivId];
        }];
        
        NSString *pixivIdFolderPath = [folderPath stringByAppendingPathComponent:pixivId];
        [[FileManager defaultManager] createFolderAtPathIfNotExist:pixivIdFolderPath];
        
        [filter bk_each:^(NSString *filePath) {
            NSString *fileName = filePath.lastPathComponent;
            NSString *destPath = [pixivIdFolderPath stringByAppendingPathComponent:fileName];
            
            [[FileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
        }];
    }
}

@end
