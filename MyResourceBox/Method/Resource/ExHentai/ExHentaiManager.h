//
//  ExHentaiManager.h
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExHentaiManager : NSObject

+ (ExHentaiManager *)defaultManager;
- (void)configMethod:(NSInteger)cellRow;

@end
