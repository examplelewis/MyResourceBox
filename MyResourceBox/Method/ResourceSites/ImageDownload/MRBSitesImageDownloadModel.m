//
//  MRBSitesImageDownloadModel.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageDownloadModel.h"

@implementation MRBSitesImageDownloadModel

- (instancetype)initWithMode:(NSInteger)mode url:(NSString *)url keyword:(NSString *)keyword inputStart:(NSInteger)inputStart inputEnd:(NSInteger)inputEnd inputStartDate:(NSDate *)inputStartDate inputEndDate:(NSDate *)inputEndDate {
    self = [super init];
    if (self) {
        self.mode = mode;
        self.url = url;
        self.keyword = keyword;
        self.inputStart = inputStart;
        self.inputEnd = inputEnd;
        self.inputStartDate = inputStartDate;
        self.inputEndDate = inputEndDate;
    }
    
    return self;
}

@end
