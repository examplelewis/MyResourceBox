//
//  JDLingyuFetchManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "JDLingyuFetchManager.h"
#import "DownloadQueueManager.h"

@interface JDLingyuFetchManager () {
    NSArray *urlArray;
    NSMutableArray *resultArray;
    NSMutableDictionary *renameDict; //重命名文件夹
    NSMutableArray *failedURLArray; //没有获取到图片的半次元网页地址
    
    NSInteger downloaded;
}

@end

@implementation JDLingyuFetchManager

// 1、解析每个页面，获取图片地址
- (void)parseHTML {
    downloaded = 0;
    urlArray = [[AppDelegate defaultVC].inputTextView.string componentsSeparatedByString:@"\n"];
    resultArray = [NSMutableArray array];
    renameDict = [NSMutableDictionary dictionary];
    failedURLArray = [NSMutableArray array];
    
    for (NSString *string in urlArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
                [self->failedURLArray addObject:[error userInfo][NSURLErrorFailingURLStringErrorKey]];
                [UtilityFile exportArray:self->failedURLArray atPath:@"/Users/Mercury/Downloads/JDLingyuFailedURLs.txt"];
                [self didFinishDownloadingOneWebpage:NO];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                //获取title标签
                NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
                TFHppleElement *element = (TFHppleElement *)titleArray.firstObject;
                NSString *title = [element.text stringByReplacingOccurrencesOfString:@" – 绝对领域" withString:@""];
                
                //获取img标签
                NSArray *imgArray = [xpathParser searchWithXPathQuery:@"//img"];
                NSMutableArray *fetchArray = [NSMutableArray array];
                for (TFHppleElement *elemnt in imgArray) {
                    NSDictionary *dic = [elemnt attributes];
                    NSString *classString = [dic objectForKey:@"class"];
                    NSString *srcString = dic[@"src"];
                    if ([classString isEqualToString:@"alignnone size-medium"] || [classString isEqualToString:@"po-img-big"]) {
                        [fetchArray addObject:srcString];
                    }
                }
                if (fetchArray.count > 0) {
                    [self->resultArray addObjectsFromArray:fetchArray];
                    
                    if ([self->renameDict.allKeys containsObject:title]) {
                        [(NSMutableArray *)self->renameDict[title] addObjectsFromArray:fetchArray];
                    } else {
                        [self->renameDict setObject:fetchArray forKey:title];
                    }
                    
                    [self didFinishDownloadingOneWebpage:YES];
                } else {
                    [self->failedURLArray addObject:response.URL.absoluteString];
                    [self didFinishDownloadingOneWebpage:NO];
                }
            }
        }];
        
        [task resume];
    }
}
// 2、导出结果
- (void)doneThings {
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取了%ld个页面的图片地址", urlArray.count]; //获取到的页面地址
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/JdlingyuImageURLs.txt"];
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", resultArray.count];
    if (failedURLArray.count > 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
        [UtilityFile exportArray:failedURLArray atPath:@"/Users/Mercury/Downloads/JDLingyuFailedURLs.txt"];
    }
    [renameDict writeToFile:@"/Users/Mercury/Downloads/JDlingyuRenameInfo.plist" atomically:YES]; //RenameDict
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"1秒后开始下载"];
    [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
}
// 3、下载图片
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:resultArray];
    manager.downloadPath = @"/Users/Mercury/Downloads/绝对领域";
    [manager startDownload];
}

// 下载完成的方法
- (void)didFinishDownloadingOneWebpage:(BOOL)success {
    downloaded++;
    
    if (success) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, urlArray.count];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", downloaded, urlArray.count];
    }
    
    if (downloaded == urlArray.count) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"已经完成获取图片地址的工作\n"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneThings];
        });
    }
}

@end
