//
//  NSString+MRBString.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MRBString)

- (NSInteger)countOfSubString:(NSString *)subString;

@end

NS_ASSUME_NONNULL_END
