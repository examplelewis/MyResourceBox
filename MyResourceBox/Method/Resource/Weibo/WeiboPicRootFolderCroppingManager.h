//
//  WeiboPicRootFolderCroppingManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/02/27.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WeiboPicRootFolderCroppingRatio) {
    WeiboPicRootFolderCroppingRatioNotSet,
    WeiboPicRootFolderCroppingRatio42, // 4.2%
    WeiboPicRootFolderCroppingRatio45, // 4.5%
    WeiboPicRootFolderCroppingRatio47, // 4.7%
    WeiboPicRootFolderCroppingRatio48, // 4.8%
};

NS_ASSUME_NONNULL_BEGIN

@interface WeiboPicRootFolderCroppingManager : NSObject

@property (assign) WeiboPicRootFolderCroppingRatio croppingRatio;

- (void)prepareCropping;

@end

NS_ASSUME_NONNULL_END
