//
//  WnacgFile.m
//  MyToolBox
//
//  Created by 龚宇 on 16/05/13.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WnacgFile.h"
#import "TFHpple.h"
#import "AFURLSessionManager.h"

static NSString * const webHead = @"http://www.wnacg.com/";
static NSString * const downloadPath = @"/Users/Mercury/Downloads/";

@interface WnacgFile () {
    NSArray *pageArray;
    NSMutableArray *downloadUrlArray;
    NSMutableArray *resultArray;
    NSMutableArray *failedArray;
    NSMutableArray *urlArray;
    
    NSInteger downloaded;
    NSFileManager *fm;
    AFURLSessionManager *manager;
}

@end

@implementation WnacgFile

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static WnacgFile *instance;
+ (WnacgFile *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WnacgFile alloc] init];
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
    
    fm = [NSFileManager defaultManager];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取wnacg的图片地址：已经准备就绪"];
}

// -------------------------------------------------------------------------------
//	第二步，获取inputView中的数据
// -------------------------------------------------------------------------------
- (void)getWnacgAddress {
    pageArray = [[AppDelegate defaultVC].inputTextView.string componentsSeparatedByString:@"\n"];
    downloadUrlArray = [NSMutableArray array];
    
    for (NSString *string in pageArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页原始数据失败，原因：%@", [error localizedDescription]];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                
                for (TFHppleElement *elemnt in aArray) {
                    NSDictionary *aDic = [elemnt attributes];
                    if ([[aDic objectForKey:@"class"] isEqualToString:@"downloadbtn"]) {
                        [downloadUrlArray addObject:[webHead stringByAppendingString:[aDic objectForKey:@"href"]]];
                        
                        break;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self didFinishDownloadingOneWebpage];
                });
            }
        }];
        
        [task resume];
    }
}

// -------------------------------------------------------------------------------
//	第三步，解析每个页面，获取下载地址和真实的文件名
// -------------------------------------------------------------------------------
- (void)parseHTML {
    downloaded = 0;
    resultArray = [NSMutableArray array]; //@[@{@"fileName":@"", @"downloadUrl":@""}, @{@"fileName":@"", @"downloadUrl":@""}]
    urlArray = [NSMutableArray array];
    
    for (NSString *string in downloadUrlArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                
                for (TFHppleElement *elemnt in aArray) {
                    NSDictionary *aDic = [elemnt attributes];
                    if ([[aDic objectForKey:@"class"] isEqualToString:@"down_btn"] && [aDic objectForKey:@"download"]) {
                        NSString *dest = [aDic objectForKey:@"download"];
                        NSString *downloadUrl = [aDic objectForKey:@"href"];
                        downloadUrl = [@"http:" stringByAppendingString:downloadUrl];
                        NSString *origin = downloadUrl.lastPathComponent;
                        
                        [urlArray addObject:downloadUrl];
                        [resultArray addObject:NSDictionaryOfVariableBindings(origin, dest)];
                        break;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self didFinishDownloadingOnePicture];
                });
            }
        }];
        
        [task resume];
    }
}

// -------------------------------------------------------------------------------
//	第四步，下载所有的文件到下载文件夹
// -------------------------------------------------------------------------------
- (void)showAlert {
    if (urlArray.count == pageArray.count) { //如果下载地址数量和网页地址数量相同，则所有页面都已解析
        //导出结果
        [UtilityFile exportArray:urlArray atPath:@"/Users/Mercury/Downloads/WNACGURLs.txt"];
//        [resultArray writeToFile:@"/Users/Mercury/Downloads/WNACGInfo.plist" atomically:YES];
        //复制到剪贴板
        NSPasteboard *paste = [NSPasteboard generalPasteboard];
        [paste declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
        [paste setString:[UtilityFile convertResultArray:urlArray] forType:NSStringPboardType];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"所有地址已经获取完毕，并且已经复制到剪贴板"];
        
        //显示警告
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleInformational];
        [alert setMessage:@"所有文件下载完成后需要重命名" infomation:nil];
        [alert setButtonTitle:@"重命名" keyEquivalent:MyAlertKeyEquivalentReturnKey];
        
        [alert showAlertAtMainWindowWithCompletionHandler:^(NSModalResponse returnCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self renameAllFile];
            });
        }];
    } else { //反之，则有部分页面没有被解析
        [[UtilityFile sharedInstance] showLogWithFormat:@"有部分页面没有被解析，1秒后重新开始流程"];
        
        [self performSelector:@selector(getImage) withObject:nil afterDelay:1.0f];
    }
}

// -------------------------------------------------------------------------------
//	第五步，重命名所有已下载的文件
// -------------------------------------------------------------------------------
- (void)renameAllFile {
    for (NSDictionary *dict in resultArray) {
        NSString *origin = dict[@"origin"];
        NSString *dest = dict[@"dest"];
        
        NSError *error;
        [fm moveItemAtPath:[downloadPath stringByAppendingString:origin] toPath:[downloadPath stringByAppendingString:dest] error:&error];
        if (error) {
            [[UtilityFile sharedInstance] showLogWithTitle:[origin stringByAppendingString:@" 文件移动失败"] andFormat:[@"原因：" stringByAppendingString:[error localizedDescription]]];
        }
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"所有文件都已经重新命名，请前往下载文件夹查看"];
}

#pragma mark -- 辅助方法 --
// -------------------------------------------------------------------------------
//	下载完成的方法
// -------------------------------------------------------------------------------
- (void)didFinishDownloadingOneWebpage {
    downloaded++;
    
    if (downloaded == pageArray.count) {
        if (downloadUrlArray.count > 0) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%lu项网页", downloadUrlArray.count];
            [self parseHTML];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"没有获取到任何网页"];
        }
    }
}
- (void)didFinishDownloadingOnePicture {
    downloaded++;
    
    if (downloaded == downloadUrlArray.count) {
        if (resultArray.count > 0) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%lu项文件地址", resultArray.count];
            [self showAlert];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"没有获取到任何文件地址"];
        }
    }
}

@end
