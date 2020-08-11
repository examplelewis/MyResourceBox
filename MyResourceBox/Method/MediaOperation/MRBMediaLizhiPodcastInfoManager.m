//
//  MRBMediaLizhiPodcastInfoManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/08/09.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBMediaLizhiPodcastInfoManager.h"
#import <AVFoundation/AVFoundation.h>

@interface MRBMediaLizhiPodcastInfoManager ()

@property (assign) NSInteger idx;
@property (strong) NSMutableArray *failedUrls;
@property (strong) NSMutableDictionary *mp3Info;

@property (copy) NSArray *lizhiUrls;
@property (copy) NSString *mp3FolderPath;

@property (copy) AVAsset *asset;
@property (assign) BOOL isPrepared;

@end

@implementation MRBMediaLizhiPodcastInfoManager

- (void)obtainProcessingData {
    self.failedUrls = [NSMutableArray array];
    self.idx = 0;
    self.mp3Info = [NSMutableDictionary dictionary];
    self.isPrepared = NO;
    
    NSString *content = [AppDelegate defaultVC].inputTextView.string;
    if (content.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    } else {
        self.lizhiUrls = [content componentsSeparatedByString:@"\n"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"一共 %ld 个网页", self.lizhiUrls.count];
    }
    
    [self obtainMP3ContainerFolderPath];
}
- (void)obtainMP3ContainerFolderPath {
//    NSOpenPanel *panel = [NSOpenPanel openPanel];
//    [panel setMessage:@"请选择包含MP3的文件夹"];
//    panel.prompt = @"确定";
//    panel.canChooseDirectories = YES;
//    panel.canCreateDirectories = NO;
//    panel.canChooseFiles = NO;
//    panel.allowsMultipleSelection = NO;
//
//    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
//        if (result == NSFileHandlingPanelOKButton) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                DDLogInfo(@"已选择的文件夹：%@", panel.URLs.firstObject);
//
//                NSString *folderPath = panel.URLs.firstObject.absoluteString;
//                folderPath = [folderPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
//                folderPath = [folderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//                self.mp3FolderPath = folderPath;
//
//                [self startFetch];
//            });
//        }
//    }];
    
    self.mp3FolderPath = @"/Users/Mercury/Music/网易云音乐/电台节目";
    [self startFetch];
}
- (void)startFetch {
    [self fetchSingleLizhiPageData];
}

- (void)fetchSingleLizhiPageData {
    [[MRBLogManager defaultManager] showLogWithFormat:@"-----【开始】抓取第 %ld 个网页: %@", self.idx + 1, self.lizhiUrls[self.idx]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.lizhiUrls[self.idx]]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0f];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
            [self.failedUrls addObject:error.userInfo[NSURLErrorFailingURLStringErrorKey]];
            
            [self fetchNext];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页信息成功"];
            
            [self fetchSucceedWithData:data];
        }
    }];
    
    [task resume];
}
- (void)fetchSucceedWithData:(NSData *)data {
    NSString *mp3Name = @"";
    NSString *imgUrl = @"";
    NSString *pubDate = @"";
    NSString *desc = @"";
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    // mp3Name
    NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
    TFHppleElement *element = (TFHppleElement *)titleArray.firstObject;
    mp3Name = [element.text stringByReplacingOccurrencesOfString:@"在线收听_友的聊播客_荔枝" withString:@""];
    mp3Name = [mp3Name stringByReplacingOccurrencesOfString:@"【" withString:@""];
    mp3Name = [mp3Name stringByReplacingOccurrencesOfString:@"】" withString:@""];
    
    // imgUrl
    NSArray *imageArray = [xpathParser searchWithXPathQuery:@"//img"];
    imageArray = [imageArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [element.attributes[@"alt"] isEqualToString:mp3Name];
    }]];
    if (imageArray.count != 0) {
        TFHppleElement *element = (TFHppleElement *)imageArray.firstObject;
        imgUrl = element.attributes[@"src"];
        
        NSString *imgName = imgUrl.lastPathComponent.stringByDeletingPathExtension;
        imgName = [imgName componentsSeparatedByString:@"_"][0];
        
        imgUrl = [NSString stringWithFormat:@"%@/%@.%@", imgUrl.stringByDeletingLastPathComponent, imgName, imgUrl.pathExtension];
    }
    
    // pubDate
    NSArray *spanArray = [xpathParser searchWithXPathQuery:@"//span"];
    spanArray = [spanArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [element.attributes[@"class"] isEqualToString:@"audioTime"];
    }]];
    if (spanArray.count != 0) {
        TFHppleElement *element = (TFHppleElement *)spanArray.firstObject;
        if (element.children.count > 0) {
            TFHppleElement *childElement = (TFHppleElement *)element.children[0];
            pubDate = childElement.content;
        }
    }
    
    // desc
    NSArray *divArray = [xpathParser searchWithXPathQuery:@"//div"];
    divArray = [divArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [element.attributes[@"class"] isEqualToString:@"desText"];
    }]];
    if (divArray.count != 0) {
        TFHppleElement *element = (TFHppleElement *)divArray.firstObject;
        if (element.children.count > 0) {
            TFHppleElement *childElement = (TFHppleElement *)element.children[0];
            desc = childElement.content;
        }
    }
    
    self.mp3Info[@"mp3Name"] = mp3Name;
    self.mp3Info[@"imgUrl"] = imgUrl;
    self.mp3Info[@"pubDate"] = pubDate;
    self.mp3Info[@"desc"] = desc;
    
    NSString *mp3FilePath = [self.mp3FolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", mp3Name]];
//    if (![[MRBFileManager defaultManager] isContentExistAtPath:mp3FilePath]) {
//        [[MRBLogManager defaultManager] showLogWithFormat:@"未找到对应的MP3文件"];
//        [self.failedUrls addObject:self.lizhiUrls[self.idx]];
//
//        [self fetchNext];
//    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"抓取到如下信息:\n%@\n%@\n%@\n%@\n%@", mp3Name, imgUrl, pubDate, desc, mp3FilePath];
        self.mp3Info[@"mp3FilePath"] = mp3FilePath;
        
        [self downloadImg];
//    }
}
- (void)downloadImg {
    NSString *imgUrl = self.mp3Info[@"imgUrl"];
    NSString *imgFolderPath = @"/Users/Mercury/Downloads/友的聊播客 封面";
    NSString *imgFileName = [NSString stringWithFormat:@"%@.%@", self.mp3Info[@"mp3Name"], imgUrl.pathExtension];
    NSString *imgFilePath = [imgFolderPath stringByAppendingPathComponent:imgFileName];
    self.mp3Info[@"imgFilePath"] = imgFilePath;
    [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:imgFolderPath]; // 创建父文件夹
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imgUrl]];
    request.timeoutInterval = 30;
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:imgFilePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载图片失败，原因：%@", [error localizedDescription]];
            [self.failedUrls addObject:error.userInfo[NSURLErrorFailingURLStringErrorKey]];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"下载图片成功"];
        }
        
        [self fetchNext];
    }];
    
    [downloadTask resume];
}


- (void)fetchNext {
    if (self.idx == self.lizhiUrls.count - 1) {
        [self fetchDone]; // 已经抓取了最后一个网页
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"-----【结束】抓取第 %ld 个网页: %@", self.idx + 1, self.lizhiUrls[self.idx]];
        
        [self.mp3Info removeAllObjects];
        self.asset = nil;
        self.isPrepared = NO;
        self.idx += 1;
        [self fetchSingleLizhiPageData];
    }
}

- (void)fetchDone {
    [[MRBLogManager defaultManager] showLogWithFormat:@"已抓取全部网页"];
    [MRBUtilityManager exportArray:self.failedUrls atPath:@"/Users/Mercury/Downloads/FailedUrl.txt"];
}

@end
