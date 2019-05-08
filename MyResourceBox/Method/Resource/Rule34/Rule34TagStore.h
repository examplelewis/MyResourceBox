//
//  Rule34TagStore.h
//  MyResourceBox
//
//  Created by 龚宇 on 18/12/14.
//  Copyright © 2018 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Rule34TagStore : NSObject

+ (Rule34TagStore *)defaultManager;
- (void)readAllNeededTags;
//- (void)readyToOrganize;
//- (void)filterAllTags;
//- (void)processNeededTags;

- (NSString *)getNeededCopyrightTags:(NSArray *)tags;
- (BOOL)checkTagsHasNeededCopyright:(NSArray *)tags;

- (NSString *)getAnimeTags:(NSString *)tags;
- (NSString *)getGameTags:(NSString *)tags;
- (NSString *)getHTags:(NSString *)tags;

@end

NS_ASSUME_NONNULL_END