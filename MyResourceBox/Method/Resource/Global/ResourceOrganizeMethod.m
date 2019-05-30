//
//  ResourceOrganizeMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ResourceOrganizeMethod.h"
#import "BCYOrganizingManager.h"
#import "OrganizeManager.h"
#import "WeiboHeader.h"

@implementation ResourceOrganizeMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [BCYOrganizingManager prepareOrganizing];
        }
            break;
        case 2: {
            OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:@"/Users/Mercury/Downloads/JDlingyuRenameInfo.plist"];
            [manager startOrganizing];
        }
            break;
        case 3: {
            OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:weiboStatusPlistFilePath];
            [manager startOrganizing];
        }
            break;
        default:
            break;
    }
}

@end
