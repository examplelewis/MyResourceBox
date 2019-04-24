//
//  GelbooruDownloadManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruDownloadManager.h"
#import "DownloadQueueManager.h"

@interface GelbooruDownloadManager () {
    NSString *txtFilePath;
    NSString *targetFolderPath;
    
    NSArray *urls;
}

@end

@implementation GelbooruDownloadManager

- (instancetype)initWithTXTFilePath:(NSString *)filePath targetFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        txtFilePath = filePath;
        targetFolderPath = folderPath;
    }
    
    return self;
}

- (void)prepareDownloading {
    if (![[FileManager defaultManager] isContentExistAtPath:txtFilePath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 不存在", txtFilePath.lastPathComponent];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gelbooruDownloadManagerDidFinishDownloading)]) {
            [self.delegate gelbooruDownloadManagerDidFinishDownloading];
        }
//        [self downloadAndOrganize];
        
        return;
    }
    
    NSString *url = [[NSString alloc] initWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    if (url.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件没有内容", txtFilePath.lastPathComponent];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gelbooruDownloadManagerDidFinishDownloading)]) {
            [self.delegate gelbooruDownloadManagerDidFinishDownloading];
        }
//        [self downloadAndOrganize];
        
        return;
    }
    urls = [url componentsSeparatedByString:@"\n"];
    NSOrderedSet *urlSet = [NSOrderedSet orderedSetWithArray:urls];
    urls = urlSet.array;
    
    [self startDownloading];
}
- (void)startDownloading {
    WS(weakSelf);
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:urls];
    manager.maxConcurrentOperationCount = 10;
    manager.maxRedownloadTimes = 1;
    manager.timeoutInterval = 15;
    manager.downloadPath = targetFolderPath;
    manager.finishBlock = ^{
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(gelbooruDownloadManagerDidFinishDownloading)]) {
            [weakSelf.delegate gelbooruDownloadManagerDidFinishDownloading];
        }
        //            [self downloadAndOrganize];
    };
    manager.showAlertAfterFinished = NO;
    
    [manager startDownload];
}

@end
