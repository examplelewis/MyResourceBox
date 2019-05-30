//
//  BCYHTMLParseManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "BCYHTMLParseManager.h"
#import "BCYHeader.h"

@implementation BCYHTMLParseManager

+ (void)startParsing {
    NSString *inputString = [AppDelegate defaultVC].inputTextView.string;
    if (inputString.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何数据，请检查输入框"];
        return;
    }
    
    NSData *data = [inputString dataUsingEncoding:NSUTF8StringEncoding];
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
    [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到%ld条数据", newImageUrls.count];
    [MRBUtilityManager exportArray:newImageUrls atPath:BCYImageUrlsPath];
    [@{title:newImageUrls} writeToFile:BCYRenameInfoPath atomically:YES]; //RenameDict
    [[MRBLogManager defaultManager] showLogWithFormat:@"整个流程已经结束，如有需要，请从上方的结果框中查看记录"];
}

@end
