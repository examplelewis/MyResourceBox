//
//  MRBSitesImageUrlFetchWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageUrlFetchWindowController.h"
#import "MRBSitesImageUrlFetchViewController.h"

@interface MRBSitesImageUrlFetchWindowController ()

@property (strong) IBOutlet NSView *mainView;

@end

@implementation MRBSitesImageUrlFetchWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    MRBSitesImageUrlFetchViewController *vc = [[MRBSitesImageUrlFetchViewController alloc] initWithNibName:@"MRBSitesImageUrlFetchViewController" bundle:nil];
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
