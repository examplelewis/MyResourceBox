//
//  Consts.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/28.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define BS(blockSelf)  __block __typeof(&*self)blockSelf = self;
#define SS(strongSelf) __strong __typeof(&*self)strongSelf = weakSelf;

// block
#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@interface Consts : NSObject

+ (NSArray *)simplePhotoType;
+ (NSArray *)allPhotoType;
+ (NSArray *)allVideoType;

@end
