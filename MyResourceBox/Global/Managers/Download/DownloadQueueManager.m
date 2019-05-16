//
//  DownloadQueueManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/07.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "DownloadQueueManager.h"
#import "DownloadOperation.h"
#import "DownloadInfoObject.h"

static NSInteger const defaultMaxRedownloadTimes = 3;
static NSInteger const defaultMaxConcurrentOperationCount = 15;
static NSInteger const defaultTimeoutInterval = 45;

@interface DownloadQueueManager () {
    AFURLSessionManager *manager;
    
    NSInteger success;
    NSInteger failure;
    NSInteger redownloadTimes;
    
    NSArray<NSString *> *downloadUrls;
    NSMutableArray<NSError *> *downloadErrors;
    NSMutableArray *downloadResults;
}

@property (nonatomic, strong) NSOperationQueue *opQueue;

@end

@implementation DownloadQueueManager

- (instancetype)initWithUrls:(NSArray<NSString *> *)urls {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        downloadUrls = [NSArray arrayWithArray:urls];
        downloadErrors = [NSMutableArray array];
        downloadResults = [NSMutableArray array];
        
        success = 0;
        failure = 0;
        redownloadTimes = 0;
        _downloadPath = @"/Users/Mercury/Downloads";
        
        _showAlertAfterFinished = YES;
        _maxConcurrentOperationCount = defaultMaxConcurrentOperationCount;
        _maxRedownloadTimes = defaultMaxRedownloadTimes;
        _timeoutInterval = defaultTimeoutInterval;
    }
    
    return self;
}

- (NSString *)getTargetFileNameWithUrl:(NSString *)url {
    NSString *targetFileName = nil;
    if (self.renameInfo) {
        targetFileName = self.renameInfo[url];
        
        if (!targetFileName || ![targetFileName isKindOfClass:[NSString class]] || targetFileName.length == 0) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 对应的文件名无效。使用 [response suggestedFilename]", url];
            targetFileName = nil;
        }
    }
    
    return targetFileName;
}
- (NSString *)getTargetFilePathWithUrl:(NSString *)url {
    NSString *targetFileName = [self getTargetFileNameWithUrl:url];
    if (!targetFileName) {
        return nil;
    } else {
        return [self.downloadPath stringByAppendingPathComponent:targetFileName];
    }
}

- (NSURLSessionDownloadTask *)downloadTaskWithUrl:(NSString *)url completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = _timeoutInterval;
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    if (self.httpHeaders) {
        for (NSString *key in self.httpHeaders) {
            [request setValue:self.httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    NSString *targetFileName = [self getTargetFileNameWithUrl:url];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *filePath = [self.downloadPath stringByAppendingPathComponent:targetFileName ? targetFileName : [response suggestedFilename]];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:completionBlock];
    
    return downloadTask;
}

- (void)startDownload {
    success = 0;
    failure = 0;
    [downloadResults removeAllObjects];
    [downloadErrors removeAllObjects];
    
    [AppDelegate defaultVC].progress.doubleValue = 0.0f;
    [[MRBLogManager defaultManager] showLogWithFormat:@"下载开始，共 %ld 个文件", downloadUrls.count];
    
    _opQueue = [NSOperationQueue new];
    _opQueue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
    
    // 准备保存结果的数组，元素个数与下载地址的个数相同，先用 NSNull 占位
    for (NSInteger i = 0; i < downloadUrls.count; i++) {
        [downloadResults addObject:[NSNull null]];
    }
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // 回到主线程执行，方便更新 UI 等
            [self performSelector:@selector(didFinishAllOperations) withObject:nil afterDelay:0.1f];
        }];
    }];
    
    for (NSInteger i = 0; i < downloadUrls.count; i++) {
        NSString *downloadUrl = downloadUrls[i];
//        NSString *targetFilePath = [self getTargetFilePathWithUrl:downloadUrl];
//        if (targetFilePath && [[FileManager defaultManager] isContentExistAtPath:targetFilePath]) {
//            [[MRBLogManager defaultManager] showLogWithFormat:@"在 %@ 位置已经存在同名文件，跳过 %@ 文件的下载", targetFilePath, downloadUrl];
//
//            success++;
//            @synchronized (downloadResults) { // NSMutableArray 是线程不安全的，所以加个同步锁
//                downloadResults[i] = targetFilePath;
//            }
//
//            NSInteger download = success + failure;
//            float doubleDownload = (float)download;
//            float doubleTotal = (float)downloadUrls.count;
//            [AppDelegate defaultVC].numberLabel.stringValue = [NSString stringWithFormat:@"已下载：%ld / %ld，成功：%ld，失败：%ld", download, downloadUrls.count, success, failure];
//            [AppDelegate defaultVC].progress.doubleValue = doubleDownload / doubleTotal * 100.0;
//
//            continue;
//        }
        
        NSURLSessionDownloadTask* uploadTask = [self downloadTaskWithUrl:downloadUrl completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                DownloadInfoObject *object = [[DownloadInfoObject alloc] initWithError:error];
                if (object.type == DownloadInfoTypeErrorConnectionLost) {
                    [[MRBLogManager defaultManager] showLogWithFormat:@"文件:%@ 下载失败:%@", self->downloadUrls[i], error.localizedDescription];
                } else {
                    [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 下载失败且无法重新下载", self->downloadUrls[i]];
                }
                
                self->failure++;
                @synchronized (self->downloadResults) { // NSMutableArray 是线程不安全的，所以加个同步锁
                    self->downloadResults[i] = object;
                }
            } else {
                self->success++;
                @synchronized (self->downloadResults) { // NSMutableArray 是线程不安全的，所以加个同步锁
                    self->downloadResults[i] = filePath;
                }
            }
            
            NSInteger download = self->success + self->failure;
            float doubleDownload = (float)download;
            float doubleTotal = (float)self->downloadUrls.count;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [AppDelegate defaultVC].numberLabel.stringValue = [NSString stringWithFormat:@"已下载：%ld / %ld，成功：%ld，失败：%ld", download, self->downloadUrls.count, self->success, self->failure];
                [AppDelegate defaultVC].progress.doubleValue = doubleDownload / doubleTotal * 100.0;
            }];
        }];
        
        DownloadOperation *operation = [DownloadOperation operationWithURLSessionTask:uploadTask];
        [completionOperation addDependency:operation];
        [_opQueue addOperation:operation];
    }
    
    [_opQueue addOperation:completionOperation];
}

- (void)didFinishAllOperations {
    NSPredicate *errorPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isMemberOfClass:[DownloadInfoObject class]];
    }];
    NSArray *downloadErrors = [downloadResults filteredArrayUsingPredicate:errorPredicate];
    
//    NSPredicate *redownloadPredicate = [NSPredicate predicateWithBlock:^BOOL(DownloadInfoObject *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
//        return evaluatedObject.type == DownloadInfoTypeErrorConnectionLost;
//    }];
//    NSArray *redownloads = [objects filteredArrayUsingPredicate:redownloadPredicate];
//    NSPredicate *cannotDownloadPredicate = [NSPredicate predicateWithBlock:^BOOL(DownloadInfoObject *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
//        return evaluatedObject.type != DownloadInfoTypeErrorConnectionLost;
//    }];
//    NSArray *cannotDownloads = [downloadErrors filteredArrayUsingPredicate:cannotDownloadPredicate];
//    NSArray *cannotUrls = [NSArray arrayWithArray:[cannotDownloads valueForKeyPath:@"url"]];
    
    downloadUrls = [NSArray arrayWithArray:[downloadErrors valueForKeyPath:@"url"]]; // 原本是 [redownloads valueForKeyPath:@"url"]；不过现在下载失败之后，全部重新下载
    
    NSString *failurePath = @"/Users/Mercury/Downloads/DownloadFailure.txt";
    if (![_downloadPath isEqualToString:@"/Users/Mercury/Downloads"]) {
        NSString *suffix = [_downloadPath stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@""];
        suffix = [suffix stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        failurePath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/DownloadFailure_%@.txt", suffix];
    }
    
    if (downloadUrls.count > 0 && redownloadTimes < _maxRedownloadTimes) {
        // 导出之前失败的内容
        [UtilityFile exportArray:downloadUrls atPath:failurePath];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"1秒后重新下载失败的图片"];
        [self performSelector:@selector(redownloadFailure) withObject:nil afterDelay:1.0f];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"下载完成"];
        if (downloadUrls.count > 0) {
            [UtilityFile exportArray:downloadUrls atPath:failurePath];
            [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 个文件仍然无法下载，列表已导出到下载文件夹中的 %@ 文件中", downloadUrls.count, failurePath.lastPathComponent];
        }
        
        if (self.showAlertAfterFinished) {
            [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.25f];
        }
        
        if (self.finishBlock) {
            self.finishBlock();
        }
    }
}

- (void)redownloadFailure {
    redownloadTimes++;
    [[MRBLogManager defaultManager] showLogWithFormat:@"第%ld次重新下载失败的图片，共%ld个文件", redownloadTimes, downloadUrls.count];
    
    [self startDownload];
}

- (void)showAlert {
    MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
    [alert setMessage:@"输入的资源已下载完成" infomation:nil];
    [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
    [alert runModel];
}

- (void)setDownloadPath:(NSString *)downloadPath {
    _downloadPath = downloadPath;
    
    // 如果目标文件夹不存在，那么创建该文件夹
    FileManager *fm = [FileManager defaultManager];
    if (![fm isContentExistAtPath:downloadPath]) {
        [fm createFolderAtPathIfNotExist:downloadPath];
    }
}

@end
