//
//  BTChinaImage.h
//  MyToolBox
//
//  Created by 龚宇 on 16/08/11.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTChinaImage : NSObject

+ (BTChinaImage *)defaultInstance;
- (void)getImage;
- (void)arrangeImageFileFromPlistPhase1;

@end