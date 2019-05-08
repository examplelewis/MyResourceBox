//
//  Rule34TagManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "Rule34DailyPicManager.h"
#import "Rule34TagStore.h"
#import "HttpManager.h"
#import "Rule34Header.h"

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
    
    NSDictionary *latestPost;
    NSDictionary *newestPost;
}

@end

@implementation Rule34DailyPicManager

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
        
        NSString *filePath = [[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"FetchResource/Rule34LatestPost.plist"];
        latestPost = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath]; // 获取之前保存的Post信息
    }
    
    return self;
}

- (void)startFetching {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取日常图片地址，流程开始"];
    
    [[Rule34TagStore defaultManager] readAllNeededTags]; // 先读取 neededTags
    
    [self fetchSingleDailyPostUrl];
}
- (void)fetchSingleDailyPostUrl {
    [[HttpManager sharedManager] getRule34PostsWithPage:curPage success:^(NSArray *array) {
        if (self->curPage == 0) {
            self->newestPost = [NSDictionary dictionaryWithDictionary:array.firstObject];
        }
        
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
            NSString *animeTags = [[Rule34TagStore defaultManager] getAnimeTags:data[@"tags"]];
            if (animeTags.length > 0) {
                [self->animePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->animeNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", animeTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
            }
            NSString *gameTags = [[Rule34TagStore defaultManager] getGameTags:data[@"tags"]];
            if (gameTags.length > 0) {
                [self->gamePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->gameNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", gameTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
            }
            NSString *hTags = [[Rule34TagStore defaultManager] getHTags:data[@"tags"]];
            if (hTags.length > 0) {
                [self->hPosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->hNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", hTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
            }
        }
        
        if (self->webmPosts.count > 0) {
            NSArray *webmIds = [self->webmPosts valueForKey:@"id"];
            NSMutableArray *webmUrls = [NSMutableArray array];
            for (NSInteger i = 0; i < webmIds.count; i++) {
                [webmUrls addObject:[NSString stringWithFormat:@"https://rule34.xxx/index.php?page=post&s=view&id=%@", webmIds[i]]];
            }
            [UtilityFile exportArray:webmUrls atPath:@"/Users/Mercury/Downloads/Rule34DailyWebmUrl.txt"];
            
            NSArray *webmFileUrls = [self->webmPosts valueForKey:@"file_url"];
            [UtilityFile exportArray:webmFileUrls atPath:@"/Users/Mercury/Downloads/Rule34DailyWebmPostUrl.txt"];
        }
        
        NSArray *fateUrls = [self->fatePosts valueForKey:@"file_url"];
        NSArray *azurUrls = [self->azurPosts valueForKey:@"file_url"];
        NSArray *overwatchUrls = [self->overwatchPosts valueForKey:@"file_url"];
        NSArray *animeUrls = [self->animePosts valueForKey:@"file_url"];
        NSArray *gameUrls = [self->gamePosts valueForKey:@"file_url"];
        NSArray *hUrls = [self->hPosts valueForKey:@"file_url"];
        
        [UtilityFile exportArray:fateUrls atPath:Rule34FatePostTxtPath];
        [UtilityFile exportArray:azurUrls atPath:Rule34AzurPostTxtPath];
        [UtilityFile exportArray:overwatchUrls atPath:Rule34OverwatchPostTxtPath];
        
        [UtilityFile exportArray:animeUrls atPath:Rule34AnimePostTxtPath];
        [self->animeNameInfo writeToFile:Rule34AnimePostRenamePlistPath atomically:YES];
        
        [UtilityFile exportArray:gameUrls atPath:Rule34GamePostTxtPath];
        [self->gameNameInfo writeToFile:Rule34GamePostRenamePlistPath atomically:YES];
        
        if (hUrls.count > 0) {
            [UtilityFile exportArray:hUrls atPath:Rule34HPostTxtPath];
            [self->hNameInfo writeToFile:Rule34HPostRenamePlistPath atomically:YES];
        }
        
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
        NSString *dest = [[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"FetchResource/Rule34LatestPost.plist"];
        
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