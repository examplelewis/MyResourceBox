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
- (void)didGetAllPixivUrls:(NSArray<NSString *> *)pixivUrls error:(nullable NSError *)error;

@optional
- (void)didGetOnePixivUrl:(NSString *)pixivUrl error:(nullable NSError *)error;

@end

@interface ExHentaiPixivUrlsManager : NSObject

@property (weak) id <ExHentaiPixivUrlsDelegate> delegate;

- (instancetype)initWithUrls:(NSArray *)urls;
- (void)startFetching;

@end

NS_ASSUME_NONNULL_END
