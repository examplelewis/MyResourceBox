//
//  MRBScreenSizeResolutionWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/07.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBScreenSizeResolutionWindowController.h"
#import "MRBScreenSizeResolutionViewController.h"

@interface MRBScreenSizeResolutionWindowController ()

@property (strong) IBOutlet NSView *mainView;

@end

@implementation MRBScreenSizeResolutionWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    MRBScreenSizeResolutionViewController *vc = [[MRBScreenSizeResolutionViewController alloc] initWithNibName:@"MRBScreenSizeResolutionViewController" bundle:nil];
    vc.response = self.response;
    [self.mainView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView.mas_top);
        make.bottom.equalTo(self.mainView.mas_bottom);
        make.leading.equalTo(self.mainView.mas_leading);
        make.trailing.equalTo(self.mainView.mas_trailing);
    }];
}

@end
