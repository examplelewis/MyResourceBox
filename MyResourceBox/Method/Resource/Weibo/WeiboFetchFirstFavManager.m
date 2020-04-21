//
//  WeiboFetchFirstFavManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/21.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "WeiboFetchFirstFavManager.h"
#import "WeiboHeader.h"
#import "WeiboStatusObject.h"
#import "MRBHttpManager.h"
#import "MRBDownloadQueueManager.h"
#import "OrganizeManager.h"
#import "MRBSQLiteFMDBManager.h"
#import "MRBSQLiteManager.h"

@interface WeiboFetchFirstFavManager () {
    NSMutableDictionary *weiboStatuses;
    NSMutableArray *weiboImages;
    NSMutableArray *weiboObjects;
    NSMutableArray *weiboIds; // 记录当前抓取到的 weibo，用于去重
    NSInteger fetchedCount;
    NSInteger maxCount;
}

@end

@implementation WeiboFetchFirstFavManager

- (void)getFavorList {
    weiboStatuses = [NSMutableDictionary dictionary];
    weiboImages = [NSMutableArray array];
    weiboObjects = [NSMutableArray array];
    weiboIds = [NSMutableArray array];
    fetchedCount = 0;
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.integerValue <= 0 || input.integerValue > 50) {
        maxCount = 1;
    } else {
        maxCount = input.integerValue;
    }
    
    [self getFavouristByApi];
}
- (void)getFavouristByApi {
    [[MRBHttpManager sharedManager] getWeiboFavoritesWithPage:1 start:nil success:^(NSDictionary *dic) {
        NSArray *favors = dic[@"favorites"];
        for (NSInteger i = 0; i < favors.count; i++) {
            if (self->fetchedCount >= self->maxCount) {
                break;
            }
            
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:favors[i]];
            NSDictionary *statusDict = dict[@"status"];
            
            // 先判断是否已经到了边界微博，也就是第一条和资源不相关的微博
            if ([statusDict[@"idstr"] isEqualToString:[MRBUserManager defaultManager].weibo_boundary_id]) {
                break;
            }
            
            self->fetchedCount += 1;
            
            NSDictionary *sDict;
            if (statusDict[@"retweeted_status"]) {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict[@"retweeted_status"]];
            } else {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict];
            }
            
            WeiboStatusObject *object = [[WeiboStatusObject alloc] initWithDictionary:sDict];
            
            // 如果在当前抓取的流程中出现了重复的 id，那么跳过
            if ([self->weiboIds containsObject:object.id_str]) {
                continue;
            }
            // 如果当前微博在数据库中有记录，那么跳过
            if ([[MRBSQLiteFMDBManager defaultDBManager] isDuplicateFromDatabaseWithWeiboStatusId:object.id_str]) {
                continue;
            }
            
            NSString *statusKey = [self generateWeiboStatusFolderNameWithObject:object];
            
            [self->weiboIds addObject:object.id_str];
            [self->weiboObjects addObject:object];
            [self->weiboStatuses setObject:object.img_urls forKey:statusKey];
            [self->weiboImages addObjectsFromArray:object.img_urls];
        }
        
        [self exportResult];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取收藏列表接口发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}
- (NSString *)generateWeiboStatusFolderNameWithObject:(WeiboStatusObject *)object {
    // 1、先添加用户昵称
    NSString *statusKey = [NSString stringWithFormat:@"%@+", object.user_screen_name];
    
    // 2、添加标签以及文字
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#[^#]+#" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:object.text options:0 range:NSMakeRange(0, object.text.length)];
    if (error) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"正则解析微博文字中的标签出错，原因：%@", error.localizedDescription];
    }
    if (results.count == 0) {
        // 2.1、没有标签的话，截取前100个文字
        if (object.text.length <= 100) {
            statusKey = [statusKey stringByAppendingFormat:@"[无标签]+%@+", object.text];
        } else {
            statusKey = [statusKey stringByAppendingFormat:@"[无标签]+%@+", [object.text substringToIndex:100]];
        }
    } else {
        // 2.2.1、有标签的话，先添加所有标签
        for (NSInteger i = 0; i < results.count; i++) {
            NSTextCheckingResult *result = results[i];
            NSString *hashtag = [object.text substringWithRange:result.range];
            hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
            statusKey = [statusKey stringByAppendingFormat:@"%@+", hashtag];
        }
        
        // 2.2.2、再添加前60个文字
        NSString *noTagText = object.text;
        for (NSInteger i = results.count - 1; i >= 0; i--) {
            NSTextCheckingResult *result = results[i];
            noTagText = [noTagText stringByReplacingCharactersInRange:result.range withString:@""];
        }
        if (noTagText.length <= 60) {
            statusKey = [statusKey stringByAppendingFormat:@"%@+", noTagText];
        } else {
            statusKey = [statusKey stringByAppendingFormat:@"%@+", [noTagText substringToIndex:60]];
        }
    }
    
    // 3、添加微博发布时间
    statusKey = [statusKey stringByAppendingFormat:@"%@", object.created_at_readable_str];
    
    // 4、防止有 / 出现以及其他特殊字符
    statusKey = [statusKey stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    statusKey = [statusKey stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    return statusKey;
}

#pragma mark -- 辅助方法 --
- (void)exportResult {
    [[MRBLogManager defaultManager] showLogWithFormat:@"一共抓取到 %ld 条微博，去重后剩余 %ld 条，重复 %ld 条", fetchedCount, weiboStatuses.count, fetchedCount - weiboStatuses.count];
    [[MRBLogManager defaultManager] showLogWithFormat:@"流程已经完成，共有 %ld 条微博的 %ld 条图片地址被获取到", weiboStatuses.count, weiboImages.count];
    
    if (weiboImages.count > 0) {
        DDLogInfo(@"图片地址是：%@", weiboImages);
        
        // 使用NSOrderedSet进行一次去重的操作
        NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:weiboImages];
        weiboImages = [NSMutableArray arrayWithArray:set.array];
        [MRBUtilityManager exportArray:weiboImages atPath:weiboImageTxtFilePath];
        [weiboStatuses writeToFile:weiboStatusPlistFilePath atomically:YES];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"将获取到微博信息存储到数据库中"];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 往数据库里写入的时候，要按照获取的倒序，也就是最早收藏的微博排在最前
            NSArray *reversedArray = [[self->weiboObjects reverseObjectEnumerator] allObjects];
            [[MRBSQLiteFMDBManager defaultDBManager] insertWeiboStatusIntoDatabase:reversedArray];
            [MRBSQLiteManager backupDatabaseFile];
        });
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"1秒后开始下载图片"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
        });
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未发现可下载的资源"];
    }
}
- (void)startDownload {
    MRBDownloadQueueManager *manager = [[MRBDownloadQueueManager alloc] initWithUrls:weiboImages];
    manager.downloadPath = @"/Users/Mercury/Downloads/微博";
    manager.finishBlock = ^{
        OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:weiboStatusPlistFilePath];
        [manager startOrganizing];
    };
    [manager startDownload];
}

@end
