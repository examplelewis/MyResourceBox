//
//  ExHentaiPixivUrlsManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ExHentaiPixivUrlsManager.h"

static NSString * const kBothUrlPath = @"/Users/Mercury/Downloads/ExHentaiParseResultBothUrls.txt";
static NSString * const kPixivUrlPath = @"/Users/Mercury/Downloads/ExHentaiParseResultPixivUrls.txt";
static NSString * const kPatreonUrlPath = @"/Users/Mercury/Downloads/ExHentaiParseResesultPatreonUrls.txt";
static NSString * const kUselessUrlPath = @"/Users/Mercury/Downloads/ExHentaiParseUselessUrls.txt";
static NSString * const kFailureUrlPath = @"/Users/Mercury/Downloads/ExHentaiParseFailureUrls.txt";

@interface ExHentaiPixivUrlsManager () {
    NSArray *allUrls; // 输入的所有URL
    NSMutableArray *usefulUrls; // 有用的URL
    NSMutableArray *pixivUrls; // 查找到的Pixiv
    NSMutableArray *patreonUrls; // 查找到的Patreon
    NSMutableArray *bothUrls; // 查找到的Pixiv和Patreon
    
    NSInteger downloaded;
    NSMutableArray *failureUrls; // 接口调用出错的URL
}

@end

@implementation ExHentaiPixivUrlsManager

- (instancetype)initWithUrls:(NSArray *)urls {
    self = [super init];
    if (self) {
        allUrls = [NSArray arrayWithArray:urls];
        usefulUrls = [NSMutableArray array];
        pixivUrls = [NSMutableArray array];
        patreonUrls = [NSMutableArray array];
        bothUrls = [NSMutableArray array];
        
        downloaded = 0;
        failureUrls = [NSMutableArray array];
    }
    
    return self;
}

// 解析每个页面，获取图片地址
- (void)startFetching {
    [usefulUrls removeAllObjects];
    [pixivUrls removeAllObjects];
    [patreonUrls removeAllObjects];
    [bothUrls removeAllObjects];
    
    downloaded = 0;
    [failureUrls removeAllObjects];
    
    for (NSInteger i = 0; i < allUrls.count; i++) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:allUrls[i]]
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
                            url = response.URL.absoluteString;
                        }
                    }
                }
                [self->failureUrls addObject:url];
                
                [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
            } else {
                TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                
                // 评论地址
                // 评论节点样式: <div class="c6" id="comment_0">Pixiv: https://www.pixiv.net/member.php?id=2141775</div>
                NSArray *divArray = [xpathParser searchWithXPathQuery:@"//div"];
                NSPredicate *divPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [element.attributes[@"id"] hasPrefix:@"comment_"] && [element.attributes[@"class"] isEqualToString:@"c6"];
                }];
                NSArray *comments = [divArray filteredArrayUsingPredicate:divPredicate];
                
                NSArray *bothR = [self parseBothUrlsWithComments:comments];
                NSArray *pixivR = [self parseUsefulUrlsWithComments:comments host:@"www.pixiv.net"];
                NSArray *patreonR = [self parseUsefulUrlsWithComments:comments host:@"www.patreon.com"];
                if (bothR.count > 0) {
                    [self->bothUrls addObjectsFromArray:[bothR valueForKeyPath:@"URL.absoluteString"]];
                    [self->usefulUrls addObject:response.URL.absoluteString];
                } else if (pixivR.count > 0) {
                    [self->pixivUrls addObjectsFromArray:[pixivR valueForKeyPath:@"URL.absoluteString"]];
                    [self->usefulUrls addObject:response.URL.absoluteString];
                } else if (patreonR.count > 0) {
                    [self->patreonUrls addObjectsFromArray:[patreonR valueForKeyPath:@"URL.absoluteString"]];
                    [self->usefulUrls addObject:response.URL.absoluteString];
                } else {
                    // 如果抓取不到 pixiv 和 patreon 的地址，再尝试解析 Title 中的 Pixiv ID
                    
                    // title ID
                    NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//h1"];
                    NSPredicate *h1Predicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
                        return [element.attributes[@"id"] isEqualToString:@"gn"];
                    }];
                    NSArray *titles = [titleArray filteredArrayUsingPredicate:h1Predicate];
                    
                    NSArray *titleR = [self parsePixivMemberIdFromTitles:titles];
                    if (titleR.count > 0) {
                        [self->pixivUrls addObjectsFromArray:titleR];
                        [self->usefulUrls addObject:response.URL.absoluteString];
                    }
                }
            }
            
            [self didFinishDownloadingOnePicture];
        }];
        
        [task resume];
    }
}
- (NSArray *)parseBothUrlsWithComments:(NSArray *)comments {
    NSPredicate *rawPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [element.raw containsString:@"www.pixiv.net"] && [element.raw containsString:@"www.patreon.com"];
    }];
    NSArray *raws = [comments filteredArrayUsingPredicate:rawPredicate];
    if (raws.count == 0) {
        return @[];
    }
    
    TFHppleElement *elem = raws[0];
    NSPredicate *contentPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable element, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [element.content containsString:@"www.pixiv.net"] || [element.content containsString:@"www.patreon.com"];
    }];
    NSArray *contents = [elem.children filteredArrayUsingPredicate:contentPredicate];
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSInteger i = 0; i < contents.count; i++) {
        TFHppleElement *element = contents[i];
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        [results addObjectsFromArray:[detector matchesInString:element.content options:kNilOptions range:NSMakeRange(0, element.content.length)]];
    }
    
    return [results copy];
}
- (NSArray *)parseUsefulUrlsWithComments:(NSArray *)comments host:(NSString *)host {
    NSPredicate *rawPredicate = [NSPredicate predicateWithFormat:@"raw CONTAINS[cd] %@", host];
    NSArray *raws = [comments filteredArrayUsingPredicate:rawPredicate];
    if (raws.count == 0) {
        return @[];
    }
    
    TFHppleElement *elem = raws[0];
    NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@", host];
    NSArray *contents = [elem.children filteredArrayUsingPredicate:contentPredicate];
    if (contents.count == 0) {
        return @[];
    }
    
    NSString *content = ((TFHppleElement *)contents[0]).content;
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    return [detector matchesInString:content options:kNilOptions range:NSMakeRange(0, content.length)];
}
- (NSArray *)parsePixivMemberIdFromTitles:(NSArray *)titles {
    if (titles.count == 0) {
        return @[];
    }
    
    TFHppleElement *element = titles[0];
    if (element.children.count == 0) {
        return @[];
    }
    
    NSMutableArray *results = [NSMutableArray array];
    NSString *content = ((TFHppleElement *)element.children[0]).content;
    
    // 只有 Title 中包含 Pixiv，那么再去查找数字
    if (![content containsString:@"pixiv"]) {
        return @[];
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d+" options:0 error:&error];
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    for (NSTextCheckingResult *match in matches) {
        NSString *strNumber = [content substringWithRange:match.range];
        [results addObject:[NSString stringWithFormat:@"https://www.pixiv.net/artworks/%@", strNumber]];
    }
    
    return [results copy];
}

// 完成下载图片地址的方法
- (void)didFinishDownloadingOnePicture {
    downloaded++;
    [[MRBLogManager defaultManager] showNotAppendLogWithFormat:@"已获取到第%lu条记录 | 共%lu条记录", downloaded, allUrls.count];
    
    if (downloaded != allUrls.count) {
        return;
    }
    
    NSMutableSet *totalSet = [NSMutableSet setWithArray:allUrls];
    NSMutableSet *usefulSet = [NSMutableSet setWithArray:usefulUrls];
    [totalSet minusSet:usefulSet]; // 取差集后就剩下没有Pixiv的ExHentai地址了
    NSMutableArray *uselessUrls = [NSMutableArray arrayWithArray:totalSet.allObjects];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"获取完成"];
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到 %ld 条 Both 数据", bothUrls.count];
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到 %ld 条 Pixiv 数据", pixivUrls.count];
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到 %ld 条 Patreon 数据", patreonUrls.count];
    [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条没有获取到数据", uselessUrls.count];
    [[MRBLogManager defaultManager] showLogWithFormat:@"有 %ld 条数据下载失败", failureUrls.count];
    
    if ([[MRBFileManager defaultManager] isContentExistAtPath:kBothUrlPath]) {
        NSString *existedStr = [[NSString alloc] initWithContentsOfFile:kBothUrlPath encoding:NSUTF8StringEncoding error:nil];
        NSArray *existedArray = [existedStr componentsSeparatedByString:@"\n"];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, existedArray.count)];
        
        [bothUrls insertObjects:existedArray atIndexes:indexSet];
    }
    
    if ([[MRBFileManager defaultManager] isContentExistAtPath:kPixivUrlPath]) {
        NSString *existedStr = [[NSString alloc] initWithContentsOfFile:kPixivUrlPath encoding:NSUTF8StringEncoding error:nil];
        NSArray *existedArray = [existedStr componentsSeparatedByString:@"\n"];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, existedArray.count)];
        
        [pixivUrls insertObjects:existedArray atIndexes:indexSet];
    }
    
    if ([[MRBFileManager defaultManager] isContentExistAtPath:kPatreonUrlPath]) {
        NSString *existedStr = [[NSString alloc] initWithContentsOfFile:kPatreonUrlPath encoding:NSUTF8StringEncoding error:nil];
        NSArray *existedArray = [existedStr componentsSeparatedByString:@"\n"];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, existedArray.count)];
        
        [patreonUrls insertObjects:existedArray atIndexes:indexSet];
    }
    
    if ([[MRBFileManager defaultManager] isContentExistAtPath:kUselessUrlPath]) {
        NSString *existedStr = [[NSString alloc] initWithContentsOfFile:kUselessUrlPath encoding:NSUTF8StringEncoding error:nil];
        NSArray *existedArray = [existedStr componentsSeparatedByString:@"\n"];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, existedArray.count)];
        
        [uselessUrls insertObjects:existedArray atIndexes:indexSet];
    }
    
    if ([[MRBFileManager defaultManager] isContentExistAtPath:kFailureUrlPath]) {
        NSString *existedStr = [[NSString alloc] initWithContentsOfFile:kFailureUrlPath encoding:NSUTF8StringEncoding error:nil];
        NSArray *existedArray = [existedStr componentsSeparatedByString:@"\n"];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, existedArray.count)];
        
        [failureUrls insertObjects:existedArray atIndexes:indexSet];
    }
    
    [MRBUtilityManager exportArray:bothUrls atPath:kBothUrlPath];
    [MRBUtilityManager exportArray:pixivUrls atPath:kPixivUrlPath];
    [MRBUtilityManager exportArray:patreonUrls atPath:kPatreonUrlPath];
    [MRBUtilityManager exportArray:uselessUrls atPath:kUselessUrlPath];
    [MRBUtilityManager exportArray:failureUrls atPath:kFailureUrlPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetAllPixivUrls:error:)]) {
            [self.delegate didGetAllPixivUrls:[self->pixivUrls mutableCopy] error:nil];
        }
    });
}


@end
