//
//  MRBResourceGlobalTagManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/10.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MRBResourceGlobalTagSite) {
    MRBResourceGlobalTagSiteGelbooru,
    MRBResourceGlobalTagSiteRule34
};

@interface MRBResourceGlobalTagManager : NSObject

+ (MRBResourceGlobalTagManager *)defaultManager;

- (void)readAndExtract;

- (NSString *)extractUsefulTagsFromTagsString:(NSString *)tagStr;
- (BOOL)didHaveUsefulTagsFromTagsString:(NSString *)tagStr;

- (NSString *)extractAnimeTagsFromTags:(NSString *)tags atSite:(MRBResourceGlobalTagSite)site;
- (NSString *)extractGameTagsFromTags:(NSString *)tags atSite:(MRBResourceGlobalTagSite)site;
- (NSString *)extractHTagsFromTags:(NSString *)tags atSite:(MRBResourceGlobalTagSite)site;

- (NSString *)removeUselessTagsFromTags:(NSString *)tags;

@end

NS_ASSUME_NONNULL_END
