//
//  MyAlert.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/01.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MyAlert.h"

@interface MyAlert () {
    NSAlert *alert;
    NSMutableArray *titles;
}

@end

@implementation MyAlert

- (instancetype)initWithAlertStyle:(NSAlertStyle)style {
    self = [super init];
    if (self) {
        titles = [NSMutableArray array];
        alert = [[NSAlert alloc] init];
        [alert setAlertStyle:style];
    }
    
    return self;
}

- (void)setMessage:(NSString *)message infomation:(NSString *)info {
    NSAssert(message, @"message参数不能为空");
    
    [alert setMessageText:message];
    if (info && info.length > 0) {
        [alert setInformativeText:info];
    }
}

- (void)setButtonTitle:(NSString *)title keyEquivalent:(NSString *)keyEquivalent {
    NSAssert(title, @"title参数不能为空");
    
    [titles addObject:title];
    [alert addButtonWithTitle:title];
    if (keyEquivalent && keyEquivalent.length > 0) {
        NSInteger buttonIndex = [titles indexOfObject:title];
        [[alert buttons][buttonIndex] setKeyEquivalent:keyEquivalent];
    }
}

- (void)showAlertAtMainWindowWithCompletionHandler:(void (^)(NSModalResponse returnCode))handler {
    [self showAlertForWindow:[NSApplication sharedApplication].keyWindow completionHandler:handler];
}
- (void)showAlertForWindow:(NSWindow *)window completionHandler:(void (^)(NSModalResponse returnCode))handler {
    [alert beginSheetModalForWindow:window completionHandler:handler];
}
- (NSModalResponse)runModel {
    return [alert runModal];
}

@end
