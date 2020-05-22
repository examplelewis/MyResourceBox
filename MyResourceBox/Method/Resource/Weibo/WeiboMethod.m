//
//  WeiboMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/07.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WeiboMethod.h"
#import "WeiboHeader.h"
#import "WeiboRequestTokenWindowController.h"
#import "WeiboBoundaryManager.h"
#import "WeiboFetchManager.h"
#import "WeiboFetchedUserManager.h"
#import "WeiboFetchFirstFavManager.h"
#import "WeiboRecommendArtistManager.h"
#import "MRBHttpManager.h"

@implementation WeiboMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [[WeiboFetchManager new] getFavorList];
        }
            break;
        case 2: {
            [[WeiboFetchFirstFavManager new] getFavorList];
        }
            break;
        case 3: {
            [[WeiboRecommendArtistManager new] start];
        }
            break;
        case 4: {
            [WeiboRecommendArtistManager destoryWeiboFavourites];
        }
            break;
        case 5: {
            [WeiboRecommendArtistManager manuallyImportRecommedArtists];
        }
            break;
        case 11: {
            WeiboRequestTokenWindowController *wc = [[WeiboRequestTokenWindowController alloc] initWithWindowNibName:@"WeiboRequestTokenWindowController"];
            [[NSApplication sharedApplication].mainWindow addChildWindow:wc.window ordered:NSWindowAbove];
            [wc becomeFirstResponder];
            [wc showWindow:nil];
        }
            break;
        case 12: {            
            [[MRBHttpManager sharedManager] getWeiboTokenInfoWithStart:nil success:^(NSDictionary *dic) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到Token信息:\n%@", dic];
            } failed:^(NSString *errorTitle, NSString *errorMsg) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取Token信息发生错误：%@，原因：%@", errorTitle, errorMsg];
            }];
            
            [[MRBHttpManager sharedManager] getWeiboLimitInfoWithStart:nil success:^(NSDictionary *dic) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到Token的Limit信息:\n%@", dic];
            } failed:^(NSString *errorTitle, NSString *errorMsg) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取Token的limit信息发生错误：%@，原因：%@", errorTitle, errorMsg];
            }];
        }
            break;
        case 21: {
            [[WeiboBoundaryManager new] getBoundaryID];
        }
            break;
        case 22: {
            [[WeiboBoundaryManager new] markNewestFavorAsBoundary];
        }
            break;
        case 31: {
            [WeiboFetchedUserManager saveUnfetchedUser];
        }
            break;
        default:
            break;
    }
}

@end
