//
//  MRBSitesImageUrlFetchManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRBSitesImageUrlFetchModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRBSitesImageUrlFetchManager : NSObject

- (instancetype)initWithModel:(MRBSitesImageUrlFetchModel *)model;
- (void)prepareFetching;

@end

NS_ASSUME_NONNULL_END
