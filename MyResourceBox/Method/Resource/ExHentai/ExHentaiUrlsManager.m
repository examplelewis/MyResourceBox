//
//  ExHentaiUrlsManager.m
//  MyToolBox
//
//  Created by 龚宇 on 16/11/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ExHentaiUrlsManager.h"

@implementation ExHentaiUrlsManager

- (instancetype)initWithUrls:(NSArray *)urls {
    self = [super init];
    if (self) {
        urlsArray = [NSArray arrayWithArray:urls];
        resultArray = [NSMutableArray array];
        failure = [NSMutableArray array];
        downloaded = 0;
    }
    
    return self;
}

// 解析每个页面，获取图片地址
- (void)startFetching {
    downloaded = 0;
    [failure removeAllObjects];
    
    for (NSInteger i = 0; i < urlsArray.count; i++) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlsArray[i]]
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
                
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
                [self->failure addObject:url];
                [UtilityFile exportArray:self->failure atPath:@"/Users/Mercury/Downloads/ExHentaiFailureUrls.txt"];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                // 查找是否包含 Download Original 的链接
                BOOL foundOrigin = NO;
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                for (TFHppleElement *elemnt in aArray) {
                    NSString *raw = elemnt.raw;
                    if ([raw containsString:@"Download original"]) {
                        foundOrigin = YES;
                        [self->resultArray addObject:[elemnt attributes][@"href"]];
                    }
                }
                
                // 如果没有找到 Original 的图片地址，再解析网页中的图片地址
                if (!foundOrigin) {
                    NSArray *imgArray = [xpathParser searchWithXPathQuery:@"//img"];
                    for (TFHppleElement *elemnt in imgArray) {
                        NSString *href = [elemnt attributes][@"src"];
                        if ([href hasPrefix:@"http://1"] || [href hasPrefix:@"http://2"] || [href hasPrefix:@"http://3"] || [href hasPrefix:@"http://4"] || [href hasPrefix:@"http://5"] || [href hasPrefix:@"http://6"] || [href hasPrefix:@"http://7"] || [href hasPrefix:@"http://8"] || [href hasPrefix:@"http://9"]) {
                            [self->resultArray addObject:href];
                        }
                    }
                }
            }
            
            [self didFinishDownloadingOnePicture];
        }];
        [task resume];
    }
}

// 完成下载图片地址的方法
- (void)didFinishDownloadingOnePicture {
    downloaded++;
    [[UtilityFile sharedInstance] showNotAppendLogWithFormat:@"已获取到第%lu条记录 | 共%lu条记录", downloaded, urlsArray.count];
    
    if (downloaded != urlsArray.count) {
        return;
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取完成"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条数据", resultArray.count];
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/ExHentaiImageUrls.txt"];
    if (failure.count > 0) {
        [UtilityFile exportArray:failure atPath:@"/Users/Mercury/Downloads/ExHentaiFailureUrls.txt"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld个文件无法下载，已导出到下载文件夹的ExHentaiFailureUrls.txt文件中", failure.count];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetAllImageUrls:error:)]) {
            [self.delegate didGetAllImageUrls:[self->resultArray mutableCopy] error:nil];
        }
    });
}

@end
