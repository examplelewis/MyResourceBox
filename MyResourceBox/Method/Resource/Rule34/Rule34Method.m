//
//  Rule34Method.m
//  MyResourceBox
//
//  Created by 龚宇 on 18/10/17.
//  Copyright © 2018 gongyuTest. All rights reserved.
//

#import "Rule34Method.h"
#import "Rule34Header.h"

#import "Rule34DailyPicManager.h"
#import "Rule34TagEndTimePicManager.h"
#import "Rule34TagPagePicManager.h"
#import "Rule34TagPagePicExportTagsManager.h"
#import "ResourceGlobalDownloadManager.h"
#import "Rule34OrganizeManager.h"
#import "Rule34FileMoveManager.h"
#import "Rule34DownloadAndOrganizeManager.h"

@implementation Rule34Method

+ (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            Rule34DailyPicManager *manager = [Rule34DailyPicManager new];
            [manager startFetching];
        }
            break;
        case 2: {
            Rule34DownloadAndOrganizeManager *manager = [Rule34DownloadAndOrganizeManager new];
            [manager startOperation];
        }
            break;
        case 3: {
            [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程开始"];
            
            [Rule34FileMoveManager moveFilesToDayFolderFromFolder:Rule34FateRootFolderPath];
            [Rule34FileMoveManager moveFilesToDayFolderFromFolder:Rule34AzurRootFolderPath];
            [Rule34FileMoveManager moveFilesToDayFolderFromFolder:Rule34OverwatchRootFolderPath];
            [Rule34FileMoveManager moveFilesToDayFolderFromFolder:Rule34AnimeRootFolderPath];
            [Rule34FileMoveManager moveFilesToDayFolderFromFolder:Rule34GameRootFolderPath];
//            [Rule34FileMoveManager moveFilesToDayFolderFromFolder:Rule34HRootFolderPath];
//            [Rule34FileMoveManager moveFilesToDayFolderFromFolder:Rule34WebmRootFolderPath];
            
            [[UtilityFile sharedInstance] showLogWithFormat:@"移动整理好的日常图片，流程结束"];
        }
            break;
        case 11: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34FatePostTxtPath targetFolderPath:Rule34FateRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 12: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34AzurPostTxtPath targetFolderPath:Rule34AzurRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 13: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34OverwatchPostTxtPath targetFolderPath:Rule34OverwatchRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 14: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34AnimePostTxtPath targetFolderPath:Rule34AnimeRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 15: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34GamePostTxtPath targetFolderPath:Rule34GameRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 16: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34HPostTxtPath targetFolderPath:Rule34HRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 17: {
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:Rule34WebmPostTxtPath targetFolderPath:Rule34WebmRootFolderPath];
            [manager prepareDownloading];
        }
            break;
        case 18: {
            NSString *input = [AppDelegate defaultVC].inputTextView.string;
            if (input.length == 0) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
                return;
            }
            
            NSString *txtFilePath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/Rule34 %@ PostUrl.txt", input];
            NSString *targetFolderPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/%@/", input];
            
            ResourceGlobalDownloadManager *manager = [[ResourceGlobalDownloadManager alloc] initWithTXTFilePath:txtFilePath targetFolderPath:targetFolderPath];
            manager.showAlertAfterFinished = YES;
            [manager prepareDownloading];
        }
            break;
        case 21: {
            Rule34OrganizeManager *manager = [[Rule34OrganizeManager alloc] initWithPlistFilePath:Rule34AnimePostRenamePlistPath targetFolderPath:Rule34AnimeRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 22: {
            Rule34OrganizeManager *manager = [[Rule34OrganizeManager alloc] initWithPlistFilePath:Rule34GamePostRenamePlistPath targetFolderPath:Rule34GameRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 23: {
            Rule34OrganizeManager *manager = [[Rule34OrganizeManager alloc] initWithPlistFilePath:Rule34HPostRenamePlistPath targetFolderPath:Rule34HRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 24: {
            Rule34OrganizeManager *manager = [[Rule34OrganizeManager alloc] initWithPlistFilePath:Rule34WebmPostRenamePlistPath targetFolderPath:Rule34WebmRootFolderPath];
            [manager startOrganizing];
        }
            break;
        case 31: {
            Rule34TagPagePicManager *manager = [Rule34TagPagePicManager new];
            [manager startFetching];
        }
            break;
        case 32: {
            Rule34TagPagePicManager *manager = [Rule34TagPagePicManager new];
            [manager startFetchingTagPicCount];
        }
            break;
        case 33: {
            Rule34TagEndTimePicManager *mananger = [Rule34TagEndTimePicManager new];
            [mananger prepareFetching];
        }
            break;
        case 34: {
            Rule34TagEndTimePicManager *mananger = [Rule34TagEndTimePicManager new];
            [mananger prepareFetchingPicCount];
        }
            break;
        case 35: {
            Rule34TagPagePicExportTagsManager *manager = [Rule34TagPagePicExportTagsManager new];
            [manager startFetching];
        }
            break;
        default:
            break;
    }
}

@end
