//
//  SQLiteFMDBManager.h
//  iOSLearningBox
//
//  Created by 龚宇 on 15/07/30.
//  Copyright (c) 2015年 softweare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "WeiboStatusObject.h"

@interface SQLiteFMDBManager : NSObject {
    FMDatabase *db;
}

+ (SQLiteFMDBManager *)defaultDBManager;

#pragma mark - BCYLink
- (BOOL)isDuplicateFromDatabaseWithBCYLink:(NSString *)urlString;
- (void)insertLinkIntoDatabase:(NSString *)urlString;
- (void)removeDuplicateLinksFromDatabase;

#pragma mark - BCYImageLink
- (BOOL)isDuplicateFromDatabaseWithBCYImageLink:(NSString *)urlString;
- (void)insertImageLinkIntoDatabase:(NSString *)urlString;
- (void)removeDuplicateImagesFromDatabase;

#pragma mark - Pixiv
- (void)cleanPixivFollowingUserTable;
- (void)insertPixivFollowingUserInfoIntoDatabase:(NSArray *)userInfo;
- (NSString *)getLastPixivFollowingUserIdFromDatabase;
- (void)insertPixivBlockUserInfoIntoDatabase:(NSArray *)userInfo;

#pragma mark - 图片整理
- (NSArray *)readPhotoOrganDest;
- (NSArray *)readPhotoOrganDownload;
- (void)deleteAllPhotoOrganTotal;
- (void)insertSinglePhotoOrganTotal:(NSString *)folder dest:(NSString *)destination;
- (NSArray *)readPhotoOrganTotal;


@end
