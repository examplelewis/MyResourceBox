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

@interface WeiboFetchManager () {
    NSMutableArray *weiboIds;
    NSMutableDictionary *weiboStatuses;
    NSMutableArray *weiboImages;
    NSInteger fetchedPage;
}

@end

@implementation WeiboFetchManager

- (void)getFavorList {
    weiboIds = [NSMutableArray array];
    weiboStatuses = [NSMutableDictionary dictionary];
    weiboImages = [NSMutableArray array];
    fetchedPage = 1;
    
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
            
            NSDictionary *sDict;
            if (statusDict[@"retweeted_status"]) {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict[@"retweeted_status"]];
            } else {
                sDict = [NSDictionary dictionaryWithDictionary:statusDict];
            }
            
            NSString *statusKey = @"";
            WeiboStatusObject *object = [[WeiboStatusObject alloc] initWithDictionary:sDict];
            
            // 如果当前微博已经被存储过的话，就忽略
            if ([self->weiboIds indexOfObject:object.id_str] != NSNotFound) {
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
    if (weiboImages.count > 0) {
        // 使用NSOrderedSet进行一次去重的操作
        NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:weiboImages];
        weiboImages = [NSMutableArray arrayWithArray:set.array];
        [UtilityFile exportArray:weiboImages atPath:weiboImageTxtFilePath];
        [weiboStatuses writeToFile:weiboStatusPlistFilePath atomically:YES];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"流程已经完成，共有 %ld 条微博的 %ld 条图片地址被获取到", weiboStatuses.count, weiboImages.count];
        DDLogInfo(@"图片地址是：%@", weiboImages);
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始下载图片"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
        });
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"未发现可下载的资源"];
        return;
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
