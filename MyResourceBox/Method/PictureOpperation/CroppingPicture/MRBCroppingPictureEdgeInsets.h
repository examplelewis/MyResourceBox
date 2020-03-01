//
//  MRBCroppingPictureEdgeInsets.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBCroppingPictureEdgeUnit : NSObject

@property (assign) CGFloat value;
@property (assign) NSInteger unit; // 1 为百分比；2 为像素
@property (assign) BOOL enabled;

@end

@interface MRBCroppingPictureEdgeInsets : NSObject

@property (strong) MRBCroppingPictureEdgeUnit *top;
@property (strong) MRBCroppingPictureEdgeUnit *left;
@property (strong) MRBCroppingPictureEdgeUnit *bottom;
@property (strong) MRBCroppingPictureEdgeUnit *right;
@property (nonatomic, assign) BOOL hasCroppingParams;

+ (instancetype)generatedEdgeInsets;

@end

NS_ASSUME_NONNULL_END
