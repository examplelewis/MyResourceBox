//
//  MRBSitesOrganization.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/10.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesOrganization.h"
#import "MRBSitesOrganizationTagExtractManager.h"
#import "PicResourceGIFWebmSeparateManager.h"

@implementation MRBSitesOrganization

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            // 抓取 Gelbooru 的所有标签
            // 做这个功能之前，需要先整理 MRBSitesOrganizationTagFetchManager
        }
            break;
        case 2: {
            [[MRBSitesOrganizationTagExtractManager new] prepareExtracting];
        }
            break;
        case 3: {
//            [PicResourceGIFWebmSeparateManager choosingRootFolder];
        }
            break;
        default:
            break;
    }
    
}

@end
