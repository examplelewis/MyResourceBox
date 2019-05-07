//
//  DownloadInfoObject.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/07.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "DownloadInfoObject.h"

@implementation DownloadInfoObject

- (instancetype)initWithURLString:(NSString *)url {
    self = [super init];
    if (self) {
        _url = url;
        _error = nil;
        [self getInfoFromUrl];
    }
    
    return self;
}
- (instancetype)initWithError:(NSError *)error {
    self = [super init];
    if (self) {
        _error = error;
        [self getInfoFromError];
    }
    
    return self;
}

- (void)getInfoFromError {
    _url = self.error.userInfo[NSURLErrorFailingURLStringErrorKey];
    if (!_url) {
        _url = self.error.userInfo[@"NSErrorFailingURLKey"];
        if (!_url) {
            _url = self.error.userInfo[@"NSErrorFailingURLStringKey"];
            if (!_url) {
                _url = @"";
            }
        }
    }
    
    if ([self.error.localizedDescription containsString:@"The network connection was lost."] || [self.error.localizedDescription containsString:@"The request timed out."]) {
        _type = DownloadInfoTypeErrorConnectionLost;
    } else {
        _type = DownloadInfoTypeErrorOther;
    }
}
- (void)getInfoFromUrl {
    NSString *extension = self.url.pathExtension;
    if ([allPhotoType containsObject:extension]) {
        _type = DownloadInfoTypeImage;
    } else if ([allVideoType containsObject:extension]) {
        _type = DownloadInfoTypeVideo;
    } else {
        _type = DownloadInfoTypeOther;
    }
}

@end
