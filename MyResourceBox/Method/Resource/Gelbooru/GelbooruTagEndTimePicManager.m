//
//  GelbooruTagEndTimePicManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/23.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruTagEndTimePicManager.h"
#import "HttpRequest.h"

@interface GelbooruTagEndTimePicManager () {
    NSString *tag;
    NSInteger page;
    NSDate *endDate;
    NSInteger pageCount;
    
    NSMutableArray *posts;
    NSDateFormatter *formatter;
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
    endDate = [NSDate dateWithString:inputComps[1] formatString:@"yyyy-MM-dd"];
    if (inputComps.count != 2 || !endDate || tag.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有的内容格式有误，请按照如下格式检查:\n%%tag%%|yyyy-MM-dd"];
        return;
    }
    
    [self startFetching];
}
- (void)startFetching {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址【截止时间】，流程开始", tag];
    
    [self fetchSinglePostUrl];
}
- (void)fetchSinglePostUrl {
    [[HttpRequest shareIndex] getSpecificTagPicFromGelbooruTag:tag page:page progress:NULL success:^(NSArray *array) {
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801) {
                continue;
            }
            
            if ([data[@"source"] isEqualToString:@""]) {
                continue;
            }
            
            [self->posts addObject:data];
        }
        
        NSArray *fileUrls = [self->posts valueForKey:@"file_url"];
        [UtilityFile exportArray:fileUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Gelbooru %@ PostUrl.txt", self->tag]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", self->tag, self->page];
        
        if (self->page == 0) {
            NSDictionary *lastPost = self->posts.lastObject;
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址【截止时间】：流程结束", self->tag];
    }];
}
- (void)fetchSucceed {
    [[UtilityFile sharedInstance] cleanLog];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址【截止时间】：流程结束", tag];
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 图片地址:\n%@", tag, [UtilityFile convertResultArray:[posts valueForKey:@"file_url"]]];
}

@end
