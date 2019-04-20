//
//  BaiduTieBaXiangCeImage.m
//  MyToolBox
//
//  Created by 龚宇 on 16/05/29.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "BaiduTieBaXiangCeImage.h"
#import "TFHpple.h"

static NSString * const webHead = @"http://tieba.baidu.com";

@interface BaiduTieBaXiangCeImage () {
    NSMutableArray *pageArrays;
    NSMutableArray *resultArray;
    
    NSInteger downloaded;
}

@end

@implementation BaiduTieBaXiangCeImage

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static BaiduTieBaXiangCeImage *instance;
+ (BaiduTieBaXiangCeImage *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BaiduTieBaXiangCeImage alloc] init];
    });
    
    return instance;
}

- (void)getImage {
    [self getReady];
    [self analysisHTML];
}

// -------------------------------------------------------------------------------
//	第一步，准备工作
// -------------------------------------------------------------------------------
- (void)getReady {
    downloaded = 0;
    
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取百度贴吧相册的图片地址：已经准备就绪"];
}

// -------------------------------------------------------------------------------
//	第二步，解析地址
// -------------------------------------------------------------------------------
- (void)analysisHTML {
    NSData *data = [[AppDelegate defaultVC].inputTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    pageArrays = [NSMutableArray array];
    
    if (data) {
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *array = [xpathParser searchWithXPathQuery:@"//a"];
        
        for (TFHppleElement *elemnt in array) {
            NSDictionary *dict = [elemnt attributes];
            if ([[dict objectForKey:@"class"] isEqualToString:@"ag_ele_a ag_ele_a_v"]) {
                NSString *address = [webHead stringByAppendingString:[dict objectForKey:@"href"]];
                
                [pageArrays addObject:address];
            }
        }
        
        if (pageArrays.count > 0) {
            [self getHTML];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"获取失败，没有获得任何数据，请检查输入内容"];
        }
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"NSData 转换失败，请重新检查输入内容"];
    }
}

// -------------------------------------------------------------------------------
//	第三步，获取地址
// -------------------------------------------------------------------------------
- (void)getHTML {
    resultArray = [NSMutableArray array];
    
    for (NSString *string in pageArrays) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
//        request.timeoutInterval = 40.0f;
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
                __weak typeof(self) weakSelf = self;
                
                [weakSelf didFinishDownloadingOnePicture];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *array = [xpathParser searchWithXPathQuery:@"//script"];
                
                __weak typeof(self) weakSelf = self;
                __weak typeof(resultArray) weakResultArray = resultArray;
                
                for (TFHppleElement *elemnt in array) {
                    NSRange range = [[elemnt raw] rangeOfString:@"imgsrc.baidu.com"];
                    
                    if (range.location != NSNotFound) {
                        NSArray *array1 = [[elemnt raw] componentsSeparatedByString:@"\":\""];
                        
                        for (NSString *string in array1) {
                            if ([string hasPrefix:@"http://imgsrc.baidu.com"]) {
                                NSArray *array2 = [string componentsSeparatedByString:@"\""];
                                
                                [weakResultArray addObject:array2.firstObject];
                            }
                        }
                    }
                }
                
                [weakSelf didFinishDownloadingOnePicture];
            }
        }];
        
        [task resume];
    }
}
// -------------------------------------------------------------------------------
//	第四步，显示并导出结果
// -------------------------------------------------------------------------------
- (void)doneThings {
    //显示结果
    [AppDelegate defaultVC].outputTextView.string = [UtilityFile convertResultArray:resultArray];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条数据，请使用Automator下载链接，然后再解析HTML文件", pageArrays.count];
    
    //导出结果
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/BaiduTieBaXiangCeImageURLs.txt"];
}

#pragma mark -- 辅助方法 --
// -------------------------------------------------------------------------------
//	下载完成的方法
// -------------------------------------------------------------------------------
- (void)didFinishDownloadingOnePicture {
    downloaded++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *tempString = [NSString stringWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, pageArrays.count];
        [[UtilityFile sharedInstance] showLogWithFormat:tempString];
    });
    
    if (downloaded == pageArrays.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UtilityFile sharedInstance] showLogWithTitle:@"成功获取到图片地址" andFormat:@"%lu条网页已全部获取", pageArrays.count];
            
            [self doneThings];
        });
    }
}

@end
