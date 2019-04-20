//
//  WNACGMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 17/01/24.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import "WNACGMethod.h"
#import "WNACGFileModel.h"
#import "FileManager.h"
#import "DownloadQueueManager.h"

static NSString * const webHeader = @"http://www.wnacg.com/";
static NSString * const plistPath = @"/Users/Mercury/Downloads/WNACG_Info.plist";

@interface WNACGMethod () {
    NSArray *urlArray;
    NSMutableArray *downloadArray;
    NSMutableArray<WNACGFileModel *> *resultArray;
    NSMutableDictionary *renameDict; //重命名文件夹
    NSMutableArray *failedURLArray; //没有获取到图片的半次元网页地址
    
    NSInteger downloaded;
}

@end

@implementation WNACGMethod

static WNACGMethod *method;
+ (WNACGMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[WNACGMethod alloc] init];
    });
    
    return method;
}
- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    
    switch (cellRow) {
        case 1:
            [self parseHTML];
            break;
        case 2:
            [self renameFilesFromFile];
            break;
        default:
            break;
    }
}

#pragma mark -- 逻辑方法 --
// 1、解析每个页面，获取下载页面地址
- (void)parseHTML {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取WNACG的图片地址：已经准备就绪"];
    
    downloaded = 0;
    urlArray = [[AppDelegate defaultVC].inputTextView.string componentsSeparatedByString:@"\n"];
    resultArray = [NSMutableArray array];
    
    for (NSString *url in urlArray) {
        WNACGFileModel *model = [WNACGFileModel new];
        model.webPageUrl = url;
        model.downloadPageUrl = [url stringByReplacingOccurrencesOfString:@"/photos-" withString:@"/download-"];
        model.webSuccess = YES;
        [resultArray addObject:model];
    }
    
    [self parseDownloadPage];
}
// 2、解析每个下载页面，获取文件地址
- (void)parseDownloadPage {
    downloaded = 0;
    NSArray *downloadPages = [NSArray arrayWithArray:[resultArray valueForKeyPath:@"downloadPageUrl"]];
    
    for (NSString *string in downloadPages) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            downloaded++;
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(WNACGFileModel * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject.downloadPageUrl isEqualToString:response.URL.absoluteString];
            }];
            WNACGFileModel *model = [resultArray filteredArrayUsingPredicate:predicate].firstObject;
            
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", downloaded, urlArray.count];
                model.downloadSuccess = NO;
            } else {
                [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, urlArray.count];
                model.downloadSuccess = YES;
                
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                // 文件名
                NSArray *pArray = [xpathParser searchWithXPathQuery:@"//p"];
                TFHppleElement *pElement = (TFHppleElement *)pArray.firstObject;
                TFHppleElement *firstChildren = (TFHppleElement *)pElement.children.firstObject;
                model.fileName = [@"/Users/Mercury/Downloads/WNACG" stringByAppendingPathComponent:firstChildren.content];
                
                // 下载地址
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
                NSPredicate *tfPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    
                    return [evaluatedObject.attributes[@"href"] containsString:@"wnacg.download"];
                }];
                NSArray *tfFilter = [aArray filteredArrayUsingPredicate:tfPredicate];
                TFHppleElement *aElement = (TFHppleElement *)tfFilter.firstObject;
                NSString *downloadLink = aElement.attributes[@"href"];
                model.fileUrl = downloadLink;
                model.downloadName = [@"/Users/Mercury/Downloads/WNACG" stringByAppendingPathComponent:downloadLink.lastPathComponent];
            }
            
            if (downloaded == urlArray.count) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"已经完成获取文件地址的工作\n"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self doneThings];
                });
            }
        }];
        
        [task resume];
    }
}
// 3、完成并导出
- (void)doneThings {
    NSArray *models = [WNACGFileModel arrayOfDictionariesFromModels:resultArray];
    NSArray *fileUrls = [NSArray arrayWithArray:[resultArray valueForKeyPath:@"fileUrl"]];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(WNACGFileModel * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !evaluatedObject.downloadSuccess || !evaluatedObject.webSuccess;
    }];
    NSArray *failedUrls = [[resultArray filteredArrayUsingPredicate:predicate] valueForKeyPath:@"webPageUrl"];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取了%ld个文件下载地址", fileUrls.count];
    [UtilityFile exportArray:fileUrls atPath:@"/Users/Mercury/Downloads/WNACG_FileUrls.txt"];
    if (failedUrls.count > 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedUrls.count]; //获取失败的页面地址
        [UtilityFile exportArray:failedUrls atPath:@"/Users/Mercury/Downloads/WNACG_FailedUrls.txt"];
    }
    [models writeToFile:plistPath atomically:YES];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始下载获取到的文件"];
    [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0];
}

- (void)startDownload {
    NSArray *downloads = [NSArray arrayWithArray:[resultArray valueForKeyPath:@"fileUrl"]];
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:downloads];
    manager.downloadPath = @"/Users/Mercury/Downloads/WNACG";
    manager.finishBlock = ^() {
        [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始重新命名文件"];
        [self performSelector:@selector(renameFiles) withObject:nil afterDelay:1.0];
    };
    [manager startDownload];
}

- (void)renameFiles {
    for (WNACGFileModel *model in resultArray) {
        [[FileManager defaultManager] moveItemAtPath:model.downloadName toDestPath:model.fileName];
    }
    [[FileManager defaultManager] trashFileAtPath:plistPath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取WNACG的图片地址：流程已经结束"];
}

- (void)renameFilesFromFile {
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取重命名WNACG文件：已经准备就绪"];
    if (![[FileManager defaultManager] isContentExistAtPath:plistPath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"plist不存在，请查看对应的文件夹"];
        return;
    }
    
    NSArray *dicts = [NSArray arrayWithContentsOfFile:plistPath];
    NSArray *models = [WNACGFileModel arrayOfModelsFromDictionaries:dicts error:NULL];
    for (WNACGFileModel *model in models) {
        [[FileManager defaultManager] moveItemAtPath:model.downloadName toDestPath:model.fileName];
    }
    [[FileManager defaultManager] trashFileAtPath:plistPath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取重命名WNACG文件：流程已经结束"];
}

@end
