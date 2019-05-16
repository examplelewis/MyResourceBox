//
//  Rule34DownloadAndOrganizeManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "Rule34DownloadAndOrganizeManager.h"
#import "Rule34Header.h"
#import "ResourceGlobalDownloadManager.h"
#import "ResourceGlobalOrganizeManager.h"

@interface Rule34DownloadAndOrganizeManager () {
    NSInteger totalDownloadStep; // -1: Not use == Finished, 0: Initial, 1: Fate, 2: Azur, 3: Overwatch, 4: Anime, 5: Game, 6: Organize Anime, 7: Organize Game
}

@end

@implementation Rule34DownloadAndOrganizeManager

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
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34FatePostTxtPath targetFolderPath:Rule34FateRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 1: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Fate 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Azur 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:Rule34FatePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34AzurPostTxtPath targetFolderPath:Rule34AzurRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 2: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Azur 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Overwatch 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:Rule34AzurPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34OverwatchPostTxtPath targetFolderPath:Rule34OverwatchRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 3: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Overwatch 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Anime 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:Rule34OverwatchPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34AnimePostTxtPath targetFolderPath:Rule34AnimeRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 4: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Anime 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Game 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:Rule34AnimePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34GamePostTxtPath targetFolderPath:Rule34GameRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 5: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 Game 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 18 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:Rule34GamePostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34HPostTxtPath targetFolderPath:Rule34HRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 6: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 18 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 webm 文件, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:Rule34HPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34WebmPostTxtPath targetFolderPath:Rule34WebmRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager prepareDownloading];
        }
            break;
        case 7: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载 webm 文件, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Anime 图片, 开始"];
            
            [[MRBFileManager defaultManager] trashFileAtPath:Rule34WebmPostTxtPath resultItemURL:nil];
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:Rule34AnimePostRenamePlistPath targetFolderPath:Rule34AnimeRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 8: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Anime 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Game 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:Rule34GamePostRenamePlistPath targetFolderPath:Rule34GameRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 9: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 Game 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 18 图片, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:Rule34HPostRenamePlistPath targetFolderPath:Rule34HRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 10: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 18 图片, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 webm 文件, 开始"];
            
            totalDownloadStep += 1;
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:Rule34WebmPostRenamePlistPath targetFolderPath:Rule34WebmRootFolderPath];
            manager.finishBlock = ^{
                [self startOperation];
            };
            [manager startOrganizing];
        }
            break;
        case 11: {
            [[MRBLogManager defaultManager] showLogWithFormat:@"整理 webm 文件, 结束"];
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载并整理日常图片，流程结束"];
        }
            break;
        default:
            break;
    }
}

@end
