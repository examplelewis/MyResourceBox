//
//  DownloadMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "DownloadMethod.h"
#import "DownloadQueueManager.h"

@interface DownloadMethod ()

@end

@implementation DownloadMethod

#pragma mark -- 生命周期方法 --
static DownloadMethod *method;
+ (DownloadMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[DownloadMethod alloc] init];
    });
    
    return method;
}

- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    NSArray *inputs = [input componentsSeparatedByString:@"\n"];
    NSSet *inputSet = [NSSet setWithArray:inputs];
    NSArray *newInputs = [NSArray arrayWithArray:inputSet.allObjects];
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:newInputs];
    
    switch (cellRow) {
        case 1: // 默认设置
            break;
        case 2: // 自定义设置
            break;
        case 3: { // 同时下载1个【同步下载】
            manager.maxConcurrentOperationCount = 1;
            manager.maxRedownloadTimes = 1;
            manager.timeoutInterval = 30;
        }
            break;
        case 4: { // 同时下载5个
            manager.maxConcurrentOperationCount = 5;
            manager.maxRedownloadTimes = 1;
            manager.timeoutInterval = 30;
        }
            break;
        case 5: { // 同时下载10个
            manager.maxConcurrentOperationCount = 10;
            manager.maxRedownloadTimes = 1;
            manager.timeoutInterval = 30;
        }
            break;
        case 6: { // 适用于 视频
            manager.maxConcurrentOperationCount = 5;
            manager.maxRedownloadTimes = 2;
            manager.timeoutInterval = 45;
        }
            break;
        default:
            break;
    }
    
    [manager startDownload];
}

@end
