//
//  WorldCosplayMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WorldCosplayMethod.h"
#import "WorldCosplayFetchManager.h"

@implementation WorldCosplayMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取WorldCosplay的图片地址：已经准备就绪"];
    
    switch (cellRow) {
        case 1: {
            [[WorldCosplayFetchManager new] getHTMLFromInput];
        }
            break;
        case 2: {
            [[WorldCosplayFetchManager new] getPageUrlsFromInput];
        }
            break;
        default:
            break;
    }
}

#pragma mark -- 逻辑方法 --


@end
