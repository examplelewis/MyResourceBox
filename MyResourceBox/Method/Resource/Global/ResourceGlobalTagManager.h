//
//  ResourceGlobalTagManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 18/12/14.
//  Copyright © 2018 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResourceGlobalTagManager : NSObject

+ (ResourceGlobalTagManager *)defaultManager;

- (NSString *)getNeededCopyrightTags:(NSArray *)tags;
- (BOOL)checkTagsHasNeededCopyright:(NSArray *)tags;

- (NSString *)getAnimeTags:(NSString *)tags;
- (NSString *)getGameTags:(NSString *)tags;
- (NSString *)getHTags:(NSString *)tags;

- (NSString *)removeUselessWebmTags:(NSString *)tags;

@end

NS_ASSUME_NONNULL_END
