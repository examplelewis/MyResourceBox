//
//  ExHentaiPixivUrlsManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ExHentaiPixivUrlsManager.h"

@implementation ExHentaiPixivUrlsManager

- (instancetype)initWithUrls:(NSArray *)urls {
    self = [super init];
    if (self) {
        oriExhentaiUrls = [NSArray arrayWithArray:urls];
        hasPixivUrlExHentaiUrls = [NSMutableArray array];
        pixivUrls = [NSMutableArray array];
        failure = [NSMutableArray array];
        parseInfo = [NSMutableDictionary dictionary];
        downloaded = 0;
    }
    
    return self;
}

// 解析每个页面，获取图片地址
- (void)startFetching {
    downloaded = 0;
    [failure removeAllObjects];
    
    for (NSInteger i = 0; i < oriExhentaiUrls.count; i++) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:oriExhentaiUrls[i]]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:15.0f];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSString *url = error.userInfo[NSURLErrorFailingURLStringErrorKey];
                if (!url) {
                    url = error.userInfo[@"NSErrorFailingURLKey"];
                    if (!url) {
                        url = error.userInfo[@"NSErrorFailingURLStringKey"];
                        if (!url) {
                            url = @"";
                        }
                    }
                }
                
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
                
                [self->failure addObject:url];
                [UtilityFile exportArray:self->failure atPath:@"/Users/Mercury/Downloads/ExHentaiParsePixivFailureUrls.txt"];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                // 评论节点样式: <div class="c6" id="comment_0">Pixiv: https://www.pixiv.net/member.php?id=2141775</div>
                NSArray *aArray = [xpathParser searchWithXPathQuery:@"//div"];
                NSMutableArray *commentArray = [NSMutableArray array];
                for (TFHppleElement *elemnt in aArray) {
                    NSDictionary *para = elemnt.attributes;
                    if ([para[@"id"] hasPrefix:@"comment_"] && [para[@"class"] isEqualToString:@"c6"]) {
                        [commentArray addObject:elemnt];
                    }
                }
                
                if (commentArray.count > 0) {
                    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement *commentElemnt, NSDictionary<NSString *,id> * _Nullable bindings) {
                        for (TFHppleElement *subElemnt in commentElemnt.children) {
                            if ([subElemnt.content containsString:@"www.pixiv.net"]) {
                                return YES;
                            }
                        }
                        
                        return NO;
                    }];
                    [commentArray filterUsingPredicate:predicate];
                    
                    if (commentArray.count > 0) {
                        TFHppleElement *commentElemnt = commentArray.firstObject;
                        NSPredicate *subCommentPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement *subElemnt, NSDictionary<NSString *,id> * _Nullable bindings) {
                            return [subElemnt.content containsString:@"www.pixiv.net"];
                        }];
                        NSArray *subCommentArray = [commentElemnt.children filteredArrayUsingPredicate:subCommentPredicate];
                        TFHppleElement *subCommentElemnt = subCommentArray.firstObject;
                        NSString *commentContent = subCommentElemnt.content;
                        
                        NSError *error = nil;
                        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                        NSArray *results = [detector matchesInString:commentContent options:kNilOptions range:NSMakeRange(0, [commentContent length])];
                        if (results.count > 0) {
                            NSArray *resultUrls = [results valueForKeyPath:@"URL.absoluteString"];
                            NSString *exHentaiUrl = response.URL.absoluteString;
                            
                            [self->pixivUrls addObjectsFromArray:resultUrls];
                            [self->parseInfo setObject:resultUrls forKey:exHentaiUrl];
                            [self->hasPixivUrlExHentaiUrls addObject:exHentaiUrl];
                        }
                    }
                }
            }
            
            [self didFinishDownloadingOnePicture];
        }];
        [task resume];
    }
}

// 完成下载图片地址的方法
- (void)didFinishDownloadingOnePicture {
    downloaded++;
    [[MRBLogManager defaultManager] showNotAppendLogWithFormat:@"已获取到第%lu条记录 | 共%lu条记录", downloaded, oriExhentaiUrls.count];
    
    if (downloaded != oriExhentaiUrls.count) {
        return;
    }
    
    NSMutableSet *totalSet = [NSMutableSet setWithArray:oriExhentaiUrls];
    NSMutableSet *hasSet = [NSMutableSet setWithArray:hasPixivUrlExHentaiUrls];
    [totalSet minusSet:hasSet]; // 取差集后就剩下没有Pixiv的ExHentai地址了
    NSArray *hasnotPixivUrlExHentaiUrls = totalSet.allObjects;
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取完成"];
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到%ld条数据", pixivUrls.count];
    [UtilityFile exportArray:pixivUrls atPath:@"/Users/Mercury/Downloads/ExHentaiParsePixivUrls.txt"];
    [UtilityFile exportArray:hasPixivUrlExHentaiUrls atPath:@"/Users/Mercury/Downloads/ExHentaiParsePixivHasPixivUrlExHentaiUrls.txt"];
    [UtilityFile exportArray:hasnotPixivUrlExHentaiUrls atPath:@"/Users/Mercury/Downloads/ExHentaiParsePixivHasnotPixivUrlExHentaiUrls.txt"];
    [UtilityFile exportDictionary:parseInfo atPlistPath:@"/Users/Mercury/Downloads/ExHentaiParsePixivParseInfo.plist"];
    if (failure.count > 0) {
        [UtilityFile exportArray:failure atPath:@"/Users/Mercury/Downloads/ExHentaiParsePixivFailureUrls.txt"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"有%ld个文件无法下载，已导出到下载文件夹的 ExHentaiParsePixivFailureUrls.txt 文件中", failure.count];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetAllPixivUrls:error:)]) {
            [self.delegate didGetAllPixivUrls:[self->pixivUrls mutableCopy] error:nil];
        }
    });
}


@end
