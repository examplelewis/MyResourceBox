//
//  GelbooruDownloadManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/24.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GelbooruDownloadManager : NSObject

@property (copy) void(^finishBlock)(void);

- (instancetype)initWithTXTFilePath:(NSString *)filePath targetFolderPath:(NSString *)folderPath;
- (void)prepareDownloading;

@end

NS_ASSUME_NONNULL_END
