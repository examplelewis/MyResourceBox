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
#import "ResourceGlobalDownloadManager.h"
#import "ResourceGlobalOrganizeManager.h"
#import "ResourceGlobalFileMoveManager.h"
#import "GelbooruDownloadAndOrganizeManager.h"

@implementation GelbooruMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
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
            [[MRBLogManager defaultManager] showLogWithFormat:@"移动整理好的日常图片，流程开始"];
            
            [ResourceGlobalFileMoveManager moveFilesToDayFolderFromFolder:GelbooruFateRootFolderPath];
            [ResourceGlobalFileMoveManager moveFilesToDayFolderFromFolder:GelbooruAzurRootFolderPath];
            [ResourceGlobalFileMoveManager moveFilesToDayFolderFromFolder:GelbooruOverwatchRootFolderPath];
            [ResourceGlobalFileMoveManager moveFilesToDayFolderFromFolder:GelbooruAnimeRootFolderPath];
            [ResourceGlobalFileMoveManager moveFilesToDayFolderFromFolder:GelbooruGameRootFolderPath];
//            [ResourceGlobalFileMoveManager moveFilesToDayFolderFromFolder:GelbooruHRootFolderPath];
//            [ResourceGlobalFileMoveManager moveFilesToDayFolderFromFolder:GelbooruWebmRootFolderPath];
            
            [[MRBLogManager defaultManager] showLogWithFormat:@"移动整理好的日常图片，流程结束"];
        }
            break;
        case 11: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruFatePostTxtPath targetFolderPath:GelbooruFateRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 12: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruAzurPostTxtPath targetFolderPath:GelbooruAzurRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 13: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruOverwatchPostTxtPath targetFolderPath:GelbooruOverwatchRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 14: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruAnimePostTxtPath targetFolderPath:GelbooruAnimeRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 15: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruGamePostTxtPath targetFolderPath:GelbooruGameRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 16: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruHPostTxtPath targetFolderPath:GelbooruHRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 17: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:GelbooruWebmPostTxtPath targetFolderPath:GelbooruWebmRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 18: {
            NSString *input = [AppDelegate defaultVC].inputTextView.string;
            if (input.length == 0) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
                return;
            }
            
            NSString *txtFilePath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/Gelbooru %@ PostUrl.txt", input];
            NSString *targetFolderPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/%@/", input];
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:txtFilePath targetFolderPath:targetFolderPath];
            manager.showAlertAfterFinished = YES;
            [manager prepareDownloading];
        }
            break;
        case 21: {
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruAnimePostRenamePlistPath targetFolderPath:GelbooruAnimeRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 22: {
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruGamePostRenamePlistPath targetFolderPath:GelbooruGameRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 23: {
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruHPostRenamePlistPath targetFolderPath:GelbooruHRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 24: {
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:GelbooruWebmPostRenamePlistPath targetFolderPath:GelbooruWebmRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 25: {
            NSString *input = [AppDelegate defaultVC].inputTextView.string;
            if (input.length == 0) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
                return;
            }
            
            NSString *plistFilePath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/Gelbooru %@ PostRenameInfo.plist", input];
            NSString *targetFolderPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/%@/", input];
            
            ResourceGlobalOrganizeManager *manager = [[ResourceGlobalOrganizeManager alloc] initWithPlistFilePath:plistFilePath targetFolderPath:targetFolderPath];
            [manager startOrganizing];
        }
            break;
        default:
            break;
    }
}

@end
