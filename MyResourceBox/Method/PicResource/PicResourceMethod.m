//
//  PicResourceMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/13.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PicResourceMethod.h"
#import "PicResourceTagFetchManager.h"
#import "PicResourceTagExtractManager.h"

@implementation PicResourceMethod

+ (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            // 抓取 Gelbooru 的所有标签
            // 做这个功能之前，需要先整理 ResourceGlobalTagFetchManager
        }
            break;
        case 2: {
            [[PicResourceTagExtractManager new] prepareExtracting];
        }
            break;
        default:
            break;
    }
    
}

@end
