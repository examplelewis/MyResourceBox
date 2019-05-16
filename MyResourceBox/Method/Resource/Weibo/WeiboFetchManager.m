//
//  WeiboFetchManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "WeiboFetchManager.h"
#import "WeiboHeader.h"
#import "WeiboStatusObject.h"
#import "HttpManager.h"
#import "DownloadQueueManager.h"
#import "OrganizeManager.h"
#import "SQLiteFMDBManager.h"
#import "SQLiteManager.h"

@interface WeiboFetchManager () {
    NSMutableDictionary *weiboStatuses;
    NSMutableArray *weiboImages;
    NSMutableArray *weiboObjects;
    NSMutableArray *weiboIds; // 记录当前抓取到的 weibo，用于去重
    NSInteger fetchedPage;
    NSInteger fetchedCount;
}

@end

@implementation WeiboFetchManager

- (void)getFavorList {
    weiboStatuses = [NSMutableDictionary dictionary];
    weiboImages = [NSMutableArray array];
    weiboObjects = [NSMutableArray array];
    weiboIds = [NSMutableArray array];
    fetchedPage = 1;
    fetchedCount = 0;
    
    [self getFavouristByApi];
}
- (void)getFavouristByApi {
    [[HttpManager sharedManager] getWeiboFavoritesWithPage:fetchedPage start:nil success:^(NSDictionary *dic) {
        NSArray *favors = dic[@"favorites"];
        BOOL found = NO;
        
        for (NSInteger i = 0; i < favors.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:favors[i]];
            NSDictionary *statusDict = dict[@"status"];
            
            // 先判断是否已经到了边界微博，也就是第一条和资源不相关的微博
            if ([statusDict[@"idstr"] isEqualToString:[UserInfo defaultUser].weibo_boundary_id]) {
                found = YES;
                break;
            }
            
            self->fetchedCount += 1;
            
            NSDictionary *sDict;
            if (statusDict[@"retweeted_status"]) {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict[@"retweeted_status"]];
            } else {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict];
            }
            
            NSString *statusKey = @"";
            WeiboStatusObject *object = [[WeiboStatusObject alloc] initWithDictionary:sDict];
            
            // 如果在当前抓取的流程中出现了重复的 id，那么跳过
            if ([self->weiboIds containsObject:object.id_str]) {
                continue;
            }
            // 如果当前微博在数据库中有记录，那么跳过
            if ([[SQLiteFMDBManager defaultDBManager] isDuplicateFromDatabaseWithWeiboStatusId:object.id_str]) {
                continue;
            }
            
            // 根据 tag 和 微博 id_str 生成文件夹的名字
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#[^#]+#" options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray *results = [regex matchesInString:object.text options:0 range:NSMakeRange(0, object.text.length)];
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"正则解析微博文字中的标签出错，原因：%@", error.localizedDescription];
            }
            if (results.count == 0) {
                // 如果没有标签的话，截取前30个文字
                if (object.text.length <= 30) {
                    statusKey = [statusKey stringByAppendingFormat:@"【无标签】+%@+", object.text];
                } else {
                    statusKey = [statusKey stringByAppendingFormat:@"【无标签】+%@+", [object.text substringToIndex:30]];
                }
            } else {
                for (NSInteger i = 0; i < results.count; i++) {
                    NSTextCheckingResult *result = results[i];
                    NSString *hashtag = [object.text substringWithRange:result.range];
                    hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
                    statusKey = [statusKey stringByAppendingFormat:@"%@+", hashtag];
                }
            }
            statusKey = [statusKey stringByAppendingFormat:@"【%@-%@】", object.user_screen_name, object.created_at_readable_str];
            statusKey = [statusKey stringByReplacingOccurrencesOfString:@"/" withString:@" "]; // 防止有 / 出现
            
            [self->weiboIds addObject:object.id_str];
            [self->weiboObjects addObject:object];
            [self->weiboStatuses setObject:object.img_urls forKey:statusKey];
            [self->weiboImages addObjectsFromArray:object.img_urls];
        }
        
        // 如果找到了边界微博，或者一直没有找到，直到取到的微博数量小于50，代表着没有更多收藏微博了，即边界微博出错
        if (found || favors.count < 50) {
            [self exportResult];
        } else {
            self->fetchedPage += 1; // 计数
            [self getFavouristByApi];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取收藏列表接口发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}


#pragma mark -- 辅助方法 --
- (void)exportResult {
    [[UtilityFile sharedInstance] showLogWithFormat:@"一共抓取到 %ld 条微博，去重后剩余 %ld 条，重复 %ld 条", fetchedCount, weiboStatuses.count, fetchedCount - weiboStatuses.count];
    [[UtilityFile sharedInstance] showLogWithFormat:@"流程已经完成，共有 %ld 条微博的 %ld 条图片地址被获取到", weiboStatuses.count, weiboImages.count];
    
    if (weiboImages.count > 0) {
        DDLogInfo(@"图片地址是：%@", weiboImages);
        
        // 使用NSOrderedSet进行一次去重的操作
        NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:weiboImages];
        weiboImages = [NSMutableArray arrayWithArray:set.array];
        [UtilityFile exportArray:weiboImages atPath:weiboImageTxtFilePath];
        [weiboStatuses writeToFile:weiboStatusPlistFilePath atomically:YES];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"将获取到微博信息存储到数据库中"];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 往数据库里写入的时候，要按照获取的倒序，也就是最早收藏的微博排在最前
            NSArray *reversedArray = [[self->weiboObjects reverseObjectEnumerator] allObjects];
            [[SQLiteFMDBManager defaultDBManager] insertWeiboStatusIntoDatabase:reversedArray];
            [SQLiteManager backupDatabaseFile];
        });
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始下载图片"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
        });
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"未发现可下载的资源"];
    }
}
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:weiboImages];
    manager.downloadPath = @"/Users/Mercury/Downloads/微博";
    manager.finishBlock = ^{
        OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:weiboStatusPlistFilePath];
        [manager startOrganizing];
    };
    [manager startDownload];
}

@end
