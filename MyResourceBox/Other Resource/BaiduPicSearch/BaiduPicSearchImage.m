//
//  BaiduPicSearchImage.m
//  MyToolBox
//
//  Created by 龚宇 on 16/05/12.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "BaiduPicSearchImage.h"
#import "FileManager.h"

@interface BaiduPicSearchImage () {
    NSMutableArray *htmlFilePaths;
    NSMutableArray *imageURLs;
}

@end

@implementation BaiduPicSearchImage

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static BaiduPicSearchImage *instance;
+ (BaiduPicSearchImage *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BaiduPicSearchImage alloc] init];
    });
    
    return instance;
}

- (void)getImage {
    MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleInformational];
    [alert setMessage:@"HTML文件修改提示" infomation:@"该方法需要提前修改HTML文件，是否已修改"];
    [alert setButtonTitle:@"已修改" keyEquivalent:MyAlertKeyEquivalentReturnKey];
    [alert setButtonTitle:@"未修改" keyEquivalent:MyAlertKeyEquivalentEscapeKey];
    
    [alert showAlertAtMainWindowWithCompletionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case 1000: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getReady];
                    [self getHTMLFilePaths];
                });
            }
                break;
            default:
                break;
        }
    }];
}

// -------------------------------------------------------------------------------
//	第一步，准备工作
// -------------------------------------------------------------------------------
- (void)getReady {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取WorldCosplay的图片地址：已经准备就绪"];
}

// -------------------------------------------------------------------------------
//	第二步，从下载文件夹中找到所需要的html文件
// -------------------------------------------------------------------------------
- (void)getHTMLFilePaths {
    htmlFilePaths = [NSMutableArray array];
    
    NSArray<NSString *> *tempArray = [[FileManager defaultManager] getFilePathsInFolder:@"/Users/Mercury/Downloads/"];
    for (NSString *filePath in tempArray) {
        if ([filePath.lastPathComponent hasSuffix:@"_百度图片搜索.html"]) {
            [htmlFilePaths addObject:filePath];
        }
    }
    
    if (htmlFilePaths.count > 0) {
        [self getPageUrls];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取失败，没有获得任何数据，请检查html文件"];
    }
}

// -------------------------------------------------------------------------------
//	第三步，从html文件中解析得到所有包含图片的网页地址【暂时假设每次只有一个文件】
// -------------------------------------------------------------------------------
- (void)getPageUrls {
    imageURLs = [NSMutableArray array];
    NSString *htmlFilePath = htmlFilePaths[0];
    NSData *data = [NSData dataWithContentsOfFile:htmlFilePath];
    
    if (data) {
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *array = [xpathParser searchWithXPathQuery:@"//li"];
        
        for (TFHppleElement *elemnt in array) {
            NSDictionary *dict = [elemnt attributes];
            if ([[dict objectForKey:@"class"] isEqualToString:@"imgitem"]) {
                float height = [[dict objectForKey:@"data-height"] floatValue];
                float width = [[dict objectForKey:@"data-width"] floatValue];
                NSString *url = [dict objectForKey:@"data-objurl"];
                if (height >= 751.0 || width >= 751.0 || [url hasSuffix:@".gif"]) {
                    [imageURLs addObject:url];
                }
            }
        }
        
        if (imageURLs.count > 0) {
            [self doneThings];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"获取失败，没有获得任何数据，请检查html文件"];
        }
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"文件不存在，路径地址：%@", htmlFilePath];
    }
}

// -------------------------------------------------------------------------------
//	第五步，显示并导出结果
// -------------------------------------------------------------------------------
- (void)doneThings {
    //显示结果
    [AppDelegate defaultVC].outputTextView.string = [UtilityFile convertResultArray:imageURLs];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条数据", imageURLs.count];
    
    //复制到剪贴板
    NSPasteboard *paste = [NSPasteboard generalPasteboard];
    [paste declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [paste setString:[UtilityFile convertResultArray:imageURLs] forType:NSStringPboardType];
    
    //导出结果
    [UtilityFile exportArray:imageURLs atPath:@"/Users/Mercury/Downloads/BaiduPicSearchImageURLs.txt"];
}

@end
