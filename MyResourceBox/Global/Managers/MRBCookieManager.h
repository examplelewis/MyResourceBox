//
//  MRBCookieManager.h
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CookieInfoObject.h"

typedef NS_ENUM(NSUInteger, CookieFileType) {
    CookieFileTypeExHentai,
    CookieFileTypeBCY,
    CookieFileTypeWorldCosplay
};

@interface MRBCookieManager : NSObject {
    NSString *file_name;
    NSString *cookie_domain;
    NSString *cookie_string;
    NSArray *cookie_dicts;
}

@property (copy, readonly) NSArray<CookieInfoObject *> *cookie_objects;

- (instancetype)initWithCookieFileType:(CookieFileType)filetype;
- (void)writeCookiesIntoHTTPStorage;
- (void)deleteCookieByName:(NSString *)cookie_name;
- (void)outputAllCookies;

@end
