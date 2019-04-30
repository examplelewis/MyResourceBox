//
//  PixivBlockingManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixivBlockingManager : NSObject

- (void)fetchPixivBlacklist;
- (void)checkPixivUserHasBlocked;
- (void)updateBlockLevel1PixivUser;
- (void)updateBlockLevel2PixivUser;

@end

NS_ASSUME_NONNULL_END
