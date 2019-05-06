//
//  DeviantartMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "DeviantartMethod.h"
#import "DeviantartFeedsManager.h"
#import "DeviantartUserManager.h"

@implementation DeviantartMethod

+ (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [[DeviantartFeedsManager new] prepareFetchingFeeds];
        }
            break;
        case 2: {
            [[DeviantartUserManager new] prepareFetchingUserGallery];
        }
            break;
        default:
            break;
    }
}

@end

