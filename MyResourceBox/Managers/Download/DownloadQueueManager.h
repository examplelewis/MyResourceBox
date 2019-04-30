//
//  DownloadQueueManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/07.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadQueueManager : NSObject

@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, copy) NSDictionary *httpHeaders;
@property (nonatomic, copy) void(^finishBlock)(void);
@property (nonatomic, copy) NSDictionary *renameInfo; // 格式: @{%url%: @"xxx.jpg"}

@property (nonatomic, assign) BOOL showAlertAfterFinished;
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;
@property (nonatomic, assign) NSInteger maxRedownloadTimes;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

- (instancetype)initWithUrls:(NSArray<NSString *> *)urls;
- (void)startDownload;

@end
