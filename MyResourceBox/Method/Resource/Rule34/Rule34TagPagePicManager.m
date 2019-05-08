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
    tag = inputComps[0];
    countBeforePage = 0;
    countAfterPage = 199;
    page = 199;
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程开始", tag];
    
    [self fetchSinglePostCountUrl];
}
- (void)fetchSinglePostCountUrl {
    [[HttpManager sharedManager] getSpecificTagPicFromRule34Tag:tag page:page success:^(NSArray *array) {
        if (array.count == 0) {
            if (self->page == 0) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量，未查询到图片，请检查输入的 Tag", self->tag];
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程结束", self->tag];
            } else {
                NSInteger nextPage = floor((self->page + self->countBeforePage) / 2.0);
                [[UtilityFile sharedInstance] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片数量，正在查询第 %ld 页\n当前页数量为 0，二分法向前查找第 %ld 页", self->tag, self->page + 1, nextPage + 1];
                self->countAfterPage = self->page;
                self->page = nextPage;
                DDLogInfo(@"after ==0 page: %ld, countBeforePage: %ld, countAfterPage: %ld", self->page, self->countBeforePage, self->countAfterPage);
                
                [self fetchSinglePostCountUrl];
            }
        } else if (array.count == 100) {
            if (self->page == 199) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量，需要抓取 >200 页，图片数量 >20000 张", self->tag];
                [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程结束", self->tag];
            } else {
                NSInteger nextPage = floor((self->page + self->countAfterPage) / 2.0);
                if (nextPage == self->page) {
                    [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量，需要抓取 %ld 页，图片数量 %ld 张", self->tag, self->page + 1, (self->page + 1) * 100];
                    [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程结束", self->tag];
                } else {
                    [[UtilityFile sharedInstance] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片数量，正在查询第 %ld 页\n当前页数量为 100，二分法向后查找第 %ld 页", self->tag, self->page + 1, nextPage + 1];
                    self->countBeforePage = self->page;
                    self->page = nextPage;
                    DDLogInfo(@"after ==100 page: %ld, countBeforePage: %ld, countAfterPage: %ld", self->page, self->countBeforePage, self->countAfterPage);
                    
                    [self fetchSinglePostCountUrl];
                }
            }
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量，需要抓取 %ld 页，图片数量 %ld 张", self->tag, self->page + 1, self->page * 100 + array.count];
            [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程结束", self->tag];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量，遇到错误：%@: %@", self->tag, errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"查询 %@ 图片数量：流程结束", self->tag];
    }];
}

@end