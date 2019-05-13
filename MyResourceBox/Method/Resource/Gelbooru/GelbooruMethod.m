//
//  GelbooruMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 18/10/17.
//  Copyright © 2018 gongyuTest. All rights reserved.
//

#import "GelbooruMethod.h"
#import "GelbooruHeader.h"

#import "GelbooruDailyPicManager.h"
#import "GelbooruTagEndTimePicManager.h"
#import "GelbooruTagPagePicManager.h"
#import "GelbooruTagPagePicExportTagsManager.h"
#import "GelbooruDownloadManager.h"
#import "GelbooruOrganizeManager.h"
#import "GelbooruFileMoveManager.h"
#import "GelbooruDownloadAndOrganizeManager.h"
#import "ResourceGlobalTagExtractManager.h"

@implementation GelbooruMethod

+ (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            GelbooruDailyPicManager *manager = [GelbooruDailyPicManager new];
            [manager startFetching];
        }
            break;
        case 2: {
            GelbooruDownloadAndOrganizeManager *manager = [GelbooruDownloadAndOrganizeManager new];
            [manager startOperation];
        }
            break;
        case 3: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程开始"];
            
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruFateRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruAzurRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruOverwatchRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruAnimeRootFolderPath];
            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruGameRootFolderPath];
//            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruHRootFolderPath];
//            [GelbooruFileMoveManager moveFilesToDayFolderFromFolder:GelbooruWebmRootFolderPath];
            
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
        case 16: {
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:GelbooruHPostTxtPath targetFolderPath:GelbooruHRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 17: {
            NSString *input = [AppDelegate defaultVC].inputTextView.string;
            if (input.length == 0) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
                return;
            }
            
            NSString *txtFilePath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/Gelbooru %@ PostUrl.txt", input];
            NSString *targetFolderPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/%@/", input];
            
            GelbooruDownloadManager *manager = [[GelbooruDownloadManager alloc] initWithTXTFilePath:txtFilePath targetFolderPath:targetFolderPath];
            manager.showAlertAfterFinished = YES;
            [manager prepareDownloading];
        }
            break;
        case 21: {
            GelbooruOrganizeManager *manager = [[GelbooruOrganizeManager alloc] initWithPlistFilePath:GelbooruAnimePostRenamePlistPath targetFolderPath:GelbooruAnimeRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 22: {
            GelbooruOrganizeManager *manager = [[GelbooruOrganizeManager alloc] initWithPlistFilePath:GelbooruGamePostRenamePlistPath targetFolderPath:GelbooruGameRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 23: {
            GelbooruOrganizeManager *manager = [[GelbooruOrganizeManager alloc] initWithPlistFilePath:GelbooruHPostRenamePlistPath targetFolderPath:GelbooruHRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 31: {
            GelbooruTagPagePicManager *manager = [GelbooruTagPagePicManager new];
            [manager startFetching];
        }
            break;
        case 32: {
            GelbooruTagPagePicManager *manager = [GelbooruTagPagePicManager new];
            [manager startFetchingTagPicCount];
        }
            break;
        case 33: {
            GelbooruTagEndTimePicManager *mananger = [GelbooruTagEndTimePicManager new];
            [mananger prepareFetching];
        }
            break;
        case 34: {
            GelbooruTagEndTimePicManager *mananger = [GelbooruTagEndTimePicManager new];
            [mananger prepareFetchingPicCount];
        }
            break;
        case 35: {
            GelbooruTagPagePicExportTagsManager *manager = [GelbooruTagPagePicExportTagsManager new];
            [manager startFetching];
        }
            break;
        default:
            break;
    }
}

@end
