//
//  NSString+MRBString.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "NSString+MRBString.h"

#import <AppKit/AppKit.h>


@implementation NSString (MRBString)

- (NSInteger)countOfSubString:(NSString *)subString {
    NSInteger subStringCount = self.length - [self stringByReplacingOccurrencesOfString:subString withString:@""].length;
    return subStringCount / subString.length;
}

@end
