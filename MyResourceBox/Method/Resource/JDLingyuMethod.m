//
//  JDLingyuMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "JDLingyuMethod.h"
#import "DownloadQueueManager.h"
#import "OrganizeManager.h"

@interface JDLingyuMethod () {
    NSArray *urlArray;
    NSMutableArray *resultArray;
    NSMutableDictionary *renameDict; //重命名文件夹
    NSMutableArray *failedURLArray; //没有获取到图片的半次元网页地址
    
    NSInteger downloaded;
}

@end

@implementation JDLingyuMethod

static JDLingyuMethod *method;
+ (JDLingyuMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[JDLingyuMethod alloc] init];
    });
    
    return method;
}

- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取绝对领域的图片地址：已经准备就绪"];
    downloaded = 0;
    
    switch (cellRow) {
        case 1:
            [self parseHTML];
            break;
        case 2:
            [self arrangeImageFile];
            break;
        default:
            break;
    }
}

#pragma mark -- 逻辑方法 --
// 1、解析每个页面，获取图片地址
- (void)parseHTML {
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
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
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
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取了%ld个页面的图片地址", urlArray.count]; //获取到的页面地址
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/JdlingyuImageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", resultArray.count];
    if (failedURLArray.count > 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
        [UtilityFile exportArray:failedURLArray atPath:@"/Users/Mercury/Downloads/JDLingyuFailedURLs.txt"];
    }
    [renameDict writeToFile:@"/Users/Mercury/Downloads/JDlingyuRenameInfo.plist" atomically:YES]; //RenameDict
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始下载"];
    [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
}
// 3、下载图片
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:resultArray];
    manager.downloadPath = @"/Users/Mercury/Downloads/绝对领域";
    [manager startDownload];
}

#pragma mark -- 辅助方法 --
// 下载完成的方法
- (void)didFinishDownloadingOneWebpage:(BOOL)success {
    downloaded++;
    
    if (success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, urlArray.count];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", downloaded, urlArray.count];
    }
    
    if (downloaded == urlArray.count) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"已经完成获取图片地址的工作\n"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneThings];
        });
    }
}

#pragma mark -- 整理方法 --
// 根据Plist文件将图片整理到对应的文件夹中（第一步，显示NSOpenPanel）
- (void)arrangeImageFile {
    OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:@"/Users/Mercury/Downloads/JDlingyuRenameInfo.plist"];
    [manager startOrganizing];
}

@end
