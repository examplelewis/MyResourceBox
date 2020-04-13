//
//  MRBMacmini2018ConfigureManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/13.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBMacmini2018ConfigureManager.h"

@implementation MRBMacmini2018ConfigureManager

- (void)prepareFetching {
    [self fetchList];
}

- (void)fetchList {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.apple.com.cn/shop/refurbished/mac/2018-mac-mini"]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0f];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页信息失败，原因：%@", [error localizedDescription]];
        } else {
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *aArray = [xpathParser searchWithXPathQuery:@"//a"];
            NSPredicate *aPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject.text hasPrefix:@"翻新 Mac mini"];
            }];
            aArray = [aArray filteredArrayUsingPredicate:aPredicate];
            aArray = [aArray valueForKeyPath:@"attributes.href"];
            
            [self prepareFetchingDetail:aArray];
            
        }
    }];
    
    [task resume];
}

- (void)prepareFetchingDetail:(NSArray *)list {
    for (NSString *address in list) {
        NSString *url = [@"https://www.apple.com.cn" stringByAppendingPathComponent:address];
        [self fetchDetailWithUrl:url];
    }
}

- (void)fetchDetailWithUrl:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0f];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取网页【%@】信息失败，原因：%@", response.URL.absoluteString, [error localizedDescription]];
        } else {
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *divArray = [xpathParser searchWithXPathQuery:@"//div"];
            NSPredicate *divPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject.attributes[@"class"] isEqualToString:@"as-productinfosection-mainpanel column large-9 small-12"] && [evaluatedObject.raw containsString:@"最初发布于"];
            }];
            divArray = [divArray filteredArrayUsingPredicate:divPredicate];
            
            if (divArray.count > 0) {
                TFHppleElement *divElement = divArray[0];
                NSArray *divChildren = divElement.children;
                NSPredicate *divPredicate = [NSPredicate predicateWithBlock:^BOOL(TFHppleElement * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [evaluatedObject.attributes[@"class"] hasPrefix:@"para-list"];
                }];
                divChildren = [divChildren filteredArrayUsingPredicate:divPredicate];
                
                for (TFHppleElement *divChild in divChildren) {
                    for (TFHppleElement *pElement in divChild.children) {
                        if (pElement.children.count > 0) {
                            TFHppleElement *textElement = pElement.children[0];
                            NSString *content = textElement.content;
                            content = [content stringByReplacingOccurrencesOfString:@"\n                " withString:@""];
                            NSLog(@"%@", content);
                        }
                    }
                }
            }
        }
    }];
    
    [task resume];
}

@end
