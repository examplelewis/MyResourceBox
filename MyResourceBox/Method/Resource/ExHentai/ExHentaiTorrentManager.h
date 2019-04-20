//
//  ExHentaiTorrentManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/08/24.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExHentaiTorrentDelegate <NSObject>

- (void)didGetAllTorrents:(NSArray *)torrents error:(NSError *)error;

@end

@interface ExHentaiTorrentManager : NSObject {
    NSArray *urlsArray;
    NSMutableArray *resultArray;
    
    NSInteger downloaded;
    NSMutableArray *failure;
}

@property (weak) id <ExHentaiTorrentDelegate> delegate;

- (instancetype)initWithUrls:(NSArray *)urls;
- (void)startFetching;

@end
