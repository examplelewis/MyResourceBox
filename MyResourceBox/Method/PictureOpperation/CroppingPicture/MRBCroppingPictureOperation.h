//
//  MRBCroppingPictureOperation.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRBCroppingPictureHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRBCroppingPictureOperation : NSOperation

+ (instancetype)operationWithFrom:(NSString *)from to:(NSString *)to insets:(MRBCroppingPictureEdgeInsets *)insets index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
