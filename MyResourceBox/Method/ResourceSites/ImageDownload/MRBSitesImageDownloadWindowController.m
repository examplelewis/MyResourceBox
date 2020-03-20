//
//  MRBSitesImageDownloadWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageDownloadWindowController.h"
#import "MRBSitesImageDownloadViewController.h"

@interface MRBSitesImageDownloadWindowController ()

@property (strong) IBOutlet NSView *mainView;

@end

@implementation MRBSitesImageDownloadWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    MRBSitesImageDownloadViewController *vc = [[MRBSitesImageDownloadViewController alloc] initWithNibName:@"MRBSitesImageDownloadViewController" bundle:nil];
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
