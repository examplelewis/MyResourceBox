//
//  ViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.inputTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
    [self.logTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
}
- (void)viewDidAppear {
    [super viewDidAppear];
    
    [[AppDelegate defaultWindow] makeFirstResponder:self.inputTextView]; // 设置组件为第一响应
//    [self.inputTextView becomeFirstResponder]; // 这个方法不能使用
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)scrollLogTextViewToBottom {
    [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.string.length, 0)];
}

#pragma mark -- 控件方法 --
- (IBAction)processingExportInput:(NSButton *)sender {
    NSString *input = self.inputTextView.string;
    if (input.length > 0) {
        [MRBUtilityManager exportString:input atPath:@"/Users/Mercury/Downloads/Input.txt"];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有可导出的输入"];
    }
}
- (IBAction)cleanLog:(NSButton *)sender {
    self.logTextView.string = @"";
}
- (IBAction)processingTemp:(NSButton *)sender {
    [[MRBLogManager defaultManager] showLogWithTitle:@"临时方法执行失败" andFormat:@"该方法没有实现"];

//    NSString *content = self.inputTextView.string;
//    NSString *content = [NSString stringWithContentsOfFile:@"" encoding:NSUTF8StringEncoding error:nil];
//    NSArray *components = [content componentsSeparatedByString:@"\n"];
//    NSMutableArray *result = [NSMutableArray array];
//    for (NSString *string in components) {
//
//    }
//    self.outputTextView.string = [MRBUtilityManager convertResultArray:result];
}

@end
