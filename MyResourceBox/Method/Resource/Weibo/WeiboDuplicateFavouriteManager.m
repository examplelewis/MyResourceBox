//
//  WeiboDuplicateFavouriteManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/08/11.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "WeiboDuplicateFavouriteManager.h"
#import "WeiboHeader.h"
#import "WeiboStatusObject.h"
#import "MRBHttpManager.h"
#import "MRBDownloadQueueManager.h"
#import "OrganizeManager.h"
#import "MRBSQLiteFMDBManager.h"
#import "MRBSQLiteManager.h"

@interface WeiboDuplicateFavouriteManager () {
    NSMutableArray *compareWeiboIds; // 没有重复的微博IDs，这里面如果没有转发的微博是原微博的ID，有转发微博时转发微博的ID
    NSMutableArray *duplicateWeiboIds; // 有重复的微博IDs，这里面全部都是当前微博的ID
    
    NSInteger fetchedPage;
    NSInteger fetchedCount;
}

@end

@implementation WeiboDuplicateFavouriteManager

- (void)fetchDuplicateFarouriteIDs {
    compareWeiboIds = [NSMutableArray array];
    duplicateWeiboIds = [NSMutableArray array];
    
    fetchedPage = 1;
    fetchedCount = 0;
    
    [self getFavouristByApi];
}
- (void)getFavouristByApi {
    [[MRBHttpManager sharedManager] getWeiboFavoritesWithPage:fetchedPage start:nil success:^(NSDictionary *dic) {
        NSArray *favors = dic[@"favorites"];
        BOOL found = NO;
        
        for (NSInteger i = 0; i < favors.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:favors[i]];
            NSDictionary *statusDict = dict[@"status"];
            
            // 先判断是否已经到了边界微博，也就是第一条和资源不相关的微博
            if ([statusDict[@"idstr"] isEqualToString:[MRBUserManager defaultManager].weibo_boundary_id]) {
                found = YES;
                break;
            }
            
            self->fetchedCount += 1;
            
            WeiboStatusObject *comparedObject;
            if (statusDict[@"retweeted_status"]) {
                comparedObject = [[WeiboStatusObject alloc] initWithDictionary:statusDict[@"retweeted_status"]];
            } else {
                comparedObject = [[WeiboStatusObject alloc] initWithDictionary:statusDict];
            }
            
            // 如果在当前抓取的流程中出现了重复的 id，那么跳过
            if ([self->compareWeiboIds containsObject:comparedObject.id_str]) {
                [self->duplicateWeiboIds addObject:[[WeiboStatusObject alloc] initWithDictionary:statusDict].id_str];
                
                continue;
            }
            // 如果当前微博在数据库中有记录，那么跳过
            if ([[MRBSQLiteFMDBManager defaultDBManager] isDuplicateFromDatabaseWithWeiboStatusId:comparedObject.id_str]) {
                [self->duplicateWeiboIds addObject:[[WeiboStatusObject alloc] initWithDictionary:statusDict].id_str];
                
                continue;
            }
            
            [self->compareWeiboIds addObject:comparedObject.id_str];
        }
        
        // 如果找到了边界微博，或者一直没有找到，直到取到的微博数量小于50，代表着没有更多收藏微博了，即边界微博出错
        if (found || favors.count < 50) {
            [self exportResult];
        } else {
            self->fetchedPage += 1; // 计数
            [self getFavouristByApi];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取收藏列表接口发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}

- (void)exportResult {
    [[MRBLogManager defaultManager] showLogWithFormat:@"一共抓取到 %ld 条微博，未重复 %ld 条，重复 %ld 条", fetchedCount, compareWeiboIds.count, duplicateWeiboIds.count];
    
    if (duplicateWeiboIds.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"重复的ID如下:\n%@", [MRBUtilityManager convertResultArray:duplicateWeiboIds]];
    }
}

@end
