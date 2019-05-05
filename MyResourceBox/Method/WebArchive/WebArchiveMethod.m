//
//  WebArchiveMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/07.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WebArchiveMethod.h"
#import "WebArchiveArchivingManager.h"

@implementation WebArchiveMethod

+ (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [[WebArchiveArchivingManager new] startArchiving];
        }
            break;
        default:
            break;
    }
}



@end
