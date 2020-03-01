//
//  ViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ViewController.h"
#import <TFHpple.h>
#import "MRBCroppingPictureManager.h"

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.inputTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
    [self.logTextView setFont:[NSFont fontWithName:@"PingFangSC-Regular" size:12.0f]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetCroppingPictureParams:) name:@"MRBDidSetCroppingPictureParams" object:nil];
}
- (void)viewDidAppear {
    [super viewDidAppear];
    
    [[AppDelegate defaultWindow] makeFirstResponder:self.inputTextView]; // 设置组件为第一响应
//    [self.inputTextView becomeFirstResponder]; // 这个方法不能使用
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MRBDidSetCroppingPictureParams" object:nil];
}

#pragma mark - IBAction
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

#pragma mark - Other
- (void)scrollLogTextViewToBottom {
    [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.string.length, 0)];
}
- (void)patchShortLinkNumbers {
    NSString *testString = [NSString stringWithContentsOfFile:@"/Users/Mercury/Downloads/test.txt" encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [testString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    //获取 tbody 标签
    NSString *result = @"";
    NSArray *tbodyArray = [xpathParser searchWithXPathQuery:@"//tbody"];
    TFHppleElement *element = (TFHppleElement *)tbodyArray.firstObject;
    for (NSInteger i = 0; i < element.children.count; i++) {
        TFHppleElement *childElement = (TFHppleElement *)element.children[i];
        for (NSInteger j = 0; j < childElement.children.count; j++) {
            TFHppleElement *rowElement = (TFHppleElement *)childElement.children[j];
            TFHppleElement *subElement = (TFHppleElement *)rowElement.children[0];
            if (subElement.isTextNode) {
                result = [result stringByAppendingFormat:@"%@\t", subElement.content];
            } else {
                result = [result stringByAppendingFormat:@"%@\t", subElement.attributes[@"title"]];
            }
        }
        
        result = [result substringToIndex:result.length - 1]; // 去掉最后一个 \t
        result = [result stringByAppendingString:@"\n"];
    }
    
    result = [result substringToIndex:result.length - 1]; // 去掉最后一个 \n
    
    [result writeToFile:@"/Users/Mercury/Downloads/testResult.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - MRBCroppingPicture
- (void)didSetCroppingPictureParams:(NSNotification *)notification {
    NSArray *data = (NSArray *)notification.object;
    MRBCroppingPictureManager *manager = [MRBCroppingPictureManager managerWithEdgeInsets:data[0] mode:[data[1] integerValue] paths:data[2]];
    
    [manager prepareCropping];
}

@end
