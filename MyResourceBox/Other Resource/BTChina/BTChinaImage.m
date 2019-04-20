//
//  BTChinaImage.m
//  MyToolBox
//
//  Created by 龚宇 on 16/08/11.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "BTChinaImage.h"
#import "TFHpple.h"
#import "ParseBTChinaOperation.h"
#import "FileManager.h"

@interface BTChinaImage () {
    NSMutableArray *pageArray;
    NSMutableArray *htmlArray;
    NSMutableArray *resultArray;
    NSMutableArray *failedURLArray;
    NSMutableDictionary *renameDict;
    
    NSInteger downloaded;
}

@property (strong) NSOperationQueue *queue;
@property (strong) ParseBTChinaOperation *parser;

@end

@implementation BTChinaImage

@synthesize queue;
@synthesize parser;

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static BTChinaImage *instance;
+ (BTChinaImage *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BTChinaImage alloc] init];
    });
    
    return instance;
}

- (void)getImage {
    [self getReady];
    [self getHTML];
}

// -------------------------------------------------------------------------------
//	第1步，准备工作
// -------------------------------------------------------------------------------
- (void)getReady {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取BTChina论坛的图片地址：已经准备就绪"];
}

// -------------------------------------------------------------------------------
//	第2步，从输入框中获取地址
// -------------------------------------------------------------------------------
- (void)getHTML {
    htmlArray = [NSMutableArray arrayWithArray:[[AppDelegate defaultVC].inputTextView.string componentsSeparatedByString:@"\n"]];
    
    [self getImageURL];
}

// -------------------------------------------------------------------------------
//	第3步，获取图片地址
// -------------------------------------------------------------------------------
- (void)getImageURL {
    downloaded = 0;
    resultArray = [NSMutableArray array];
    renameDict = [NSMutableDictionary dictionary];
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
                queue = [[NSOperationQueue alloc] init];
                parser = [[ParseBTChinaOperation alloc] initWithData:data url:response.URL.absoluteString];
                
                __weak typeof(self) weakSelf = self;
                __weak typeof(resultArray) weakResultArray = resultArray;
                __weak typeof(parser) weakParser = parser;
                __weak typeof(renameDict) weakRenameDict = renameDict;
                __weak typeof(failedURLArray) weakFailedURLArray = failedURLArray;
                
                parser.errorHandler = ^(NSError *parseError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [parseError localizedDescription]];
                    });
                };
                parser.completionBlock = ^(void) {
                    if (weakParser.imgURLArray.count > 0) {
                        [weakResultArray addObjectsFromArray:weakParser.imgURLArray];
                        [weakRenameDict setObject:weakParser.imgURLArray forKey:weakParser.title];
                        [weakSelf didFinishDownloadingOneHTML:YES];
                    } else {
                        [weakFailedURLArray addObject:weakParser.url];
                        [weakSelf didFinishDownloadingOneHTML:NO];
                    }
                };
                
                [queue addOperation:parser]; // this will start the "ParseOperation"
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
    [UtilityFile exportArray:htmlArray atPath:@"/Users/Mercury/Downloads/BTChinaPageURLs.txt"];
    [AppDelegate defaultVC].outputTextView.string = [UtilityFile convertResultArray:resultArray]; //图片地址
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", resultArray.count];
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/BTChinaImageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
    [UtilityFile exportArray:failedURLArray atPath:@"/Users/Mercury/Downloads/BTChinaFailedURLs.txt"];
    [renameDict writeToFile:@"/Users/Mercury/Downloads/BTChinaRenameInfo.plist" atomically:YES]; //RenameDict
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

#pragma mark -- 整理方法 --
// -------------------------------------------------------------------------------
//	根据Plist文件将图片整理到对应的文件夹中（第一步，显示NSOpenPanel）
// -------------------------------------------------------------------------------
- (void)arrangeImageFileFromPlistPhase1 {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理BTChina下载好的图片：已经准备就绪"];
    
    //先判断有没有plist文件
    if (![[FileManager defaultManager] isContentExistAtPath:@"/Users/Mercury/Downloads/BTChinaRenameInfo.plist"]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"plist不存在，请查看对应的文件夹"];
        return;
    }
    
    //显示NSOpenPanel
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"选择BTChina下载文件夹"];
    panel.prompt = @"选择";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    panel.directoryURL = [NSURL fileURLWithPath:@"/Users/Mercury/Downloads"];
    
    [panel beginSheetModalForWindow:[AppDelegate defaultWindow] completionHandler:^(NSInteger result) {
        if (result == 1) {
            NSURL *fileUrl = [panel URLs].firstObject;
            NSString *filePath = [fileUrl path];
            [[UtilityFile sharedInstance] showLogWithFormat:@"已选择路径：%@", filePath];
            
            [self arrangeImageFileFromPlistPhase2:filePath];
        }
    }];
}
// -------------------------------------------------------------------------------
//	根据Plist文件将图片整理到对应的文件夹中（第二步，具体逻辑）
// -------------------------------------------------------------------------------
- (void)arrangeImageFileFromPlistPhase2:(NSString *)rootFolderName {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/Users/Mercury/Downloads/BTChinaRenameInfo.plist"];

    //先查找BTChina文件夹里是否有图片文件，如果没有可能是没有将图片文件移动到BTChina文件夹内，目前给出提示
    NSArray *contents = [[FileManager defaultManager] getFilePathsInFolder:rootFolderName specificExtensions:@[@"jpg", @"gif", @"jpeg", @"png"]];
    if (contents.count == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有在BTChina文件夹内找到图片文件，可能是没有将图片文件移动到BTChina文件夹内，请检查BTChina文件夹"];
        return;
    }
    
    //根据Plist文件整理记录的图片
    NSArray *allKeys = [dict allKeys];
    for (NSString *folderName in allKeys) {
        //创建目录文件夹
        NSString *folderPath = [rootFolderName stringByAppendingPathComponent:folderName];
        if (![[FileManager defaultManager] createFolderAtPathIfNotExist:folderPath]) {
            continue; //如果文件夹创建失败，就跳过
        }
        
        //获取图片文件路径并且移动文件
        NSArray *array = [NSArray arrayWithArray:dict[folderName]];
        for (NSString *url in array) {
            NSString *filePath = [rootFolderName stringByAppendingPathComponent:url.lastPathComponent];
            NSString *destPath = [folderPath stringByAppendingPathComponent:url.lastPathComponent];
            
            // 网站上面的图片大小可能不定，所以很有可能图片已被删除，先判断一下在不在，然后再删除
            if ([[FileManager defaultManager] isContentExistAtPath:filePath]) {
                [[FileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
            }
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"所有BTChina图片已经整理完成"];
    
    // 网站上面的图片大小可能不定，所以很有可能图片已被删除，也很有可能整个文件内的文件都被删除，所以要删除空文件夹
    NSMutableArray *trashes = [NSMutableArray array];
    for (NSString *folderName in allKeys) {
        NSString *folderPath = [rootFolderName stringByAppendingPathComponent:folderName];
        if ([[FileManager defaultManager] isEmptyFolderAtPath:folderPath]) {
            [trashes addObject:[NSURL fileURLWithPath:folderPath]];
        }
    }
    [[FileManager defaultManager] trashFilesAtPaths:trashes];
    
    if ([[FileManager defaultManager] isContentExistAtPath:@"/Users/Mercury/Downloads/BTChinaRenameInfo.plist"]) {
        [[FileManager defaultManager] trashFileAtPath:@"/Users/Mercury/Downloads/BTChinaRenameInfo.plist" resultItemURL:nil];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"BCYRenameInfo.plist 不存在，或许已经被删除"];
    }
}

@end
