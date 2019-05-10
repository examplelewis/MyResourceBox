//
//  Rule34TagPagePicManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "Rule34TagPagePicManager.h"
#import "HttpManager.h"
#import "Rule34Header.h"

@interface Rule34TagPagePicManager () {
    NSString *tag;
    NSInteger minPage;
    NSInteger maxPage;
    NSInteger page;
    
    NSMutableArray *posts;
    NSMutableArray *webmPosts;
    
    NSInteger countBeforePage;
    NSInteger countAfterPage;
}

@end

@implementation Rule34TagPagePicManager

- (instancetype)init {
    self = [super init];
    if (self) {
        posts = [NSMutableArray array];
        webmPosts = [NSMutableArray array];
    }
    
    return self;
}

- (void)startFetching {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取特定标签的图片地址，流程开始"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"注意：本流程将忽略 webm 文件"];
    
    NSString *inputString = [AppDelegate defaultVC].inputTextView.string;
    if (inputString.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *inputComps = [inputString componentsSeparatedByString:@"|"];
    tag = inputComps[0];
    if (inputComps.count == 1) {
        minPage = 1;
        maxPage = 40;
    } else if (inputComps.count == 2) {
        minPage = 1;
        maxPage = [inputComps[1] integerValue];
    } else {
        minPage = [inputComps[1] integerValue];
        maxPage = [inputComps[2] integerValue];
    }
    page = minPage;
    DDLogInfo(@"fetchSpecificTagPostUrl minPage: %ld, maxPage: %ld, page: %ld", minPage, maxPage, page);
    
    [self fetchSinglePostUrl];
}
- (void)fetchSinglePostUrl {
    [[HttpManager sharedManager] getSpecificTagPicFromRule34Tag:tag page:page - 1 success:^(NSArray *array) {
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
            
            [self->posts addObject:data];
        }
        
        if (self->webmPosts.count > 0) {
            NSArray *webmIds = [self->webmPosts valueForKey:@"id"];
            NSMutableArray *webmUrls = [NSMutableArray array];
            for (NSInteger i = 0; i < webmIds.count; i++) {
                [webmUrls addObject:[NSString stringWithFormat:@"https://rule34.xxx/index.php?page=post&s=view&id=%@", webmIds[i]]];
            }
            [UtilityFile exportArray:webmUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ WebmUrl.txt", self->tag]];
            
            NSArray *webmFileUrls = [self->webmPosts valueForKey:@"file_url"];
            [UtilityFile exportArray:webmFileUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ WebmPostUrl.txt", self->tag]];
        }
        
        NSArray *urls = [self->posts valueForKey:@"file_url"];
        [UtilityFile exportArray:urls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ PostUrl.txt", self->tag]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", self->tag, self->page];
        
        // 如果某一页小于100条原始数据，说明是最后一页
        if (self->page >= self->maxPage || array.count != 100) {
            [self fetchSucceed];
        } else {
            self->page += 1;
            [self fetchSinglePostUrl];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址，遇到错误：%@: %@", self->tag, errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：流程结束", self->tag];
    }];
}
- (void)fetchSucceed {
    [[UtilityFile sharedInstance] cleanLog];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：流程结束", tag];
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 图片地址:\n%@", tag, [UtilityFile convertResultArray:[self->posts valueForKey:@"file_url"]]];
}

- (void)startFetchingTagPicCount {
    NSString *inputString = [AppDelegate defaultVC].inputTextView.string;
    if (inputString.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *inputComps = [inputString componentsSeparatedByString:@"|"];
    NSString *inputTag = inputComps[0];
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程开始", inputTag];
    
    [[HttpManager sharedManager] getSpecificTagPicCountFromRule34Tag:inputTag success:^(NSInteger totalCount) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量，需要抓取 %.0f 页，图片数量 %ld 张", inputTag, ceil(totalCount / 100.0), totalCount];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程结束", inputTag];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量，遇到错误：%@: %@", inputTag, errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程结束", inputTag];
    }];
}

@end
