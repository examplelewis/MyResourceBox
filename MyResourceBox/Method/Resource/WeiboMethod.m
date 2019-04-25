//
//  WeiboMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/07.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WeiboMethod.h"
#import "FileManager.h"
#import "WeiboStatusObject.h"
#import "HttpManager.h"
#import "OrganizeManager.h"
#import "DownloadQueueManager.h"

#import "WeiboTokenWindowController.h"
#import "WeiboRequestTokenWindowController.h"

@interface WeiboMethod () {
    NSMutableDictionary *weiboStatuses;
    NSMutableArray *weiboImages;
    NSInteger fetchedPage;
}

@end

static NSString * const weiboImageTxtFilePath = @"/Users/Mercury/Downloads/weiboImage.txt";
static NSString * const weiboStatusPlistFilePath = @"/Users/Mercury/Downloads/weiboStatuses.plist";

@implementation WeiboMethod

#pragma mark -- 生命周期方法 --
static WeiboMethod *method;
+ (WeiboMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[WeiboMethod alloc] init];
    });
    
    return method;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        weiboStatuses = [NSMutableDictionary dictionary];
        weiboImages = [NSMutableArray array];
        fetchedPage = 1;
    }
    
    return self;
}

- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1:
            [self getFavorList];
            break;
        case 2:
            [self organizeFavorImage];
            break;
        case 3:
            [self requestToken];
            break;
        case 4:
            [self showTokenInfo];
            break;
        case 5:
            [self getBoundaryID];
            break;
        case 6:
            [self markNewestFavorAsBoundary];
            break;
        default:
            break;
    }
}

#pragma mark -- 具体方法 --
- (void)requestToken {
    WeiboRequestTokenWindowController *wc = [[WeiboRequestTokenWindowController alloc] initWithWindowNibName:@"WeiboRequestTokenWindowController"];
    [[NSApplication sharedApplication].mainWindow addChildWindow:wc.window ordered:NSWindowAbove];
    [wc becomeFirstResponder];
    [wc showWindow:nil];
}
- (void)showTokenInfo {
    WeiboTokenWindowController *wc = [[WeiboTokenWindowController alloc] initWithWindowNibName:@"WeiboTokenWindowController"];
    [[NSApplication sharedApplication].mainWindow addChildWindow:wc.window ordered:NSWindowAbove];
    [wc becomeFirstResponder];
    [wc showWindow:nil];
}
- (void)getFavorList {
    [weiboStatuses removeAllObjects];
    [weiboImages removeAllObjects];
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
- (void)organizeFavorImage {
    OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:weiboStatusPlistFilePath];
    [manager startOrganizing];
}

@end
