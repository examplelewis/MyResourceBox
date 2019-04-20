//
//  WeiboRequestTokenWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/22.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WeiboRequestTokenWindowController.h"
#import "WeiboRequestTokenViewController.h"

@interface WeiboRequestTokenWindowController ()

@property (strong) IBOutlet NSView *mainView;

@end

@implementation WeiboRequestTokenWindowController

- (void)windowDidLoad {
    [super windowDidLoad];

    WeiboRequestTokenViewController *vc = [[WeiboRequestTokenViewController alloc] initWithNibName:@"WeiboRequestTokenViewController" bundle:nil];
    [self.mainView addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView.mas_top);
        make.bottom.equalTo(self.mainView.mas_bottom);
        make.leading.equalTo(self.mainView.mas_leading);
        make.trailing.equalTo(self.mainView.mas_trailing);
    }];
    
    
}

@end
