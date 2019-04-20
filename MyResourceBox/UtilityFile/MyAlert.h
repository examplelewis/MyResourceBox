//
//  MyAlert.h
//  MyComicView
//
//  Created by 龚宇 on 16/08/01.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

static NSString * const MyAlertKeyEquivalentReturnKey = @"\r";
static NSString * const MyAlertKeyEquivalentEscapeKey = @"\033";

@interface MyAlert : NSObject

- (instancetype)initWithAlertStyle:(NSAlertStyle)style;
- (void)setMessage:(NSString *)message infomation:(NSString *)info;
- (void)setButtonTitle:(NSString *)title keyEquivalent:(NSString *)keyEquivalent;

- (void)showAlertAtMainWindowWithCompletionHandler:(void (^)(NSModalResponse returnCode))handler;
- (void)showAlertForWindow:(NSWindow *)window completionHandler:(void (^)(NSModalResponse returnCode))handler;
- (NSModalResponse)runModel;

@end
