//
//  ExHentaiPagesManager.h
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExHentaiPagesDelegate <NSObject>

@required
- (void)didGetAllUrls:(NSArray<NSString *> *)urls error:(NSError *)error;

@optional
- (void)didGetAllPages:(NSArray<NSString *> *)pages error:(NSError *)error;

@end

@interface ExHentaiPagesManager : NSObject {
    NSMutableArray *pageArray;
    NSMutableArray *urlArray;
    
    NSInteger downloaded;
    NSMutableArray *failure;
}

@property (weak) id <ExHentaiPagesDelegate> delegate;
@property (readonly, copy) NSString *homepage;
@property (readonly, copy) NSString *title;
@property (readonly, assign) NSInteger start;
@property (readonly, assign) NSInteger end;
@property (readonly, assign) NSInteger total;

- (instancetype)initWithHomepage:(NSString *)homepage;
- (void)startFetching;

@end
