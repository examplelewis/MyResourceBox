//
//  WeiboRequestTokenViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/22.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WeiboRequestTokenViewController.h"
#import <WebKit/WebKit.h>
#import "WeiboRequestTokenWindowController.h"

@interface WeiboRequestTokenViewController () <WebFrameLoadDelegate>

@property (strong) IBOutlet WebView *requestWebView;

@end

@implementation WeiboRequestTokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.requestWebView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[UserInfo defaultUser].weibo_url]]];
    self.requestWebView.frameLoadDelegate = self;
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
//    NSLog(@"%@", sender.mainFrameURL);
    
    
}
- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame {
    NSString *code = [URL.absoluteString componentsSeparatedByString:@"code="].lastObject;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiboTokenDidGet" object:code];
}


@end
