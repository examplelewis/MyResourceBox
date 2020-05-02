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
        case 21: {
            [[FOExtractTypesFileManager new] startExtractingSpecificTypes:nil];
        }
            break;
        case 22: {
            [[FOExtractTypesFileManager new] startExtractingSpecificTypes:@[@"gif"]];
        }
            break;
        case 31: {
            [[MRBGenerate32BitMD5NameManager new] chooseFiles];
        }
            break;
        default:
            break;
    }
}


@end
