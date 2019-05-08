//
//  GelbooruDownloadAndOrganizeManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruDownloadAndOrganizeManager.h"
#import "GelbooruHeader.h"
#import "GelbooruDownloadManager.h"
#import "GelbooruOrganizeManager.h"

@interface GelbooruDownloadAndOrganizeManager () {
    NSInteger totalDownloadStep; // -1: Not use == Finished, 0: Initial, 1: Fate, 2: Azur, 3: Overwatch, 4: Anime, 5: Game, 6: Organize Anime, 7: Organize Game
}

@end

@implementation GelbooruDownloadAndOrganizeManager

- (instancetype)init {
    self = [super init];
    if (self) {
        totalDownloadStep = 0;
    }
    
    return self;
}

- (void)startOperation {
    switch (totalDownloadStep) {
        case 0: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载并整理日常图片，流程开始"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Fate 图片, 开始"];
            
            totalDownloadStep += 1;
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruFatePostTxtPath targetFolderPath:GelbooruFateRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 1: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Fate 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Azur 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruFatePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruAzurPostTxtPath targetFolderPath:GelbooruAzurRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 2: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Azur 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Overwatch 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruAzurPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruOverwatchPostTxtPath targetFolderPath:GelbooruOverwatchRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 3: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Overwatch 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Anime 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruOverwatchPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruAnimePostTxtPath targetFolderPath:GelbooruAnimeRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 4: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Anime 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Game 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruAnimePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruGamePostTxtPath targetFolderPath:GelbooruGameRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 5: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 Game 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 18 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruGamePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruHPostTxtPath targetFolderPath:GelbooruHRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 6: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 18 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 webm 文件, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruHPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruWebmPostTxtPath targetFolderPath:GelbooruWebmRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 7: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载 webm 文件, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 Anime 图片, 开始"];
            
            [[FileManager defaultManager] trashFileAtPath:GelbooruWebmPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            GelbooruOrganizeManager *manager = [[GelbooruOrganizeManager alloc] initWithPlistFilePath:GelbooruAnimePostRenamePlistPath targetFolderPath:GelbooruAnimeRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 8: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 Anime 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 Game 图片, 开始"];
            
            totalDownloadStep += 1;
            
            GelbooruOrganizeManager *manager = [[GelbooruOrganizeManager alloc] initWithPlistFilePath:GelbooruGamePostRenamePlistPath targetFolderPath:GelbooruGameRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 9: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 Game 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 18 图片, 开始"];
            
            totalDownloadStep += 1;
            
            GelbooruOrganizeManager *manager = [[GelbooruOrganizeManager alloc] initWithPlistFilePath:GelbooruHPostRenamePlistPath targetFolderPath:GelbooruHRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 10: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 18 图片, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 webm 文件, 开始"];
            
            totalDownloadStep += 1;
            
            GelbooruOrganizeManager *manager = [[GelbooruOrganizeManager alloc] initWithPlistFilePath:GelbooruWebmPostRenamePlistPath targetFolderPath:GelbooruWebmRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 11: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"整理 webm 文件, 结束"];
            [[UtilityFile sharedInstance] showLogWithFormat:@"下载并整理日常图片，流程结束"];
        }
            break;
        default:
            break;
    }
}

@end
