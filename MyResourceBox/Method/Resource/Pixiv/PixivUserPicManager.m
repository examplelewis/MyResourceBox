//
//  PixivUserPicManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivUserPicManager.h"
#import "PixivUserManager.h"
#import "PixivDownloadManager.h"

@interface PixivUserPicManager ()

@property (nonatomic, copy) NSMutableArray *users; // 用户
@property (nonatomic, copy) NSMutableArray *illusts; // illusts
@property (nonatomic, copy) NSMutableDictionary *results; // 下载文件夹
@property (nonatomic, copy) NSMutableArray *imgsUrl; // 下载地址
@property (nonatomic, copy) NSMutableArray *failures; // 获取失败的 用户 或者 illust 地址

@end

@implementation PixivUserPicManager

- (void)prepareFetching {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取Pixiv的User地址：已经准备就绪"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    _results = [NSMutableDictionary dictionary];
    _failures = [NSMutableArray array];
    _imgsUrl = [NSMutableArray array];
    
    _users = [NSMutableArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
    [[MRBLogManager defaultManager] showLogWithFormat:@"从输入框解析到%ld条网页\n", _users.count];
    
    [self fetchUserInfo:NO];
}

// 获取user
- (void)fetchUserInfo:(BOOL)cleanFirstPage {
    if (cleanFirstPage) {
        [_users removeObjectAtIndex:0];
    }
    if (_users.count == 0) {
        [self startDownloading];
        return;
    }
    
    PixivUserManager *manager = [[PixivUserManager alloc] initWithUserPage:_users.firstObject];
    [manager fetchUserIllusts:^(BOOL success, NSString *errorMsg, NSDictionary *illusts) {
        if (!success) {
            [[MRBLogManager defaultManager] showLogWithFormat:errorMsg];
            [self->_failures addObject:illusts[@"userPage"]];
        } else {
            [self->_results addEntriesFromDictionary:illusts];
            [self->_imgsUrl addObjectsFromArray:[NSArray arrayWithArray:illusts.allValues.firstObject]];
        }
    }];
}
// 获取完用户信息或者图片信息后开始下载
- (void)startDownloading {
    [UtilityFile exportArray:_imgsUrl atPath:@"/Users/Mercury/Downloads/PixivIllustURLs.txt"];
    [_results writeToFile:@"/Users/Mercury/Downloads/PixivIllustInfo.plist" atomically:YES];
    if (_failures.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有%ld个用户获取失败，请查看错误文件", _failures.count]; //获取失败的页面地址
        [UtilityFile exportArray:_failures atPath:@"/Users/Mercury/Downloads/PixivFailedURLs.txt"];
    }
    
    PixivDownloadManager *manager = [[PixivDownloadManager alloc] initWithResult:_results];
    [manager startDownload];
}

@end
