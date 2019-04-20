//
//  WeiboStatusObject.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WeiboStatusObject.h"

@implementation WeiboStatusObject

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSDateFormatter *parser = [[NSDateFormatter alloc] init];
        parser.dateStyle = NSDateFormatterNoStyle;
        parser.timeStyle = NSDateFormatterNoStyle;
        parser.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
        parser.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        
        _id_str = dict[@"idstr"];
        
        _created_at = dict[@"created_at"];
        _created_at_date = [parser dateFromString:_created_at];
        _created_at_readable_str = [_created_at_date formattedDateWithFormat:@"yyyyMMddHHmmss"];
        
        //图片
        NSArray *pArray = [NSArray arrayWithArray:dict[@"pic_urls"]];
        NSMutableArray *pmArray = [NSMutableArray array];
        for (NSDictionary *pDict in pArray) {
            NSString *large = pDict[@"thumbnail_pic"];
            large = [large stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
            [pmArray addObject:large];
        }
        _img_urls = [NSArray arrayWithArray:pmArray];
        _img_urls_str = [_img_urls componentsJoinedByString:@";"];
        
        //用户
        NSDictionary *uDict = [NSDictionary dictionaryWithDictionary:dict[@"user"]];
        _user_screen_name = uDict[@"screen_name"];
        _user_id_str = uDict[@"idstr"];
        
        //文字
        _text = dict[@"text"];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"created_at--:%@, id_str--:%@, img_urls_str--:%@, user_screen_name--:%@, user_id_str--:%@", _created_at, _id_str, _img_urls_str, _user_screen_name, _user_id_str];
}

@end
