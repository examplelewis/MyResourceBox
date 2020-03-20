//
//  PixivMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/06.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "PixivMethod.h"
#import "PixivLoginUserManager.h"
#import "PixivUserPicManager.h"
#import "PixivIllustPicManager.h"
#import "PixivPicDownloadManager.h"
#import "PixivFollowingManager.h"
#import "PixivBlockingManager.h"
#import "PixivFetchingManager.h"
#import "PixivExHentaiManager.h"
#import "PixivOrganizingManager.h"
#import "MRBPixivFollowingAndBlockingDuplicateManager.h"

@implementation PixivMethod

#pragma mark - Base Method
+ (void)configMethod:(NSInteger)cellRow {
    if (cellRow >= 11) {
        [self processOtherMethod:cellRow];
    } else {
        [[PixivLoginUserManager sharedManager] loginWithUsername:@"examplelewis" password:@"Example163" success:^{
            DDLogInfo(@"Pixiv 登录成功");
            
            [self processMethod:cellRow];
        } failure:^(NSError * _Nonnull error) {
            DDLogInfo(@"Pixiv 登录失败：%@", error.localizedDescription);
            
            [[MRBLogManager defaultManager] showLogWithFormat:@"Pixiv 登陆失败，无法进行后续操作: %@", error.localizedDescription];
        }];
    }
}
+ (void)processMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            PixivUserPicManager *manager = [PixivUserPicManager new];
            [manager prepareFetching];
        }
            break;
        case 2: {
            PixivIllustPicManager *manager = [PixivIllustPicManager new];
            [manager prepareFetching];
        }
            break;
        case 3: {
            [PixivPicDownloadManager downloadPixivImage];
        }
            break;
        case 4: {
            PixivFollowingManager *manager = [PixivFollowingManager new];
            [manager updateMyFollowing];
        }
            break;
        default:
            break;
    }
}
+ (void)processOtherMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 11: {
            PixivBlockingManager *manager = [PixivBlockingManager new];
            [manager fetchPixivBlacklist];
        }
            break;
        case 12: {
            PixivBlockingManager *manager = [PixivBlockingManager new];
            [manager updateBlockLevel1PixivUser];
        }
            break;
        case 13: {
            PixivBlockingManager *manager = [PixivBlockingManager new];
            [manager updateBlockLevel2PixivUser];
        }
            break;
        case 21: {
            PixivFollowingManager *manager = [PixivFollowingManager new];
            [manager checkPixivUserHasFollowed];
        }
            break;
        case 22: {
            PixivBlockingManager *manager = [PixivBlockingManager new];
            [manager checkPixivUserHasBlocked];
        }
            break;
        case 23: {
            [PixivFetchingManager checkPixivUtilHasFetched];
        }
            break;
        case 31: {
            PixivExHentaiManager *manager = [PixivExHentaiManager new];
            [manager startManaging];
        }
            break;
        case 41: {
            [[MRBPixivFollowingAndBlockingDuplicateManager new] startSearching];
        }
            break;
        case 91: {
            [PixivOrganizingManager organizePixivPhotos];
        }
            break;
        default:
            break;
    }
}

@end
