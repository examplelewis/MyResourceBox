//
//  LofterMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/03.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "LofterMethod.h"
#import "CookieManager.h"
#import "DownloadQueueManager.h"
#import "OrganizeManager.h"

@interface LofterMethod () {
    NSInteger downloaded;
    
    NSArray *pageArray;
    NSMutableArray *resultArray;
    NSMutableDictionary *renameDict; //重命名文件夹
    NSMutableArray *failedURLArray; //没有获取到图片的半次元网页地址
}

@end

@implementation LofterMethod

static LofterMethod *instance;
+ (LofterMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LofterMethod alloc] init];
    });
    
    return instance;
}

- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取Lofter的图片地址：已经准备就绪"];
    downloaded = 0;
    
    switch (cellRow) {
        case 1:
            [self getPage];
            break;
        case 2:
            [self getImage];
            break;
        case 3:
            [self arrangeImageFile];
            break;
        default:
            break;
    }
}

// 1、获取网页地址
- (void)getPage {
    NSData *data = [[AppDelegate defaultVC].inputTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    //获取a标签
    NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
    NSPredicate *postPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable elemnt, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [elemnt.attributes[@"href"] hasPrefix:@"/post/"];
    }];
    NSPredicate *netPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable elemnt, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [elemnt.attributes[@"href"] containsString:@".lofter.com"] && ![elemnt.attributes[@"href"] containsString:@"www.lofter.com"];
    }];
    NSArray *postArray = [aArray filteredArrayUsingPredicate:postPredicate];
    NSArray *netArray = [aArray filteredArrayUsingPredicate:netPredicate];
    TFHppleElement *netElement = (TFHppleElement *)netArray.firstObject;
    NSString *netPrefix = netElement.attributes[@"href"];
    
    NSMutableArray *fetchArray = [NSMutableArray array];
    for (TFHppleElement *elemnt in postArray) {
        NSString *src = [netPrefix stringByAppendingPathComponent:elemnt.attributes[@"href"]];
        
        [fetchArray addObject:src];
    }
    
    // 导出结果
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条数据", fetchArray.count];
    [UtilityFile exportArray:fetchArray atPath:@"/Users/Mercury/Downloads/LofterPageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"整个流程已经结束，如有需要，请从上方的结果框中查看记录"];
}

// 2、解析输入的地址
- (void)getImage {
    CookieManager *manager = [[CookieManager alloc] initWithCookieFileType:CookieFileTypeLofter];
    [manager writeCookiesIntoHTTPStorage];
    
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    if (input.length > 0) {
        pageArray = [NSArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"从文件解析到%ld条网页\n", pageArray.count];
        
        [self fetchHtml];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
    }
}
// 3、获取网页数据
- (void)fetchHtml {
    resultArray = [NSMutableArray array];
    renameDict = [NSMutableDictionary dictionary];
    failedURLArray = [NSMutableArray array];
    
    for (NSString *string in pageArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
                [failedURLArray addObject:[error userInfo][NSURLErrorFailingURLStringErrorKey]];
                [self didFinishFetchingOnePage:NO];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                //获取title标签
                NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
                TFHppleElement *element = (TFHppleElement *)titleArray.firstObject;
                NSString *title = [element.text componentsSeparatedByString:@"-"].firstObject;
                
                
                //获取img标签
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable elemnt, NSDictionary<NSString *,id> * _Nullable bindings) {
                    NSString *bigimgsrc = elemnt.attributes[@"bigimgsrc"];
                    return (bigimgsrc && ![bigimgsrc hasPrefix:@"http://imgsize"]);
                }];
                NSArray *filterArray = [aArray filteredArrayUsingPredicate:predicate];
                NSMutableArray *fetchArray = [NSMutableArray array];
                for (NSInteger i = 0; i < filterArray.count; i++) {
                    TFHppleElement *element = (TFHppleElement *)filterArray[i];
                    
                    NSString *url = element.attributes[@"bigimgsrc"];
                    if ([url containsString:@"?"]) {
                        url = [url componentsSeparatedByString:@"?"].firstObject;
                    }
                    
                    [fetchArray addObject:url];
                }
                
                
                // 结果
                if (fetchArray.count > 0) {
                    [resultArray addObjectsFromArray:fetchArray];
                    
                    if ([renameDict.allKeys containsObject:title]) {
                        [(NSMutableArray *)renameDict[title] addObjectsFromArray:fetchArray];
                    } else {
                        [renameDict setObject:fetchArray forKey:title];
                    }
                    
                    [self didFinishFetchingOnePage:YES];
                } else {
                    [failedURLArray addObject:response.URL.absoluteString];
                    [self didFinishFetchingOnePage:NO];
                }
            }
        }];
        
        [task resume];
    }
}
// 3、导出结果
- (void)doneThings {
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取了%ld个页面的图片地址", pageArray.count]; //获取到的页面地址
    [UtilityFile exportArray:pageArray atPath:@"/Users/Mercury/Downloads/LofterPageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", resultArray.count];
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/LofterImageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
    [UtilityFile exportArray:failedURLArray atPath:@"/Users/Mercury/Downloads/LofterFailedURLs.txt"];
    [renameDict writeToFile:@"/Users/Mercury/Downloads/LofterRenameInfo.plist" atomically:YES]; //RenameDict
    
    // 下载
    [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始下载图片"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
    });
}
// 4、下载
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:resultArray];
    manager.downloadPath = @"/Users/Mercury/Downloads/Lofter";
    [manager startDownload];
}

#pragma mark -- 整理方法 --
// 根据Plist文件将图片整理到对应的文件夹中（第一步，显示NSOpenPanel）
- (void)arrangeImageFile {
    OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:@"/Users/Mercury/Downloads/LofterRenameInfo.plist"];
    [manager startOrganizing];
}

#pragma mark -- 辅助方法 --
// 下载完成的方法
- (void)didFinishFetchingOnePage:(BOOL)success {
    downloaded++;
    
    if (success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, pageArray.count];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", downloaded, pageArray.count];
    }
    
    if (downloaded == pageArray.count) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"已经完成获取图片地址的工作\n"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneThings];
        });
    }
}

@end
