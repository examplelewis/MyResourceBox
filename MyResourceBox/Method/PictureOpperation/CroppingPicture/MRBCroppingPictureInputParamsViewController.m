//
//  MRBCroppingPictureInputParamsViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/01.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBCroppingPictureInputParamsViewController.h"
#import "MRBCroppingPictureHeader.h"
#import "NSString+MRBString.h"
#import "MRBCroppingPictureInputParamsWindowController.h"

@interface MRBCroppingPictureInputParamsViewController () <NSTextFieldDelegate> {
    MRBCroppingPictureEdgeInsets *edgeInsets;
    NSInteger selectedMode; // 0 为未选择；1 为文件；2 为文件夹
    NSArray *selectedPaths;
}

@property (strong) IBOutlet NSButton *topEnableCheckBox;
@property (strong) IBOutlet NSButton *leftEnableCheckBox;
@property (strong) IBOutlet NSButton *bottomEnableCheckBox;
@property (strong) IBOutlet NSButton *rightEnableCheckBox;

@property (strong) IBOutlet NSButton *topUnitCheckBox;
@property (strong) IBOutlet NSButton *leftUnitCheckBox;
@property (strong) IBOutlet NSButton *bottomUnitCheckBox;
@property (strong) IBOutlet NSButton *rightUnitCheckBox;

@property (strong) IBOutlet NSTextField *topInputTextField;
@property (strong) IBOutlet NSTextField *leftInputTextField;
@property (strong) IBOutlet NSTextField *bottomInputTextField;
@property (strong) IBOutlet NSTextField *rightInputTextField;

@property (strong) IBOutlet NSTextField *topDescLabel;
@property (strong) IBOutlet NSTextField *bottomDescLabel;
@property (strong) IBOutlet NSTextField *leftDescLabel;
@property (strong) IBOutlet NSTextField *rightDescLabel;

@property (strong) IBOutlet NSTextView *filePathTextView;

@property (strong) IBOutlet NSButton *confirmButton;

@end

@implementation MRBCroppingPictureInputParamsViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUIAndData];
}
- (void)dealloc {
    [self.topEnableCheckBox removeObserver:self forKeyPath:@"state"];
    [self.leftEnableCheckBox removeObserver:self forKeyPath:@"state"];
    [self.bottomEnableCheckBox removeObserver:self forKeyPath:@"state"];
    [self.rightEnableCheckBox removeObserver:self forKeyPath:@"state"];
    [self.topUnitCheckBox removeObserver:self forKeyPath:@"state"];
    [self.leftUnitCheckBox removeObserver:self forKeyPath:@"state"];
    [self.bottomUnitCheckBox removeObserver:self forKeyPath:@"state"];
    [self.rightUnitCheckBox removeObserver:self forKeyPath:@"state"];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    selectedMode = 0;
    selectedPaths = @[];
    edgeInsets = [MRBCroppingPictureEdgeInsets generatedEdgeInsets];
    
    // UI
    [self.topEnableCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.leftEnableCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.bottomEnableCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.rightEnableCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.topUnitCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.leftUnitCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.bottomUnitCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    [self.rightUnitCheckBox addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)resetupCroppingUIAndData:(NSInteger)tag {
    MRBCroppingPictureEdgeUnit *edgeUnit;
    NSTextField *label;
    NSString *direction;
    NSButton *enableCheckBox;
    NSButton *unitCheckBox;
    NSTextField *textField;
    
    switch (tag % 10) {
        case 1: {
            edgeUnit = edgeInsets.top;
            label = self.topDescLabel;
            direction = @"上：";
            enableCheckBox = self.topEnableCheckBox;
            unitCheckBox = self.topUnitCheckBox;
            textField = self.topInputTextField;
        }
            break;
        case 2: {
            edgeUnit = edgeInsets.left;
            label = self.leftDescLabel;
            direction = @"左：";
            enableCheckBox = self.leftEnableCheckBox;
            unitCheckBox = self.leftUnitCheckBox;
            textField = self.leftInputTextField;
        }
            break;
        case 3: {
            edgeUnit = edgeInsets.bottom;
            label = self.bottomDescLabel;
            direction = @"下：";
            enableCheckBox = self.bottomEnableCheckBox;
            unitCheckBox = self.bottomUnitCheckBox;
            textField = self.bottomInputTextField;
        }
            break;
        case 4: {
            edgeUnit = edgeInsets.right;
            label = self.rightDescLabel;
            direction = @"右：";
            enableCheckBox = self.rightEnableCheckBox;
            unitCheckBox = self.rightUnitCheckBox;
            textField = self.rightInputTextField;
        }
            break;
        default:
            break;
    }
    
    if (enableCheckBox.state == NSOnState && textField.stringValue.length == 0) {
        enableCheckBox.state = NSOffState;
    }
    
    if (enableCheckBox.state == NSOnState) {
        edgeUnit.enabled = YES;
        edgeUnit.value = textField.stringValue.floatValue;
        edgeUnit.unit = unitCheckBox.state == NSOnState ? 2 : 1;
        
        label.stringValue = [NSString stringWithFormat:@"%@%@ %@", direction, textField.stringValue, unitCheckBox.state == NSOnState ? @"像素" : @"%"];
        label.textColor = [NSColor labelColor];
    } else {
        edgeUnit.enabled = NO;
        edgeUnit.value = -1.0;
//        edgeUnit.unit = 1; // 不用改变 unit
        
        if (tag > 30) {
            label.stringValue = [NSString stringWithFormat:@"%@未启用", direction];
        } else {
            label.stringValue = @"只能输入数字和1个小数点";
        }
        label.textColor = [NSColor systemRedColor];
    }
    
    self.confirmButton.enabled = edgeInsets.hasCroppingParams && selectedMode != 0;
}

#pragma mark - NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
    NSTextField *textField = (NSTextField *)obj.object;
    NSButton *enableCheckBox;
    
    switch (textField.tag) {
        case 11: {
            enableCheckBox = self.topEnableCheckBox;
        }
            break;
        case 12: {
            enableCheckBox = self.leftEnableCheckBox;
        }
            break;
        case 13: {
            enableCheckBox = self.bottomEnableCheckBox;
        }
            break;
        case 14: {
            enableCheckBox = self.rightEnableCheckBox;
        }
            break;
        default:
            break;
    }
    
    NSCharacterSet *noDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    BOOL onlyNumberAnd1Dot = [textField.stringValue rangeOfCharacterFromSet:noDigitsSet].location == NSNotFound && [textField.stringValue countOfSubString:@"."] <= 1 && textField.stringValue.floatValue > 0; // textField.stringValue 只包含数字和小数点，且小数点的个数不超过1个，且 textField.stringValue 对应的数字大于0
    enableCheckBox.state = onlyNumberAnd1Dot ? NSOnState : NSOffState;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSButton class]] && [keyPath isEqualToString:@"state"]) {
        NSButton *checkbox = (NSButton *)object;
        if (checkbox.tag < 30 && checkbox.tag > 20) {
            [self dealWithUnitCheckboxStateChanged:checkbox];
        } else if (checkbox.tag < 40 && checkbox.tag > 30) {
            [self resetupCroppingUIAndData:checkbox.tag];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)dealWithUnitCheckboxStateChanged:(NSButton *)sender {
    MRBCroppingPictureEdgeUnit *edgeUnit;
    NSTextField *label;
    
    switch (sender.tag) {
        case 21: {
            edgeUnit = edgeInsets.top;
            label = self.topDescLabel;
        }
            break;
        case 22: {
            edgeUnit = edgeInsets.left;
            label = self.leftDescLabel;
        }
            break;
        case 23: {
            edgeUnit = edgeInsets.bottom;
            label = self.bottomDescLabel;
        }
            break;
        case 24: {
            edgeUnit = edgeInsets.right;
            label = self.rightDescLabel;
        }
            break;
        default:
            break;
    }
    
    if (!edgeUnit.enabled) {
        return;
    }
    
    if (sender.state == NSOnState) {
        edgeUnit.unit = 2;
        
        label.stringValue = [label.stringValue stringByReplacingOccurrencesOfString:@"%" withString:@"像素"];
    } else {
        edgeUnit.unit = 1;
        
        label.stringValue = [label.stringValue stringByReplacingOccurrencesOfString:@"像素" withString:@"%"];
    }
}

#pragma mark - FilePath
- (void)saveSelectedPath:(NSArray *)paths mode:(NSInteger)mode {
    selectedMode = mode;
    selectedPaths = [paths copy];
    
    self.filePathTextView.string = [selectedPaths componentsJoinedByString:@"\n"];
    
    self.confirmButton.enabled = edgeInsets.hasCroppingParams && selectedMode != 0;
}

#pragma mark - IBActions
- (IBAction)checkboxDidPressed:(NSButton *)sender {
    [sender willChangeValueForKey:@"state"];
    [sender didChangeValueForKey:@"state"];
}
- (IBAction)selectFiles:(NSButton *)sender {
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
                [self saveSelectedPath:[[MRBFileManager defaultManager] convertFileURLsArrayToFilePathsArray:panel.URLs] mode:1];
            });
        }
    }];
}
- (IBAction)selectFolders:(NSButton *)sender {
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
                [self saveSelectedPath:[[MRBFileManager defaultManager] convertFileURLsArrayToFilePathsArray:panel.URLs] mode:2];
            });
        }
    }];
}
- (IBAction)confirmCropping:(NSButton *)sender {
    NSArray *data = @[edgeInsets, @(selectedMode), selectedPaths];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MRBDidSetCroppingPictureParams" object:data];
    
    [[NSApplication sharedApplication] stopModal];
}
- (IBAction)cancelCropping:(NSButton *)sender {
    [[NSApplication sharedApplication] stopModal];
}

@end
