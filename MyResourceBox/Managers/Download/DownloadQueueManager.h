//
//  DownloadQueueManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/07.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadQueueManager : NSObject

@property (copy) NSString *downloadPath;
@property (copy) NSDictionary *httpHeaders;
@property (copy) void(^finishBlock)(void);

@property (assign) BOOL showAlertAfterFinished;
@property (assign) NSInteger maxConcurrentOperationCount;
@property (assign) NSInteger maxRedownloadTimes;
@property (assign) NSTimeInterval timeoutInterval;

- (instancetype)initWithUrls:(NSArray<NSString *> *)urls;
- (void)startDownload;

@end
