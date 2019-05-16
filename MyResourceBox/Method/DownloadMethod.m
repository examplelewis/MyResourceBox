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

@end
