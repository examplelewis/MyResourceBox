//
//  MRBMediaOperationMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/08/09.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBMediaOperationMethod.h"
#import "MRBMediaLizhiPodcastInfoManager.h"

@implementation MRBMediaOperationMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [[MRBMediaLizhiPodcastInfoManager new] obtainProcessingData];
        }
            break;
        default:
            break;
    }
}

@end
