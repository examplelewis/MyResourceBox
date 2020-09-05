//
//  FileOperationMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "FileOperationMethod.h"
#import "FODayFolderManager.h"
#import "FOFilteredImageManager.h"
#import "FOFolderManager.h"
#import "FOExtractTypesFileManager.h"
#import "MRBGenerate32BitMD5NameManager.h"
#import "MRBFileNameFindSpecificCharactersManager.h"
#import "MRBExtraceUnzipFolderManager.h"
#import "MRBRenameSingleSubFolderNameManager.h"
#import "MRBCleanNoneItemSubFolderManager.h"

@implementation FileOperationMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [FODayFolderManager start];
        }
            break;
        case 2: {
            [FOFilteredImageManager organizingExportPhotos];
        }
            break;
        case 3: {
            [FOFilteredImageManager organizingDatabase];
        }
            break;
        case 4: {
            [FOFilteredImageManager prepareOrganizingPhotos];
        }
            break;
        case 11: {
            [FOFolderManager prepareCopyingFolder];
        }
            break;
        case 12: {
            [[MRBExtraceUnzipFolderManager new] start];
        }
            break;
        case 13: {
            [[MRBRenameSingleSubFolderNameManager new] start];
        }
            break;
        case 14: {
            [[MRBCleanNoneItemSubFolderManager new] start];
        }
            break;
        case 21: {
            [[FOExtractTypesFileManager new] startExtractingSpecificTypes:nil];
        }
            break;
        case 22: {
            [[FOExtractTypesFileManager new] startExtractingSpecificTypes:@[@"gif"]];
        }
            break;
        case 23: {
            [[FOExtractTypesFileManager new] startExtractingSpecificTypes:[MRBUserManager defaultManager].mime_video_types];
        }
            break;
        case 31: {
            [[MRBGenerate32BitMD5NameManager new] startGenerateFileNamesByFolderWithRootFolder];
        }
            break;
        case 32: {
            [[MRBGenerate32BitMD5NameManager new] startGenerateFileNamesByFileWithRootFolder];
        }
            break;
        case 41: {
            [[[MRBFileNameFindSpecificCharactersManager alloc] initWithCharacters:@"* ? \\ \" < > |"] selectRootFolder];
        }
            break;
        case 42: {
            [[[MRBFileNameFindSpecificCharactersManager alloc] initWithCharacters:nil] selectRootFolder];
        }
            break;
        case 51: {
            [[[MRBFileNameFindSpecificCharactersManager alloc] initWithCharacters:@"* ? \\ \" < > |"] modifyFileNames];
        }
            break;
        case 52: {
            [[[MRBFileNameFindSpecificCharactersManager alloc] initWithCharacters:nil] modifyFileNames];
        }
            break;
        default:
            break;
    }
}

// 将每一个单独的文件移动到新的文件夹中，即每一个文件夹中只有一个文件。将导出的图片归类的时候需要使用，使用之后将其导入到iPhoto中可以方便整理归类
- (void)moveSingleFileToEachFolder {
    NSString *folder = @"/Users/mercury/Downloads/运动/~单独的图片";
    NSArray *files = [[MRBFileManager defaultManager] getFilePathsInFolder:folder];
    for (NSInteger i = 0; i < files.count; i++) {
        NSString *filePath = files[i];
        
        NSString *folderPath = [NSString stringWithFormat:@"/Users/mercury/Downloads/运动/~单独的图片/~单独的图片 %03ld", i + 1];
        [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:folderPath];
        
        NSString *destPath = [filePath stringByReplacingOccurrencesOfString:@"~单独的图片" withString:[NSString stringWithFormat:@"~单独的图片/~单独的图片 %03ld", i + 1]];
        
        [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"Done"];
}

// 用文件夹的名字来修改文件的名字，只针对每一个文件夹中只有一个文件的情况
- (void)modifyFileNameUsingFolderName {
    NSString *folder = @"/Users/mercury/Downloads/秀人网视频合集";
    NSArray *folders = [[MRBFileManager defaultManager] getFolderPathsInFolder:folder];
    for (NSInteger i = 0; i < folders.count; i++) {
        NSString *folderPath = folders[i];
        NSArray *folderFiles = [[MRBFileManager defaultManager] getFilePathsInFolder:folderPath];
        
        NSString *filePath = folderFiles[0];
        NSString *destPath = [filePath stringByReplacingOccurrencesOfString:filePath.lastPathComponent.stringByDeletingPathExtension withString:folderPath.lastPathComponent];
        
        [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"Done"];
}

@end
