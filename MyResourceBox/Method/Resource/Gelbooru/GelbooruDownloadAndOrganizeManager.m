//
//  GelbooruDownloadAndOrganizeManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "GelbooruDownloadAndOrganizeManager.h"
#import "GelbooruHeader.h"
#import "ResourceGlobalDownloadManager.h"
#import "ResourceGlobalOrganizeManager.h"

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
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载并整理日常图片，流程开始"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Fate 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruFatePostTxtPath targetFolderPath:GelbooruFateRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 1: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Fate 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Azur 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:GelbooruFatePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruAzurPostTxtPath targetFolderPath:GelbooruAzurRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 2: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Azur 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Overwatch 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:GelbooruAzurPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruOverwatchPostTxtPath targetFolderPath:GelbooruOverwatchRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 3: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Overwatch 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Anime 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:GelbooruOverwatchPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruAnimePostTxtPath targetFolderPath:GelbooruAnimeRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 4: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Anime 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Game 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:GelbooruAnimePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruGamePostTxtPath targetFolderPath:GelbooruGameRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 5: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Game 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 18 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:GelbooruGamePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruHPostTxtPath targetFolderPath:GelbooruHRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 6: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 18 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 webm 文件, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:GelbooruHPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruWebmPostTxtPath targetFolderPath:GelbooruWebmRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 7: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 webm 文件, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Fate 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:GelbooruWebmPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruFatePostRenamePlistPath targetFolderPath:GelbooruFateRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 8: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Fate 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Azur Lane 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruAzurPostRenamePlistPath targetFolderPath:GelbooruAzurRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 9: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Azur Lane 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Overwatch 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruOverwatchPostRenamePlistPath targetFolderPath:GelbooruOverwatchRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 10: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Overwatch 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Anime 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruAnimePostRenamePlistPath targetFolderPath:GelbooruAnimeRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 11: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Anime 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Game 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruGamePostRenamePlistPath targetFolderPath:GelbooruGameRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 12: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Game 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 18 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruHPostRenamePlistPath targetFolderPath:GelbooruHRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 13: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 18 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 webm 文件, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruWebmPostRenamePlistPath targetFolderPath:GelbooruWebmRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 14: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 webm 文件, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载并整理日常图片，流程结束"];
        }
            break;
        default:
            break;
    }
}

@end
