//
//  GelbooruTagStoreFetchManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/10.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GelbooruTagStoreFetchManager : NSObject

- (void)readyToOrganize;
- (void)filterAllTags;
- (void)processNeededTags;

@end

NS_ASSUME_NONNULL_END
