//
//  MRBSitesImageDownloadManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/22.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageDownloadManager.h"
#import "MRBDownloadQueueManager.h"

@interface MRBSitesImageDownloadManager () {
    NSMutableArray<MRBDownloadQueueManager *> *managers;
    NSInteger downloading;
}

@end

@implementation MRBSitesImageDownloadManager

- (instancetype)init {
    self = [super init];
    if (self) {
        managers = [NSMutableArray array];
        downloading = 0;
    }
    
    return self;
}

- (void)chooseDownloadedFiles {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择包含下载列表的 txt 文件的根目录"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择的根目录：%@", panel.URLs.firstObject);
                
                NSString *rootFolder = [panel.URLs.firstObject.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                [self startDownloadFromRootFolder:rootFolder];
            });
        }
    }];
}

- (void)startDownloadFromRootFolder:(NSString *)rootFolder {
    WS(weakSelf);
    
    NSString *rootImageFolder = [rootFolder.stringByDeletingLastPathComponent stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ 下载图片", rootFolder.lastPathComponent.stringByDeletingPathExtension]];
    [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:rootImageFolder];
    
    NSArray *allTxtFilePaths = [[MRBFileManager defaultManager] getSubFilePathsInFolder:rootFolder specificExtensions:@[@"txt"]];
    for (NSInteger i = 0; i < allTxtFilePaths.count; i++) {
        NSString *txtFilePath = allTxtFilePaths[i];
        
        // 下载具体图片的父文件夹
        NSString *targetImageFolderPath = [txtFilePath stringByDeletingPathExtension];
        targetImageFolderPath = [targetImageFolderPath stringByReplacingOccurrencesOfString:@"Rule34 " withString:@""];
        targetImageFolderPath = [targetImageFolderPath stringByReplacingOccurrencesOfString:@"Gelbooru " withString:@""];
        targetImageFolderPath = [targetImageFolderPath stringByReplacingOccurrencesOfString:rootFolder withString:rootImageFolder];
        
        NSString *urlStr = [[NSString alloc] initWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
        MRBDownloadQueueManager *manager = [[MRBDownloadQueueManager alloc] initWithUrls:[urlStr componentsSeparatedByString:@"\n"]];
        manager.maxConcurrentOperationCount = 3;
        manager.maxRedownloadTimes = 1;
        manager.timeoutInterval = 15;
        manager.downloadPath = targetImageFolderPath;
        manager.finishBlock = ^{
            [weakSelf startSignleDownload];
        };
        manager.showAlertAfterFinished = NO;
        
        [managers addObject:manager];
    }
    
    [self startSignleDownload];
}

- (void)startSignleDownload {
    if (downloading > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"MRBSitesImageDownloadManager 已经下载第 %ld 个 txt 文件内的资源", downloading];
    }
    
    if (downloading >= managers.count) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"MRBSitesImageDownloadManager 所有 txt 文件内的资源已下载完成"];
    } else {
        MRBDownloadQueueManager *manager = managers[downloading];
        [manager startDownload];
        
        downloading += 1;
        [[MRBLogManager defaultManager] showLogWithFormat:@"MRBSitesImageDownloadManager 即将下载第 %ld 个 txt 文件内的资源", downloading];
    }
}

@end
