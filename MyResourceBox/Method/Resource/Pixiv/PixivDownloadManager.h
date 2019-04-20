//
//  PixivDownloadManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/07.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PixivDownloadManagerDelegate <NSObject>

- (void)didFinishAllDonwload;

@end

@interface PixivDownloadManager : NSObject

@property (nonatomic, weak) id <PixivDownloadManagerDelegate> delegate;

- (instancetype)initWithResult:(NSDictionary *)result;
- (void)startDownload;

@end
