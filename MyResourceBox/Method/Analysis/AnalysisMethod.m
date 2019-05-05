//
//  AnalysisMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "AnalysisMethod.h"
#import "AnalysisInputManager.h"
#import "AnalysisFileManager.h"

@implementation AnalysisMethod

+ (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1: {
            [AnalysisInputManager startAnalysising];
        }
            break;
        case 2: {
            [AnalysisFileManager startAnalysising];
        }
            break;
        default:
            break;
    }
}

@end
