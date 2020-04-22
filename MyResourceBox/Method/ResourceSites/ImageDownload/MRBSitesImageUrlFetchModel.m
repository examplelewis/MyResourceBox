//
//  MRBSitesImageUrlFetchModel.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageUrlFetchModel.h"

@implementation MRBSitesImageUrlFetchModel

- (instancetype)initWithMode:(NSInteger)mode url:(NSString *)url keyword:(NSString *)keyword inputStart:(NSInteger)inputStart inputEnd:(NSInteger)inputEnd inputStartDate:(NSDate *)inputStartDate inputEndDate:(NSDate *)inputEndDate {
    self = [super init];
    if (self) {
        self.mode = mode;
        self.url = url;
        self.keyword = [keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.urlHost = [NSURL URLWithString:url].host;
        self.inputStart = inputStart;
        self.inputEnd = inputEnd;
        self.inputStartDate = inputStartDate;
        self.inputEndDate = inputEndDate;
        
        if ([url containsString:@"gelbooru"]) {
            self.urlMode = 1;
            self.urlHostName = @"Gelbooru";
        } else if ([url containsString:@"rule34"]) {
            self.urlMode = 2;
            self.urlHostName = @"Rule34";
        }
    }
    
    return self;
}

- (NSString *)description {
    if (self.mode == 12) {
        return [NSString stringWithFormat:@"keyword: %@, url: %@, mode: %ld, startDate: %@, endDate: %@", self.keyword, self.url, self.mode, self.inputStartDate, self.inputEndDate];
    } else {
        return [NSString stringWithFormat:@"keyword: %@, url: %@, mode: %ld, start: %ld, end: %ld", self.keyword, self.url, self.mode, self.inputStart, self.inputEnd];
    }
}

@end
