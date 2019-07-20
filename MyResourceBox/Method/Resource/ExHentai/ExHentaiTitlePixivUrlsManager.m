//
//  ExHentaiTitlePixivUrlsManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/07/20.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ExHentaiTitlePixivUrlsManager.h"
#import "MRBHttpManager.h"

@implementation ExHentaiTitlePixivUrlsManager

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

- (void)startFetching {
    downloaded = 0;
    [failure removeAllObjects];
    
    for (NSInteger i = 0; i < oriExhentaiUrls.count; i++) {
        NSString *url = oriExhentaiUrls[i];
        
        [[MRBHttpManager sharedManager] getExHentaiPostDetailWithUrl:url success:^(NSDictionary *result) {
            NSString *title;
            if (result[@"title"]) {
                title = result[@"title"];
            } else if (result[@"title_jpn"]) {
                title = result[@"title_jpn"];
            }
            
            if (!title || title.length == 0) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"标题获取失败"];
                
                [self->failure addObject:url];
                [MRBUtilityManager exportArray:self->failure atPath:@"/Users/Mercury/Downloads/ExHentaiParseTitlePixivFailureUrls.txt"];
                
                return;
            }
            
            if ([title rangeOfString:@"pixiv" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSInteger findInt;
                NSScanner *scanner = [NSScanner scannerWithString:title];
                NSCharacterSet *numberSC = [NSCharacterSet decimalDigitCharacterSet];
                
                [scanner scanUpToCharactersFromSet:numberSC intoString:nil];
                while (![scanner isAtEnd]) {
                    if ([scanner scanInteger:&findInt]) {
                        NSString *pixivUrl = [NSString stringWithFormat:@"https://www.pixiv.net/member_illust.php?id=%ld", findInt];
                        
                        [self->pixivUrls addObject:pixivUrl];
                        [self->parseInfo setObject:pixivUrl forKey:url];
                        [self->hasPixivUrlExHentaiUrls addObject:url];
                    } else {
                        [scanner setScanLocation:[scanner scanLocation] + 1];
                    }
                }
            }
            
            
            [self didFinishDownloadingOnePicture];
        } failed:^(NSString *errorTitle, NSString *errorMsg) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"ExHentai 接口调用失败，原因：%@", errorMsg];
            
            [self->failure addObject:url];
            [MRBUtilityManager exportArray:self->failure atPath:@"/Users/Mercury/Downloads/ExHentaiParseTitlePixivFailureUrls.txt"];
            
            [self didFinishDownloadingOnePicture];
        }];
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
    [MRBUtilityManager exportArray:pixivUrls atPath:@"/Users/Mercury/Downloads/ExHentaiParseTitlePixivUrls.txt"];
    [MRBUtilityManager exportArray:hasPixivUrlExHentaiUrls atPath:@"/Users/Mercury/Downloads/ExHentaiParseTitlePixivHasPixivUrlExHentaiUrls.txt"];
    [MRBUtilityManager exportArray:hasnotPixivUrlExHentaiUrls atPath:@"/Users/Mercury/Downloads/ExHentaiParseTitlePixivHasnotPixivUrlExHentaiUrls.txt"];
    [MRBUtilityManager exportDictionary:parseInfo atPlistPath:@"/Users/Mercury/Downloads/ExHentaiParseTitlePixivParseInfo.plist"];
    if (failure.count > 0) {
        [MRBUtilityManager exportArray:failure atPath:@"/Users/Mercury/Downloads/ExHentaiParseTitlePixivFailureUrls.txt"];
        [[MRBLogManager defaultManager] showLogWithFormat:@"有%ld个文件无法下载，已导出到下载文件夹的 ExHentaiParseTitlePixivFailureUrls.txt 文件中", failure.count];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetAllTitlePixivUrls:error:)]) {
            [self.delegate didGetAllTitlePixivUrls:[self->pixivUrls mutableCopy] error:nil];
        }
    });
}

@end
