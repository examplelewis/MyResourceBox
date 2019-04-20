//
//  ParseBTChinaOperation.m
//  MyToolBox
//
//  Created by 龚宇 on 16/08/11.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ParseBTChinaOperation.h"
#import "TFHpple.h"

@interface ParseBTChinaOperation ()

@property (strong) NSData *dataToParse;

@end

@implementation ParseBTChinaOperation

@synthesize dataToParse;
@synthesize imgURLArray;
@synthesize errorHandler;
@synthesize title;
@synthesize url;

- (instancetype)initWithData:(NSData *)data url:(NSString *)urlString {
    self = [super init];
    
    if (self) {
        dataToParse = data;
        imgURLArray = [NSMutableArray array];
        url = urlString;
        title = @"未解析到或者网页获取失败";
    }
    
    return self;
}

- (void)main {
    [self parsing];
}

- (void)parsing {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:dataToParse];
    
    //获取title标签
    NSArray *titleArray = [xpathParser searchWithXPathQuery:@"//title"];
    TFHppleElement *elemnt = (TFHppleElement *)titleArray.firstObject;
    title = [elemnt.text substringToIndex:elemnt.content.length - 6];
    
    //获取a标签
    NSArray *imgArray = [xpathParser searchWithXPathQuery:@"//img"];
    for (TFHppleElement *elemnt in imgArray) {
        NSDictionary *dic = [elemnt attributes];
        NSString *src = [dic objectForKey:@"src"];
        if ([src hasPrefix:@"http://img.users.51"]) {
            continue;
        }
        if ([src hasPrefix:@"/upload/attach"]) {
            continue;
        }
        
        [imgURLArray addObject:src];
    }
}

@end
