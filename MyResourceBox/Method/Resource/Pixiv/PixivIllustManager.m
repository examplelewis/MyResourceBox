//
//  PixivIllustManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/06.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "PixivIllustManager.h"
#import "PixivAPI.h"

@interface PixivIllustManager () {
    NSMutableArray *fetchLists;
}

@property (nonatomic, copy) NSString *webPage;
@property (nonatomic, assign) NSInteger illustId;
@property (nonatomic, strong) NSOperationQueue *opQueue;
@property (nonatomic, strong) PAPIIllust *illust;

@end

@implementation PixivIllustManager

- (instancetype)initWithWebpage:(NSString *)webPage {
    self = [super init];
    if (self) {
        _webPage = webPage;
        _illustId = [[webPage componentsSeparatedByString:@"id="].lastObject integerValue];
        
        fetchLists = [NSMutableArray array];
        _opQueue = [NSOperationQueue new];
        
        // 使用KVO 来监控opQueue是否已经完成
//        [_opQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)fetchIllusts:(void (^)(BOOL, NSString *, NSDictionary *))fetchResult {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        self->_illust = [[PixivAPI sharedInstance] PAPI_works:self->_illustId];
    }];
    operation.completionBlock = ^() {
        if (!self->_illust) {
            fetchResult(NO, @"获取illust失败，无法进行后续操作", @{@"webPage":self->_webPage});
        } else {
            NSDictionary *result = @{};
            if (self->_illust.is_manga) {
                NSMutableArray *imgs = [NSMutableArray array];
                [imgs addObject:self->_illust.url_large];
                for (NSInteger i = 1; i < self->_illust.page_count; i++) {
                    [imgs addObject:[self->_illust.url_large stringByReplacingOccurrencesOfString:@"_p0" withString:[NSString stringWithFormat:@"_p%ld", i]]];
                }
                
                result = @{self->_illust.user[@"name"]:[NSArray arrayWithArray:imgs]};
            } else {
                NSString *large = self->_illust.url_large;
                if ([large containsString:@"ugoira"]) {
                    NSDictionary *zip_urls = [NSDictionary dictionaryWithDictionary:self->_illust.metadata[@"zip_urls"]];
                    result = @{self->_illust.user[@"name"]:@[zip_urls.allValues.firstObject]};
                } else {
                    result = @{self->_illust.user[@"name"]:@[large]};
                }
            }
            fetchResult(YES, @"获取illust成功", result);
        }
    };
    [_opQueue addOperation:operation];
}

@end
