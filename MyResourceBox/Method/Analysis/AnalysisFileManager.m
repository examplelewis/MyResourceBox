//
//  AnalysisFileManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/05.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "AnalysisFileManager.h"
#import "BCYMethod.h"

@implementation AnalysisFileManager

+ (void)startAnalysising {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:@"/Users/Mercury/Downloads/Safari 书签.html"]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有找到书签文件"];
        return;
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"已检测到书签文件，开始解析半次元的链接"];
    [BCYMethod configMethod:2];
}

@end
