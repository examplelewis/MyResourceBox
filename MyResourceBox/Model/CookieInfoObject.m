//
//  CookieInfoObject.m
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "CookieInfoObject.h"

@implementation CookieInfoObject

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

#pragma mark - key mapping
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqualToString:@"id"]) {
            return @"_id";
        }
        return keyName;
        
    } modelToJSONBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqualToString:@"_id"]) {
            return @"id";
        }
        return keyName;
    }];
}

@end
