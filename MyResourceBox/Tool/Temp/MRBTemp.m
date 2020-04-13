//
//  MRBTemp.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/13.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBTemp.h"
#import "MRBMacmini2018ConfigureManager.h"

@implementation MRBTemp

+ (void)configMethod:(NSInteger)cellRow {
//    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [[MRBMacmini2018ConfigureManager new] prepareFetching];
        }
            break;
        case 2: {
            
        }
            break;
        case 3: {
            
        }
            break;
        default:
            break;
    }
}

@end
