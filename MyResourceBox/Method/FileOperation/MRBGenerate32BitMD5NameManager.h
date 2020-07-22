//
//  MRBGenerate32BitMD5NameManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/23.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBGenerate32BitMD5NameManager : NSObject

- (void)startGenerateFileNamesByFolderWithRootFolder;
- (void)startGenerateFileNamesByFileWithRootFolder;

@end

NS_ASSUME_NONNULL_END
