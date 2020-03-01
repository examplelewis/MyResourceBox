//
//  PictureOperationMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "PictureOperationMethod.h"
#import "MRBCroppingPictureInputParamsWindowController.h"

@implementation PictureOperationMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            // 参考：https://www.raywenderlich.com/613-windows-and-windowcontroller-tutorial-for-macos  Modal Windows 章节
            MRBCroppingPictureInputParamsWindowController *wc = [[MRBCroppingPictureInputParamsWindowController alloc] initWithWindowNibName:@"MRBCroppingPictureInputParamsWindowController"];
            [[NSApplication sharedApplication] runModalForWindow:wc.window];
            [wc.window close];
                
            // runModal 类似于 PresentViewController 添加的是 ModalWindow 会覆盖当前的 Window
            // addChildWindow 类似于 addChildViewController 添加的是 ChildWindow 并不会覆盖当前的 Window
//            [[NSApplication sharedApplication].mainWindow addChildWindow:wc.window ordered:NSWindowAbove];
//            [wc becomeFirstResponder];
//            [wc showWindow:nil];
        }
            break;
        case 2: {
            
        }
            break;
        case 3: {
            
        }
            break;
        default:
            break;
    }
}

@end
