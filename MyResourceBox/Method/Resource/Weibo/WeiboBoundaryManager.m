//
//  WeiboBoundaryManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "WeiboBoundaryManager.h"
#import "HttpManager.h"
#import "WeiboStatusObject.h"

@interface WeiboBoundaryManager () {
    NSInteger fetchedPage;
}

@end

@implementation WeiboBoundaryManager

- (void)getBoundaryID {
    [[UserInfo defaultUser] configureData]; //重新读一遍Plist文件
    [[UtilityFile sharedInstance] showLogWithFormat:@"原有边界微博的ID：%@", [UserInfo defaultUser].weibo_boundary_id];
    fetchedPage = 1;
    
    [self getBoundaryByApi];
}
- (void)getBoundaryByApi {
    [[HttpManager sharedManager] getWeiboFavoritesWithPage:fetchedPage start:nil success:^(NSDictionary *dic) {
        NSArray *favors = dic[@"favorites"];
        BOOL found = NO;
        
        for (NSInteger i = 0; i < favors.count; i++) {
            NSDictionary *dict = favors[i];
            WeiboStatusObject *object = [[WeiboStatusObject alloc] initWithDictionary:dict[@"status"]];
            if ([object.text containsString:[UserInfo defaultUser].weibo_boundary_text] && [object.user_screen_name containsString:[UserInfo defaultUser].weibo_boundary_author]) {
                [UserInfo defaultUser].weibo_boundary_id = object.id_str;
                [[UserInfo defaultUser] saveAuthDictIntoPlistFile];
                [[UtilityFile sharedInstance] showLogWithFormat:@"已经找到边界微博的ID：%@", object.id_str];
                found = YES;
                
                break;
            }
        }
        
        // 如果找到了边界微博，或者一直没有找到，直到取到的微博数量小于50，代表着没有更多收藏微博了，即边界微博出错
        if (found) {
            // do nothing...
        } else if (favors.count < 50) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"没有找到符合条件的收藏内容，跳过"];
        } else {
            self->fetchedPage += 1; // 计数
            [self getBoundaryByApi];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取收藏列表接口发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}

- (void)markNewestFavorAsBoundary {
    [[UserInfo defaultUser] configureData]; //重新读一遍Plist文件
    [[UtilityFile sharedInstance] showLogWithFormat:@"原有边界微博的ID：%@", [UserInfo defaultUser].weibo_boundary_id];
    
    [[HttpManager sharedManager] getWeiboFavoritesWithPage:fetchedPage start:nil success:^(NSDictionary *dic) {
        NSArray *favors = dic[@"favorites"];
        if (!favors || favors.count == 0) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"当前没有收藏内容，跳过"];
            return;
        }
        
        NSDictionary *newest = [NSDictionary dictionaryWithDictionary:favors.firstObject];
        WeiboStatusObject *object = [[WeiboStatusObject alloc] initWithDictionary:newest[@"status"]];
        
        [UserInfo defaultUser].weibo_boundary_id = object.id_str;
        [UserInfo defaultUser].weibo_boundary_author = object.user_screen_name;
        [UserInfo defaultUser].weibo_boundary_text = object.text;
        [[UserInfo defaultUser] saveAuthDictIntoPlistFile];
        [[UtilityFile sharedInstance] showLogWithFormat:@"已经找到边界微博的ID：%@", object.id_str];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取收藏列表接口发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}

@end