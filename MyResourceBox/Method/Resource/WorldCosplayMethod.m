//
//  WorldCosplayMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WorldCosplayMethod.h"
#import "CookieManager.h"
#import "FileManager.h"
#import "DownloadQueueManager.h"

@interface WorldCosplayMethod () {
    NSString *title;
    NSArray *pageUrls;
    NSMutableArray *results;
    NSMutableArray *failedURLArray; //没有获取到图片的Cosplay网页地址
    
    NSInteger downloaded;
}

@end

@implementation WorldCosplayMethod

static const NSString *worldCosplayPrefix = @"http://worldcosplay.net";

static WorldCosplayMethod *method;
+ (WorldCosplayMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[WorldCosplayMethod alloc] init];
    });
    
    return method;
}

- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取WorldCosplay的图片地址：已经准备就绪"];
    
    CookieManager *manager = [[CookieManager alloc] initWithCookieFileType:CookieFileTypeWorldCosplay];
    [manager writeCookiesIntoHTTPStorage];
    
    switch (cellRow) {
        case 1:
            [self getHTMLFromInput];
            break;
        case 2:
            [self getPageUrlsFromInput];
            break;
        default:
            break;
    }
}

#pragma mark -- 逻辑方法 --
// 1.1、从输入的HTML中获取网页信息
- (void)getHTMLFromInput {
    pageUrls = [NSMutableArray array];
    NSData *data = [[AppDelegate defaultVC].inputTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    //获取title标签
    NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
    TFHppleElement *element = (TFHppleElement *)titleArray.firstObject;
    title = [element.text stringByReplacingOccurrencesOfString:@"上传图像一览 | " withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@" - Cure WorldCosplay" withString:@""];
    
    
    //获取img标签
    NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable elemnt, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [elemnt.attributes[@"ng-href"] isEqualToString:elemnt.attributes[@"href"]];
    }];
    NSArray *filterArray = [aArray filteredArrayUsingPredicate:predicate];
    pageUrls = [NSArray arrayWithArray:[filterArray valueForKeyPath:@"attributes.href"]];
    
    if (pageUrls.count > 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条网页地址", pageUrls.count];
        
        // 处理获取到的Pages
        NSMutableArray *fullPages = [NSMutableArray array];
        for (NSInteger i = 0; i < pageUrls.count; i++) {
            NSString *page = pageUrls[i];
            page = [@"http://worldcosplay.net" stringByAppendingString:page];
            [fullPages addObject:page];
        }
        pageUrls = [NSArray arrayWithArray:fullPages];
        
        NSString *urlsPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/WorldCosplayPageURLs__%@.txt", title];
        [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取了%ld个页面的图片地址", pageUrls.count]; //获取到的页面地址
        [UtilityFile exportArray:pageUrls atPath:urlsPath];
        
        [self parseHTML];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取失败，没有获得任何数据，请检查输入框"];
    }
}
// 1.2、从输入中获取网页信息
- (void)getPageUrlsFromInput {
    NSString *string = [AppDelegate defaultVC].inputTextView.string;
    pageUrls = [string componentsSeparatedByString:@"\n"];
    
    if (string.length > 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条网页地址", pageUrls.count];
        
        [self parseHTML];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取失败，没有获得任何数据，请检查输入框"];
    }
}
// 2、解析每个页面，获取图片地址
- (void)parseHTML {
    downloaded = 0;
    results = [NSMutableArray array];
    failedURLArray = [NSMutableArray array];
    
    for (NSString *string in pageUrls) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            self->downloaded++;
            
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                [[UtilityFile sharedInstance] showNotAppendLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", self->downloaded, self->pageUrls.count];
                
                NSString *url = [error userInfo][NSURLErrorFailingURLStringErrorKey];
                if (url) {
                    [self->failedURLArray addObject:url];
                    
                    NSString *failPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/WorldCosplayFailedURLs__%@.txt", self->title];
                    [UtilityFile exportArray:self->failedURLArray atPath:failPath];
                }
            } else {
                [[UtilityFile sharedInstance] showNotAppendLogWithFormat:@"第%lu条网页已获取成功 | 共%lu条网页", self->downloaded, self->pageUrls.count];
                
                NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([htmlString isEqualToString:@"Retry later\n"]) {
                    [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页 超过了最大限制次数", self->downloaded];
                }
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
                NSArray<NSTextCheckingResult *> *matchResults = [detector matchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
                
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSTextCheckingResult * _Nullable detectResult, NSDictionary<NSString *,id> * _Nullable bindings) {
                    NSString *urlString = [htmlString substringWithRange:detectResult.range];
                    
                    if (![urlString hasSuffix:@"jpeg"] && ![urlString hasSuffix:@"jpg"] && ![urlString hasSuffix:@"png"]) {
                        return NO;
                    }
                    if (![urlString containsString:@".sakurastorage.jp"]) {
                        return NO;
                    }
                    // 包含: /sq300/ 是缓存图片
                    if ([urlString containsString:@"/sq300/"]) {
                        return NO;
                    }
                    // 取包含-740的图片地址作为分析对象
                    if (![urlString containsString:@"-740"]) {
                        return NO;
                    }
                    
                    return YES;
                }];
                NSArray<NSTextCheckingResult *> *filterResults = [matchResults filteredArrayUsingPredicate:predicate];
                
                if (filterResults.count > 0) {
                    NSString *urlString = [htmlString substringWithRange:filterResults.firstObject.range];
                    NSString *tagComponent = urlString.pathComponents[2];
                    NSInteger tag = [tagComponent hasPrefix:@"max"] ? [[tagComponent componentsSeparatedByString:@"-"].lastObject integerValue] : 3000;
                    NSString *filePath = [urlString stringByReplacingOccurrencesOfString:@"-740" withString:[NSString stringWithFormat:@"-%ld", tag]];
                    
                    [self->results addObject:filePath];
                } else {
                    if (response.URL.absoluteString) {
                        [self->failedURLArray addObject:response.URL.absoluteString];
                    }
                }
            }
            
            if (self->downloaded == self->pageUrls.count) {
                [self doneThings];
            }
        }];
        
        [task resume];
    }
}

// 5、导出结果
- (void)doneThings {
    NSString *imgsPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/WorldCosplayImageURLs__%@.txt", title];
    NSString *failPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/WorldCosplayFailedURLs__%@.txt", title];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", results.count];
    [UtilityFile exportArray:results atPath:imgsPath];
    [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
    [UtilityFile exportArray:failedURLArray atPath:failPath];
    
    // 下载
//    [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始下载图片"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
//    });
}
// 6、下载
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:results];
    manager.downloadPath = @"/Users/Mercury/Downloads/WorldCosplay";
    [manager startDownload];
}

@end
