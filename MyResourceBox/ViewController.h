//
//  ViewController.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, ProcessingType) {
    ProcessingTypeNotStart,
    ProcessingTypeStarted,
    ProcessingTypeDone
};

@interface ViewController : NSViewController

@property (strong) IBOutlet NSTextView *inputTextView;
@property (strong) IBOutlet NSTextView *logTextView;
@property (strong) IBOutlet NSTextField *numberLabel;
@property (strong) IBOutlet NSProgressIndicator *progress;

@end
