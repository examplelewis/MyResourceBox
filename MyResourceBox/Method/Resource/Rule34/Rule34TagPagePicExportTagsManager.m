//
//  Rule34TagPagePicExportTagsManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/10.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "Rule34TagPagePicExportTagsManager.h"
#import "MRBHttpManager.h"
#import "Rule34Header.h"
#import "ResourceGlobalTagManager.h"

@interface Rule34TagPagePicExportTagsManager () {
    NSString *tag;
    NSInteger minPage;
    NSInteger maxPage;
    NSInteger page;
    
    NSMutableArray *posts;
    NSMutableArray *webmPosts;
    
    NSMutableDictionary *renameInfo;
}

@end

@implementation Rule34TagPagePicExportTagsManager

- (void)startFetching {
    NSString *inputString = [AppDelegate defaultVC].inputTextView.string;
    if (inputString.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    posts = [NSMutableArray array];
    webmPosts = [NSMutableArray array];
    renameInfo = [NSMutableDictionary dictionary];
    
    NSArray *inputComps = [inputString componentsSeparatedByString:@"|"];
    tag = inputComps[0];
    if (inputComps.count == 1) {
        minPage = 1;
        maxPage = 200;
    } else if (inputComps.count == 2) {
        minPage = 1;
        maxPage = [inputComps[1] integerValue];
    } else {
        minPage = [inputComps[1] integerValue];
        maxPage = [inputComps[2] integerValue];
    }
    page = minPage;
    DDLogInfo(@"fetchSpecificTagPostUrl minPage: %ld, maxPage: %ld, page: %ld", minPage, maxPage, page);
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【页数 + 导出标签】，流程开始", tag];
    [[MRBLogManager defaultManager] showLogWithFormat:@"注意：本流程将忽略 webm 文件"];
    
    [self fetchSinglePostUrl];
}
- (void)fetchSinglePostUrl {
    [[MRBHttpManager sharedManager] getSpecificTagPicFromRule34Tag:tag page:page - 1 success:^(NSArray *array) {
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
            
            NSString *fileNameAndExtension = [data[@"file_url"] lastPathComponent];
            NSArray *tags = [data[@"tags"] componentsSeparatedByString:@" "];
            NSString *tagsStr = [[ResourceGlobalTagManager defaultManager] getNeededCopyrightTags:tags];
            if (tagsStr.length == 0) {
                [self->renameInfo setObject:[NSString stringWithFormat:@"%@.%@", data[@"id"], fileNameAndExtension.pathExtension] forKey:fileNameAndExtension];
            } else {
                [self->renameInfo setObject:[NSString stringWithFormat:@"%@ - %@.%@", data[@"id"], tagsStr, fileNameAndExtension.pathExtension] forKey:fileNameAndExtension];
            }
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
        
        NSArray *urls = [self->posts valueForKey:@"file_url"];
        [MRBUtilityManager exportArray:urls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ PostUrl.txt", self->tag]];
        [self->renameInfo writeToFile:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ PostRenameInfo.plist", self->tag] atomically:YES];
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【页数 + 导出标签】：第 %ld 页已获取", self->tag, self->page];
        
        // 如果某一页小于100条原始数据，说明是最后一页
        if (self->page >= self->maxPage || array.count != 100) {
            [self fetchSucceed];
        } else {
            self->page += 1;
            [self fetchSinglePostUrl];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【页数 + 导出标签】，遇到错误：%@: %@", self->tag, errorTitle, errorMsg];
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【页数 + 导出标签】：流程结束", self->tag];
    }];
}
- (void)fetchSucceed {
    [[MRBLogManager defaultManager] cleanLog];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址【页数 + 导出标签】：流程结束", tag];
    [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 图片地址:\n%@", tag, [MRBUtilityManager convertResultArray:[self->posts valueForKey:@"file_url"]]];
}

@end
