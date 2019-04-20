//
//  HaodiaoImage.m
//  MyToolBox
//
//  Created by 龚宇 on 16/03/18.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "HaodiaoImage.h"
#import "TFHpple.h"

@interface HaodiaoImage () {
    NSString *address;
    NSString *head;
    NSInteger start;
    NSInteger end;
    NSMutableArray *pageArray;
    NSMutableArray *resultArray;
    
    NSInteger downloaded;
}

@end

@implementation HaodiaoImage

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static HaodiaoImage *inputInstance;
+ (HaodiaoImage *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inputInstance = [[HaodiaoImage alloc] init];
    });
    
    return inputInstance;
}

- (void)getImage {
    [self getReady];
    [self getHaodiaoAddress];
}

// -------------------------------------------------------------------------------
//	第一步，准备工作
// -------------------------------------------------------------------------------
- (void)getReady {
    downloaded = 0;
    
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"从书签文件获取半次元的图片地址：已经准备就绪"];
}

// -------------------------------------------------------------------------------
//	第二步，获取inputView中的数据
// -------------------------------------------------------------------------------
- (void)getHaodiaoAddress {
    address = [AppDelegate defaultVC].inputTextView.string;
    if (!address || address.length == 0) {
        [[UtilityFile sharedInstance] showLogWithTitle:@"错误" andFormat:@"没有从inputView中获取到数据"];
        return;
    }
    
    NSArray *componentArray = [address componentsSeparatedByString:@"|"];
    head = [componentArray[0] stringByAppendingString:@"/nggallery/page/"];
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
        [pageArray addObject:[NSString stringWithFormat:@"%@%ld", head, i]];
    }
    
    [self getImageURL];
}

// -------------------------------------------------------------------------------
//	第三步，获取图片地址
// -------------------------------------------------------------------------------
- (void)getImageURL {
    resultArray = [NSMutableArray array];
    
    for (NSString *string in pageArray) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
//        request.timeoutInterval = 40.0f;
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页原始数据失败，原因：%@", [error localizedDescription]];
                
                __weak typeof(self) weakSelf = self;
                
                [weakSelf didFinishDownloadingOneWebpage];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                
                __weak typeof(self) weakSelf = self;
                __weak typeof(resultArray) weakResultArray = resultArray;
                
                for (TFHppleElement *elemnt in aArray) {
                    NSDictionary *aDic = [elemnt attributes];
                    NSString *string = [aDic objectForKey:@"href"];
                    if ([string hasPrefix:@"http://haodiao.org/wp-content/gallery/"]) {
                        [weakResultArray addObject:string];
                    }
                }
                
                [weakSelf didFinishDownloadingOneWebpage];
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
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"整个流程已经结束，记录已复制到剪贴板中。如有需要，请从上方的结果框中查看记录"];
}

#pragma mark -- 辅助方法 --
// -------------------------------------------------------------------------------
//	下载完成的方法
// -------------------------------------------------------------------------------
- (void)didFinishDownloadingOneWebpage {
    downloaded++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *tempString = [NSString stringWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, pageArray.count];
        [[UtilityFile sharedInstance] showLogWithFormat:tempString];
    });
    
    if (downloaded == pageArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultArray.count > 0) {
                [self doneThings];
            } else {
                [[UtilityFile sharedInstance] showLogWithFormat:@"没有获取到任何网页"];
            }
        });
    }
}

@end
