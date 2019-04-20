//
//  WNACGMethod.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/01/24.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WNACGMethod : NSObject

+ (WNACGMethod *)defaultMethod;
- (void)configMethod:(NSInteger)cellRow;

@end
