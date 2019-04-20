//
//  ParseBTChinaOperation.h
//  MyToolBox
//
//  Created by 龚宇 on 16/08/11.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseBTChinaOperation : NSOperation

@property (copy) void (^errorHandler)(NSError *error);
@property (strong, readonly) NSMutableArray *imgURLArray;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *url;

- (instancetype)initWithData:(NSData *)data url:(NSString *)urlString;

@end
