//
//  DownloadInfoObject.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/07.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

typedef NS_ENUM(NSUInteger, DownloadInfoType) {
    DownloadInfoTypeOther,
    DownloadInfoTypeVideo,
    DownloadInfoTypeImage,
    DownloadInfoTypeErrorOther,
    DownloadInfoTypeErrorConnectionLost
};

#import <Foundation/Foundation.h>

@interface DownloadInfoObject : NSObject

@property (copy) NSString *url;
@property (strong) NSError *error;
@property (assign) DownloadInfoType type;

- (instancetype)initWithURLString:(NSString *)url;
- (instancetype)initWithError:(NSError *)error;

@end
