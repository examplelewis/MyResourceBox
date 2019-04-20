//
//  ExHentaiTorrentManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/08/24.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "ExHentaiTorrentManager.h"

@implementation ExHentaiTorrentManager

- (instancetype)initWithUrls:(NSArray *)urls {
    self = [super init];
    if (self) {
        urlsArray = [NSArray arrayWithArray:urls];
        resultArray = [NSMutableArray array];
        failure = [NSMutableArray array];
        downloaded = 0;
        
        for (NSString *url in urls) {
            [resultArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"url": url, @"title": @"", @"torrent": @""}]];
        }
    }
    
    return self;
}

- (void)startFetching {
    downloaded = 0;
    [failure removeAllObjects];
    
    [self fetchTorrent];
}

// 解析每个页面，获取图片地址
- (void)fetchTorrent {
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
                [UtilityFile exportArray:self->failure atPath:@"/Users/Mercury/Downloads/ExHentaiFailureTorrents.txt"];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
//                BOOL hasTorrent = NO;
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                for (TFHppleElement *elemnt in aArray) {
                    TFHppleElement *firstChild = (TFHppleElement *)elemnt.children.firstObject;
                    
                    if (firstChild && [firstChild.content containsString:@"Torrent Download"] && [self findNumFromStr:firstChild.content] > 0) {
                        NSString *ops = [elemnt attributes][@"onClick"];
                        NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
                        [detector enumerateMatchesInString:ops options:NSMatchingReportCompletion range:NSMakeRange(0, ops.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                            
                        }];
                        [self->resultArray addObject:[elemnt attributes][@"href"]];
                    }
                }
            }
            [self didFinishDownloadingOnePicture];
        }];
        [task resume];
    }
}

- (NSInteger)findNumFromStr:(NSString *)originalString {
    // Intermediate
    NSMutableString *numberString = [[NSMutableString alloc] init];
    NSString *tempStr;
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (![scanner isAtEnd]) {
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        [numberString appendString:tempStr];
        tempStr = @"";
    }
    
    // Result.
    return [numberString integerValue];
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
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/ExHentaiTorrents.txt"];
    if (failure.count > 0) {
        [UtilityFile exportArray:failure atPath:@"/Users/Mercury/Downloads/ExHentaiFailureTorrents.txt"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld个文件无法下载，已导出到下载文件夹的ExHentaiFailureTorrents.txt文件中", failure.count];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetAllTorrents:error:)]) {
            [self.delegate didGetAllTorrents:[self->resultArray mutableCopy] error:nil];
        }
    });
}

@end
