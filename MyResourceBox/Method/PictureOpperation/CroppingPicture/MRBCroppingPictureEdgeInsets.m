//
//  MRBCroppingPictureEdgeInsets.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureEdgeInsets.h"

@implementation MRBCroppingPictureEdgeUnit

- (instancetype)init {
    self = [super init];
    if (self) {
        self.unit = 1;
        self.enabled = NO;
        self.value = -1.0;
    }
    
    return self;
}

- (NSString *)description {
    return self.enabled ? [NSString stringWithFormat:@"%.3f %@", self.value, self.unit == 1 ? @"%" : @"像素"] : @"未启用";
}

@end

@implementation MRBCroppingPictureEdgeInsets

+ (instancetype)generatedEdgeInsets {
    MRBCroppingPictureEdgeInsets *edgeInsets = [MRBCroppingPictureEdgeInsets new];
    edgeInsets.top = [MRBCroppingPictureEdgeUnit new];
    edgeInsets.left = [MRBCroppingPictureEdgeUnit new];
    edgeInsets.bottom = [MRBCroppingPictureEdgeUnit new];
    edgeInsets.right = [MRBCroppingPictureEdgeUnit new];
    
    return edgeInsets;
}

- (BOOL)hasCroppingParams {
    return self.top.enabled || self.left.enabled || self.bottom.enabled || self.right.enabled;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"上：%@，左：%@，下：%@，右：%@", self.top, self.left, self.bottom, self.right];
}

@end
