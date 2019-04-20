//
//  ParseWnacgOperation.h
//  MyToolBox
//
//  Created by 龚宇 on 16/04/29.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseWnacgOperation : NSOperation

@property (copy) void (^errorHandler)(NSError *error);
@property (strong, readonly) NSString *imgURL;

- (instancetype)initWithData:(NSData *)data;

@end
