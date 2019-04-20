//
//  PixivMasterObject.m
//  MyToolBox
//
//  Created by 龚宇 on 16/07/14.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "PixivMasterObject.h"

@implementation PixivMasterObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %ld, %@, %@, %ld, %@, %@", self.created_date, self.image_id, self.is_manga, self.last_update_date, self.member_id, self.save_name, self.title];
}

@end
