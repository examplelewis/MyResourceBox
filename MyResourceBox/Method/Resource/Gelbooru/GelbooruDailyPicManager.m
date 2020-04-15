//
//  GelbooruTagManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruDailyPicManager.h"
#import "MRBResourceGlobalTagManager.h"
#import "MRBHttpManager.h"
#import "GelbooruHeader.h"

static NSInteger const MRBGelbooruDailyPicMaxFetchWrongTimes = 3;

@interface GelbooruDailyPicManager () {
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

@implementation GelbooruDailyPicManager

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
        
        NSString *filePath = [[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"FetchResource/GelbooruLatestPost.plist"];
        latestPost = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath]; // 获取之前保存的Post信息
    }
    
    return self;
}

- (void)startFetching {
    if ([[MRBFileManager defaultManager] isContentExistAtPath:GelbooruFatePostTxtPath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"已检测到之前获取到的文件, 可能获取完成之后并没有下载, 请先下载之前获取到的图片, 或者删除已下载的 txt 文件"];
        return;
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Gelbooru 日常图片地址，流程开始"];
    
    [self fetchSingleDailyPostUrl];
}
- (void)fetchSingleDailyPostUrl {
    [[MRBHttpManager sharedManager] getGelbooruPostsWithPage:curPage success:^(NSArray *array) {
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
            NSString *animeTags = [[MRBResourceGlobalTagManager defaultManager] extractAnimeTagsFromTags:data[@"tags"] atSite:MRBResourceGlobalTagSiteGelbooru];
            if (animeTags.length > 0) {
                [self->animePosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:animeTags usefulTags:usefulTags];
                [self->animeNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
            }
            NSString *gameTags = [[MRBResourceGlobalTagManager defaultManager] extractGameTagsFromTags:data[@"tags"] atSite:MRBResourceGlobalTagSiteGelbooru];
            if (gameTags.length > 0) {
                [self->gamePosts addObject:data];
                
                NSString *usefulTags = [[MRBResourceGlobalTagManager defaultManager] extractUsefulTagsFromTagsString:data[@"tags"]];
                NSString *targetName = [self targetFileNameAndExtensionWithData:data typeTags:gameTags usefulTags:usefulTags];
                [self->gameNameInfo setObject:targetName forKey:[data[@"file_url"] lastPathComponent]];
            }
            NSString *hTags = [[MRBResourceGlobalTagManager defaultManager] extractHTagsFromTags:data[@"tags"] atSite:MRBResourceGlobalTagSiteGelbooru];
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
        
        [MRBUtilityManager exportArray:fateUrls atPath:GelbooruFatePostTxtPath];
        [self->fateNameInfo writeToFile:GelbooruFatePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:azurUrls atPath:GelbooruAzurPostTxtPath];
        [self->azurNameInfo writeToFile:GelbooruAzurPostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:overwatchUrls atPath:GelbooruOverwatchPostTxtPath];
        [self->overwatchNameInfo writeToFile:GelbooruOverwatchPostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:animeUrls atPath:GelbooruAnimePostTxtPath];
        [self->animeNameInfo writeToFile:GelbooruAnimePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:gameUrls atPath:GelbooruGamePostTxtPath];
        [self->gameNameInfo writeToFile:GelbooruGamePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:hUrls atPath:GelbooruHPostTxtPath];
        [self->hNameInfo writeToFile:GelbooruHPostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:webmUrls atPath:GelbooruWebmPostTxtPath];
        [self->webmNameInfo writeToFile:GelbooruWebmPostRenamePlistPath atomically:YES];
        
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Gelbooru 日常图片地址：第 %ld 页已获取", self->curPage + 1];
        
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
        if (self->maxAPIWrongTimes >= MRBGelbooruDailyPicMaxFetchWrongTimes) {
            self->maxAPIWrongTimes = 0; // 重置错误计数
            
            DDLogError(@"%@: %@", errorTitle, errorMsg);
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Gelbooru 日常图片地址，遇到错误：%@: %@", errorTitle, errorMsg];
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Gelbooru 日常图片地址，当前获取页码(curPage): %ld", self->curPage];
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Gelbooru 日常图片地址：流程结束"];
        } else {
            self->maxAPIWrongTimes += 1;
            [self fetchSingleDailyPostUrl];
        }
    }];
}
- (void)fetchFatePostsSucceed {
    // 更新 latestPost
    if (!!newestPost) {
        NSString *dest = [[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"FetchResource/GelbooruLatestPost.plist"];
        
        BOOL success = [NSKeyedArchiver archiveRootObject:newestPost toFile:dest];
        if (success) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已成功保存最新的Post, id: %@", newestPost[@"id"]];
            
            latestPost = newestPost;
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"将最新Post保存至本地时出错，请重新保存"];
        }
    }
    
    [[MRBLogManager defaultManager] cleanLog];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 Gelbooru 日常图片地址：流程结束"];
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
