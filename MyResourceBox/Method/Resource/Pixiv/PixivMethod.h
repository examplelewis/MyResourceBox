//
//  PixivMethod.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/06.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PixivAPI.h"

@interface PixivMethod : NSObject

@property (nonatomic, assign) BOOL login;

+ (PixivMethod *)defaultMethod;
- (void)configMethod:(NSInteger)cellRow;

@end
