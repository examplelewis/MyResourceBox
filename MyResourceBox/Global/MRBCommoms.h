//
//  MRBCommoms.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/07.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#ifndef MRBCommoms_h
#define MRBCommoms_h

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

#define simplePhotoType @[@"jpg", @"jpeg", @"gif", @"png"]
#define allPhotoType @[@"jpg", @"jpeg", @"gif", @"png", @"raw", @"bmp", @"tiff"]
#define allVideoType @[@"mkv", @"mp4", @"avi", @"mpg", @"webm", @"ogv", @"m4v", @"rmvb"]

#endif /* MRBCommoms_h */
