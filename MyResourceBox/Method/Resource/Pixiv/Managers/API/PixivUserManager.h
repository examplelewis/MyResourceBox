//
//  PixivUserManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/06.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PixivUserManager : NSObject

- (instancetype)initWithUserPage:(NSString *)userPage;
- (void)fetchUserIllusts:(void(^)(BOOL success, NSString *errorMsg, NSDictionary *illusts))fetchResult;

@end
