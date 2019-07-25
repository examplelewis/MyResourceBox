//
//  FOExtractTypesFileModel.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/07/25.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "FOExtractTypesFileModel.h"

@implementation FOExtractTypesFileModel

- (void)setupData {
    NSString *rootFolderName = _rootFolder.lastPathComponent;
    NSString *targetRootFolderName = [NSString stringWithFormat:@"%@ %@", rootFolderName, _type];
    _targetRootFolder = [_rootFolder stringByReplacingOccurrencesOfString:rootFolderName withString:targetRootFolderName];
    _target = [_original stringByReplacingOccurrencesOfString:_rootFolder withString:_targetRootFolder];
    _containerFolder = _target.stringByDeletingLastPathComponent;
}

@end
