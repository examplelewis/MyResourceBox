//
//  ExHentaiUrlsManager.h
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExHentaiUrlsDelegate <NSObject>

@required
- (void)didGetAllImageUrls:(NSArray<NSString *> *)imageUrls error:(NSError *)error;

@optional
- (void)didGetOneImageUrl:(NSString *)imageUrl error:(NSError *)error;

@end

@interface ExHentaiUrlsManager : NSObject {
    NSArray *urlsArray;
    NSMutableArray *resultArray;
    
    NSInteger downloaded;
    NSMutableArray *failure;
}

@property (weak) id <ExHentaiUrlsDelegate> delegate;

- (instancetype)initWithUrls:(NSArray *)urls;
- (void)startFetching;

@end
