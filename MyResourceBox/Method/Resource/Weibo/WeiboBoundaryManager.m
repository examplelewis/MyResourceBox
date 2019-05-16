//
//  WeiboBoundaryManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "WeiboBoundaryManager.h"
#import "MRBHttpManager.h"
#import "WeiboStatusObject.h"

@interface WeiboBoundaryManager () {
    NSInteger fetchedPage;
}

@end

@implementation WeiboBoundaryManager

- (void)getBoundaryID {
    [[MRBUserManager defaultUser] configureData]; //重新读一遍Plist文件
    [[MRBLogManager defaultManager] showLogWithFormat:@"原有边界微博的ID：%@", [MRBUserManager defaultUser].weibo_boundary_id];
    fetchedPage = 1;
    
    [self getBoundaryByApi];
}
- (void)getBoundaryByApi {
    [[MRBHttpManager sharedManager] getWeiboFavoritesWithPage:fetchedPage start:nil success:^(NSDictionary *dic) {
        NSArray *favors = dic[@"favorites"];
        BOOL found = NO;
        
        for (NSInteger i = 0; i < favors.count; i++) {
            NSDictionary *dict = favors[i];
            WeiboStatusObject *object = [[WeiboStatusObject alloc] initWithDictionary:dict[@"status"]];
            if ([object.text containsString:[MRBUserManager defaultUser].weibo_boundary_text] && [object.user_screen_name containsString:[MRBUserManager defaultUser].weibo_boundary_author]) {
                [MRBUserManager defaultUser].weibo_boundary_id = object.id_str;
                [[MRBUserManager defaultUser] saveAuthDictIntoPlistFile];
                [[MRBLogManager defaultManager] showLogWithFormat:@"已经找到边界微博的ID：%@", object.id_str];
                found = YES;
                
                break;
            }
        }
        
        // 如果找到了边界微博，或者一直没有找到，直到取到的微博数量小于50，代表着没有更多收藏微博了，即边界微博出错
        if (found) {
            // do nothing...
        } else if (favors.count < 50) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"没有找到符合条件的收藏内容，跳过"];
        } else {
            self->fetchedPage += 1; // 计数
            [self getBoundaryByApi];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取收藏列表接口发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}

- (void)markNewestFavorAsBoundary {
    [[MRBUserManager defaultUser] configureData]; //重新读一遍Plist文件
    [[MRBLogManager defaultManager] showLogWithFormat:@"原有边界微博的ID：%@", [MRBUserManager defaultUser].weibo_boundary_id];
    fetchedPage = 1;
    
    [[MRBHttpManager sharedManager] getWeiboFavoritesWithPage:fetchedPage start:nil success:^(NSDictionary *dic) {
        NSArray *favors = dic[@"favorites"];
        if (!favors || favors.count == 0) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"当前没有收藏内容，跳过"];
            return;
        }
        
        NSDictionary *newest = [NSDictionary dictionaryWithDictionary:favors.firstObject];
        WeiboStatusObject *object = [[WeiboStatusObject alloc] initWithDictionary:newest[@"status"]];
        
        [MRBUserManager defaultUser].weibo_boundary_id = object.id_str;
        [MRBUserManager defaultUser].weibo_boundary_author = object.user_screen_name;
        [MRBUserManager defaultUser].weibo_boundary_text = object.text;
        [[MRBUserManager defaultUser] saveAuthDictIntoPlistFile];
        [[MRBLogManager defaultManager] showLogWithFormat:@"已经找到边界微博的ID：%@", object.id_str];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取收藏列表接口发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}

@end
