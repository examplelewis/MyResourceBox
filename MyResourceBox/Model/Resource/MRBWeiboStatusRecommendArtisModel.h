//
//  MRBWeiboStatusRecommendArtisModel.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/05/08.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "WeiboStatusObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRBWeiboStatusRecommendArtisModel : WeiboStatusObject

@property (copy) NSArray *recommendSites;
@property (copy) NSString *recommendDescription;
@property (copy) NSString *id_original_str;

+ (NSDictionary *)generateDictionaryWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
