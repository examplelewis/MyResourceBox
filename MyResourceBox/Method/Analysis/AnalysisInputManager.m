//
//  AnalysisInputManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/05.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "AnalysisInputManager.h"
#import "BCYMethod.h"
#import "ExHentaiManager.h"
//#import "LofterMethod.h"
#import "JDLingyuMethod.h"
#import "PixivMethod.h"
//#import "WNACGMethod.h"
#import "WorldCosplayMethod.h"

@implementation AnalysisInputManager

+ (void)startAnalysising {
    NSString *inputString = [AppDelegate defaultVC].inputTextView.string;
    
    if ([inputString containsString:@"bcy."]) {
        [BCYMethod configMethod:1];
    } else if ([inputString containsString:@"exhentai."]) {
        [[ExHentaiManager defaultManager] configMethod:1];
    } else if ([inputString containsString:@"lofter."]) {
        //        [[LofterMethod defaultMethod] configMethod:2];
    } else if ([inputString containsString:@"jdlingyu."]) {
        [JDLingyuMethod configMethod:1];
    } else if ([inputString containsString:@"pixiv."]) {
        if ([inputString containsString:@"member.php?id="] || [inputString containsString:@"member_illust.php?id="]) {
            [PixivMethod configMethod:1];
        } else if ([inputString containsString:@"illust_id"]) {
            [PixivMethod configMethod:2];
        } else {
            [PixivMethod configMethod:3];
        }
    } else if ([inputString containsString:@"wnacg."]) {
        //        [[WNACGMethod defaultMethod] configMethod:1];
    } else if ([inputString containsString:@"worldcosplay."]) {
        [WorldCosplayMethod configMethod:2];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有解析到有用的地址，请检查输入框的内容"];
    }
}

@end
