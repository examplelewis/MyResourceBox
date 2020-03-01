//
//  MRBCroppingPictureCustomViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/02.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureCustomViewController.h"

@interface MRBCroppingPictureCustomViewController ()

@property (assign) NSInteger buttonTag;
@property (strong) IBOutlet NSButton *sourceCheckBox;

@end

@implementation MRBCroppingPictureCustomViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - IBAction
- (IBAction)weiboWaterprintCustomOperation:(NSButton *)sender {
    self.buttonTag = sender.tag;
    
    if (self.sourceCheckBox.state == NSOffState) {
        [self selectFolders];
    } else {
        [self selectFiles];
    }
}

- (void)selectFiles {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择图片"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = NO;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = YES;
    panel.allowedFileTypes = @[@"jpg", @"jpeg", @"png"];
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self confirmCroppingWithSelectedPath:[[MRBFileManager defaultManager] convertFileURLsArrayToFilePathsArray:panel.URLs] mode:1];
            });
        }
    }];
}
- (void)selectFolders {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择根文件夹"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = YES;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self confirmCroppingWithSelectedPath:[[MRBFileManager defaultManager] convertFileURLsArrayToFilePathsArray:panel.URLs] mode:2];
            });
        }
    }];
}

- (void)confirmCroppingWithSelectedPath:(NSArray *)paths mode:(NSInteger)mode {
    NSArray *data = @[@(self.buttonTag), @(mode), paths];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MRBDidSetCroppingPictureCustomParams" object:data];
    
    [[NSApplication sharedApplication] stopModal];
}

@end
