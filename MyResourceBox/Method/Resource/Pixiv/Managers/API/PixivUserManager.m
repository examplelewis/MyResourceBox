//
//  PixivUserManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/06.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "PixivUserManager.h"
#import "PixivAPI.h"

@interface PixivUserManager () {
    NSMutableArray *fetchLists;
    NSInteger illustCount;
}

@property (nonatomic, copy) NSString *userPage;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) PAPIAuthor *user;
@property (nonatomic, strong) NSOperationQueue *opQueue;

@end

@implementation PixivUserManager

- (instancetype)initWithUserPage:(NSString *)userPage {
    self = [super init];
    if (self) {
        illustCount = 0;
        _userPage = userPage;
        _userId = [[userPage componentsSeparatedByString:@"id="].lastObject integerValue];
        
        fetchLists = [NSMutableArray array];
        _opQueue = [NSOperationQueue new];
        
        // 使用KVO 来监控opQueue是否已经完成
//        [_opQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)fetchUserIllusts:(void(^)(BOOL success, NSString *errorMsg, NSDictionary *illusts))fetchResult {
    NSBlockOperation *userOperation = [NSBlockOperation blockOperationWithBlock:^{
        self->_user = [[PixivAPI sharedInstance] PAPI_users:self->_userId];
    }];
    userOperation.completionBlock = ^() {
        if (!self->_user) {
            fetchResult(NO, @"获取用户信息失败，无法进行后续操作", @{@"userPage":self->_userPage});
        } else {
            self->illustCount = [self->_user.response[@"stats"][@"works"] integerValue];
            NSInteger pageCount = ceilf(self->illustCount / 30.0); // 30 illusts per page
            
            for (int i = 1; i <= pageCount; i++) {
                NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                    PAPIIllustList *list = [[PixivAPI sharedInstance] PAPI_users_works:self->_user.author_id page:i publicity:NO];
                    for (int i = 0; i < list.illusts.count; i++) {
                        PAPIIllust *illust = (PAPIIllust *)list.illusts[i];
                        
                        if (illust.is_manga) {
                            NSMutableArray *imgs = [NSMutableArray array];
                            [imgs addObject:illust.url_large];
                            for (NSInteger i = 1; i < illust.page_count; i++) {
                                [imgs addObject:[illust.url_large stringByReplacingOccurrencesOfString:@"_p0" withString:[NSString stringWithFormat:@"_p%ld", i]]];
                            }
                            
                            [self->fetchLists addObject:[NSArray arrayWithArray:imgs]];
                        } else {
                            NSString *large = illust.url_large;
                            if ([large containsString:@"ugoira"]) {
                                NSDictionary *zip_urls = [NSDictionary dictionaryWithDictionary:illust.metadata[@"zip_urls"]];
                                [self->fetchLists addObject:@[zip_urls.allValues.firstObject]];
                            } else {
                                [self->fetchLists addObject:@[large]];
                            }
                        }
                    }
                }];
                operation.completionBlock = ^() {
                    [[UtilityFile sharedInstance] showLogWithFormat:@"已获取到: %ld条信息, 共计: %ld条", self->fetchLists.count, [self->_user.response[@"stats"][@"works"] integerValue]];
                    
                    if (self->fetchLists.count == self->illustCount) {
                        NSMutableArray *imgUrls = [NSMutableArray array];
                        for (NSInteger i = 0; i < self->fetchLists.count; i++) {
                            NSArray *fetch = [NSArray arrayWithArray:self->fetchLists[i]];
                            [imgUrls addObjectsFromArray:fetch];
                        }
                        
                        fetchResult(YES, @"获取illust成功", @{self->_user.name:[NSArray arrayWithArray:imgUrls]});
                    }
                };
                [self->_opQueue addOperation:operation];
            }
        }
    };
    [_opQueue addOperation:userOperation];
}

@end
