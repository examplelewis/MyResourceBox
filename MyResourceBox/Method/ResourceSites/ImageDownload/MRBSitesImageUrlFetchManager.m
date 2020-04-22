//
//  MRBSitesImageUrlFetchManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageUrlFetchManager.h"
#import "MRBHttpManager.h"
#import <NSDate+DateTools.h>

static NSInteger const MRBSitesImageMaxFetchWrongTimes = 3;

typedef NS_ENUM(NSUInteger, MRBSitesImageUrlFetchAction) {
    MRBSitesImageUrlFetchActionContinue,
    MRBSitesImageUrlFetchActionNext,
    MRBSitesImageUrlFetchActionDone
};

@interface MRBSitesImageUrlFetchManager () {
    NSInteger currentPage;
    
    NSMutableArray *posts;
    NSMutableArray *webmPosts;
    
    NSDateFormatter *formatter;
    
    NSInteger apiWrongTimes;
}

@property (strong) MRBSitesImageUrlFetchModel *model;

@end

@implementation MRBSitesImageUrlFetchManager

#pragma mark - Lifecycle
- (instancetype)initWithModel:(MRBSitesImageUrlFetchModel *)model {
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
    BS(blockSelf);
    [[MRBHttpManager sharedManager] getResourceSitesPostsWithUrl:self.model.url tag:self.model.keyword page:currentPage success:^(NSArray *array) {
        SS(strongSelf);
        
        MRBSitesImageUrlFetchAction action = [strongSelf actionForThisPageWithResults:array];
        switch (action) {
            case MRBSitesImageUrlFetchActionNext: {
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", strongSelf.model.keyword, blockSelf->currentPage + 1];
                
                blockSelf->currentPage += 1;
                [strongSelf fetchSinglePost];
            }
                break;
            case MRBSitesImageUrlFetchActionContinue: {
                [strongSelf parseFetchedResults:array];
                
                blockSelf->currentPage += 1;
                [strongSelf fetchSinglePost];
            }
                break;
            case MRBSitesImageUrlFetchActionDone: {
                [strongSelf fetchSucceed];
            }
                break;
            default:
                break;
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        SS(strongSelf);
        
        if (blockSelf->apiWrongTimes >= MRBSitesImageMaxFetchWrongTimes) {
            blockSelf->apiWrongTimes = 0; // 重置错误计数
            
            DDLogError(@"%@: %@", errorTitle, errorMsg);
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取特定标签的图片地址，遇到错误：%@: %@", errorTitle, errorMsg];
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取特定标签的图片地址，当前获取页码: %ld, 当前Model: %@", blockSelf->currentPage, strongSelf.model];
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：流程结束", strongSelf.model.keyword];
        } else {
            blockSelf->apiWrongTimes += 1;
            [strongSelf fetchSinglePost];
        }
    }];
}
- (MRBSitesImageUrlFetchAction)actionForThisPageWithResults:(NSArray *)array {
    // 如果某一页小于100条原始数据，说明是最后一页
    if (array.count != 100) {
        return MRBSitesImageUrlFetchActionDone;
    }
    
    // API 限制 1000 页
    if (currentPage >= 1000) {
        return MRBSitesImageUrlFetchActionDone;
    }
    
    switch (self.model.mode) {
        case 10: {
            return MRBSitesImageUrlFetchActionContinue;
        }
            break;
        case 11: {
            if ([array.lastObject[@"id"] integerValue] > self.model.inputEnd) {
                return MRBSitesImageUrlFetchActionNext;
            } else if ([array.firstObject[@"id"] integerValue] < self.model.inputStart) {
                return MRBSitesImageUrlFetchActionDone;
            } else {
                return MRBSitesImageUrlFetchActionContinue;
            }
        }
            break;
        case 12: {
            NSDate *firstCreatedAt = [formatter dateFromString:array.firstObject[@"created_at"]];
            NSDate *lastCreatedAt = [formatter dateFromString:array.lastObject[@"created_at"]];
            
            if ([lastCreatedAt isLaterThan:self.model.inputEndDate]) {
                return MRBSitesImageUrlFetchActionNext;
            } else if ([firstCreatedAt isEarlierThan:self.model.inputStartDate]) {
                return MRBSitesImageUrlFetchActionDone;
            } else {
                return MRBSitesImageUrlFetchActionContinue;
            }
        }
            break;
        case 13: {
            if (currentPage < self.model.inputStart) {
                return MRBSitesImageUrlFetchActionNext;
            } else if (currentPage > self.model.inputEnd) {
                return MRBSitesImageUrlFetchActionDone;
            } else {
                return MRBSitesImageUrlFetchActionContinue;
            }
        }
            break;
        default: {
            return MRBSitesImageUrlFetchActionDone;
        }
            break;
    }
}
- (void)parseFetchedResults:(NSArray *)array {
    // Filter
    for (NSInteger i = 0; i < array.count; i++) {
        NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
        MRBSitesImageUrlFetchAction action = [self actionForThisPostWithDictionary:data];
        if (action == MRBSitesImageUrlFetchActionNext) {
            continue;
        } else if (action == MRBSitesImageUrlFetchActionContinue) {
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
        NSArray *webmFileUrls = [webmPosts valueForKey:@"file_url"];
        [MRBUtilityManager exportArray:webmFileUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/%@ %@ Webm.txt", self.model.urlHostName, self.model.keyword]];
    }
    
    NSArray *urls = [posts valueForKey:@"file_url"];
    [MRBUtilityManager exportArray:urls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/%@ %@.txt", self.model.urlHostName, self.model.keyword]];
    
    // Log
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", self.model.keyword, currentPage + 1];
}
- (MRBSitesImageUrlFetchAction)actionForThisPostWithDictionary:(NSDictionary *)data {
    switch (self.model.mode) {
        case 10: {
            return MRBSitesImageUrlFetchActionContinue;
        }
            break;
        case 11: {
            if ([data[@"id"] integerValue] > self.model.inputEnd) {
                return MRBSitesImageUrlFetchActionNext;
            } else if ([data[@"id"] integerValue] < self.model.inputStart) {
                return MRBSitesImageUrlFetchActionDone;
            } else {
                return MRBSitesImageUrlFetchActionContinue;
            }
        }
            break;
        case 12: {
            NSDate *createdAt = [formatter dateFromString:data[@"created_at"]];
            
            if ([createdAt isLaterThan:self.model.inputEndDate]) {
                return MRBSitesImageUrlFetchActionNext;
            } else if ([createdAt isEarlierThan:self.model.inputStartDate]) {
                return MRBSitesImageUrlFetchActionDone;
            } else {
                return MRBSitesImageUrlFetchActionContinue;
            }
        }
            break;
        case 13: {
            return MRBSitesImageUrlFetchActionContinue;
        }
            break;
        default: {
            return MRBSitesImageUrlFetchActionDone;
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
