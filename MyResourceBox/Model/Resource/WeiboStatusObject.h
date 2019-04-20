//
//  WeiboStatusObject.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboStatusObject : NSObject

@property (copy, readonly) NSString *created_at;
@property (strong, readonly) NSDate *created_at_date;
@property (copy, readonly) NSString *created_at_readable_str;
@property (copy, readonly) NSString *id_str;
@property (copy, readonly) NSString *img_urls_str;
@property (copy, readonly) NSArray *img_urls;
@property (copy, readonly) NSString *user_screen_name;
@property (copy, readonly) NSString *user_id_str;
@property (copy, readonly) NSString *text;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
