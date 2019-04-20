//
//  BCYMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "BCYMethod.h"

#import "SQLiteManager.h"
#import "SQLiteFMDBManager.h"

#import "CookieManager.h"
#import "DownloadQueueManager.h"

@interface BCYMethod () {
    NSInteger downloaded;
    
    NSMutableArray *checkArray; //半次元校验位组成的数组
    NSMutableArray *pageArray;
    NSMutableArray *resultArray;
    NSMutableDictionary *renameDict; //重命名文件夹
    NSMutableArray *failedURLArray; //没有获取到图片的半次元网页地址
    
    BOOL checkDB; // 是否检查数据库
}

@end

@implementation BCYMethod

static NSString * const filePath = @"/Users/Mercury/Downloads/Safari 书签.html";

static BCYMethod *method;
+ (BCYMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[BCYMethod alloc] init];
    });
    
    return method;
}

- (void)configMethod:(NSInteger)cellRow {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"获取半次元的图片地址：已经准备就绪"];
    downloaded = 0;
    
    CookieManager *manager = [[CookieManager alloc] initWithCookieFileType:CookieFileTypeBCY];
    [manager writeCookiesIntoHTTPStorage];
    
    switch (cellRow) {
        case 1:
            [self getPageURLFromInput:YES];
            break;
        case 2:
            [self getPageURLFromFile];
            break;
        case 3:
            [self parseHTML];
            break;
        case 4:
            [self arrangeImageFileFromPlistPhase1];
            break;
        case 5:
            [self getPageURLFromInput:NO];
        default:
            break;
    }
}

#pragma mark -- 逻辑方法 --
// 1.1~1.3、获取半次元网页地址
- (void)getPageURLFromInput:(BOOL)check {
    NSString *input = [AppDelegate defaultVC].inputTextView.string;
    checkDB = check;
    
    if (input.length > 0) {
        pageArray = [NSMutableArray arrayWithArray:[input componentsSeparatedByString:@"\n"]];
        [[UtilityFile sharedInstance] showLogWithFormat:@"从文件解析到%ld条网页\n", pageArray.count];
        
        [self ruleoutDuplicatePages];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
    }
}
- (void)getPageURLFromFile {
    NSMutableArray *parsedArray = [NSMutableArray array];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *array = [xpathParser searchWithXPathQuery:@"//a"];
    
    for (TFHppleElement *elemnt in array) {
        NSDictionary *dict = [elemnt attributes];
        NSString *url = [dict objectForKey:@"href"];
        
        if ([url hasPrefix:@"http://bcy.net/coser/detail/"] || [url hasPrefix:@"http://bcy.net/illust/detail/"] || [url hasPrefix:@"http://bcy.net/party/expo/post/"] || [url hasPrefix:@"http://bcy.net/group/detail/"] || [url hasPrefix:@"http://bcy.net/group/detail/"]) {
            [parsedArray addObject:url];
        }
    }
    
    if (parsedArray.count > 0) {
        pageArray = [NSMutableArray arrayWithArray:parsedArray];
        [[UtilityFile sharedInstance] showLogWithFormat:@"从文件解析到%ld条网页\n", pageArray.count];
        
        [self ruleoutDuplicatePages];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有获得任何数据，请检查书签文件"];
    }
}
- (void)parseHTML {
    NSData *data = [[AppDelegate defaultVC].inputTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    //获取title标签
    NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
    TFHppleElement *element = (TFHppleElement *)titleArray.firstObject;
    NSString *title = [element.text stringByReplacingOccurrencesOfString:@" | 半次元-第一中文COS绘画小说社区" withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    
    
    // 获取 script 标签
    NSArray *scriptArray = [xpathParser searchWithXPathQuery:@"//script"];
    TFHppleElement *jsonElement = [scriptArray bk_match:^BOOL(TFHppleElement *elemnt) {
        return elemnt.raw && [elemnt.raw containsString:@"JSON.parse"];
    }];
    
    NSString *jsonRaw = jsonElement.raw;
    jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\\\u002F" withString:@"\\"];
    jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    NSArray *imageComp = [jsonRaw componentsSeparatedByString:@":\""];
    NSArray *imageUrls = [imageComp bk_select:^BOOL(NSString *obj) {
        return [obj hasPrefix:@"https://img-bcy-qn.pstatp.com/user/"] && ![obj containsString:@"post_count"];
    }];
    NSArray *newImageUrls = [imageUrls bk_map:^(NSString *obj) {
        NSString *newObj = [obj stringByReplacingOccurrencesOfString:@",\"type\"" withString:@""];
        newObj = [newObj stringByReplacingOccurrencesOfString:@"/w650\"" withString:@""];
        newObj = [newObj stringByReplacingOccurrencesOfString:@"/w230\"" withString:@""];
        
        return newObj;
    }];
    
    // 导出结果
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条数据", newImageUrls.count];
    [UtilityFile exportArray:newImageUrls atPath:@"/Users/Mercury/Downloads/BCYImageURLs.txt"];
    [@{title:newImageUrls} writeToFile:@"/Users/Mercury/Downloads/BCYRenameInfo.plist" atomically:YES]; //RenameDict
    [[UtilityFile sharedInstance] showLogWithFormat:@"整个流程已经结束，如有需要，请从上方的结果框中查看记录"];
}
// 2、排除重复的页面地址
- (void)ruleoutDuplicatePages {
    checkArray = [NSMutableArray array];
    
    //使用NSOrderedSet，去掉在收藏到Safari时就存在的重复页面
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:pageArray];
    pageArray = [NSMutableArray arrayWithArray:set.array];
    
    if (checkDB) {
        //从数据库中查询是否有重复的页面地址，如果页面地址重复从数组中删除，如果页面地址不重复添加到数据库中
        for (NSInteger i = pageArray.count - 1; i >= 0; i--) {
            if ([[SQLiteFMDBManager defaultDBManager] isDuplicateFromDatabaseWithBCYLink:pageArray[i]]) {
                [pageArray removeObjectAtIndex:i];
            }
        }
    }
    
    //页面地址确保没有重复的情况下，添加半次元校验位
    for (NSString *url in pageArray) {
        NSArray *componet = [url componentsSeparatedByString:@"/"];
        [checkArray addObject:componet[5]];
    }
    
    if (pageArray.count == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"未找到具体网页地址，流程结束"];
    } else {
        [self fetchHTML];
    }
}
// 3、解析每个页面，获取图片地址
- (void)fetchHTML {
    resultArray = [NSMutableArray array];
    renameDict = [NSMutableDictionary dictionary];
    failedURLArray = [NSMutableArray array];
    
    for (NSString *string in pageArray) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
                [self->failedURLArray addObject:[error userInfo][NSURLErrorFailingURLStringErrorKey]];
                [UtilityFile exportArray:self->failedURLArray atPath:@"/Users/Mercury/Downloads/BCYFailedURLs.txt"];
                [self didFinishDownloadingOnePicture:NO];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                //获取title标签
                NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
                TFHppleElement *element = (TFHppleElement *)titleArray.firstObject;
                NSString *title = [element.text stringByReplacingOccurrencesOfString:@" | 半次元-第一中文COS绘画小说社区" withString:@""];
                title = [title stringByReplacingOccurrencesOfString:@"/" withString:@" "];

                
                // 获取 script 标签
                NSArray *scriptArray = [xpathParser searchWithXPathQuery:@"//script"];
                TFHppleElement *jsonElement = [scriptArray bk_match:^BOOL(TFHppleElement *elemnt) {
                    return elemnt.raw && [elemnt.raw containsString:@"JSON.parse"];
                }];
                
                NSError *error;
                NSString *jsonRaw = jsonElement.raw;
                jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\\\u002F" withString:@"\\"];
                jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                jsonRaw = [jsonRaw stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                NSArray *matchResult = [detector matchesInString:jsonRaw options:kNilOptions range:NSMakeRange(0, [jsonRaw length])];
                NSArray *matchUrlsResult = [matchResult valueForKeyPath:@"URL.absoluteString"];
                
                NSArray *imageUrls = [matchUrlsResult bk_select:^BOOL(NSString *obj) {
                    BOOL contains = [obj containsString:@"img-bcy-qn.pstatp.com/coser/"] || [obj containsString:@"img-bcy-qn.pstatp.com/user/"];
                    BOOL doesnotContains = ![obj containsString:@"post_count"] && ![obj containsString:@"2X2"];
                    
                    return contains && doesnotContains;
                }];
                NSArray *rawImageUrls = [imageUrls bk_map:^(NSString *obj) {
                    NSString *newObj = [obj stringByReplacingOccurrencesOfString:@",\"type\"" withString:@""];
                    newObj = [newObj stringByReplacingOccurrencesOfString:@"/w650\"" withString:@""];
                    newObj = [newObj stringByReplacingOccurrencesOfString:@"/w230\"" withString:@""];
                    newObj = [newObj stringByReplacingOccurrencesOfString:@"\"},{\"type\"" withString:@""];
                    
                    return newObj;
                }];
                
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [evaluatedObject hasSuffix:@"jpg"] || [evaluatedObject hasSuffix:@"jpeg"] || [evaluatedObject hasSuffix:@"png"];
                }];
                NSMutableArray *newImageUrls = [NSMutableArray arrayWithArray:[rawImageUrls filteredArrayUsingPredicate:predicate]];
                
                // 结果
                if (newImageUrls.count > 0) {
                    [self->resultArray addObjectsFromArray:newImageUrls];
                    
                    if ([self->renameDict.allKeys containsObject:title]) {
                        [(NSMutableArray *)self->renameDict[title] addObjectsFromArray:newImageUrls];
                    } else {
                        [self->renameDict setObject:newImageUrls forKey:title];
                    }
                    
                    [self didFinishDownloadingOnePicture:YES];
                } else {
                    [self->failedURLArray addObject:response.URL.absoluteString];
                    [self didFinishDownloadingOnePicture:NO];
                }
            }
        }];
        
        [task resume];
    }
}
// 4、排除重复的图片地址，并且将没有重复的图片地址保存到数据库中
- (void)ruleoutDuplicateImages {
    //使用NSOrderedSet，去掉在解析HTML文件时获取到的重复图片地址
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:resultArray];
    resultArray = [NSMutableArray arrayWithArray:set.array];
    
    if (checkDB) {
        //从数据库中查询是否有重复的图片地址，如果图片地址重复从数组中删除
        for (NSInteger i = resultArray.count - 1; i >= 0; i--) {
            if ([[SQLiteFMDBManager defaultDBManager] isDuplicateFromDatabaseWithBCYImageLink:resultArray[i]]) {
                NSLog(@"第%ld个图片地址重复: %@", i, resultArray[i]);
                [resultArray removeObjectAtIndex:i];
            }
        }
    }
    
    //如果有下载失败的页面地址，从pageArray中删除
    for (NSString *obj in failedURLArray) {
        [pageArray removeObject:obj];
    }
    
    [self doneThings];
}
// 5、导出结果
- (void)doneThings {
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取了%ld个页面的图片地址", pageArray.count]; //获取到的页面地址
    [UtilityFile exportArray:pageArray atPath:@"/Users/Mercury/Downloads/BCYPageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到%ld条图片地址，在右上方输出框内显示", resultArray.count];
    [UtilityFile exportArray:resultArray atPath:@"/Users/Mercury/Downloads/BCYImageURLs.txt"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"有%ld条网页解析失败，请查看错误文件", failedURLArray.count]; //获取失败的页面地址
    [UtilityFile exportArray:failedURLArray atPath:@"/Users/Mercury/Downloads/BCYFailedURLs.txt"];
    [renameDict writeToFile:@"/Users/Mercury/Downloads/BCYRenameInfo.plist" atomically:YES]; //RenameDict
    
    if (checkDB) {
        //把页面地址和图片地址全部写入到数据库中
        for (NSString *obj in pageArray) {
            [[SQLiteFMDBManager defaultDBManager] insertLinkIntoDatabase:obj];
        }
        for (NSString *obj in resultArray) {
            [[SQLiteFMDBManager defaultDBManager] insertImageLinkIntoDatabase:obj];
        }
        
        // 备份数据库
        [[SQLiteManager defaultManager] backupBCYDatabase];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整个流程已经结束，数据库已备份"];
    }
    
    // 下载
    [[UtilityFile sharedInstance] showLogWithFormat:@"1秒后开始下载图片"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
    });
}
// 6、下载
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:resultArray];
    manager.downloadPath = @"/Users/Mercury/Downloads/半次元";
    [manager startDownload];
}

#pragma mark -- 辅助方法 --
// 下载完成的方法
- (void)didFinishDownloadingOnePicture:(BOOL)success {
    downloaded++;
    
    if (success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取完成 | 共%lu条网页", downloaded, pageArray.count];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"第%lu条网页已获取失败 | 共%lu条网页", downloaded, pageArray.count];
    }
    
    if (downloaded == pageArray.count) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"已经完成获取图片地址的工作\n"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ruleoutDuplicateImages];
        });
    }
}

#pragma mark -- 整理方法 --
// 根据Plist文件将图片整理到对应的文件夹中（第一步，显示NSOpenPanel）
- (void)arrangeImageFileFromPlistPhase1 {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理半次元下载好的图片：已经准备就绪"];
    
    //先判断有没有plist文件
    if (![[FileManager defaultManager] isContentExistAtPath:@"/Users/Mercury/Downloads/BCYRenameInfo.plist"]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"plist不存在，请查看对应的文件夹"];
        return;
    }
    
    // 如果文件夹存在，那么直接对文件夹进行处理
    if ([[FileManager defaultManager] isContentExistAtPath:@"/Users/Mercury/Downloads/半次元/"]) {
        [self arrangeImageFileFromPlistPhase2:@"/Users/Mercury/Downloads/半次元/"];
    } else {
        //显示NSOpenPanel
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setMessage:@"选择半次元下载文件夹"];
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
}
// 根据Plist文件将图片整理到对应的文件夹中（第二步，具体逻辑）
- (void)arrangeImageFileFromPlistPhase2:(NSString *)rootFolderName {
    FileManager *fm = [FileManager defaultManager];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/Users/Mercury/Downloads/BCYRenameInfo.plist"];
    
    //根据Plist文件整理记录的图片
    NSArray *allKeys = [dict allKeys];
    for (NSString *key in allKeys) {
        //获取文件夹的名字和路径
        NSString *folderName = @"";
        if ([key hasPrefix:@"http://bcy.net"]) {
            NSArray *array = [key componentsSeparatedByString:@"/"];
            folderName = [folderName stringByAppendingString:array[3]];
            folderName = [folderName stringByAppendingString:array[5]];
            folderName = [folderName stringByAppendingString:array[4]];
            folderName = [folderName stringByAppendingString:array[6]];
        } else {
            folderName = key;
        }
        //创建目录文件夹
        NSString *folderPath = [rootFolderName stringByAppendingPathComponent:folderName];
        [fm createFolderAtPathIfNotExist:folderPath];
        
        //获取图片文件路径并且移动文件
        NSArray *array = [NSArray arrayWithArray:dict[key]];
        for (NSString *url in array) {
            NSString *filePath = [rootFolderName stringByAppendingPathComponent:url.lastPathComponent];
            NSString *destPath = [folderPath stringByAppendingPathComponent:url.lastPathComponent];
            
            [fm moveItemAtPath:filePath toDestPath:destPath];
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"Plist中记录的图片已经整理完成"];
    
    // 新建"未整理"文件夹并将剩下的图片整理到"未整理"文件夹
    NSString *otherFolderName = [rootFolderName stringByAppendingPathComponent:@"未整理"];
    [fm createFolderAtPathIfNotExist:otherFolderName];
    
    NSArray<NSString *> *imageFiles = [fm getFilePathsInFolder:rootFolderName specificExtensions:[Consts simplePhotoType]];
    for (NSString *filePath in imageFiles) {
        NSString *destPath = [otherFolderName stringByAppendingPathComponent:filePath.lastPathComponent];
        [fm moveItemAtPath:filePath toDestPath:destPath];
    }
    
    [fm trashFileAtPath:@"/Users/Mercury/Downloads/BCYRenameInfo.plist" resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"其他图片已经整理完成"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"所有半次元图片已经整理完成"];
}

@end
