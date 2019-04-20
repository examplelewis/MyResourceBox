//
//  ExHentaiPixivUrlsManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExHentaiPixivUrlsDelegate <NSObject>

@required
- (void)didGetAllPixivUrls:(NSArray<NSString *> *)pixivUrls error:(NSError *)error;

@optional
- (void)didGetOnePixivUrl:(NSString *)pixivUrl error:(NSError *)error;

@end

@interface ExHentaiPixivUrlsManager : NSObject {
    NSArray *oriExhentaiUrls;
    NSMutableArray *hasPixivUrlExHentaiUrls;
    NSMutableArray *pixivUrls;
    NSMutableDictionary *parseInfo; // hasPixivUrlExHentaiUrls 和 pixivUrls 的对应关系
    
    NSInteger downloaded;
    NSMutableArray *failure;
}

@property (weak) id <ExHentaiPixivUrlsDelegate> delegate;

- (instancetype)initWithUrls:(NSArray *)urls;
- (void)startFetching;

@end

NS_ASSUME_NONNULL_END
