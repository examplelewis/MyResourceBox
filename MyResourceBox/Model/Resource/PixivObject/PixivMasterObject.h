//
//  PixivMasterObject.h
//  MyToolBox
//
//  Created by 龚宇 on 16/07/14.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PixivMasterObject : NSObject

@property (strong) NSDate *created_date;
@property (assign) NSInteger image_id;
@property (strong) NSString *is_manga;
@property (strong) NSDate *last_update_date;
@property (assign) NSInteger member_id;
@property (strong) NSString *save_name;
@property (strong) NSString *title;

@end
