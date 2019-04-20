//
//  CookieInfoObject.h
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CookieInfoObject : JSONModel

@property (strong) NSString *domain;
@property (assign) NSTimeInterval expirationDate;
@property (assign) NSInteger hostOnly;
@property (assign) NSInteger httpOnly;
@property (assign) NSInteger _id;
@property (strong) NSString *name;
@property (strong) NSString *path;
@property (strong) NSString *sameSite;
@property (assign) NSInteger secure;
@property (assign) NSInteger session;
@property (assign) NSInteger storeId;
@property (strong) NSString *value;

@end
