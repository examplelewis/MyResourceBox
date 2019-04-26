//
//  GelbooruTagPagePicManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruTagPagePicManager.h"
#import "HttpManager.h"

@interface GelbooruTagPagePicManager () {
    NSString *tag;
    NSInteger minPage;
    NSInteger maxPage;
    NSInteger page;
    NSMutableArray *posts;
    
    NSInteger countBeforePage;
    NSInteger countAfterPage;
}

@end

@implementation GelbooruTagPagePicManager

- (instancetype)init {
    self = [super init];
    if (self) {
        posts = [NSMutableArray array];
    }
    
    return self;
}

- (void)startFetching {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取特定标签的图片地址，流程开始"];
    
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
    [[HttpManager sharedManager] getSpecificTagPicFromGelbooruTag:tag page:page - 1 success:^(NSArray *array) {
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801) {
                continue;
            }
            
//            if ([data[@"source"] isEqualToString:@""]) {
//                continue;
//            }
            
            [self->posts addObject:data];
        }
        
        NSArray *urls = [self->posts valueForKey:@"file_url"];
        [UtilityFile exportArray:urls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Gelbooru %@ PostUrl.txt", self->tag]];
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
    [[HttpManager sharedManager] getSpecificTagPicFromGelbooruTag:tag page:page success:^(NSArray *array) {
        if (array.count == 0) {
            NSInteger nextPage = floor((self->page + self->countBeforePage) / 2.0);
            [[UtilityFile sharedInstance] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片数量，正在查询第 %ld 页\n----------------------------------------\n当前页数量为 0，二分法向前查找第 %ld 页\n----------------------------------------", self->tag, self->page + 1, nextPage + 1];
            self->countAfterPage = self->page;
            self->page = nextPage;
            DDLogInfo(@"after ==0 page: %ld, countBeforePage: %ld, countAfterPage: %ld", self->page, self->countBeforePage, self->countAfterPage);
            
            [self fetchSinglePostCountUrl];
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
                    [[UtilityFile sharedInstance] showLogWithFormat:@"\n----------------------------------------\n查询 %@ 图片数量，正在查询第 %ld 页\n----------------------------------------\n当前页数量为 100，二分法向后查找第 %ld 页\n----------------------------------------", self->tag, self->page + 1, nextPage + 1];
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
