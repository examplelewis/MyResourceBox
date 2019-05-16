//
//  PixivDownloadManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/07.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "PixivDownloadManager.h"
#import "PixivDownloadObject.h"
#import "MRBDownloadQueueManager.h"
#import "PixivAPI.h"

@interface PixivDownloadManager () {
    NSMutableArray *lists;
}

@property (nonatomic, copy) NSDictionary *result;

@end

@implementation PixivDownloadManager

- (instancetype)initWithResult:(NSDictionary *)result {
    self = [super init];
    if (self) {
        _result = [NSDictionary dictionaryWithDictionary:result];
        lists = [NSMutableArray array];
        
        for (NSInteger i = 0; i < result.allKeys.count; i++) {
            NSString *title = result.allKeys[i];
            PixivDownloadObject *object = [PixivDownloadObject new];
            object.name = title;
            object.imgUrls = [NSArray arrayWithArray:result[title]];
            
            [lists addObject:object];
        }
    }
    
    return self;
}

- (void)startDownload {
    PixivDownloadObject *object = lists.firstObject;
    [[MRBLogManager defaultManager] showLogWithFormat:@"正在下载用户: %@ 的图片", object.name];
    
    MRBDownloadQueueManager *manager = [[MRBDownloadQueueManager alloc] initWithUrls:object.imgUrls];
    manager.finishBlock = ^() {
        PixivDownloadObject *object = self->lists.firstObject;
        [[MRBLogManager defaultManager] showLogWithFormat:@"用户: %@ 已经下载完成", object.name];
        
        [self->lists removeObjectAtIndex:0];
        if (self->lists.count == 0) {
            [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.25f];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishAllDonwload)]) {
                [self.delegate didFinishAllDonwload];
            }
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"1秒后开始下载下一个用户的图片"];
            [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0];
        }
    };
    manager.downloadPath = [@"/Users/Mercury/Downloads/Pixiv" stringByAppendingPathComponent:object.name];
    manager.httpHeaders = PIXIV_DEFAULT_HEADERS;
    [manager startDownload];
}

- (void)showAlert {
    MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
    [alert setMessage:@"Pixiv图片资源已下载完成" infomation:nil];
    [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
    [alert runModel];
}

@end
