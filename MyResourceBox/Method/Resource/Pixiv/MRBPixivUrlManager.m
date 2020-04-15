//
//  MRBPixivUrlManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/14.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBPixivUrlManager.h"

@implementation MRBPixivUrlManager

- (void)start {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择图片文件"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = NO;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = YES;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *fileNames = [panel.URLs valueForKeyPath:@"absoluteString.lastPathComponent"];
            NSMutableArray *urls = [NSMutableArray array];
            
            for (NSInteger i = 0; i < fileNames.count; i++) {
                NSString *fileName = fileNames[i];
                NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d+" options:0 error:nil];
                NSArray *matches = [regex matchesInString:fileName options:0 range:NSMakeRange(0, fileName.length)];
                
                for (NSTextCheckingResult *match in matches) {
                    NSString *strNumber = [fileName substringWithRange:match.range];
                    if (strNumber.length == 8 || strNumber.length == 9) {
                        [urls addObject:[NSString stringWithFormat:@"https://www.pixiv.net/artworks/%@", strNumber]];
                    }
                }
            }
            
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取到的图片地址如下：\n%@", [MRBUtilityManager convertResultArray:urls]];
        }
    }];
}

@end
