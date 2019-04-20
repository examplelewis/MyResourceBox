//
//  TumblrVideoObject.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/02.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TumblrVideoObject : NSObject

@property (assign, readonly) NSTimeInterval timestamp;
@property (assign, readonly) NSTimeInterval liked_timestamp;
@property (copy, readonly) NSString *id_str;
@property (copy, readonly) NSString *date;
@property (copy, readonly) NSString *video_url;
@property (copy, readonly) NSString *video_type;
@property (copy, readonly) NSString *blog_name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
