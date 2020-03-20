//
//  MRBSitesImageDownloadModel.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBSitesImageDownloadModel : NSObject

@property (assign) NSInteger mode; // 10: 全部, 11: Image ID, 12: 日期, 13: 页码
@property (copy) NSString *url;
@property (copy) NSString *keyword;
@property (assign) NSInteger inputStart;
@property (assign) NSInteger inputEnd;
@property (strong) NSDate *inputStartDate;
@property (strong) NSDate *inputEndDate;

- (instancetype)initWithMode:(NSInteger)mode url:(NSString *)url keyword:(NSString *)keyword inputStart:(NSInteger)inputStart inputEnd:(NSInteger)inputEnd inputStartDate:(NSDate *)inputStartDate inputEndDate:(NSDate *)inputEndDate;

@end

NS_ASSUME_NONNULL_END
