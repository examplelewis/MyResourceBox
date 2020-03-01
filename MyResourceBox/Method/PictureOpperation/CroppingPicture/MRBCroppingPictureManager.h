//
//  MRBCroppingPictureManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRBCroppingPictureHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRBCroppingPictureManager : NSObject

+ (instancetype)managerWithEdgeInsets:(MRBCroppingPictureEdgeInsets *)insets mode:(NSInteger)mode paths:(NSArray *)paths;

- (void)prepareCropping;

@end

NS_ASSUME_NONNULL_END
