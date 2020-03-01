//
//  MRBCroppingPictureCustomWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/02.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureCustomWindowController.h"
#import "MRBCroppingPictureCustomViewController.h"

@interface MRBCroppingPictureCustomWindowController ()

@property (strong) IBOutlet NSView *mainView;

@end

@implementation MRBCroppingPictureCustomWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    MRBCroppingPictureCustomViewController *vc = [[MRBCroppingPictureCustomViewController alloc] initWithNibName:@"MRBCroppingPictureCustomViewController" bundle:nil];
    [self.mainView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView.mas_top);
        make.bottom.equalTo(self.mainView.mas_bottom);
        make.leading.equalTo(self.mainView.mas_leading);
        make.trailing.equalTo(self.mainView.mas_trailing);
    }];
}

@end
