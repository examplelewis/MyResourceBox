//
//  ResourceGlobalDownloadManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/13.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ResourceGlobalDownloadManager.h"
#import "DownloadQueueManager.h"

@interface ResourceGlobalDownloadManager () {
    NSString *txtFilePath;
    NSString *targetFolderPath;
    
    NSArray *urls;
}

@end

@implementation ResourceGlobalDownloadManager

- (instancetype)initWithTXTFilePath:(NSString *)filePath targetFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        txtFilePath = filePath;
        targetFolderPath = folderPath;
        _showAlertAfterFinished = NO;
    }
    
    return self;
}

- (void)prepareDownloading {
    if (![[MRBFileManager defaultManager] isContentExistAtPath:txtFilePath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 不存在", txtFilePath.lastPathComponent];
        if (self.finishBlock) {
            self.finishBlock();
        }
        
        return;
    }
    
    NSString *url = [[NSString alloc] initWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    if (url.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 文件没有内容", txtFilePath.lastPathComponent];
        if (self.finishBlock) {
            self.finishBlock();
        }
        
        return;
    }
    urls = [url componentsSeparatedByString:@"\n"];
    NSOrderedSet *urlSet = [NSOrderedSet orderedSetWithArray:urls];
    urls = urlSet.array;
    
    [self startDownloading];
}
- (void)startDownloading {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:urls];
    manager.maxConcurrentOperationCount = 3;
    manager.maxRedownloadTimes = 1;
    manager.timeoutInterval = 15;
    manager.downloadPath = targetFolderPath;
    manager.finishBlock = ^{
        if (self.finishBlock) {
            self.finishBlock();
        }
    };
    manager.showAlertAfterFinished = self.showAlertAfterFinished;
    
    [manager startDownload];
}

@end
