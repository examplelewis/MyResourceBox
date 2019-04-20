//
//  PixivMangaObject.m
//  MyToolBox
//
//  Created by 龚宇 on 16/07/14.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "PixivMangaObject.h"

@implementation PixivMangaObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %ld, %@, %ld, %@", self.created_date, self.image_id, self.last_update_date, self.page, self.save_name];
}

@end
