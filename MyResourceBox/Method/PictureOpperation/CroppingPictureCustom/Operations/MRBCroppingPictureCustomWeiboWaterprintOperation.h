//
//  MRBCroppingPictureCustomWeiboWaterprintOperation.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/02.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBCroppingPictureCustomWeiboWaterprintOperation : NSOperation

+ (instancetype)operationWithFrom:(NSString *)from to:(NSString *)to percent:(CGFloat)percent index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
