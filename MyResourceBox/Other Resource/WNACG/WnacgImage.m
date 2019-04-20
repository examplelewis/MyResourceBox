//
//  WnacgImage.m
//  MyToolBox
//
//  Created by 龚宇 on 16/04/29.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WnacgImage.h"
#import "TFHpple.h"
#import "ParseWnacgOperation.h"

static NSString * const webHead = @"http://www.wnacg.com";

@interface WnacgImage () {
    NSString *address;
    NSString *head;
    NSInteger start;
    NSInteger end;
    NSMutableArray *pageArray;
    NSMutableArray *urlArray;
    NSMutableArray *resultArray;
    
    NSInteger downloaded;
}

@property (strong) NSOperationQueue *queue;
@property (strong) ParseWnacgOperation *parser;

@end

@implementation WnacgImage

@synthesize queue;
@synthesize parser;

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static WnacgImage *instance;
+ (WnacgImage *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WnacgImage alloc] init];
    });
    
    return instance;
}

- (void)getImage {
    [self getReady];
    [self getWnacgAddress];
}

// -------------------------------------------------------------------------------
//	第一步，准备工作
// -------------------------------------------------------------------------------
- (void)getReady {
    downloaded = 0;
    
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取wnacg的图片地址：已经准备就绪"];
}

// -------------------------------------------------------------------------------
//	第二步，获取inputView中的数据
// -------------------------------------------------------------------------------
- (void)getWnacgAddress {
    address = [AppDelegate defaultVC].inputTextView.string;
    if (!address || address.length == 0) {
        [[UtilityFile sharedInstance] showLogWithTitle:@"错误" andFormat:@"没有从inputView中获取到数据"];
        return;
    }
    
    NSArray *componentArray = [address componentsSeparatedByString:@"|"];
    head = componentArray[0];
    if (componentArray.count == 1) {
        start = 1;
        end = 1;
    } else if (componentArray.count == 2) {
        start = 1;
        end = [componentArray[1] integerValue];
    } else {
        start = [componentArray[1] integerValue];
        end = [componentArray[2] integerValue];
    }
    
    pageArray = [NSMutableArray array];
    for (NSInteger i = start; i <= end; i++) {
        NSMutableString *mutableHead = [NSMutableString stringWithString:head];
        [mutableHead insertString:[NSString stringWithFormat:@"page-%ld-", i] atIndex:34];
        [pageArray addObject:mutableHead];
    }
    
    [self getPageURL];
}

// -------------------------------------------------------------------------------
//	第三步，获取每个页面
// -------------------------------------------------------------------------------
- (void)getPageURL {
    urlArray = [NSMutableArray array];
    
    for (NSString *string in pageArray) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
//        request.timeoutInterval = 40.0f;
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页原始数据失败，原因：%@", [error localizedDescription]];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                
                for (TFHppleElement *elemnt in aArray) {
                    NSDictionary *aDic = [elemnt attributes];
                    NSString *string = [aDic objectForKey:@"href"];
                    if (string && [string hasPrefix:@"/photos-view-id"]) {
                        [urlArray addObject:[webHead stringByAppendingString:string]];
                    }
                }
                
                [self didFinishDownloadingOneWebpage];
            }
        }];
        
        [task resume];
    }
}

// -------------------------------------------------------------------------------
//	第四步，解析每个页面，获取图片地址
// -------------------------------------------------------------------------------
- (void)parseHTML {
    resultArray = [NSMutableArray array];
    
    for (NSString *string in urlArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
            } else {
                queue = [[NSOperationQueue alloc] init];
                parser = [[ParseWnacgOperation alloc] initWithData:data];
                
                __weak typeof(self) weakSelf = self;
                __weak typeof(parser) weakParser = parser;
                __weak typeof(resultArray) weakResultArray = resultArray;
                
                parser.errorHandler = ^(NSError *parseError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [parseError localizedDescription]];
                    });
                };
                parser.completionBlock = ^(void) {
                    if (weakParser.imgURL != nil) {
                        [weakResultArray addObject:weakParser.imgURL];
                        
                        [weakSelf didFinishDownloadingOnePicture];
                    }
                };
                
                [queue addOperation:parser]; // this will start the "ParseOperation"
            }
        }];
        
        [task resume];
    }
}

// -------------------------------------------------------------------------------
//	第五步，显示并导出结果
// -------------------------------------------------------------------------------
- (void)doneThings {
    //显示结果
    [AppDelegate defaultVC].outputTextView.string = [UtilityFile convertResultArray:resultArray];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条数据", resultArray.count];
    
    //复制到剪贴板
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [paste setString:[UtilityFile convertResultArray:resultArray] forType:NSStringPboardType];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整个流程已经结束，记录已复制到剪贴板中。如有需要，请从上方的结果框中查看记录"];
}

#pragma mark -- 辅助方法 --
// -------------------------------------------------------------------------------
//	下载完成的方法
// -------------------------------------------------------------------------------
- (void)didFinishDownloadingOneWebpage {
    downloaded++;
    
    if (downloaded == pageArray.count) {
        if (urlArray.count > 0) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%lu项网页", urlArray.count];
            [self parseHTML];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"没有获取到任何网页"];
        }
    }
}
- (void)didFinishDownloadingOnePicture {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *tempString = [NSString stringWithFormat:@"已获取到第%lu条记录 | 共%lu条记录", resultArray.count, urlArray.count];
        [[UtilityFile sharedInstance] showLogWithFormat:tempString];
    });
    
    if (resultArray.count == urlArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneThings];
        });
    }
}

@end
