//
//  HttpManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/10/05.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpManager : NSObject

+ (HttpManager *)sharedManager;

- (void)getExHentaiPostDetail:(NSString *)url completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end
