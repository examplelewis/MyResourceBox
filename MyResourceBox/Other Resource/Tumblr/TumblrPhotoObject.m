//
//  TumblrPhotoObject.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/01.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "TumblrPhotoObject.h"

@implementation TumblrPhotoObject

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _date = dict[@"date"];
        _timestamp = [dict[@"timestamp"] integerValue];
        _liked_timestamp = [dict[@"liked_timestamp"] integerValue];
        _id_str = [NSString stringWithFormat:@"%ld", [dict[@"id"] integerValue]];
        _blog_name = dict[@"blog_name"];
        
        //图片
        NSArray *pArray = [NSArray arrayWithArray:dict[@"photos"]];
        NSMutableArray *pmArray = [NSMutableArray array];
        for (NSInteger i = 0; i < pArray.count; i++) {
            NSDictionary *pDict = [NSDictionary dictionaryWithDictionary:pArray[i]];
            NSDictionary *oriPDict = [NSDictionary dictionaryWithDictionary:pDict[@"original_size"]];
            [pmArray addObject:oriPDict[@"url"]];
        }
        _img_urls = [NSArray arrayWithArray:pmArray];
        _img_urls_str = [_img_urls componentsJoinedByString:@";"];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"date--:%@, status_id--:%@, img_urls_str--:%@, blog_name--:%@", _date, _id_str, _img_urls_str, _blog_name];
}

@end
