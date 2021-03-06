//
//  Rule34TagManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "Rule34DailyPicManager.h"
#import "MRBResourceGlobalTagManager.h"
#import "MRBHttpManager.h"
#import "Rule34Header.h"

static NSInteger const MRBRule34DailyPicMaxFetchWrongTimes = 3;

@interface Rule34DailyPicManager () {
    NSInteger curPage;
    
    NSMutableArray *webmPosts; // webm
    NSMutableArray *fatePosts; // fate
    NSMutableArray *azurPosts; // 碧蓝航线
    NSMutableArray *overwatchPosts; // overwatch
    NSMutableArray *animePosts; // 动漫
    NSMutableArray *gamePosts; // 游戏
    NSMutableArray *hPosts; // 18
    
    NSMutableDictionary *animeNameInfo;
    NSMutableDictionary *gameNameInfo;
    NSMutableDictionary *hNameInfo;
    NSMutableDictionary *fateNameInfo;
    NSMutableDictionary *azurNameInfo;
    NSMutableDictionary *overwatchNameInfo;
    NSMutableDictionary *webmNameInfo;
    
    NSDictionary *latestPost;
    NSDictionary *newestPost;
    
    NSInteger maxAPIWrongTimes;
}

@end

@implementation Rule34DailyPicManager

- (instancetype)init {
    self = [super init];
    if (self) {
        curPage = 0;
        maxAPIWrongTimes = 0;
        webmPosts = [NSMutableArray array];
        fatePosts = [NSMutableArray array];
        azurPosts = [NSMutableArray array];
        overwatchPosts = [NSMutableArray array];
        animePosts = [NSMutableArray array];
        gamePosts = [NSMutableArray array];
        hPosts = [NSMutableArray array];
        animeNameInfo = [NSMutableDictionary dictionary];
        gameNameInfo = [NSMutableDictionary dictionary];
        hNameInfo = [NSMutableDictionary dictionary];
        fateNameInfo = [NSMutableDictionary dictionary];
        azurNameInfo = [NSMutableDictionary dictionary];
        overwatchNameInfo = [NSMutableDictionary dictionary];
        webmNameInfo = [NSMutableDictionary dictionary];
        
        NSString *filePath = [[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"FetchResource/Rule34LatestPost.plist"];
        latestPost = [NSDictionary dictionaryWithContentsOfFile:filePath]; // 获取之前保存的Post信息
    }
    
    return self;
}

- (void)startFetching {
    if ([[MRBFileManager defaultManager] isContentExistAtPath:Rule34FatePostTxtPath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"已检测到之前获取到的文件, 可能获取完成之后并没有下载, 请先下载之前获取到的图片, 或者删除已下载的 txt 文件"];
        return;
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Rule34 日常图片地址，流程开始"];
    
    [self fetchSingleDailyPostUrl];
}
- (void)fetchSingleDailyPostUrl {
    [[MRBHttpManager sharedManager] getRule34PostsWithPage:curPage success:^(NSArray *array) {
        if (self->curPage == 0) {
            self->newestPost = [NSDictionary dictionaryWithDictionary:array.firstObject];
        }
        
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            
            // 忽略 webm 文件
            if ([[data[@"file_url"] pathExtension] isEqualToString:@"webm"]) {
                [self->webmPosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:@"" usefulTags:usefulTags];
                [self->webmNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
                
                continue;
            }
            
            // 小于 801 * 801 的非 gif 文件将被忽略
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801 && ![[data[@"file_url"] pathExtension] isEqualToString:@"gif"]) {
                continue;
            }
            
            if ([data[@"tags"] containsString:@"fate"]) {
                [self->fatePosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:@"fate_(series)" usefulTags:usefulTags];
                [self->fateNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
                
                continue;
            }
            
            if ([data[@"tags"] containsString:@"azur_lane"]) {
                [self->azurPosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:@"azur_lane" usefulTags:usefulTags];
                [self->azurNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
                
                continue;
            }
            
            if ([data[@"tags"] containsString:@"overwatch"]) {
                [self->overwatchPosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:@"overwatch" usefulTags:usefulTags];
                [self->overwatchNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
                
                continue;
            }
            
            // 可能存在一张图片既在动漫又在游戏的情况，这是为了确定图片的真实tag
            NSString *animeTags = [[MRBResourceGlobalTagManager defaultManager] extractAnimeTagsFromTags:data[@"tags"] atSite:MRBResourceGlobalTagSiteRule34];
            if (animeTags.length > 0) {
                [self->animePosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:animeTags usefulTags:usefulTags];
                [self->animeNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
            }
            NSString *gameTags = [[MRBResourceGlobalTagManager defaultManager] extractGameTagsFromTags:data[@"tags"] atSite:MRBResourceGlobalTagSiteRule34];
            if (gameTags.length > 0) {
                [self->gamePosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:gameTags usefulTags:usefulTags];
                [self->gameNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
            }
            NSString *hTags = [[MRBResourceGlobalTagManager defaultManager] extractHTagsFromTags:data[@"tags"] atSite:MRBResourceGlobalTagSiteRule34];
            if (hTags.length > 0) {
                [self->hPosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:hTags usefulTags:usefulTags];
                [self->hNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
            }
        }
        
        
        NSArray *fateUrls = [self->fatePosts valueForKey:@"file_url"];
        NSArray *azurUrls = [self->azurPosts valueForKey:@"file_url"];
        NSArray *overwatchUrls = [self->overwatchPosts valueForKey:@"file_url"];
        NSArray *animeUrls = [self->animePosts valueForKey:@"file_url"];
        NSArray *gameUrls = [self->gamePosts valueForKey:@"file_url"];
        NSArray *hUrls = [self->hPosts valueForKey:@"file_url"];
        NSArray *webmUrls = [self->webmPosts valueForKey:@"file_url"];
        
        [MRBUtilityManager exportArray:fateUrls atPath:Rule34FatePostTxtPath];
        [self->fateNameInfo writeToFile:Rule34FatePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:azurUrls atPath:Rule34AzurPostTxtPath];
        [self->azurNameInfo writeToFile:Rule34AzurPostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:overwatchUrls atPath:Rule34OverwatchPostTxtPath];
        [self->overwatchNameInfo writeToFile:Rule34OverwatchPostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:animeUrls atPath:Rule34AnimePostTxtPath];
        [self->animeNameInfo writeToFile:Rule34AnimePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:gameUrls atPath:Rule34GamePostTxtPath];
        [self->gameNameInfo writeToFile:Rule34GamePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:hUrls atPath:Rule34HPostTxtPath];
        [self->hNameInfo writeToFile:Rule34HPostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:webmUrls atPath:Rule34WebmPostTxtPath];
        [self->webmNameInfo writeToFile:Rule34WebmPostRenamePlistPath atomically:YES];
        
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Rule34 日常图片地址：第 %ld 页已获取", self->curPage + 1];
        
        // 超过 200 页，就报错了
        if (self->curPage >= 199) {
            [self fetchFatePostsSucceed];
            return;
        }
        
        NSDictionary *lastData = [NSDictionary dictionaryWithDictionary:array.lastObject];
        if ([lastData[@"id"] integerValue] <= [self->latestPost[@"id"] integerValue]) {
            [self fetchFatePostsSucceed];
        } else {
            self->curPage += 1;
            [self fetchSingleDailyPostUrl];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        if (self->maxAPIWrongTimes >= MRBRule34DailyPicMaxFetchWrongTimes) {
            self->maxAPIWrongTimes = 0; // 重置错误计数
            
            DDLogError(@"%@: %@", errorTitle, errorMsg);
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Rule34 日常图片地址，遇到错误：%@: %@", errorTitle, errorMsg];
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Rule34 日常图片地址，当前获取页码(curPage): %ld", self->curPage];
            
            [self fetchFatePostsSucceed];
        } else {
            self->maxAPIWrongTimes += 1;
            [self fetchSingleDailyPostUrl];
        }
    }];
}
- (void)fetchFatePostsSucceed {
    // 更新 latestPost
    if (!!newestPost) {
        NSString *dest = [[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"FetchResource/Rule34LatestPost.plist"];
        
        BOOL success = [newestPost writeToFile:dest atomically:YES];
        if (success) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已成功保存最新的Post, id: %@", newestPost[@"id"]];
            
            latestPost = newestPost;
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"将最新Post保存至本地时出错，请重新保存"];
        }
    }
    
    [[MRBLogManager defaultManager] cleanLog];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Rule34 日常图片地址：流程结束"];
}

- (NSString *)targetFileNameAndExtensionWithData:(NSDictionary *)data typeTags:(NSString *)typeTags usefulTags:(NSString *)usefulTags {
    NSString *copiedUsefulTags = [usefulTags copy];
    
    // 如果 usefulTags 中包含 typeTags, 那么需要去除
    if (typeTags && typeTags.length > 0) {
        NSMutableArray *tags = [NSMutableArray arrayWithArray:[usefulTags componentsSeparatedByString:@"+"]];
        if ([tags indexOfObject:typeTags] != NSNotFound) {
            [tags removeObject:typeTags];
            copiedUsefulTags = [tags componentsJoinedByString:@"+"];
        }
    }
    
    NSMutableArray *components = [NSMutableArray array];
    if (typeTags && typeTags.length > 0) {
        // fate、azue_lane、overwatch 不添加
        if (![typeTags isEqualToString:@"fate_(series)"] && ![typeTags isEqualToString:@"azur_lane"] && ![typeTags isEqualToString:@"overwatch"]) {
            [components addObject:typeTags];
        }
    }
    if (copiedUsefulTags && copiedUsefulTags.length > 0) {
        [components addObject:copiedUsefulTags];
    }
    if (data[@"id"] && [data[@"id"] length] > 0) {
        [components addObject:data[@"id"]];
    }
    
    NSString *targetName = [components componentsJoinedByString:@" - "];
    if (targetName.length > 230) {
        targetName = [targetName substringToIndex:230];
    }
    
    return [NSString stringWithFormat:@"%@.%@", targetName, [data[@"file_url"] pathExtension]];
}

@end
