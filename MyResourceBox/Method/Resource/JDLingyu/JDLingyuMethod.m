//
//  JDLingyuMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "JDLingyuMethod.h"
#import "JDLingyuFetchManager.h"

@implementation JDLingyuMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取绝对领域的图片地址：已经准备就绪"];
    
    switch (cellRow) {
        case 1: {
            [[JDLingyuFetchManager new] parseHTML];
        }
            break;
        default:
            break;
    }
}

@end
