//
//  Rule34OrganizeManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Rule34OrganizeManager : NSObject

@property (copy) void(^finishBlock)(void);

- (instancetype)initWithPlistFilePath:(NSString *)filePath targetFolderPath:(NSString *)folderPath;
- (void)startOrganizing;

@end

NS_ASSUME_NONNULL_END
