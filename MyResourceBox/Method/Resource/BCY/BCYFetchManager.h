//
//  BCYFetchManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCYFetchManager : NSObject

- (void)getPageURLFromInput:(BOOL)check;
- (void)getPageURLFromFile;

@end

NS_ASSUME_NONNULL_END
