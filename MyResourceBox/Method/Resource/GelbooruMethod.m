//
//  GelbooruMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 18/10/17.
//  Copyright © 2018 gongyuTest. All rights reserved.
//

#import "GelbooruMethod.h"
#import "HttpRequest.h"
#import "GelbooruTagManager.h"
#import "DownloadMethod.h"
#import "DownloadQueueManager.h"

@interface GelbooruMethod () {
    NSInteger curPage;
    NSMutableArray *fatePosts; // fate
    NSMutableArray *azurPosts; // 碧蓝航线
    NSMutableArray *overwatchPosts; // overwatch
    NSMutableArray *animePosts; // 动漫
    NSMutableArray *gamePosts; // 游戏
    NSMutableDictionary *animeNameInfo;
    NSMutableDictionary *gameNameInfo;
    NSDictionary *latestPost;
    NSDictionary *newestPost;
    NSInteger totalDownloadStep; // -1: Not use == Finished, 0: Initial, 1: Fate, 2: Azur, 3: Overwatch, 4: Anime, 5: Game, 6: Organize Anime, 7: Organize Game
    
    NSString *specificTag;
    NSInteger minPage;
    NSInteger maxPage;
    NSInteger curTagPage;
    NSMutableArray *specificTagPosts;
}

@end

@implementation GelbooruMethod

static GelbooruMethod *method;
+ (GelbooruMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[GelbooruMethod alloc] init];
    });
    
    return method;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        totalDownloadStep = -1;
    }
    
    return self;
}

- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1:
            [self fetchDailyPostUrl];
            break;
        case 2: {
            totalDownloadStep = 0;
            [self downloadAndOrganize];
        }
            break;
        case 3:
            [self movePicToDayFolder];
            break;
        case 11:
            [self downloadFatePic];
            break;
        case 12:
            [self downloadAzurPic];
            break;
        case 13:
            [self downloadOverwatchPic];
            break;
        case 14:
            [self downloadAnimePic];
            break;
        case 15:
            [self downloadGamePic];
            break;
        case 21:
            [self organizeAnimePic];
            break;
        case 22:
            [self organizeGamePic];
            break;
        case 31:
            [self fetchSpecificTagPostUrl];
            break;
        default:
            break;
    }
}

#pragma mark - 获取 Fate 和 ACG 图片地址
- (void)fetchDailyPostUrl {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 Fate 和 ACG 图片地址，流程开始"];
    
    curPage = 0;
    fatePosts = [NSMutableArray array];
    azurPosts = [NSMutableArray array];
    overwatchPosts = [NSMutableArray array];
    animePosts = [NSMutableArray array];
    gamePosts = [NSMutableArray array];
    animeNameInfo = [NSMutableDictionary dictionary];
    gameNameInfo = [NSMutableDictionary dictionary];
    
    NSString *filePath = [[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"latestPost.plist"];
    latestPost = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath]; // 获取之前保存的Post信息
    
    [self fetchSingleDailyPostUrl];
}
- (void)fetchSingleDailyPostUrl {
    __weak typeof(self) weakSelf = self;
    [[HttpRequest shareIndex] getGelbooruPostsWithPage:curPage progress:^(NSProgress *downloadProgress) {
        
    } success:^(NSArray *array) {
        if (self->curPage == 0) {
            self->newestPost = [NSDictionary dictionaryWithDictionary:array.firstObject];
        }
        
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801) {
                continue;
            }
            
            if ([data[@"source"] isEqualToString:@""]) {
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
            
            NSString *animeTags = [[GelbooruTagManager defaultManager] getAnimeTags:data[@"tags"]];
            if (animeTags.length > 0) {
                [self->animePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->animeNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", animeTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
                
                continue;
            }
            NSString *gameTags = [[GelbooruTagManager defaultManager] getGameTags:data[@"tags"]];
            if (gameTags.length > 0) {
                [self->gamePosts addObject:data];
                
                NSString *donwloadFileNameAndExtension = [data[@"file_url"] lastPathComponent];
                [self->gameNameInfo setObject:[NSString stringWithFormat:@"%@ - %@", gameTags, donwloadFileNameAndExtension] forKey:donwloadFileNameAndExtension];
                
                continue;
            }
        }
        
        NSArray *fateUrls = [self->fatePosts valueForKey:@"file_url"];
        NSArray *azurUrls = [self->azurPosts valueForKey:@"file_url"];
        NSArray *overwatchUrls = [self->overwatchPosts valueForKey:@"file_url"];
        NSArray *animeUrls = [self->animePosts valueForKey:@"file_url"];
        NSArray *gameUrls = [self->gamePosts valueForKey:@"file_url"];
        
        [UtilityFile exportArray:fateUrls atPath:@"/Users/Mercury/Downloads/GelbooruFatePostUrl.txt"];
        [UtilityFile exportArray:azurUrls atPath:@"/Users/Mercury/Downloads/GelbooruAzurPostUrl.txt"];
        [UtilityFile exportArray:overwatchUrls atPath:@"/Users/Mercury/Downloads/GelbooruOverwatchPostUrl.txt"];
        [UtilityFile exportArray:animeUrls atPath:@"/Users/Mercury/Downloads/GelbooruAnimePostUrl.txt"];
        [UtilityFile exportArray:gameUrls atPath:@"/Users/Mercury/Downloads/GelbooruGamePostUrl.txt"];
        [self->animeNameInfo writeToFile:@"/Users/Mercury/Downloads/GelbooruAnimePostRenameInfo.plist" atomically:YES];
        [self->gameNameInfo writeToFile:@"/Users/Mercury/Downloads/GelbooruGamePostRenameInfo.plist" atomically:YES];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 Fate 和 ACG 图片地址：第 %ld 页已获取", self->curPage + 1];
        
        // 超过 200 页，就报错了
        if (self->curPage >= 199) {
            [weakSelf fetchFatePostsSucceed];
            return;
        }
        
        NSDictionary *lastData = [NSDictionary dictionaryWithDictionary:array.lastObject];
        if ([lastData[@"id"] integerValue] <= [self->latestPost[@"id"] integerValue]) {
            [weakSelf fetchFatePostsSucceed];
        } else {
            self->curPage += 1;
            [weakSelf fetchSingleDailyPostUrl];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 Fate 和 ACG 图片地址，遇到错误：%@: %@", errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 Fate 和 ACG 图片地址：流程结束"];
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
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 Fate 和 ACG 图片地址：流程结束"];
    
    curPage = 0;
    [fatePosts removeAllObjects];
    [azurPosts removeAllObjects];
    [overwatchPosts removeAllObjects];
    [animePosts removeAllObjects];
    [gamePosts removeAllObjects];
}

#pragma mark - 获取特定标签的图片地址
- (void)fetchSpecificTagPostUrl {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取特定标签的图片地址，流程开始"];
    
    NSString *inputString = [AppDelegate defaultVC].inputTextView.string;
    if (inputString.length == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSArray *inputComps = [inputString componentsSeparatedByString:@"|"];
    specificTag = inputComps[0];
    if (inputComps.count == 1) {
        minPage = 0;
        maxPage = 40;
    } else if (inputComps.count == 2) {
        minPage = 0;
        maxPage = [inputComps[1] integerValue];
    } else {
        minPage = [inputComps[1] integerValue];
        maxPage = [inputComps[2] integerValue];
    }
    curTagPage = minPage;
    DDLogInfo(@"fetchSpecificTagPostUrl minPage: %ld, maxPage: %ld, curTagPage: %ld", minPage, maxPage, curTagPage);
    
    specificTagPosts = [NSMutableArray array];
    
    [self fetchSingleSepcificTagPostUrl];
}
- (void)fetchSingleSepcificTagPostUrl {
    __weak typeof(self) weakSelf = self;
    [[HttpRequest shareIndex] getSpecificTagPicFromGelbooruTag:specificTag page:curTagPage progress:^(NSProgress *downloadProgress) {
        
    } success:^(NSArray *array) {
        __strong typeof(self) strongSelf = weakSelf;
        
        for (NSInteger i = 0; i < array.count; i++) {
            NSDictionary *data = [NSDictionary dictionaryWithDictionary:array[i]];
            if ([data[@"width"] integerValue] < 801 && [data[@"height"] integerValue] < 801) {
                continue;
            }
            
            if ([data[@"source"] isEqualToString:@""]) {
                continue;
            }
            
            [strongSelf->specificTagPosts addObject:data];
        }
        
        NSArray *specificTagUrls = [strongSelf->specificTagPosts valueForKey:@"file_url"];
        
        [UtilityFile exportArray:specificTagUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/Gelbooru %@ PostUrl.txt", strongSelf->specificTag]];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", strongSelf->specificTag, strongSelf->curTagPage + 1];
        
        // 超过 200 页，就报错了；如果某一页小于100条原始数据，说明是最后一页
        if (strongSelf->curTagPage >= strongSelf->maxPage || array.count != 100) {
            [strongSelf fetchSpecificTagPostsSucceed];
        } else {
            strongSelf->curTagPage += 1;
            [strongSelf fetchSingleSepcificTagPostUrl];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        DDLogError(@"%@: %@", errorTitle, errorMsg);
        
        __strong typeof(self) strongSelf = weakSelf;
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址，遇到错误：%@: %@", strongSelf->specificTag, errorTitle, errorMsg];
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：流程结束", strongSelf->specificTag];
    }];
}
- (void)fetchSpecificTagPostsSucceed {
    [[UtilityFile sharedInstance] cleanLog];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：流程结束", specificTag];
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 图片地址:\n%@", specificTag, [UtilityFile convertResultArray:[self->specificTagPosts valueForKey:@"file_url"]]];
    
    curTagPage = 0;
    [specificTagPosts removeAllObjects];
    specificTag = nil;
    maxPage = 0;
}

#pragma mark - 下载并整理日常图片
- (void)downloadAndOrganize {
    [[UtilityFile sharedInstance] showLogWithFormat:@"下载并整理日常图片，流程开始"];
    
    switch (totalDownloadStep) {
        case 0: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Fate 图片, 开始"];
            
            totalDownloadStep += 1;
            [self downloadFatePic];
        }
            break;
        case 1: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Fate 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Azur 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:@"/Users/Mercury/Downloads/GelbooruFatePostUrl.txt" resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadAzurPic];
        }
            break;
        case 2: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Azur 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Overwatch 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:@"/Users/Mercury/Downloads/GelbooruAzurPostUrl.txt" resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadOverwatchPic];
        }
            break;
        case 3: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Overwatch 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Anime 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:@"/Users/Mercury/Downloads/GelbooruOverwatchPostUrl.txt" resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadAnimePic];
        }
            break;
        case 4: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Anime 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Game 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:@"/Users/Mercury/Downloads/GelbooruAnimePostUrl.txt" resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadGamePic];
        }
            break;
        case 5: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Game 图片, 结束"];
            
            [[FileManager defaultManager] trashFileAtPath:@"/Users/Mercury/Downloads/GelbooruGamePostUrl.txt" resultItemURL:nil];
            totalDownloadStep += 1;
            [self organizeAnimePic];
        }
            break;
        case 6: {
            totalDownloadStep += 1;
            [self organizeGamePic];
        }
            break;
        case 7: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载并整理日常图片，流程结束"];
            
            totalDownloadStep = -1;
        }
            break;
        default:
            break;
    }
}

#pragma mark - 下载图片
- (void)downloadFatePic {
    [self downloadGelbooruPic:@"/Users/Mercury/Downloads/GelbooruFatePostUrl.txt" targetFolderPath:@"/Users/Mercury/Downloads/~Fate/" organizeAfterDownload:NO];
}
- (void)downloadAzurPic {
    [self downloadGelbooruPic:@"/Users/Mercury/Downloads/GelbooruAzurPostUrl.txt" targetFolderPath:@"/Users/Mercury/Downloads/~Azur/" organizeAfterDownload:NO];
}
- (void)downloadOverwatchPic {
    [self downloadGelbooruPic:@"/Users/Mercury/Downloads/GelbooruOverwatchPostUrl.txt" targetFolderPath:@"/Users/Mercury/Downloads/~Overwatch/" organizeAfterDownload:NO];
}
- (void)downloadAnimePic {
    [self downloadGelbooruPic:@"/Users/Mercury/Downloads/GelbooruAnimePostUrl.txt" targetFolderPath:@"/Users/Mercury/Downloads/~Anime/" organizeAfterDownload:YES];
}
- (void)downloadGamePic {
    [self downloadGelbooruPic:@"/Users/Mercury/Downloads/GelbooruGamePostUrl.txt" targetFolderPath:@"/Users/Mercury/Downloads/~Game/" organizeAfterDownload:YES];
}
- (void)downloadGelbooruPic:(NSString *)fetchedFilePath targetFolderPath:(NSString *)targetFolderPath organizeAfterDownload:(BOOL)organize {
    if (![[FileManager defaultManager] isContentExistAtPath:fetchedFilePath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 不存在", fetchedFilePath.lastPathComponent];
        [self downloadAndOrganize];
        
        return;
    }
    
    NSString *url = [[NSString alloc] initWithContentsOfFile:fetchedFilePath encoding:NSUTF8StringEncoding error:nil];
    if (url.length == 0) {
        [self downloadAndOrganize];
        
        return;
    }
    NSArray *urls = [url componentsSeparatedByString:@"\n"];
    NSSet *urlSet = [NSSet setWithArray:urls];
    NSArray *newUrls = [NSArray arrayWithArray:urlSet.allObjects];
    
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:newUrls];
    manager.maxConcurrentOperationCount = 10;
    manager.maxRedownloadTimes = 1;
    manager.timeoutInterval = 15;
    manager.downloadPath = targetFolderPath;
    if (totalDownloadStep != -1) {
        manager.finishBlock = ^{
            [self downloadAndOrganize];
        };
    }
    manager.showAlertAfterFinished = NO;
    
    [manager startDownload];
}

#pragma mark - 整理图片
- (void)organizeAnimePic {
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的动漫图片, 流程开始"];
    NSString *plistFilePath = @"/Users/Mercury/Downloads/GelbooruAnimePostRenameInfo.plist";
    NSString *animeRootFodlerPath = @"/Users/Mercury/Downloads/~Anime/";
    
    if (![[FileManager defaultManager] isContentExistAtPath:plistFilePath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 不存在，请检查下载文件夹", plistFilePath];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的动漫图片, 流程结束"];
        return;
    }
    
    NSDictionary *renameInfo = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    for (NSInteger i = 0; i < renameInfo.allKeys.count; i++) {
        NSString *key = renameInfo.allKeys[i]; // key 是下载好的文件名
        NSString *value = renameInfo[key];
        value = [value stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@":" withString:@" "];
        NSString *downloadPath = [NSString stringWithFormat:@"%@%@", animeRootFodlerPath, key];
        NSString *targetPath = [NSString stringWithFormat:@"%@%@", animeRootFodlerPath, value];
        
        [[FileManager defaultManager] moveItemAtPath:downloadPath toDestPath:targetPath];
    }
    
    [[FileManager defaultManager] trashFileAtPath:plistFilePath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的动漫图片, 流程结束"];
    
    if (totalDownloadStep != -1) {
        [self downloadAndOrganize];
    }
}
- (void)organizeGamePic {
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的游戏图片, 流程开始"];
    NSString *plistFilePath = @"/Users/Mercury/Downloads/GelbooruGamePostRenameInfo.plist";
    NSString *gameRootFodlerPath = @"/Users/Mercury/Downloads/~Game/";
    
    if (![[FileManager defaultManager] isContentExistAtPath:plistFilePath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 不存在，请检查下载文件夹", plistFilePath.lastPathComponent];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的游戏图片, 流程结束"];
        return;
    }
    
    NSDictionary *renameInfo = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    for (NSInteger i = 0; i < renameInfo.allKeys.count; i++) {
        NSString *key = renameInfo.allKeys[i]; // key 是下载好的文件名
        NSString *value = renameInfo[key];
        value = [value stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@":" withString:@" "];
        NSString *downloadPath = [NSString stringWithFormat:@"%@%@", gameRootFodlerPath, key];
        NSString *targetPath = [NSString stringWithFormat:@"%@%@", gameRootFodlerPath, value];
        
        [[FileManager defaultManager] moveItemAtPath:downloadPath toDestPath:targetPath];
    }
    
    [[FileManager defaultManager] trashFileAtPath:plistFilePath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的游戏图片, 流程结束"];
    
    if (totalDownloadStep != -1) {
        [self downloadAndOrganize];
    }
}

#pragma mark - 移动整理好的日常图片
- (void)movePicToDayFolder {
    [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程开始"];
    
    [self moveFilesToDayFolderFromFolder:@"/Users/Mercury/Downloads/~Fate/"];
    [self moveFilesToDayFolderFromFolder:@"/Users/Mercury/Downloads/~Azur/"];
    [self moveFilesToDayFolderFromFolder:@"/Users/Mercury/Downloads/~Overwatch/"];
    NSArray *animeFolders = [[FileManager defaultManager] getSubFoldersPathInFolder:@"/Users/Mercury/Downloads/~Anime/"];
    for (NSInteger i = 0; i < animeFolders.count; i++) {
        NSString *animeFolder = animeFolders[i];
        [self moveFilesToDayFolderFromFolder:animeFolder];
    }
    NSArray *gameFolders = [[FileManager defaultManager] getSubFoldersPathInFolder:@"/Users/Mercury/Downloads/~Game/"];
    for (NSInteger i = 0; i < gameFolders.count; i++) {
        NSString *gameFolder = gameFolders[i];
        [self moveFilesToDayFolderFromFolder:gameFolder];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程结束"];
}
- (void)moveFilesToDayFolderFromFolder:(NSString *)fromFolder {
    NSString *toFolder = [fromFolder stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
    [[FileManager defaultManager] createFolderAtPathIfNotExist:toFolder];
    
    NSArray *fromFiles = [[FileManager defaultManager] getFilePathsInFolder:fromFolder];
    for (NSInteger i = 0; i < fromFiles.count; i++) {
        NSString *fromFile = fromFiles[i];
        NSString *toFile = [fromFile stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
        
        [[FileManager defaultManager] moveItemAtPath:fromFile toDestPath:toFile];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件内所有文件以及移动到 %@ 中", fromFolder, toFolder];
}

@end
