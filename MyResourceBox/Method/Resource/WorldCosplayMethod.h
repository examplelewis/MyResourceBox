//
//  WorldCosplayMethod.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorldCosplayMethod : NSObject

+ (WorldCosplayMethod *)defaultMethod;
- (void)configMethod:(NSInteger)cellRow;

@end
