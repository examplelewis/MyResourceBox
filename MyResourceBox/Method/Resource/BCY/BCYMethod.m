//
//  BCYMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "BCYMethod.h"
#import "BCYFetchManager.h"
#import "BCYHTMLParseManager.h"
#import "BCYOrganizingManager.h"

@implementation BCYMethod

+ (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1: {
            BCYFetchManager *manager = [BCYFetchManager new];
            [manager getPageURLFromInput:YES];
        }
            break;
        case 2: {
            BCYFetchManager *manager = [BCYFetchManager new];
            [manager getPageURLFromFile];
        }
            break;
        case 3: {
            [BCYHTMLParseManager startParsing];
        }
            break;
        case 4: {
            [BCYOrganizingManager prepareOrganizing];
        }
            break;
        case 5: {
            BCYFetchManager *manager = [BCYFetchManager new];
            [manager getPageURLFromInput:NO];
        }
        default:
            break;
    }
}

@end
