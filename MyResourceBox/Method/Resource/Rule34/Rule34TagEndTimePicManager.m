//
//  Rule34TagEndTimePicManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/23.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "Rule34TagEndTimePicManager.h"
#import "MRBHttpManager.h"
#import "Rule34Header.h"

@interface Rule34TagEndTimePicManager () {
    NSString *tag;
    NSInteger page;
    NSDate *endDate;
    
    NSMutableArray *posts;
    NSMutableArray *webmPosts;
    NSDateFormatter *formatter;
    
    NSInteger countBeforePage;
    NSInteger countAfterPage;
}

@end

@implementation Rule34TagEndTimePicManager

- (void)prepareFetching {
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    posts = [NSMutableArray array];
    webmPosts = [NSMutableArray array];
    
    formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    
    NSArray *inputComps = [input componentsSeparatedByString:@"|"];
    page = 0;
    tag = inputComps[0];
    if (inputComps.count == 1) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未输入截止日期，将使用默认值：2018-10-11，如需修改请退出程序，重新设置"];
        endDate = [NSDate dateWithYear:2018 month:10 day:11];
    } else {
        endDate = [NSDate dateWithString:inputComps[1] formatString:@"yyyy-MM-dd"];
        if (!endDate) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"输入的截止日期有误，请按照如下格式检查:\n%%tag%%|yyyy-MM-dd"];
            return;
        }
    }
    
    [self startFetching];
}
- (void)startFetching {
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【截止时间】，流程开始", tag];
    [[MRBLogManager defaultManager] showLogWithFormat:@"注意：本流程将忽略 webm 文件"];
    
    [self fetchSinglePostUrl];
}
- (void)fetchSinglePostUrl {
    [[MRBHttpManager sharedManager] getSpecificTagPicFromRule34Tag:tag page:page success:^(NSArray *array) {
        BOOL foundNearest = NO; // 找到早于 endDate 的 post
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            
            // 忽略 webm 文件
            if ([[data[@"file_url"] pathExtension] isEqualToString:@"webm"]) {
                [self->webmPosts addObject:data];
                continue;
            }
            
            // 小于 801 * 801 的非 gif 文件将被忽略
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801 && ![[data[@"file_url"] pathExtension] isEqualToString:@"gif"]) {
                continue;
            }
            
            // 出现第一个比 endDate 晚的 post，就中断循环，因为就到这一个批次为止
            NSDate *postDate = [self->formatter dateFromString:data[@"created_at"]];
            if ([postDate isEarlierThan:self->endDate]) {
                foundNearest = YES;
                break;
            }
            
            [self->posts addObject:data];
        }
        
        if (self->webmPosts.count > 0) {
            NSArray *webmIds = [self->webmPosts valueForKey:@"id"];
            NSMutableArray *webmUrls = [NSMutableArray array];
            for (NSInteger i = 0; i < webmIds.count; i++) {
                [webmUrls addObject:[NSString stringWithFormat:@"https://rule34.xxx/index.php?page=post&s=view&id=%@", webmIds[i]]];
            }
            [MRBUtilityManager exportArray:webmUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ WebmUrl.txt", self->tag]];
            
            NSArray *webmFileUrls = [self->webmPosts valueForKey:@"file_url"];
            [MRBUtilityManager exportArray:webmFileUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ WebmPostUrl.txt", self->tag]];
        }
        
        NSArray *fileUrls = [self->posts valueForKey:@"file_url"];
        [MRBUtilityManager exportArray:fileUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ PostUrl.txt", self->tag]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", self->tag, self->page + 1];
        
        // API 限制最多 200 页；如果某一页小于 100 条原始数据，说明是最后一页；或者找到了第一条早于 endDate 的 post
        if (self->page >= 199 || array.count != 100 || foundNearest) {
            [self fetchSucceed];
        } else {
            self->page += 1;
            [self fetchSinglePostUrl];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【截止时间】，遇到错误：%@: %@", self->tag, errorTitle, errorMsg];
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【截止时间】，流程结束", self->tag];
    }];
}
- (void)fetchSucceed {
    [[MRBLogManager defaultManager] cleanLog];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【截止时间】：流程结束", tag];
    [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 图片地址:\n%@", tag, [MRBUtilityManager convertResultArray:[posts valueForKey:@"file_url"]]];
}

- (void)prepareFetchingPicCount {
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    
    NSArray *inputComps = [input componentsSeparatedByString:@"|"];
    tag = inputComps[0];
    if (inputComps.count == 1) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未输入截止日期，将使用默认值：2018-10-11，如需修改请退出程序，重新设置"];
        endDate = [NSDate dateWithYear:2018 month:10 day:11];
    } else {
        endDate = [NSDate dateWithString:inputComps[1] formatString:@"yyyy-MM-dd"];
        if (!endDate) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"输入的截止日期有误，请按照如下格式检查:\n%%tag%%|yyyy-MM-dd"];
            return;
        }
    }
    countBeforePage = 0;
    countAfterPage = 199;
    page = 199;
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，流程开始", tag];
    
    [self fetchSinglePostCountUrl];
}
- (void)fetchSinglePostCountUrl {
    [[MRBHttpManager sharedManager] getSpecificTagPicFromRule34Tag:tag page:page success:^(NSArray *array) {
        NSDate *firstCreatedAt = [self->formatter dateFromString:(array.firstObject)[@"created_at"]];
        NSDate *lastCreatedAt = [self->formatter dateFromString:(array.lastObject)[@"created_at"]];
        
        if (array.count == 0 || [firstCreatedAt isEarlierThan:self->endDate]) {
            if (self->page == 0) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，未查询到图片，请检查输入的 Tag", self->tag];
                [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
            } else {
                NSInteger nextPage = floor((self->page + self->countBeforePage) / 2.0);
                [[MRBLogManager defaultManager] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片地址【截止时间】的数量，正在查询第 %ld 页\n当前页数量为 0，二分法向前查找第 %ld 页", self->tag, self->page + 1, nextPage + 1];
                self->countAfterPage = self->page;
                self->page = nextPage;
                DDLogInfo(@"after ==0 page: %ld, countBeforePage: %ld, countAfterPage: %ld", self->page, self->countBeforePage, self->countAfterPage);
                
                [self fetchSinglePostCountUrl];
            }
        } else if ([lastCreatedAt isLaterThanOrEqualTo:self->endDate]) {
            if (self->page == 199) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，需要抓取 >200 页，图片数量 >20000 张", self->tag];
                [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
            } else {
                NSInteger nextPage = floor((self->page + self->countAfterPage) / 2.0);
                if (nextPage == self->page) {
                    NSInteger total = 0;
                    for (NSInteger i = 0; i < array.count; i++) {
                        NSDate *createdAt = [self->formatter dateFromString:(array[i])[@"created_at"]];
                        if ([createdAt isLaterThanOrEqualTo:self->endDate]) {
                            total += 1;
                        } else {
                            break;
                        }
                    }
                    
                    [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，需要抓取 %ld 页，图片数量 %ld 张", self->tag, self->page + 1, self->page * 100 + total];
                    [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
                } else {
                    [[MRBLogManager defaultManager] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片地址【截止时间】的数量，正在查询第 %ld 页\n当前页数量为 100，二分法向后查找第 %ld 页", self->tag, self->page + 1, nextPage + 1];
                    self->countBeforePage = self->page;
                    self->page = nextPage;
                    DDLogInfo(@"after ==100 page: %ld, countBeforePage: %ld, countAfterPage: %ld", self->page, self->countBeforePage, self->countAfterPage);
                    
                    [self fetchSinglePostCountUrl];
                }
            }
        } else {
            NSInteger total = 0;
            for (NSInteger i = 0; i < array.count; i++) {
                NSDate *createdAt = [self->formatter dateFromString:(array[i])[@"created_at"]];
                if ([createdAt isLaterThanOrEqualTo:self->endDate]) {
                    total += 1;
                } else {
                    break;
                }
            }
            
            [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，需要抓取 %ld 页，图片数量 %ld 张", self->tag, self->page + 1, self->page * 100 + total];
            [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，遇到错误：%@: %@", self->tag, errorTitle, errorMsg];
        [[MRBLogManager defaultManager] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
    }];
}

@end
