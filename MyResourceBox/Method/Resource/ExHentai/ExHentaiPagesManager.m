//
//  ExHentaiPagesManager.m
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ExHentaiPagesManager.h"
#import "HttpManager.h"

@implementation ExHentaiPagesManager

- (instancetype)initWithHomepage:(NSString *)homepage {
    self = [super init];
    if (self) {
        _homepage = homepage;
    }
    
    return self;
}

- (void)startFetching {
    urlArray = [NSMutableArray array];
    failure = [NSMutableArray array];
    
    NSArray *components = [_homepage componentsSeparatedByString:@"|"];
    _homepage = components.firstObject;
    
    downloaded = 0;
    _title = @"";
    
    switch (components.count) {
        case 1: {
            _start = 1;
            _end = 1;
            
            [self fetchPostDetail];
        }
            break;
        case 2: {
            _start = [components[1] integerValue];
            _end = 1;
            
            [self fetchPostDetail];
        }
            break;
        case 3: {
            _start = [components[1] integerValue];
            _end = [components[2] integerValue];
            
            [self getAnotherPage];
        }
            break;
        default:
            break;
    }
}

// 获取首页包含图片的网页地址以及数据信息
- (void)fetchPostDetail {
    [[HttpManager sharedManager] getExHentaiPostDetailWithUrl:self.homepage success:^(NSDictionary *result) {
        self->_total = [result[@"filecount"] integerValue];
        self->_end = ceil(self->_total / 20.0);
        self->_title = [result[@"title_jpn"] length] == 0 ? result[@"title"] : result[@"title_jpn"];
        
        [self getAnotherPage];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"ExHentai 接口调用失败，原因：%@", errorMsg];
    }];
}


// 获取包含图片的网页地址以及数据信息
- (void)getAnotherPage {
    for (NSInteger i = _start; i <= _end; i++) {
        NSString *urlString = [self.homepage stringByAppendingFormat:@"?p=%ld", i - 1];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSString *url = error.userInfo[NSURLErrorFailingURLStringErrorKey];
                if (!url) {
                    url = error.userInfo[@"NSErrorFailingURLKey"];
                    if (!url) {
                        url = error.userInfo[@"NSErrorFailingURLStringKey"];
                        if (!url) {
                            url = @"";
                        }
                    }
                }
                
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页原始数据失败，原因：%@", [error localizedDescription]];
                
                [self->failure addObject:url];
                [UtilityFile exportArray:self->failure atPath:@"/Users/Mercury/Downloads/ExHentaiFailurePages.txt"];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                
                for (TFHppleElement *elemnt in aArray) {
                    NSDictionary *aDic = [elemnt attributes];
                    NSString *string = [aDic objectForKey:@"href"];
                    if ([string hasPrefix:@"https://exhentai.org/s/"]) {
                        [self->urlArray addObject:string];
                    }
                }
            }
            
            [self didFinishDownloadingOneWebpage];
        }];
        [task resume];
    }
}

// -------------------------------------------------------------------------------
//	完成下载网页地址的方法
// -------------------------------------------------------------------------------
- (void)didFinishDownloadingOneWebpage {
    downloaded++;
    
    if (downloaded != _end - _start + 1) {
        return;
    }
    
    if (urlArray.count == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获取到包含图片的网页地址"];
        // 提醒 Cookie 过期
        if ([[NSDate date] timeIntervalSince1970] > 1541415982.704804) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"如果确认操作无误，有可能是ExHentai的Cookie过期了，请重新在Chrome中刷新Cookie。Cookie预计到期时间：2018年11月05日"];
        }
        
        return;
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"已获取到%lu条包含图片的网页地址", urlArray.count];
    
    if (failure.count > 0) {
        [UtilityFile exportArray:failure atPath:@"/Users/Mercury/Downloads/ExHentaiFailurePages.txt"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld个页面无法解析，已导出到下载文件夹的ExHentaiFailurePages.txt文件中", failure.count];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetAllUrls:error:)]) {
            [self.delegate didGetAllUrls:[self->urlArray mutableCopy] error:nil];
        }
    });
}

@end
