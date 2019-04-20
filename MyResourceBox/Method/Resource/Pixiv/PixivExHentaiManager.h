//
//  PixivExHentaiManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/08.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixivExHentaiManager : NSObject

- (instancetype)initWithOriginalUrls:(NSArray *)urls;
- (void)startManaging;

@end

NS_ASSUME_NONNULL_END
