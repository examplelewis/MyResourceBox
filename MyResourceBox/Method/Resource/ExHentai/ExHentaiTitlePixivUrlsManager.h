//
//  ExHentaiTitlePixivUrlsManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/07/20.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExHentaiTitlePixivUrlsDelegate <NSObject>

@required
- (void)didGetAllTitlePixivUrls:(NSArray<NSString *> *)pixivUrls error:(nullable NSError *)error;

@optional
- (void)didGetOneTitlePixivUrl:(NSString *)pixivUrl error:(nullable NSError *)error;

@end


@interface ExHentaiTitlePixivUrlsManager : NSObject {
    NSArray *oriExhentaiUrls;
    NSMutableArray *hasPixivUrlExHentaiUrls;
    NSMutableArray *pixivUrls;
    NSMutableDictionary *parseInfo; // hasPixivUrlExHentaiUrls 和 pixivUrls 的对应关系
    
    NSInteger downloaded;
    NSMutableArray *failure;
}

@property (weak) id <ExHentaiTitlePixivUrlsDelegate> delegate;

- (instancetype)initWithUrls:(NSArray *)urls;
- (void)startFetching;

@end

NS_ASSUME_NONNULL_END
