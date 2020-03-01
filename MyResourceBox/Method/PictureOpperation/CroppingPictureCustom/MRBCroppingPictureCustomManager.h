//
//  MRBCroppingPictureCustomManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/02.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBCroppingPictureCustomManager : NSObject

+ (instancetype)managerWithButtonTag:(NSInteger)tag mode:(NSInteger)mode paths:(NSArray *)paths;

- (void)prepareCropping;

@end

NS_ASSUME_NONNULL_END
