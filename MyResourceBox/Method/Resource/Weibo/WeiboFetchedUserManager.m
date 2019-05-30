//
//  WeiboFetchedUserManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "WeiboFetchedUserManager.h"
#import "MRBSQLiteFMDBManager.h"

@implementation WeiboFetchedUserManager

+ (void)saveUnfetchedUser {
    NSString *content = [AppDelegate defaultVC].inputTextView.string;
    if (content.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *string in components) {
        NSArray *strComps = [string componentsSeparatedByString:@" "];
        NSDictionary *dict = @{@"userUrl": strComps[0], @"screenName": strComps[1]};
        [result addObject:dict];
    }
    
    [[MRBSQLiteFMDBManager defaultDBManager] insertWeiboFetchedUserIntoDatabase:result status:0];
}

@end
