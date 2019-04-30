//
//  AnalysisMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "AnalysisMethod.h"

#import "BCYMethod.h"
#import "ExHentaiManager.h"
//#import "LofterMethod.h"
#import "JDLingyuMethod.h"
#import "PixivMethod.h"
//#import "WNACGMethod.h"
#import "WorldCosplayMethod.h"

@implementation AnalysisMethod

- (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1:
            [self analysisInput];
            break;
        case 2:
            [self analysisFile];
            break;
        default:
            break;
    }
}

// 解析输入的地址
- (void)analysisInput {
    NSString *inputString = [AppDelegate defaultVC].inputTextView.string;
    
    if ([inputString containsString:@"bcy."]) {
        [BCYMethod configMethod:1];
    } else if ([inputString containsString:@"exhentai."]) {
        [[ExHentaiManager defaultManager] configMethod:1];
    } else if ([inputString containsString:@"lofter."]) {
//        [[LofterMethod defaultMethod] configMethod:2];
    } else if ([inputString containsString:@"jdlingyu."]) {
        [[JDLingyuMethod defaultMethod] configMethod:1];
    } else if ([inputString containsString:@"pixiv."]) {
        if ([inputString containsString:@"member.php?id="] || [inputString containsString:@"member_illust.php?id="]) {
            [[PixivMethod defaultMethod] configMethod:1];
        } else if ([inputString containsString:@"illust_id"]) {
            [[PixivMethod defaultMethod] configMethod:2];
        } else {
            [[PixivMethod defaultMethod] configMethod:3];
        }
    } else if ([inputString containsString:@"wnacg."]) {
//        [[WNACGMethod defaultMethod] configMethod:1];
    } else if ([inputString containsString:@"worldcosplay."]) {
        [[WorldCosplayMethod defaultMethod] configMethod:2];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有解析到有用的地址，请检查输入框的内容"];
    }
}
// 解析文件中的地址
- (void)analysisFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:@"/Users/Mercury/Downloads/Safari 书签.html"]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"没有找到书签文件"];
        return;
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"已检测到书签文件，开始解析半次元的链接"];
    [BCYMethod configMethod:2];
}

@end
