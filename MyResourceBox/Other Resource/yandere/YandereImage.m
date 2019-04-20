//
//  YandereImage.m
//  MyToolBox
//
//  Created by 龚宇 on 16/05/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "YandereImage.h"
#import "TFHpple.h"
#import "ParseYandereOperation.h"

static NSString * const webHead = @"https://yande.re";

@interface YandereImage () {
    NSMutableArray *urlArray;
    NSMutableArray *resultArray;
    
    NSInteger downloaded;
}

@property (strong) NSOperationQueue *queue;
@property (strong) ParseYandereOperation *parser;

@end

@implementation YandereImage

@synthesize queue;
@synthesize parser;

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static YandereImage *instance;
+ (YandereImage *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YandereImage alloc] init];
    });
    
    return instance;
}

- (void)getImage {
    [self getReady];
    [self getYandereAddress];
}

// -------------------------------------------------------------------------------
//	第一步，准备工作
// -------------------------------------------------------------------------------
- (void)getReady {
    downloaded = 0;
    
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取yande.re的图片地址：已经准备就绪"];
}

// -------------------------------------------------------------------------------
//	第二步，获取inputView中的数据，并且获取包含图片的网页地址
// -------------------------------------------------------------------------------
- (void)getYandereAddress {
    urlArray = [NSMutableArray array];
    NSString *rootAddress = [AppDelegate defaultVC].inputTextView.string;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rootAddress]];
//    request.timeoutInterval = 40.0f;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页原始数据失败，原因：%@", [error localizedDescription]];
            
            __weak typeof(self) weakSelf = self;
            
            [weakSelf didFinishDownloadUrlAddress];
        } else {
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(urlArray) weakURLArray = urlArray;
            
            for (TFHppleElement *elemnt in aArray) {
                NSDictionary *aDic = [elemnt attributes];
                NSString *string = [aDic objectForKey:@"href"];
                if (string && [string hasPrefix:@"/post/show"]) {
                    NSString *address = [webHead stringByAppendingString:string];
                    [weakURLArray addObject:address];
                }
            }
            
            [weakSelf didFinishDownloadUrlAddress];
        }
    }];
    
    [task resume];
}

// -------------------------------------------------------------------------------
//	第三步，解析每个页面，获取图片地址
// -------------------------------------------------------------------------------
- (void)parseHTML {
    resultArray = [NSMutableArray array];
    
    for (NSString *urlString in urlArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
            } else {
                queue = [[NSOperationQueue alloc] init];
                parser = [[ParseYandereOperation alloc] initWithData:data andURLstring:response.URL.absoluteString];
                
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
//	第四步，显示并导出结果
// -------------------------------------------------------------------------------
- (void)doneThings {
    //显示结果
    [AppDelegate defaultVC].outputTextView.string = [UtilityFile convertResultArray:resultArray];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条数据", resultArray.count];
    
    //复制到剪贴板
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [paste setString:[UtilityFile convertResultArray:resultArray] forType:NSStringPboardType];
    
    //导出结果
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/YandereImageURLs.txt"];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整个流程已经结束，记录已复制到剪贴板中。\n注意：获取到的图片地址数量可能会比真实数量少几个，这是一个Bug，暂未解决\n如果发现图片地址缺失，有可能缺失的图片是整个图片集的最后几个\n如有需要，请从上方的结果框中查看记录或者在下载文件夹中寻找YandereImageURLs.txt文件"];
}

#pragma mark -- 辅助方法 --
// -------------------------------------------------------------------------------
//	下载完成的方法
// -------------------------------------------------------------------------------
- (void)didFinishDownloadUrlAddress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (urlArray.count > 0) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%lu项网页", urlArray.count];
            [self parseHTML];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"没有获取到任何网页"];
        }
    });
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
