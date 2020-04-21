//
//  ExHentaiManager.m
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ExHentaiManager.h"

#import "MRBCookieManager.h"
#import "MRBDownloadQueueManager.h"
#import "ExHentaiPagesManager.h"
#import "ExHentaiUrlsManager.h"
#import "ExHentaiTorrentManager.h"
#import "ExHentaiPixivUrlsManager.h"

@interface ExHentaiManager () <ExHentaiPagesDelegate, ExHentaiUrlsDelegate, ExHentaiTorrentDelegate, ExHentaiPixivUrlsDelegate> {
    ExHentaiPagesManager *pagesManager;
    ExHentaiUrlsManager *urlsManager;
    ExHentaiTorrentManager *torrentManager;
    ExHentaiPixivUrlsManager *pixivUrlsManager;
}

@end

@implementation ExHentaiManager

static ExHentaiManager *manager;
+ (ExHentaiManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ExHentaiManager alloc] init];
    });
    
    return manager;
}
- (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1: {
            [self getImage];
        }
            break;
        case 2: {
            [self parsePages];
        }
            break;
        case 3: {
            [self parseTorrent];
        }
            break;
        case 4: {
            [self parsePixivUrls];
        }
            break;
        case 5: {
            
        }
            break;
        default:
            break;
    }
}

- (void)getImage {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取E-Hentai的图片地址：已经准备就绪"];
    
    MRBCookieManager *manager = [[MRBCookieManager alloc] initWithCookieFileType:CookieFileTypeExHentai];
    [manager deleteCookieByName:@"yay"];
    [manager writeCookiesIntoHTTPStorage];
    
    NSString *homepage = [AppDelegate defaultVC].inputTextView.string;
    if (!homepage || homepage.length == 0) {
        [[MRBLogManager defaultManager] showLogWithTitle:@"错误" andFormat:@"没有从inputView中获取到数据"];
        return;
    }
    
    pagesManager = [[ExHentaiPagesManager alloc] initWithHomepage:homepage];
    pagesManager.delegate = self;
    [pagesManager startFetching];
}
- (void)parsePages {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取E-Hentai的图片地址：已经准备就绪"];
    
    NSString *content = [AppDelegate defaultVC].inputTextView.string;
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    urlsManager = [[ExHentaiUrlsManager alloc] initWithUrls:components];
    urlsManager.delegate = self;
    [urlsManager startFetching];
}
- (void)parseTorrent {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取E-Hentai的种子文件地址：已经准备就绪"];
    
    MRBCookieManager *manager = [[MRBCookieManager alloc] initWithCookieFileType:CookieFileTypeExHentai];
    [manager deleteCookieByName:@"yay"];
    [manager writeCookiesIntoHTTPStorage];
    
    NSString *content = [AppDelegate defaultVC].inputTextView.string;
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    torrentManager = [[ExHentaiTorrentManager alloc] initWithUrls:components];
    torrentManager.delegate = self;
    [torrentManager startFetching];
}
- (void)parsePixivUrls {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取E-Hentai的Pixiv地址：已经准备就绪"];
    
    MRBCookieManager *manager = [[MRBCookieManager alloc] initWithCookieFileType:CookieFileTypeExHentai];
    [manager deleteCookieByName:@"yay"];
    [manager writeCookiesIntoHTTPStorage];
    
    NSString *homepage = [AppDelegate defaultVC].inputTextView.string;
    if (!homepage || homepage.length == 0) {
        [[MRBLogManager defaultManager] showLogWithTitle:@"错误" andFormat:@"没有从inputView中获取到数据"];
        return;
    }
    
    NSString *content = [AppDelegate defaultVC].inputTextView.string;
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    pixivUrlsManager = [[ExHentaiPixivUrlsManager alloc] initWithUrls:components];
    pixivUrlsManager.delegate = self;
    [pixivUrlsManager startFetching];
}

#pragma mark -- 委托方法 --
// ExHentaiPagesDelegate
- (void)didGetAllUrls:(NSArray<NSString *> *)urls error:(NSError *)error {
    NSArray *newUrls = [NSSet setWithArray:urls].allObjects;
    urlsManager = [[ExHentaiUrlsManager alloc] initWithUrls:newUrls];
    urlsManager.delegate = self;
    [urlsManager startFetching];
}
// ExHentaiUrlsDelegate
- (void)didGetAllImageUrls:(NSArray<NSString *> *)imageUrls error:(NSError *)error {
    if (imageUrls.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获取到可用的图片地址，流程结束"];
    } else {
        MRBDownloadQueueManager *manager = [[MRBDownloadQueueManager alloc] initWithUrls:imageUrls];
        if (pagesManager.title) {
            manager.downloadPath = [@"/Users/Mercury/Downloads/ExHentai" stringByAppendingPathComponent:pagesManager.title];
        }
        [manager startDownload];
    }
}
// ExHentaiTorrentDelegate
- (void)didGetAllTorrents:(NSArray *)torrents error:(NSError *)error {
    
}
// ExHentaiPixivUrlsDelegate
- (void)didGetAllPixivUrls:(NSArray<NSString *> *)pixivUrls error:(NSError *)error {
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取E-Hentai的资源地址：流程结束"];
}

@end
