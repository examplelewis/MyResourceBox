//
//  MRBShadowsocksXRuleViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBShadowsocksXRuleViewController.h"

@interface MRBShadowsocksXRuleViewController () {
    
}

@property (strong) IBOutlet NSTextView *inputATextView;
@property (strong) IBOutlet NSTextView *inputBTextView;
@property (strong) IBOutlet NSTextView *resultTextView;

@end

@implementation MRBShadowsocksXRuleViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewDidDisappear {
    [[NSApplication sharedApplication] stopModal];
}

#pragma mark - Combine
- (IBAction)combineButtonPressed:(NSButton *)sender {
    if (self.inputATextView.string.length == 0) {
        self.resultTextView.string = @"请在左侧输入框复制规则";
        return;
    }
    
    if (self.inputBTextView.string.length == 0) {
        self.resultTextView.string = @"请在中间输入框复制规则";
        return;
    }
    
    [self startCombining];
}
- (void)startCombining {
    NSArray *inputAArray = [self.inputATextView.string componentsSeparatedByString:@"\n"];
    NSArray *inputBArray = [self.inputBTextView.string componentsSeparatedByString:@"\n"];
    NSArray *inputArray = [inputAArray arrayByAddingObjectsFromArray:inputBArray];
    
    NSPredicate *neededP = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH '||'"];
    NSPredicate *tempUnneededP = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH '! ||'"];
    NSPredicate *unneededP = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH '@@'"];
    
    NSArray *neededArray = [inputArray filteredArrayUsingPredicate:neededP];
    NSArray *tempUnneededArray = [inputArray filteredArrayUsingPredicate:tempUnneededP];
    NSArray *unneededArray = [inputArray filteredArrayUsingPredicate:unneededP];
    
    NSOrderedSet *neededOSet = [NSOrderedSet orderedSetWithArray:neededArray];
    NSOrderedSet *tempUnneededOSet = [NSOrderedSet orderedSetWithArray:tempUnneededArray];
    NSOrderedSet *unneededOSet = [NSOrderedSet orderedSetWithArray:unneededArray];
    
    neededArray = neededOSet.array;
    tempUnneededArray = tempUnneededOSet.array;
    unneededArray = unneededOSet.array;
    
    self.resultTextView.string = [NSString stringWithFormat:@"! Put user rules line by line in this file.\n! See https://adblockplus.org/en/filter-cheatsheet\n\n! 下面是【需要代理】的内容\n%@\n\n! 下面是【暂时不需要代理】的内容\n%@\n\n! 下面是【不需要代理】的内容\n%@", [neededArray componentsJoinedByString:@"\n"], [tempUnneededArray componentsJoinedByString:@"\n"], [unneededArray componentsJoinedByString:@"\n"]];
}

@end
