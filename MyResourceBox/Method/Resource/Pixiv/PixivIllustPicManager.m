//
//  PixivIllustPicManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivIllustPicManager.h"
#import "PixivIllustManager.h"
#import "PixivDownloadManager.h"

@interface PixivIllustPicManager ()

@property (nonatomic, copy) NSMutableArray *illusts; // illusts
@property (nonatomic, copy) NSMutableDictionary *results; // 下载文件夹
@property (nonatomic, copy) NSMutableArray *imgsUrl; // 下载地址
@property (nonatomic, copy) NSMutableArray *failures; // 获取失败的 用户 或者 illust 地址

@end

@implementation PixivIllustPicManager

// 获取illusts
- (void)prepareFetching {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取Pixiv的illust地址：已经准备就绪"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    _results = [NSMutableDictionary dictionary];
    _failures = [NSMutableArray array];
    _imgsUrl = [NSMutableArray array];
    
    _illusts = [NSMutableArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
    [[MRBLogManager defaultManager] showLogWithFormat:@"从输入框解析到%ld条网页\n", _illusts.count];
    
    [self fetchIllustInfo:NO];
}

// 获取illust
- (void)fetchIllustInfo:(BOOL)cleanFirstPage {
    if (cleanFirstPage) {
        [_illusts removeObjectAtIndex:0];
    }
    if (_illusts.count == 0) {
        [self startDownloading];
        return;
    }
    
    PixivIllustManager *manager = [[PixivIllustManager alloc] initWithWebpage:_illusts.firstObject];
    [manager fetchIllusts:^(BOOL success, NSString *errorMsg, NSDictionary *illusts) {
        if (!success) {
            [[MRBLogManager defaultManager] showLogWithFormat:errorMsg];
            [self->_failures addObject:illusts[@"webPage"]];
        } else {
            NSString *key = illusts.allKeys.firstObject;
            if ([self->_results.allKeys containsObject:key]) {
                NSArray *imgs = self->_results[key];
                imgs = [imgs arrayByAddingObjectsFromArray:illusts[key]];
                [self->_results setObject:imgs forKey:key];
            } else {
                [self->_results addEntriesFromDictionary:illusts];
            }
            [self->_imgsUrl addObjectsFromArray:[NSArray arrayWithArray:illusts.allValues.firstObject]];
        }
        
        [self fetchIllustInfo:YES];
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
