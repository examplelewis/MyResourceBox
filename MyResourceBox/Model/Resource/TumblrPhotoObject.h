//
//  TumblrPhotoObject.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/01.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TumblrPhotoObject : NSObject

@property (assign, readonly) NSTimeInterval timestamp;
@property (assign, readonly) NSTimeInterval liked_timestamp;
@property (copy, readonly) NSString *id_str;
@property (copy, readonly) NSString *date;
@property (copy, readonly) NSArray *img_urls;
@property (copy, readonly) NSString *img_urls_str;
@property (copy, readonly) NSString *blog_name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
