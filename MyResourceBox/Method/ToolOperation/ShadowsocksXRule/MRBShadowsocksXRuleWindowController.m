//
//  MRBShadowsocksXRuleWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBShadowsocksXRuleWindowController.h"
#import "MRBShadowsocksXRuleViewController.h"

@interface MRBShadowsocksXRuleWindowController ()

@property (strong) IBOutlet NSView *mainView;

@end

@implementation MRBShadowsocksXRuleWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    MRBShadowsocksXRuleViewController *vc = [[MRBShadowsocksXRuleViewController alloc] initWithNibName:@"MRBShadowsocksXRuleViewController" bundle:nil];
    [self.mainView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView.mas_top);
        make.bottom.equalTo(self.mainView.mas_bottom);
        make.leading.equalTo(self.mainView.mas_leading);
        make.trailing.equalTo(self.mainView.mas_trailing);
    }];
}

@end
