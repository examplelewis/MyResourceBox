//
//  HotGirlHubImage.m
//  MyToolBox
//
//  Created by 龚宇 on 16/08/12.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "HotGirlHubImage.h"
#import "TFHpple.h"

@interface HotGirlHubImage () {
    NSMutableArray *htmlArray;
    NSMutableArray *resultArray;
    NSMutableArray *failedURLArray;
    
    NSInteger downloaded;
}

@end

@implementation HotGirlHubImage

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static HotGirlHubImage *instance;
+ (HotGirlHubImage *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HotGirlHubImage alloc] init];
    });
    
    return instance;
}

// -------------------------------------------------------------------------------
//	第1步，准备工作
// -------------------------------------------------------------------------------
- (void)getImage {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取HotGirlHub论坛的图片地址：已经准备就绪"];
    
    [self getHTML];
}

// -------------------------------------------------------------------------------
//	第2步，获取网页地址
// -------------------------------------------------------------------------------
- (void)getHTML {
    htmlArray = [NSMutableArray arrayWithArray:[[AppDelegate defaultVC].inputTextView.string componentsSeparatedByString:@"\n"]];
    
    [self getImageURL];
}
// -------------------------------------------------------------------------------
//	第3步，获取图片地址
// -------------------------------------------------------------------------------
- (void)getImageURL {
    //先去除重复的网页地址
    NSSet *set = [NSSet setWithArray:htmlArray];
    htmlArray = [NSMutableArray arrayWithArray:set.allObjects];
    
    downloaded = 0;
    resultArray = [NSMutableArray array];
    failedURLArray = [NSMutableArray array];
    
    for (NSString *string in htmlArray) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
//        request.timeoutInterval = 40.0f;
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                __weak typeof(self) weakSelf = self;
                __weak typeof(failedURLArray) weakFailedURLArray = failedURLArray;
                
                DDLogInfo(@"获取网页：%@ 信息失败，原因：%@", [error userInfo][NSURLErrorFailingURLStringErrorKey], [error localizedDescription]);
                
                [weakFailedURLArray addObject:[error userInfo][NSURLErrorFailingURLStringErrorKey]];
                [weakSelf didFinishDownloadingOneHTML:NO];
            } else {
                __weak typeof(self) weakSelf = self;
                __weak typeof(resultArray) weakResultArray = resultArray;
                __weak typeof(failedURLArray) weakFailedURLArray = failedURLArray;
                
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                //获取title标签
                NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
                TFHppleElement *elemnt = (TFHppleElement *)titleArray.firstObject;
                NSString *title = elemnt.content;
                
                //获取img标签
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//img"];
                BOOL found = NO;
                for (TFHppleElement *elemnt in aArray) {
                    NSDictionary *dic = [elemnt attributes];
                    
                    if (dic[@"alt"] && [dic[@"alt"] isEqualToString:title]) {
                        found = YES;
                        [weakResultArray addObject:dic[@"src"]];
                    }
                }
                
                if (found) {
                    [weakSelf didFinishDownloadingOneHTML:YES];
                } else {
                    [weakFailedURLArray addObject:response.URL.absoluteString];
                    [weakSelf didFinishDownloadingOneHTML:NO];
                }
                
                
            }
        }];
        
        [task resume];
    }
}
// -------------------------------------------------------------------------------
//	第4步，显示并导出结果
// -------------------------------------------------------------------------------
- (void)doneThings {
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取了%ld个页面地址", htmlArray.count]; //获取到的页面地址
    [UtilityFile exportArray:htmlArray atPath:@"/Users/Mercury/Downloads/HotGirlHubPageURLs.txt"];
    [AppDelegate defaultVC].outputTextView.string = [UtilityFile convertResultArray:resultArray]; //图片地址
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", resultArray.count];
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/HotGirlHubImageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
    [UtilityFile exportArray:failedURLArray atPath:@"/Users/Mercury/Downloads/HotGirlHubFailedURLs.txt"];
}

#pragma mark -- 辅助方法 --
// -------------------------------------------------------------------------------
//	下载完成的方法
// -------------------------------------------------------------------------------
- (void)didFinishDownloadingOneHTML:(BOOL)success {
    downloaded++;
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, htmlArray.count];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", downloaded, htmlArray.count];
        });
    }
    
    if (downloaded == htmlArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UtilityFile sharedInstance] showLogWithFormat:@"已经完成获取图片地址的流程，获取到%ld条图片地址\n", resultArray.count];
            
            [self doneThings];
        });
    }
}

@end
