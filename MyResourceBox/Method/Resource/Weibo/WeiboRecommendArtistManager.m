//
//  WeiboRecommendArtistManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/05/08.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "WeiboRecommendArtistManager.h"
#import "WeiboHeader.h"
#import "MRBHttpManager.h"
#import "MRBDownloadQueueManager.h"
#import "OrganizeManager.h"
#import "MRBSQLiteFMDBManager.h"
#import "MRBSQLiteManager.h"
#import "MRBWeiboStatusRecommendArtisModel.h"

@interface WeiboRecommendArtistManager () {
    NSMutableArray *weiboIds; // 记录当前抓取到的 weibo，用于去重
    NSMutableArray *needDeletes; // 需要删除收藏的微博 ID
    NSMutableString *recommendDesc;
    NSInteger fetchedPage;
    NSInteger fetchedCount;
}

@end

@implementation WeiboRecommendArtistManager

- (void)start {
    weiboIds = [NSMutableArray array];
    needDeletes = [NSMutableArray array];
    recommendDesc = [NSMutableString string];
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
            
            NSDictionary *sDict;
            if (statusDict[@"retweeted_status"]) {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict[@"retweeted_status"]];
            } else {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict];
            }
            
            MRBWeiboStatusRecommendArtisModel *model = [[MRBWeiboStatusRecommendArtisModel alloc] initWithDictionary:sDict];
            model.id_original_str = statusDict[@"idstr"];
            
            // 如果在当前抓取的流程中出现了重复的 id，那么跳过
            if ([self->weiboIds containsObject:model.id_str]) {
                continue;
            }
            
            // 如果没有查找到推荐内容，跳过
            if (model.recommendSites.count == 0) {
                continue;
            }
            
            if (![[MRBSQLiteFMDBManager defaultDBManager] isExistingWeiboRecommendArtist:model]) {
                [[MRBSQLiteFMDBManager defaultDBManager] insertSingleWeiboRecommendArtistWithWeiboStatus:model];
                
                self->fetchedCount += 1;
                [self->recommendDesc appendFormat:@"%@\n", model.recommendDescription];
            }
            
            [self->needDeletes addObject:model.id_original_str];
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
    [[MRBLogManager defaultManager] showLogWithFormat:@"一共抓取到 %ld 条微博推荐，去重后剩余 %ld 条，重复 %ld 条", needDeletes.count, fetchedCount, needDeletes.count - fetchedCount];
    
    if (needDeletes.count > 0) {
        [MRBUtilityManager exportArray:needDeletes atPath:weiboRemoveFavouriteTxtFilePath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"需要取消收藏的微博如下:\n%@", [MRBUtilityManager convertResultArray:needDeletes]];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有需要取消收藏的微博"];
    }
    
    if (fetchedCount > 0) {
        if (recommendDesc.length >= 1) {
            [recommendDesc deleteCharactersInRange:NSMakeRange(recommendDesc.length - 1, 1)];
        }
        
        [MRBUtilityManager exportString:recommendDesc atPath:weiboRecommendArtisTxtFilePath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"已获取到的推荐列表:\n%@", recommendDesc];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获取到推荐用户"];
    }
}

+ (void)destoryWeiboFavourites {
    NSString *weiboIdStr = [NSString stringWithContentsOfFile:weiboRemoveFavouriteTxtFilePath encoding:NSUTF8StringEncoding error:nil];
    if (weiboIdStr.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *weiboIds = [weiboIdStr componentsSeparatedByString:@"\n"];
    for (NSInteger i = 0; i < weiboIds.count; i++) {
        NSString *weiboId = weiboIds[i];
        [[MRBHttpManager sharedManager] deleteWeiboFavoriteWithId:weiboId start:NULL success:^(NSDictionary *dic) {
            BOOL isDeleteSuccess = [dic[@"favorited_time"] isKindOfClass:[NSString class]] && [dic[@"favorited_time"] length] > 0;
            BOOL isNotFavourite = dic[@"error_code"] && [dic[@"error_code"] isEqualToString:@"20705"];
            
            if (isDeleteSuccess || isNotFavourite) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 取消收藏成功", weiboId];
            } else {
                [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 取消收藏失败: %@", weiboId, dic[@"error"]];
            }
        } failed:^(NSString *errorTitle, NSString *errorMsg) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 取消收藏失败: %@", weiboId, errorMsg];
        }];
    }
}

@end
