//
//  DownloadMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "DownloadMethod.h"
#import "MRBDownloadQueueManager.h"

@interface DownloadMethod ()

@end

@implementation DownloadMethod

+ (void)configMethod:(NSInteger)cellRow {
    if (cellRow == 31) {
        [self createDownloadQueueByTXTFile];
        return;
    }
    
    [MRBLogManager resetCurrentDate];
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    NSArray *inputs = [input componentsSeparatedByString:@"\n"];
    NSSet *inputSet = [NSSet setWithArray:inputs];
    NSArray *newInputs = [NSArray arrayWithArray:inputSet.allObjects];
    MRBDownloadQueueManager *manager = [[MRBDownloadQueueManager alloc] initWithUrls:newInputs];
    
    switch (cellRow) {
        case 1: // 默认设置
            break;
        case 2: // 自定义设置
            break;
        case 11: { // 同时下载1个【同步下载】
            manager.maxConcurrentOperationCount = 1;
            manager.maxRedownloadTimes = 1;
            manager.timeoutInterval = 30;
        }
            break;
        case 12: { // 同时下载5个
            manager.maxConcurrentOperationCount = 5;
            manager.maxRedownloadTimes = 1;
            manager.timeoutInterval = 30;
        }
            break;
        case 13: { // 同时下载10个
            manager.maxConcurrentOperationCount = 10;
            manager.maxRedownloadTimes = 1;
            manager.timeoutInterval = 30;
        }
            break;
        case 21: { // 适用于 视频
            manager.maxConcurrentOperationCount = 5;
            manager.maxRedownloadTimes = 2;
            manager.timeoutInterval = 45;
        }
            break;
        case 22: { // 适用于 Gelbooru
            manager.maxConcurrentOperationCount = 3;
            manager.maxRedownloadTimes = 2;
            manager.timeoutInterval = 15;
        }
            break;
        default:
            break;
    }
    
    [manager startDownload];
}
+ (void)createDownloadQueueByTXTFile {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择包含下载列表的 txt 文件"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = NO;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = NO;
    panel.allowedFileTypes = @[@"txt"];
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择的 txt 文件：%@", panel.URLs.firstObject);
                
                NSString *txtFilePath = panel.URLs.firstObject.absoluteString;
                txtFilePath = [txtFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                NSString *downloadStr = [[NSString alloc] initWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
                NSArray *downloadList = [downloadStr componentsSeparatedByString:@"\n"];
                
                MRBDownloadQueueManager *manager = [[MRBDownloadQueueManager alloc] initWithUrls:downloadList];
                manager.maxConcurrentOperationCount = 10;
                manager.maxRedownloadTimes = 1;
                manager.timeoutInterval = 30;
                manager.downloadPath = txtFilePath.stringByDeletingPathExtension;
                
                [manager startDownload];
            });
        }
    }];
}

@end
