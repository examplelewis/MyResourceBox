//
//  PixivPicDownloadManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivPicDownloadManager.h"
#import "DownloadQueueManager.h"
#import "PixivAPI.h"

@implementation PixivPicDownloadManager

// 下载图片
+ (void)downloadPixivImage {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取Pixiv的图片地址：已经准备就绪"];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *images = [NSArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
    [[UtilityFile sharedInstance] showLogWithFormat:@"从输入框解析到%ld条图片地址\n", images.count];
    
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:images];
    manager.finishBlock = ^() {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"Pixiv图片资源已下载完成" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
    };
    manager.downloadPath = @"/Users/Mercury/Downloads/Pixiv";
    manager.httpHeaders = PIXIV_DEFAULT_HEADERS;
    [manager startDownload];
}

@end
