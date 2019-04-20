
//
//  WeiboTokenWindowController.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/06.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WeiboTokenWindowController.h"
#import "HttpRequest.h"

@interface WeiboTokenWindowController ()

@property (strong) IBOutlet NSTextView *tokenTextView;
@property (strong) IBOutlet NSTextView *limitTextView;

@end

@implementation WeiboTokenWindowController

@synthesize tokenTextView;
@synthesize limitTextView;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self getTokenInfo];
    [self getLimitInfo];
}

- (void)getTokenInfo {
    [[HttpRequest shareIndex] getWeiboTokenInfoWithStart:nil success:^(NSDictionary *dic) {
        self.tokenTextView.string = dic.description;
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到Token信息：%@", dic];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        self.tokenTextView.string = [NSString stringWithFormat:@"%@ - %@", errorTitle, errorMsg];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取Token信息发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}
- (void)getLimitInfo {
    [[HttpRequest shareIndex] getWeiboLimitInfoWithStart:nil success:^(NSDictionary *dic) {
        self.limitTextView.string = dic.description;
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到Token的Limit信息：%@", dic];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        self.tokenTextView.string = [NSString stringWithFormat:@"%@ - %@", errorTitle, errorMsg];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取Token的limit信息发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}

@end
