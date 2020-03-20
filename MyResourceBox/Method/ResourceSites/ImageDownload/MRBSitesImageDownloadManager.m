//
//  MRBSitesImageDownloadManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageDownloadManager.h"
#import "MRBHttpManager.h"

@interface MRBSitesImageDownloadManager () {
    NSInteger currentPage;
    
    NSMutableArray *posts;
    NSMutableArray *webmPosts;
}

@property (strong) MRBSitesImageDownloadModel *model;

@end

@implementation MRBSitesImageDownloadManager

#pragma mark - Lifecycle
- (instancetype)initWithModel:(MRBSitesImageDownloadModel *)model {
    self = [super init];
    if (self) {
        self.model = model;
    }
    
    return self;
}

#pragma mark - Fetch Picture
- (void)prepareFetching {
    if (_model.mode == 13) {
        currentPage = _model.inputStart - 1;
    } else {
        currentPage = 0;
    }
    
//    [self fetchSinglePost];
}
- (void)fetchSinglePost {
    [[MRBHttpManager sharedManager] getResourceSitesPostsWithUrl:self.model.url tag:self.model.keyword page:currentPage success:^(NSArray *array) {
        
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        
    }];
}
- (void)fetchSucceed {
    [[MRBLogManager defaultManager] cleanLog];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取 %@ 图片地址：流程结束", self.model.keyword];
}

@end
