//
//  TumblrVideoObject.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/02.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "TumblrVideoObject.h"

@implementation TumblrVideoObject

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _date = dict[@"date"];
        _timestamp = [dict[@"timestamp"] integerValue];
        _liked_timestamp = [dict[@"liked_timestamp"] integerValue];
        _id_str = [NSString stringWithFormat:@"%ld", [dict[@"id"] integerValue]];
        _blog_name = dict[@"blog_name"];
        
        // 视频
        _video_type = dict[@"video_type"];
        if ([_video_type isEqualToString:@"tumblr"]) {
            _video_url = dict[@"video_url"];
        } else {
            _video_url = dict[@"permalink_url"];
        }
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"date--:%@, status_id--:%@, video_url--:%@, video_type--:%@, blog_name--:%@", _date, _id_str, _video_url, _video_type, _blog_name];
}

@end
