//
//  MRBSitesOrganizationTagFetchManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/10.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBSitesOrganizationTagFetchManager : NSObject

- (void)readyToOrganize;
- (void)filterAllTags;
- (void)processNeededTags;

@end

NS_ASSUME_NONNULL_END
