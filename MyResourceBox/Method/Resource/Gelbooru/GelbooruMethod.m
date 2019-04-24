//
//  GelbooruMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 18/10/17.
//  Copyright © 2018 gongyuTest. All rights reserved.
//

#import "GelbooruMethod.h"
#import "HttpRequest.h"
#import "GelbooruTagStore.h"
#import "DownloadMethod.h"
#import "DownloadQueueManager.h"

#import "GelbooruDailyPicManager.h"
#import "GelbooruTagEndTimePicManager.h"

@interface GelbooruMethod () {
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
        case 1: {
            GelbooruDailyPicManager *manager = [GelbooruDailyPicManager new];
            [manager startFetching];
        }
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
        case 32: {
            GelbooruTagEndTimePicManager *mananger = [GelbooruTagEndTimePicManager new];
            [mananger prepareFetching];
        }
            break;
        default:
            break;
    }
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
        minPage = 1;
        maxPage = 40;
    } else if (inputComps.count == 2) {
        minPage = 1;
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
    [[HttpRequest shareIndex] getSpecificTagPicFromGelbooruTag:specificTag page:curTagPage - 1 progress:^(NSProgress *downloadProgress) {
        
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
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取 %@ 图片地址：第 %ld 页已获取", strongSelf->specificTag, strongSelf->curTagPage];
        
        // 如果某一页小于100条原始数据，说明是最后一页
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
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruFatePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadAzurPic];
        }
            break;
        case 2: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Azur 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Overwatch 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruAzurPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadOverwatchPic];
        }
            break;
        case 3: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Overwatch 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Anime 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruOverwatchPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadAnimePic];
        }
            break;
        case 4: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Anime 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Game 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruAnimePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            [self downloadGamePic];
        }
            break;
        case 5: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Game 图片, 结束"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruGamePostTxtPath resultItemURL:nil];
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
    [self downloadGelbooruPic:GelbooruFatePostTxtPath targetFolderPath:GelbooruFateRootFolderPath organizeAfterDownload:NO];
}
- (void)downloadAzurPic {
    [self downloadGelbooruPic:GelbooruAzurPostTxtPath targetFolderPath:GelbooruAzurRootFolderPath organizeAfterDownload:NO];
}
- (void)downloadOverwatchPic {
    [self downloadGelbooruPic:GelbooruOverwatchPostTxtPath targetFolderPath:GelbooruOverwatchRootFolderPath organizeAfterDownload:NO];
}
- (void)downloadAnimePic {
    [self downloadGelbooruPic:GelbooruAnimePostTxtPath targetFolderPath:GelbooruAnimeRootFolderPath organizeAfterDownload:YES];
}
- (void)downloadGamePic {
    [self downloadGelbooruPic:GelbooruGamePostTxtPath targetFolderPath:GelbooruGameRootFolderPath organizeAfterDownload:YES];
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
    
    if (![[FileManager defaultManager] isContentExistAtPath:GelbooruAnimePostRenamePlistPath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 不存在，请检查下载文件夹", GelbooruAnimePostRenamePlistPath.lastPathComponent];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的动漫图片, 流程结束"];
        return;
    }
    
    NSDictionary *renameInfo = [NSDictionary dictionaryWithContentsOfFile:GelbooruAnimePostRenamePlistPath];
    for (NSInteger i = 0; i < renameInfo.allKeys.count; i++) {
        NSString *key = renameInfo.allKeys[i]; // key 是下载好的文件名
        NSString *value = renameInfo[key];
        value = [value stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@":" withString:@" "];
        NSString *downloadPath = [NSString stringWithFormat:@"%@%@", GelbooruAnimeRootFolderPath, key];
        NSString *targetPath = [NSString stringWithFormat:@"%@%@", GelbooruAnimeRootFolderPath, value];
        
        [[FileManager defaultManager] moveItemAtPath:downloadPath toDestPath:targetPath];
    }
    
    [[FileManager defaultManager] trashFileAtPath:GelbooruAnimePostRenamePlistPath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的动漫图片, 流程结束"];
    
    if (totalDownloadStep != -1) {
        [self downloadAndOrganize];
    }
}
- (void)organizeGamePic {
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的游戏图片, 流程开始"];
    
    if (![[FileManager defaultManager] isContentExistAtPath:GelbooruGamePostRenamePlistPath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 不存在，请检查下载文件夹", GelbooruGamePostRenamePlistPath.lastPathComponent];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的游戏图片, 流程结束"];
        return;
    }
    
    NSDictionary *renameInfo = [NSDictionary dictionaryWithContentsOfFile:GelbooruGamePostRenamePlistPath];
    for (NSInteger i = 0; i < renameInfo.allKeys.count; i++) {
        NSString *key = renameInfo.allKeys[i]; // key 是下载好的文件名
        NSString *value = renameInfo[key];
        value = [value stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@":" withString:@" "];
        NSString *downloadPath = [NSString stringWithFormat:@"%@%@", GelbooruGameRootFolderPath, key];
        NSString *targetPath = [NSString stringWithFormat:@"%@%@", GelbooruGameRootFolderPath, value];
        
        [[FileManager defaultManager] moveItemAtPath:downloadPath toDestPath:targetPath];
    }
    
    [[FileManager defaultManager] trashFileAtPath:GelbooruGamePostRenamePlistPath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理下载的游戏图片, 流程结束"];
    
    if (totalDownloadStep != -1) {
        [self downloadAndOrganize];
    }
}

#pragma mark - 移动整理好的日常图片
- (void)movePicToDayFolder {
    [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程开始"];
    
    [self moveFilesToDayFolderFromFolder:GelbooruFateRootFolderPath];
    [self moveFilesToDayFolderFromFolder:GelbooruAzurRootFolderPath];
    [self moveFilesToDayFolderFromFolder:GelbooruOverwatchRootFolderPath];
    [self moveFilesToDayFolderFromFolder:GelbooruAnimeRootFolderPath];
    [self moveFilesToDayFolderFromFolder:GelbooruGameRootFolderPath];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程结束"];
}
- (void)moveFilesToDayFolderFromFolder:(NSString *)fromFolder {
    if (![[FileManager defaultManager] isContentExistAtPath:fromFolder]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件夹不存在，无法移动内容到 Day 文件夹中", fromFolder];
        
        return;
    }
    
    NSString *toFolder = [fromFolder stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
    [[FileManager defaultManager] createFolderAtPathIfNotExist:toFolder];
    
    NSArray *fromFiles = [[FileManager defaultManager] getFilePathsInFolder:fromFolder];
    for (NSInteger i = 0; i < fromFiles.count; i++) {
        NSString *fromFile = fromFiles[i];
        NSString *toFile = [fromFile stringByReplacingOccurrencesOfString:@"/Users/Mercury/Downloads/" withString:@"/Users/Mercury/Pictures/Day/"];
        
        [[FileManager defaultManager] moveItemAtPath:fromFile toDestPath:toFile];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件内所有文件以及移动到 %@ 中", fromFolder, toFolder];
    
    [[FileManager defaultManager] trashFileAtPath:fromFolder resultItemURL:nil];
    [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件夹已被移动到废纸篓中", fromFolder];
}

@end
