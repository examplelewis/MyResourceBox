//
//  WeiboPicCroppingManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/14.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WeiboPicCroppingRatio) {
    WeiboPicCroppingRatioNotSet,
    WeiboPicCroppingRatio42, // 4.2%
    WeiboPicCroppingRatio45, // 4.5%
    WeiboPicCroppingRatio47, // 4.7%
    WeiboPicCroppingRatio48, // 4.8%
};

NS_ASSUME_NONNULL_BEGIN

@interface WeiboPicCroppingManager : NSObject

@property (assign) WeiboPicCroppingRatio croppingRatio;

- (void)prepareCropping;

@end

NS_ASSUME_NONNULL_END
