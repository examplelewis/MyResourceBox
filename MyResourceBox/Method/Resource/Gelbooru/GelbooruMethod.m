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
#import "GelbooruTagPagePicManager.h"
#import "GelbooruDownloadManager.h"
#import "GelbooruFileMoveManager.h"

@interface GelbooruMethod () {
    NSInteger totalDownloadStep; // -1: Not use == Finished, 0: Initial, 1: Fate, 2: Azur, 3: Overwatch, 4: Anime, 5: Game, 6: Organize Anime, 7: Organize Game
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
        case 3: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程开始"];
            
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruFateRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruAzurRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruOverwatchRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruAnimeRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruGameRootFolderPath];
            
            [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程结束"];
        }
            break;
        case 11: {
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruFatePostTxtPath targetFolderPath:GelbooruFateRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 12: {
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruAzurPostTxtPath targetFolderPath:GelbooruAzurRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 13: {
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruOverwatchPostTxtPath targetFolderPath:GelbooruOverwatchRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 14: {
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruAnimePostTxtPath targetFolderPath:GelbooruAnimeRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 15: {
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruGamePostTxtPath targetFolderPath:GelbooruGameRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 21:
            [self organizeAnimePic];
            break;
        case 22:
            [self organizeGamePic];
            break;
        case 31: {
            GelbooruTagPagePicManager *manager = [GelbooruTagPagePicManager new];
            [manager startFetching];
        }
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
    
}
- (void)downloadAzurPic {
    
}
- (void)downloadOverwatchPic {
    
}
- (void)downloadAnimePic {
    
}
- (void)downloadGamePic {
    
}
- (void)downloadGelbooruPic:(NSString *)fetchedFilePath targetFolderPath:(NSString *)targetFolderPath organizeAfterDownload:(BOOL)organize {
    
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

@end
