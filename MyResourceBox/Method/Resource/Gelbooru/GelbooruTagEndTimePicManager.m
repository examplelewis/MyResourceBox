//
//  GelbooruTagEndTimePicManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/23.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruTagEndTimePicManager.h"
#import "HttpManager.h"
#import "GelbooruHeader.h"

@interface GelbooruTagEndTimePicManager () {
    NSString *tag;
    NSInteger page;
    NSDate *endDate;
    NSInteger pageCount;
    
    NSMutableArray *posts;
    NSDateFormatter *formatter;
    
    NSInteger countBeforePage;
    NSInteger countAfterPage;
}

@end

@implementation GelbooruTagEndTimePicManager

- (void)prepareFetching {
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    posts = [NSMutableArray array];
    
    formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    
    NSArray *inputComps = [input componentsSeparatedByString:@"|"];
    page = 0;
    pageCount = 0;
    tag = inputComps[0];
    if (inputComps.count == 1) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"未输入截止日期，将使用默认值：2018-10-11，如需修改请退出程序，重新设置"];
        endDate = [NSDate dateWithYear:2018 month:10 day:11];
    } else {
        endDate = [NSDate dateWithString:inputComps[1] formatString:@"yyyy-MM-dd"];
        if (!endDate) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"输入的截止日期有误，请按照如下格式检查:\n%%tag%%|yyyy-MM-dd"];
            return;
        }
    }
    
    [self startFetching];
}
- (void)startFetching {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址【截止时间】，流程开始", tag];
    
    [self fetchSinglePostUrl];
}
- (void)fetchSinglePostUrl {
    [[HttpManager sharedManager] getSpecificTagPicFromGelbooruTag:tag page:page success:^(NSArray *array) {
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801) {
                continue;
            }
            
//            if ([data[@"source"] isEqualToString:@""]) {
//                continue;
//            }
            
            // 出现第一个比 endDate 晚的 post，就中断循环，因为就到这一个批次为止
            NSDate *postDate = [self->formatter dateFromString:data[@"created_at"]];
            if ([postDate isEarlierThan:self->endDate]) {
                break;
            }
            
            [self->posts addObject:data];
        }
        
        NSArray *fileUrls = [self->posts valueForKey:@"file_url"];
        [UtilityFile exportArray:fileUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Gelbooru %@ PostUrl.txt", self->tag]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", self->tag, self->page + 1];
        
        if (self->page == 0) {
            NSDictionary *lastPost = array.lastObject;
            NSDate *lastPostDate = [self->formatter dateFromString:lastPost[@"created_at"]];
            
            double intervalTimes = self->endDate.timeIntervalSinceNow / lastPostDate.timeIntervalSinceNow;
            self->pageCount = ceil(intervalTimes);
            NSInteger picCount = ceil(intervalTimes * 100);
            
            [[UtilityFile sharedInstance] showLogWithFormat:@"\n----------------------------------------\n根据第一页的结果，预计需要抓取 %ld 页数据，%ld 条图片地址\n----------------------------------------\n若需抓取的数据过多，请退出应用以终止进程。\n----------------------------------------", self->pageCount, picCount];
        }
        
        // API 限制最多 200 页；page 从 0 开始的，所以和 pageCount 比较的时候需要 -1；如果某一页小于 100 条原始数据，说明是最后一页
        if (self->page >= 199 || self->page >= self->pageCount - 1 || array.count != 100) {
            [self fetchSucceed];
        } else {
            self->page += 1;
            [self fetchSinglePostUrl];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址【截止时间】，遇到错误：%@: %@", self->tag, errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址【截止时间】，流程结束", self->tag];
    }];
}
- (void)fetchSucceed {
    [[UtilityFile sharedInstance] cleanLog];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址【截止时间】：流程结束", tag];
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 图片地址:\n%@", tag, [UtilityFile convertResultArray:[posts valueForKey:@"file_url"]]];
}

- (void)prepareFetchingPicCount {
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    formatter = [NSDateFormatter new];
    formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    
    NSArray *inputComps = [input componentsSeparatedByString:@"|"];
    tag = inputComps[0];
    if (inputComps.count == 1) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"未输入截止日期，将使用默认值：2018-10-11，如需修改请退出程序，重新设置"];
        endDate = [NSDate dateWithYear:2018 month:10 day:11];
    } else {
        endDate = [NSDate dateWithString:inputComps[1] formatString:@"yyyy-MM-dd"];
        if (!endDate) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"输入的截止日期有误，请按照如下格式检查:\n%%tag%%|yyyy-MM-dd"];
            return;
        }
    }
    countBeforePage = 0;
    countAfterPage = 199;
    page = 199;
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，流程开始", tag];
    
    [self fetchSinglePostCountUrl];
}
- (void)fetchSinglePostCountUrl {
    [[HttpManager sharedManager] getSpecificTagPicFromGelbooruTag:tag page:page success:^(NSArray *array) {
        NSDate *firstCreatedAt = [self->formatter dateFromString:(array.firstObject)[@"created_at"]];
        NSDate *lastCreatedAt = [self->formatter dateFromString:(array.lastObject)[@"created_at"]];
        
        if (array.count == 0 || [firstCreatedAt isEarlierThan:self->endDate]) {
            if (self->page == 0) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，未查询到图片，请检查输入的 Tag", self->tag];
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
            } else {
                NSInteger nextPage = floor((self->page + self->countBeforePage) / 2.0);
                [[UtilityFile sharedInstance] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片地址【截止时间】的数量，正在查询第 %ld 页\n当前页数量为 0，二分法向前查找第 %ld 页", self->tag, self->page + 1, nextPage + 1];
                self->countAfterPage = self->page;
                self->page = nextPage;
                DDLogInfo(@"after ==0 page: %ld, countBeforePage: %ld, countAfterPage: %ld", self->page, self->countBeforePage, self->countAfterPage);
                
                [self fetchSinglePostCountUrl];
            }
        } else if ([lastCreatedAt isLaterThanOrEqualTo:self->endDate]) {
            if (self->page == 199) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，需要抓取 >200 页，图片数量 >20000 张", self->tag];
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
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
                    
                    [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，需要抓取 %ld 页，图片数量 %ld 张", self->tag, self->page + 1, self->page * 100 + total];
                    [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
                } else {
                    [[UtilityFile sharedInstance] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片地址【截止时间】的数量，正在查询第 %ld 页\n当前页数量为 100，二分法向后查找第 %ld 页", self->tag, self->page + 1, nextPage + 1];
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
            
            [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，需要抓取 %ld 页，图片数量 %ld 张", self->tag, self->page + 1, self->page * 100 + total];
            [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量，遇到错误：%@: %@", self->tag, errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片地址【截止时间】的数量：流程结束", self->tag];
    }];
}

@end
