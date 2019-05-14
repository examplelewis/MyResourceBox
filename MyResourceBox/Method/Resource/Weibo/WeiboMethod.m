//
//  WeiboMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/07.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WeiboMethod.h"
#import "WeiboHeader.h"
#import "OrganizeManager.h"
#import "WeiboTokenWindowController.h"
#import "WeiboRequestTokenWindowController.h"
#import "WeiboBoundaryManager.h"
#import "WeiboFetchManager.h"
#import "WeiboPicCroppingManager.h"

@implementation WeiboMethod

+ (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [[WeiboFetchManager new] getFavorList];
        }
            break;
        case 2: {
            OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:weiboStatusPlistFilePath];
            [manager startOrganizing];
        }
            break;
        case 3: {
            WeiboRequestTokenWindowController *wc = [[WeiboRequestTokenWindowController alloc] initWithWindowNibName:@"WeiboRequestTokenWindowController"];
            [[NSApplication sharedApplication].mainWindow addChildWindow:wc.window ordered:NSWindowAbove];
            [wc becomeFirstResponder];
            [wc showWindow:nil];
        }
            break;
        case 4: {
            WeiboTokenWindowController *wc = [[WeiboTokenWindowController alloc] initWithWindowNibName:@"WeiboTokenWindowController"];
            [[NSApplication sharedApplication].mainWindow addChildWindow:wc.window ordered:NSWindowAbove];
            [wc becomeFirstResponder];
            [wc showWindow:nil];
        }
            break;
        case 5: {
            [[WeiboBoundaryManager new] getBoundaryID];
        }
            break;
        case 6: {
            [[WeiboBoundaryManager new] markNewestFavorAsBoundary];
        }
            break;
        case 101: {
            WeiboPicCroppingManager *manager = [WeiboPicCroppingManager new];
            manager.croppingRatio = WeiboPicCroppingRatio42;
            [manager prepareCropping];
        }
            break;
        case 102: {
            WeiboPicCroppingManager *manager = [WeiboPicCroppingManager new];
            manager.croppingRatio = WeiboPicCroppingRatio45;
            [manager prepareCropping];
        }
            break;
        case 103: {
            WeiboPicCroppingManager *manager = [WeiboPicCroppingManager new];
            manager.croppingRatio = WeiboPicCroppingRatio47;
            [manager prepareCropping];
        }
            break;
        case 104: {
            WeiboPicCroppingManager *manager = [WeiboPicCroppingManager new];
            manager.croppingRatio = WeiboPicCroppingRatio48;
            [manager prepareCropping];
        }
            break;
        default:
            break;
    }
}

@end
