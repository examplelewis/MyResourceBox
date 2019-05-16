//
//  BCYFetchManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "BCYFetchManager.h"
#import "BCYHeader.h"
#import "SQLiteManager.h"
#import "SQLiteFMDBManager.h"
#import "CookieManager.h"
#import "DownloadQueueManager.h"

@interface BCYFetchManager () {
    NSInteger downloaded;
    
    NSMutableArray *checkArray; //半次元校验位组成的数组
    NSMutableArray *pageArray;
    NSMutableArray *resultArray;
    NSMutableDictionary *renameDict; //重命名文件夹
    NSMutableArray *failedURLArray; //没有获取到图片的半次元网页地址
    
    BOOL checkDB; // 是否检查数据库
}

@end

@implementation BCYFetchManager

// 1.1 ~ 1.2、获取半次元网页地址
- (void)getPageURLFromInput:(BOOL)check {
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取半次元的图片地址：已经准备就绪"];
    
    CookieManager *manager = [[CookieManager alloc] initWithCookieFileType:CookieFileTypeBCY];
    [manager writeCookiesIntoHTTPStorage];
    
    checkDB = check;
    downloaded = 0;
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length > 0) {
        pageArray = [NSMutableArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
        [[MRBLogManager defaultManager] showLogWithFormat:@"从文件解析到%ld条网页\n", pageArray.count];
        
        [self ruleoutDuplicatePages];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
    }
}
- (void)getPageURLFromFile {
    [MRBLogManager resetCurrentDate];
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取半次元的图片地址：已经准备就绪"];
    
    CookieManager *manager = [[CookieManager alloc] initWithCookieFileType:CookieFileTypeBCY];
    [manager writeCookiesIntoHTTPStorage];
    
    checkDB = YES;
    downloaded = 0;
    
    NSMutableArray *parsedArray = [NSMutableArray array];
    NSData *data = [NSData dataWithContentsOfFile:BCYHtmlFilePath];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *array = [xpathParser searchWithXPathQuery:@"//a"];
    
    for (TFHppleElement *elemnt in array) {
        NSDictionary *dict = [elemnt attributes];
        NSString *url = [dict objectForKey:@"href"];
        
        if ([url hasPrefix:@"http://bcy.net/coser/detail/"] || [url hasPrefix:@"http://bcy.net/illust/detail/"] || [url hasPrefix:@"http://bcy.net/party/expo/post/"] || [url hasPrefix:@"http://bcy.net/group/detail/"] || [url hasPrefix:@"http://bcy.net/group/detail/"]) {
            [parsedArray addObject:url];
        }
    }
    
    if (parsedArray.count > 0) {
        pageArray = [NSMutableArray arrayWithArray:parsedArray];
        [[MRBLogManager defaultManager] showLogWithFormat:@"从文件解析到%ld条网页\n", pageArray.count];
        
        [self ruleoutDuplicatePages];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查书签文件"];
    }
}
// 2、排除重复的页面地址
- (void)ruleoutDuplicatePages {
    checkArray = [NSMutableArray array];
    
    //使用NSOrderedSet，去掉在收藏到Safari时就存在的重复页面
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:pageArray];
    pageArray = [NSMutableArray arrayWithArray:set.array];
    
    if (checkDB) {
        //从数据库中查询是否有重复的页面地址，如果页面地址重复从数组中删除，如果页面地址不重复添加到数据库中
        for (NSInteger i = pageArray.count - 1; i >= 0; i--) {
            if ([[SQLiteFMDBManager defaultDBManager] isDuplicateFromDatabaseWithBCYLink:pageArray[i]]) {
                [pageArray removeObjectAtIndex:i];
            }
        }
    }
    
    //页面地址确保没有重复的情况下，添加半次元校验位
    for (NSString *url in pageArray) {
        NSArray *componet = [url componentsSeparatedByString:@"/"];
        [checkArray addObject:componet[5]];
    }
    
    if (pageArray.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未找到具体网页地址，流程结束"];
    } else {
        [self fetchHTML];
    }
}
// 3、解析每个页面，获取图片地址
- (void)fetchHTML {
    resultArray = [NSMutableArray array];
    renameDict = [NSMutableDictionary dictionary];
    failedURLArray = [NSMutableArray array];
    
    for (NSString *string in pageArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
                [self->failedURLArray addObject:[error userInfo][NSURLErrorFailingURLStringErrorKey]];
                [MRBUtilityManager exportArray:self->failedURLArray atPath:BCYFailedUrlsPath];
                [self didFinishDownloadingOnePicture:NO];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                //获取title标签
                NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
                TFHppleElement *element = (TFHppleElement *)titleArray.firstObject;
                NSString *title = [element.text stringByReplacingOccurrencesOfString:@" | 半次元-第一中文COS绘画小说社区" withString:@""];
                title = [title stringByReplacingOccurrencesOfString:@"/" withString:@" "];
                
                
                // 获取 script 标签
                NSArray *scriptArray = [xpathParser searchWithXPathQuery:@"//script"];
                TFHppleElement *jsonElement = [scriptArray bk_match:^BOOL(TFHppleElement *elemnt) {
                    return elemnt.raw && [elemnt.raw containsString:@"JSON.parse"];
                }];
                
                NSError *error;
                NSString *jsonRaw = jsonElement.raw;
                jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\\\u002F" withString:@"\\"];
                jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                NSArray *matchResult = [detector matchesInString:jsonRaw options:kNilOptions range:NSMakeRange(0, [jsonRaw length])];
                NSArray *matchUrlsResult = [matchResult valueForKeyPath:@"URL.absoluteString"];
                
                NSArray *imageUrls = [matchUrlsResult bk_select:^BOOL(NSString *obj) {
                    BOOL contains = [obj containsString:@"img-bcy-qn.pstatp.com/coser/"] || [obj containsString:@"img-bcy-qn.pstatp.com/user/"];
                    BOOL doesnotContains = ![obj containsString:@"post_count"] && ![obj containsString:@"2X2"];
                    
                    return contains && doesnotContains;
                }];
                NSArray *rawImageUrls = [imageUrls bk_map:^(NSString *obj) {
                    NSString *newObj = [obj stringByReplacingOccurrencesOfString:@",\"type\"" withString:@""];
                    newObj = [newObj stringByReplacingOccurrencesOfString:@"/w650\"" withString:@""];
                    newObj = [newObj stringByReplacingOccurrencesOfString:@"/w230\"" withString:@""];
                    newObj = [newObj stringByReplacingOccurrencesOfString:@"\"},{\"type\"" withString:@""];
                    
                    return newObj;
                }];
                
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [evaluatedObject hasSuffix:@"jpg"] || [evaluatedObject hasSuffix:@"jpeg"] || [evaluatedObject hasSuffix:@"png"];
                }];
                NSMutableArray *newImageUrls = [NSMutableArray arrayWithArray:[rawImageUrls filteredArrayUsingPredicate:predicate]];
                
                // 结果
                if (newImageUrls.count > 0) {
                    [self->resultArray addObjectsFromArray:newImageUrls];
                    
                    if ([self->renameDict.allKeys containsObject:title]) {
                        [(NSMutableArray *)self->renameDict[title] addObjectsFromArray:newImageUrls];
                    } else {
                        [self->renameDict setObject:newImageUrls forKey:title];
                    }
                    
                    [self didFinishDownloadingOnePicture:YES];
                } else {
                    [self->failedURLArray addObject:response.URL.absoluteString];
                    [self didFinishDownloadingOnePicture:NO];
                }
            }
        }];
        
        [task resume];
    }
}
// 4、排除重复的图片地址，并且将没有重复的图片地址保存到数据库中
- (void)ruleoutDuplicateImages {
    //使用NSOrderedSet，去掉在解析HTML文件时获取到的重复图片地址
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:resultArray];
    resultArray = [NSMutableArray arrayWithArray:set.array];
    
    if (checkDB) {
        //从数据库中查询是否有重复的图片地址，如果图片地址重复从数组中删除
        for (NSInteger i = resultArray.count - 1; i >= 0; i--) {
            if ([[SQLiteFMDBManager defaultDBManager] isDuplicateFromDatabaseWithBCYImageLink:resultArray[i]]) {
                NSLog(@"第%ld个图片地址重复: %@", i, resultArray[i]);
                [resultArray removeObjectAtIndex:i];
            }
        }
    }
    
    //如果有下载失败的页面地址，从pageArray中删除
    for (NSString *obj in failedURLArray) {
        [pageArray removeObject:obj];
    }
    
    [self doneThings];
}
// 5、导出结果
- (void)doneThings {
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取了%ld个页面的图片地址", pageArray.count]; //获取到的页面地址
    [MRBUtilityManager exportArray:pageArray atPath:BCYPageUrlsPath];
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", resultArray.count];
    [MRBUtilityManager exportArray:resultArray atPath:BCYImageUrlsPath];
    [[MRBLogManager defaultManager] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
    [MRBUtilityManager exportArray:failedURLArray atPath:BCYFailedUrlsPath];
    [renameDict writeToFile:BCYRenameInfoPath atomically:YES]; //RenameDict
    
    if (checkDB) {
        //把页面地址和图片地址全部写入到数据库中
        for (NSString *obj in pageArray) {
            [[SQLiteFMDBManager defaultDBManager] insertLinkIntoDatabase:obj];
        }
        for (NSString *obj in resultArray) {
            [[SQLiteFMDBManager defaultDBManager] insertImageLinkIntoDatabase:obj];
        }
        
        // 备份数据库
        [SQLiteManager backupDatabaseFile];
        [[MRBLogManager defaultManager] showLogWithFormat:@"整个流程已经结束，数据库已备份"];
    }
    
    // 下载
    [[MRBLogManager defaultManager] showLogWithFormat:@"1秒后开始下载图片"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
    });
}
// 6、下载
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:resultArray];
    manager.downloadPath = BCYDefaultDownloadPath;
    [manager startDownload];
}

#pragma mark -- 辅助方法 --
// 下载完成的方法
- (void)didFinishDownloadingOnePicture:(BOOL)success {
    downloaded++;
    
    if (success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, pageArray.count];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", downloaded, pageArray.count];
    }
    
    if (downloaded == pageArray.count) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"已经完成获取图片地址的工作\n"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ruleoutDuplicateImages];
        });
    }
}

@end
