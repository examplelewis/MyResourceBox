//
//  GelbooruTagManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruDailyPicManager.h"
#import "GelbooruTagStore.h"
#import "HttpManager.h"
#import "GelbooruHeader.h"

@interface GelbooruDailyPicManager () {
    NSInteger curPage;
    
    NSMutableArray *webmPosts; // webm
    NSMutableArray *fatePosts; // fate
    NSMutableArray *azurPosts; // 碧蓝航线
    NSMutableArray *overwatchPosts; // overwatch
    NSMutableArray *animePosts; // 动漫
    NSMutableArray *gamePosts; // 游戏
    
    NSMutableDictionary *animeNameInfo;
    NSMutableDictionary *gameNameInfo;
    
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
        animeNameInfo = [NSMutableDictionary dictionary];
        gameNameInfo = [NSMutableDictionary dictionary];
        
        NSString *filePath = [[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"latestPost.plist"];
        latestPost = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath]; // 获取之前保存的Post信息
    }
    
    return self;
}

- (void)startFetching {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取日常图片地址，流程开始"];
    
    [[GelbooruTagStore defaultManager] readAllNeededTags]; // 先读取 neededTags
    
    [self fetchSingleDailyPostUrl];
}
- (void)fetchSingleDailyPostUrl {
    [[HttpManager sharedManager] getGelbooruPostsWithPage:curPage success:^(NSArray *array) {
        if (self->curPage == 0) {
            self->newestPost = [NSDictionary dictionaryWithDictionary:array.firstObject];
        }
        
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801) {
                continue;
            }
            
//            if ([data[@"source"] isEqualToString:@""]) {
//                continue;
//            }
            
            if ([[data[@"tags"] pathExtension] isEqualToString:@"webm"]) {
                [self->webmPosts addObject:data];
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
            
            NSString *animeTags = [[GelbooruTagStore defaultManager] getAnimeTags:data[@"tags"]];
            if (animeTags.length > 0) {
                [self->animePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->animeNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", animeTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
                
                continue;
            }
            NSString *gameTags = [[GelbooruTagStore defaultManager] getGameTags:data[@"tags"]];
            if (gameTags.length > 0) {
                [self->gamePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->gameNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", gameTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
                
                continue;
            }
        }
        
        if (self->webmPosts.count > 0) {
            NSArray *webmIds = [self->webmPosts valueForKey:@"id"];
            NSMutableArray *webmUrls = [NSMutableArray array];
            for (NSInteger i = 0; i < webmIds.count; i++) {
                [webmUrls addObject:[NSString stringWithFormat:@"https://gelbooru.com/index.php?page=post&s=view&id=%@", webmIds[i]]];
            }
            [UtilityFile exportArray:webmUrls atPath:GelbooruWebmPostTxtPath];
        }
        
        NSArray *fateUrls = [self->fatePosts valueForKey:@"file_url"];
        NSArray *azurUrls = [self->azurPosts valueForKey:@"file_url"];
        NSArray *overwatchUrls = [self->overwatchPosts valueForKey:@"file_url"];
        NSArray *animeUrls = [self->animePosts valueForKey:@"file_url"];
        NSArray *gameUrls = [self->gamePosts valueForKey:@"file_url"];
        
        [UtilityFile exportArray:fateUrls atPath:GelbooruFatePostTxtPath];
        [UtilityFile exportArray:azurUrls atPath:GelbooruAzurPostTxtPath];
        [UtilityFile exportArray:overwatchUrls atPath:GelbooruOverwatchPostTxtPath];
        [UtilityFile exportArray:animeUrls atPath:GelbooruAnimePostTxtPath];
        [UtilityFile exportArray:gameUrls atPath:GelbooruGamePostTxtPath];
        [self->animeNameInfo writeToFile:GelbooruAnimePostRenamePlistPath atomically:YES];
        [self->gameNameInfo writeToFile:GelbooruGamePostRenamePlistPath atomically:YES];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取日常图片地址：第 %ld 页已获取", self->curPage + 1];
        
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
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取日常图片地址，遇到错误：%@: %@", errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取日常图片地址：流程结束"];
    }];
}
- (void)fetchFatePostsSucceed {
    // 更新 latestPost
    if (!!newestPost) {
        NSString *dest = [[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"latestPost.plist"];
        
        BOOL success = [NSKeyedArchiver archiveRootObject:newestPost toFile:dest];
        if (success) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"已成功保存最新的Post, id: %@", newestPost[@"id"]];
            
            latestPost = newestPost;
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"将最新Post保存至本地时出错，请重新保存"];
        }
    }
    
    [[UtilityFile sharedInstance] cleanLog];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取日常图片地址：流程结束"];
}

@end
