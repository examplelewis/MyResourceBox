//
//  ParseYandereOperation.h
//  MyToolBox
//
//  Created by 龚宇 on 16/05/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseYandereOperation : NSOperation

@property (copy) void (^errorHandler)(NSError *error);
@property (strong, readonly) NSString *imgURL;
@property (strong, readonly) NSString *url;

- (instancetype)initWithData:(NSData *)data andURLstring:(NSString *)urlString;

@end
