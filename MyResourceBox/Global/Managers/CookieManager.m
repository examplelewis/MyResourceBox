//
//  CookieManager.m
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "CookieManager.h"
#import <JSONKit.h>

@implementation CookieManager

- (instancetype)initWithCookieFileType:(CookieFileType)filetype {
    self = [super init];
    if (self) {
        switch (filetype) {
            case CookieFileTypeExHentai:
                file_name = @"ExHentaiCookie.txt";
                cookie_domain = @"https://exhentai.org/";
                break;
            case CookieFileTypeBCY:
                file_name = @"BCYCookie.txt";
                cookie_domain = @"http://bcy.net/";
                break;
            case CookieFileTypeLofter:
                file_name = @"LofterCookie.txt";
                cookie_domain = @"http://lofter.com/";
                break;
            case CookieFileTypeWorldCosplay:
                file_name = @"WorldCosplayCookie.txt";
                cookie_domain = @"https://worldcosplay.net/";
                break;
            default:
                file_name = @"";
                cookie_domain = @"";
                break;
        }
        
        if (file_name.length != 0) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
            
            [self readCookieIntoDictionary];
        }
    }
    
    return self;
}

- (void)readCookieIntoDictionary {
    NSString *file_path = [[DeviceInfo sharedDevice].path_root_folder stringByAppendingFormat:@"/Cookie文件/%@", file_name];
    cookie_string = [NSString stringWithContentsOfFile:file_path encoding:NSUTF8StringEncoding error:nil];
    NSData *cookie_data = [cookie_string dataUsingEncoding:NSUTF8StringEncoding];
    cookie_dicts = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:cookie_data options:0 error:nil]];
    _cookie_objects = [NSArray arrayWithArray:[CookieInfoObject arrayOfModelsFromDictionaries:cookie_dicts error:nil]];
}

- (void)writeCookiesIntoHTTPStorage {
    NSNumber *max = [self.cookie_objects valueForKeyPath:@"@max.expirationDate"];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:max.doubleValue];
    // Cookie即将过期，需要使用Chrome再次请求Cookie
    if ([expireDate isEarlierThan:[NSDate date]]) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"有部分Cookie即将过期，需要使用Chrome再次请求Cookie" infomation:file_name];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
    }
    
    for (NSInteger i = 0; i < self.cookie_objects.count; i++) {
        CookieInfoObject *object = self.cookie_objects[i];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName:object.name, NSHTTPCookieValue:object.value, NSHTTPCookieDomain:object.domain, NSHTTPCookieOriginURL:object.domain, NSHTTPCookiePath:object.path, NSHTTPCookieExpires:[NSDate dateWithTimeIntervalSince1970:object.expirationDate]}];
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

- (void)deleteCookieByName:(NSString *)cookie_name {
    //获取cookie，并删除不必要的Cookie
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:cookie_domain]];
    for (NSHTTPCookie *tempCookie in cookies) {
        if ([tempCookie.name isEqualToString:cookie_name]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:tempCookie];
        }
    }
}

- (void)outputAllCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:cookie_domain]];
    for (NSHTTPCookie *tempCookie in cookies) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"getCookie: %@, %@", tempCookie.name, tempCookie.value];
    }
}

@end
