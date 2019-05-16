//
//  MRBDownloadOperation.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/07.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRBDownloadOperation : NSOperation

+ (instancetype)operationWithURLSessionTask:(NSURLSessionTask *)task;

@end
