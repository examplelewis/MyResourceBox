//
//  PixivGeneralManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/27.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivGeneralManager.h"

@implementation PixivGeneralManager

+ (NSString *)encodeDictionary:(NSDictionary *)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        id value = [dictionary objectForKey:key];
        if (![value isKindOfClass:[NSString class]]) {
            value = [NSString stringWithFormat:@"%@", value];
        }
        NSString *encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [parts addObject:[NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue]];
    }
    if ([parts count] > 0) {
        return [parts componentsJoinedByString:@"&"];
    } else {
        return nil;
    }
}

@end
