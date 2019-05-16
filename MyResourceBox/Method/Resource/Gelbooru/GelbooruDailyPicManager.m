//
//  GelbooruTagManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruDailyPicManager.h"
#import "ResourceGlobalTagManager.h"
#import "MRBHttpManager.h"
#import "GelbooruHeader.h"

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
    NSMutableDictionary *webmNameInfo;
    
    NSDictionary *latestPost;
    NSDictionary *newestPost;
}

@end

@implementation GelbooruDailyPicManager

- (instancetype)init {
    self = [super init];
    if (self) {
        curPage = 0;
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
        webmNameInfo = [NSMutableDictionary dictionary];
        
        NSString *filePath = [[MRBUserManager defaultUser].path_root_folder stringByAppendingPathComponent:@"FetchResource/GelbooruLatestPost.plist"];
        latestPost = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath]; // 获取之前保存的Post信息
    }
    
    return self;
}

- (void)startFetching {
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取日常图片地址，流程开始"];
    
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
                
                NSArray *dataTags = [data[@"tags"] componentsSeparatedByString:@" "];
                NSString *copyrightTags = [[ResourceGlobalTagManager defaultManager] getNeededCopyrightTags:dataTags];
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                if (copyrightTags.length == 0) {
                    [self->webmNameInfo setObject:[NSString stringWithFormat:@"%@.%@", data[@"id"], donwloadFileNameAndExtension.pathExtension] forKey:donwloadFileNameAndExtension];
                } else {
                    [self->webmNameInfo setObject:[NSString stringWithFormat:@"%@ - %@.%@", copyrightTags, data[@"id"], donwloadFileNameAndExtension.pathExtension] forKey:donwloadFileNameAndExtension];
                }
                
                continue;
            }
            
            // 小于 801 * 801 的非 gif 文件将被忽略
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801 && ![[data[@"file_url"] pathExtension] isEqualToString:@"gif"]) {
                continue;
            }
            
            if ([data[@"tags"] containsString:@"fate"]) {
                [self->fatePosts addObject:data];
                continue;
            }
            
            if ([data[@"tags"] containsString:@"azur_lane"]) {
                [self->azurPosts addObject:data];
                continue;
            }
            
            if ([data[@"tags"] containsString:@"overwatch"]) {
                [self->overwatchPosts addObject:data];
                continue;
            }
            
            // 可能存在一张图片既在动漫又在游戏的情况，这是为了确定图片的真实tag
            NSString *animeTags = [[ResourceGlobalTagManager defaultManager] getAnimeTags:data[@"tags"]];
            if (animeTags.length > 0) {
                [self->animePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->animeNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", animeTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
            }
            NSString *gameTags = [[ResourceGlobalTagManager defaultManager] getGameTags:data[@"tags"]];
            if (gameTags.length > 0) {
                [self->gamePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->gameNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", gameTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
            }
            NSString *hTags = [[ResourceGlobalTagManager defaultManager] getHTags:data[@"tags"]];
            if (hTags.length > 0) {
                [self->hPosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->hNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", hTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
            }
        }
        
        
        NSArray *fateUrls = [self->fatePosts valueForKey:@"file_url"];
        NSArray *azurUrls = [self->azurPosts valueForKey:@"file_url"];
        NSArray *overwatchUrls = [self->overwatchPosts valueForKey:@"file_url"];
        NSArray *animeUrls = [self->animePosts valueForKey:@"file_url"];
        NSArray *gameUrls = [self->gamePosts valueForKey:@"file_url"];
        NSArray *hUrls = [self->hPosts valueForKey:@"file_url"];
        NSArray *webUrls = [self->webmPosts valueForKey:@"file_url"];
        
        [MRBUtilityManager exportArray:fateUrls atPath:GelbooruFatePostTxtPath];
        [MRBUtilityManager exportArray:azurUrls atPath:GelbooruAzurPostTxtPath];
        [MRBUtilityManager exportArray:overwatchUrls atPath:GelbooruOverwatchPostTxtPath];
        
        [MRBUtilityManager exportArray:animeUrls atPath:GelbooruAnimePostTxtPath];
        [self->animeNameInfo writeToFile:GelbooruAnimePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:gameUrls atPath:GelbooruGamePostTxtPath];
        [self->gameNameInfo writeToFile:GelbooruGamePostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:hUrls atPath:GelbooruHPostTxtPath];
        [self->hNameInfo writeToFile:GelbooruHPostRenamePlistPath atomically:YES];
        
        [MRBUtilityManager exportArray:webUrls atPath:GelbooruWebmPostTxtPath];
        [self->webmNameInfo writeToFile:GelbooruWebmPostRenamePlistPath atomically:YES];
        
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取日常图片地址：第 %ld 页已获取", self->curPage + 1];
        
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
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取日常图片地址，遇到错误：%@: %@", errorTitle, errorMsg];
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取日常图片地址：流程结束"];
    }];
}
- (void)fetchFatePostsSucceed {
    // 更新 latestPost
    if (!!newestPost) {
        NSString *dest = [[MRBUserManager defaultUser].path_root_folder stringByAppendingPathComponent:@"FetchResource/GelbooruLatestPost.plist"];
        
        BOOL success = [NSKeyedArchiver archiveRootObject:newestPost toFile:dest];
        if (success) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已成功保存最新的Post, id: %@", newestPost[@"id"]];
            
            latestPost = newestPost;
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"将最新Post保存至本地时出错，请重新保存"];
        }
    }
    
    [[MRBLogManager defaultManager] cleanLog];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取日常图片地址：流程结束"];
}

@end
