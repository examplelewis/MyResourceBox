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
        case 5: {
            [FOFolderManager prepareCopyingFolder];
        }
            break;
        case 6: {
            [[FOExtractTypesFileManager new] startExtractingSpecificTypes:nil];
        }
            break;
        case 7: {
            [[FOExtractTypesFileManager new] startExtractingSpecificTypes:@[@"gif"]];
        }
            break;
        default:
            break;
    }
}


@end
