//
//  MRBSitesImageDownloadManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageDownloadManager.h"
#import "MRBHttpManager.h"
#import <NSDate+DateTools.h>

static NSInteger const MRBSitesImageMaxFetchWrongTimes = 3;

typedef NS_ENUM(NSUInteger, MRBSitesImageDownloadAction) {
    MRBSitesImageDownloadActionContinue,
    MRBSitesImageDownloadActionNext,
    MRBSitesImageDownloadActionDone
};

@interface MRBSitesImageDownloadManager () {
    NSInteger currentPage;
    
    NSMutableArray *posts;
    NSMutableArray *webmPosts;
    
    NSDateFormatter *formatter;
    
    NSInteger apiWrongTimes;
}

@property (strong) MRBSitesImageDownloadModel *model;

@end

@implementation MRBSitesImageDownloadManager

#pragma mark - Lifecycle
- (instancetype)initWithModel:(MRBSitesImageDownloadModel *)model {
    self = [super init];
    if (self) {
        self.model = model;
        
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
        
        apiWrongTimes = 0;
    }
    
    return self;
}

#pragma mark - Fetch Picture
- (void)prepareFetching {
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取特定标签的图片地址，流程开始"];
    
    posts = [NSMutableArray array];
    webmPosts = [NSMutableArray array];
    
    if (_model.mode == 13) {
        currentPage = _model.inputStart - 1;
    } else {
        currentPage = 0;
    }
    
    [self fetchSinglePost];
}
- (void)fetchSinglePost {
    WS(weakSelf);
    [[MRBHttpManager sharedManager] getResourceSitesPostsWithUrl:self.model.url tag:self.model.keyword page:currentPage success:^(NSArray *array) {
        SS(strongSelf);
        
        MRBSitesImageDownloadAction action = [strongSelf actionForThisPageWithResults:array];
        
        switch (action) {
            case MRBSitesImageDownloadActionNext: {
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", strongSelf.model.keyword, strongSelf->currentPage + 1];
                
                strongSelf->currentPage += 1;
                [strongSelf fetchSinglePost];
            }
                break;
            case MRBSitesImageDownloadActionContinue: {
                [strongSelf parseFetchedResults:array];
                
                strongSelf->currentPage += 1;
                [strongSelf fetchSinglePost];
            }
                break;
            case MRBSitesImageDownloadActionDone: {
                [strongSelf fetchSucceed];
            }
                break;
            default:
                break;
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        SS(strongSelf);
        
        if (strongSelf->apiWrongTimes >= MRBSitesImageMaxFetchWrongTimes) {
            strongSelf->apiWrongTimes = 0; // 重置错误计数
            
            DDLogError(@"%@: %@", errorTitle, errorMsg);
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取特定标签的图片地址，遇到错误：%@: %@", errorTitle, errorMsg];
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取特定标签的图片地址，当前获取页码: %ld, 当前Model: %@", strongSelf->currentPage, strongSelf.model];
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：流程结束", strongSelf.model.keyword];
        } else {
            strongSelf->apiWrongTimes += 1;
            [strongSelf fetchSinglePost];
        }
    }];
}
- (MRBSitesImageDownloadAction)actionForThisPageWithResults:(NSArray *)array {
    // 如果某一页小于100条原始数据，说明是最后一页
    if (array.count != 100) {
        return MRBSitesImageDownloadActionDone;
    }
    
    // API 限制 1000 页
    if (currentPage >= 1000) {
        return MRBSitesImageDownloadActionDone;
    }
    
    switch (self.model.mode) {
        case 10: {
            return MRBSitesImageDownloadActionContinue;
        }
            break;
        case 11: {
            if ([array.lastObject[@"id"] integerValue] > self.model.inputEnd) {
                return MRBSitesImageDownloadActionNext;
            } else if ([array.firstObject[@"id"] integerValue] < self.model.inputStart) {
                return MRBSitesImageDownloadActionDone;
            } else {
                return MRBSitesImageDownloadActionContinue;
            }
        }
            break;
        case 12: {
            NSDate *firstCreatedAt = [formatter dateFromString:array.firstObject[@"created_at"]];
            NSDate *lastCreatedAt = [formatter dateFromString:array.lastObject[@"created_at"]];
            
            if ([lastCreatedAt isLaterThan:self.model.inputEndDate]) {
                return MRBSitesImageDownloadActionNext;
            } else if ([firstCreatedAt isEarlierThan:self.model.inputStartDate]) {
                return MRBSitesImageDownloadActionDone;
            } else {
                return MRBSitesImageDownloadActionContinue;
            }
        }
            break;
        case 13: {
            if (currentPage < self.model.inputStart) {
                return MRBSitesImageDownloadActionNext;
            } else if (currentPage > self.model.inputEnd) {
                return MRBSitesImageDownloadActionDone;
            } else {
                return MRBSitesImageDownloadActionContinue;
            }
        }
            break;
        default: {
            return MRBSitesImageDownloadActionDone;
        }
            break;
    }
}
- (void)parseFetchedResults:(NSArray *)array {
    // Filter
    for (NSInteger i = 0; i < array.count; i++) {
        NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
        MRBSitesImageDownloadAction action = [self actionForThisPostWithDictionary:data];
        if (action == MRBSitesImageDownloadActionNext) {
            continue;
        } else if (action == MRBSitesImageDownloadActionContinue) {
            // 忽略 webm 文件
            if ([[data[@"file_url"] pathExtension] isEqualToString:@"webm"]) {
                [webmPosts addObject:data];
                continue;
            }
            
            // 小于 801 * 801 的非 gif 文件将被忽略
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801 && ![[data[@"file_url"] pathExtension] isEqualToString:@"gif"]) {
                continue;
            }
            
            [posts addObject:data];
        } else {
            break;
        }
    }
    
    // Export
    if (webmPosts.count > 0) {
        NSArray *webmIds = [webmPosts valueForKey:@"id"];
        NSMutableArray *webmUrls = [NSMutableArray array];
        for (NSInteger i = 0; i < webmIds.count; i++) {
            [webmUrls addObject:[NSString stringWithFormat:@"https://rule34.xxx/index.php?page=post&s=view&id=%@", webmIds[i]]];
        }
        [MRBUtilityManager exportArray:webmUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ WebmUrl.txt", self.model.keyword]];
        
        NSArray *webmFileUrls = [webmPosts valueForKey:@"file_url"];
        [MRBUtilityManager exportArray:webmFileUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ WebmPostUrl.txt", self.model.keyword]];
    }
    
    NSArray *urls = [posts valueForKey:@"file_url"];
    [MRBUtilityManager exportArray:urls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ PostUrl.txt", self.model.keyword]];
    
    // Log
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", self.model.keyword, currentPage + 1];
}
- (MRBSitesImageDownloadAction)actionForThisPostWithDictionary:(NSDictionary *)data {
    switch (self.model.mode) {
        case 10: {
            return MRBSitesImageDownloadActionContinue;
        }
            break;
        case 11: {
            if ([data[@"id"] integerValue] > self.model.inputEnd) {
                return MRBSitesImageDownloadActionNext;
            } else if ([data[@"id"] integerValue] < self.model.inputStart) {
                return MRBSitesImageDownloadActionDone;
            } else {
                return MRBSitesImageDownloadActionContinue;
            }
        }
            break;
        case 12: {
            NSDate *createdAt = [formatter dateFromString:data[@"created_at"]];
            
            if ([createdAt isLaterThan:self.model.inputEndDate]) {
                return MRBSitesImageDownloadActionNext;
            } else if ([createdAt isEarlierThan:self.model.inputStartDate]) {
                return MRBSitesImageDownloadActionDone;
            } else {
                return MRBSitesImageDownloadActionContinue;
            }
        }
            break;
        case 13: {
            return MRBSitesImageDownloadActionContinue;
        }
            break;
        default: {
            return MRBSitesImageDownloadActionDone;
        }
            break;
    }
}

- (void)fetchSucceed {
    [[MRBLogManager defaultManager] cleanLog];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：流程结束", self.model.keyword];
    [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 图片地址:\n%@", self.model.keyword, [MRBUtilityManager convertResultArray:[posts valueForKey:@"file_url"]]];
}

@end
