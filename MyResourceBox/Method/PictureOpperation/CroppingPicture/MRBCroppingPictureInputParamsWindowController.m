//
//  MRBCroppingPictureInputParamsWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureInputParamsWindowController.h"
#import "MRBCroppingPictureInputParamsViewController.h"

@interface MRBCroppingPictureInputParamsWindowController ()

@property (strong) IBOutlet NSView *mainView;

@end

@implementation MRBCroppingPictureInputParamsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    MRBCroppingPictureInputParamsViewController *vc = [[MRBCroppingPictureInputParamsViewController alloc] initWithNibName:@"MRBCroppingPictureInputParamsViewController" bundle:nil];
    [self.mainView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView.mas_top);
        make.bottom.equalTo(self.mainView.mas_bottom);
        make.leading.equalTo(self.mainView.mas_leading);
        make.trailing.equalTo(self.mainView.mas_trailing);
    }];
}

@end
