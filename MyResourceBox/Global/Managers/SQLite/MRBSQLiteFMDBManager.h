//
//  MRBSQLiteFMDBManager.h
//  iOSLearningBox
//
//  Created by 龚宇 on 15/07/30.
//  Copyright (c) 2015年 softweare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "WeiboStatusObject.h"
#import "MRBWeiboStatusRecommendArtisModel.h"

@interface MRBSQLiteFMDBManager : NSObject {
    FMDatabase *db;
}

+ (MRBSQLiteFMDBManager *)defaultDBManager;

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
- (void)insertPixivFollowingUserInfoIntoDatabase:(NSArray *)MRBUserManager;
- (NSString *)getLastPixivFollowingUserIdFromDatabase;
- (void)insertPixivBlockUserInfoIntoDatabase:(NSArray *)MRBUserManager;

#pragma mark - 图片整理
- (NSArray *)readPhotoOrganDest;
- (NSArray *)readPhotoOrganDownload;
- (void)deleteAllPhotoOrganTotal;
- (void)insertSinglePhotoOrganTotal:(NSString *)folder dest:(NSString *)destination inTable:(NSString *)table;
- (NSArray *)readPhotoOrganTotal;
- (NSString *)readOrganRootFolder;

#pragma mark - WeiboStatus
- (BOOL)isDuplicateFromDatabaseWithWeiboStatusId:(NSString *)weiboStatusId;
- (void)insertWeiboStatusIntoDatabase:(NSArray *)weiboObjects;

#pragma mark - WeiboFetchedUser
- (void)insertWeiboFetchedUserIntoDatabase:(NSArray *)weiboUsers status:(NSInteger)status;
- (void)updateFetchedUserStatus:(NSArray *)weiboUserScreenNames status:(NSInteger)status;

#pragma mark - WeiboRecommendArtists
- (void)insertSingleWeiboRecommendArtistWithWeiboStatus:(MRBWeiboStatusRecommendArtisModel *)model;
- (BOOL)isExistingWeiboRecommendArtist:(MRBWeiboStatusRecommendArtisModel *)model;

@end
