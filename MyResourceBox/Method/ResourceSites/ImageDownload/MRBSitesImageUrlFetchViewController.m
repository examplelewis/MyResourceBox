//
//  MRBSitesImageUrlFetchViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesImageUrlFetchViewController.h"
#import "MRBHttpManager.h"
#import "MRBSitesImageUrlFetchModel.h"
#import <DateTools.h>

@interface MRBSitesImageUrlFetchViewController () {
    NSInteger selectedRadioButtonTag;
    NSArray *siteUrls;
    
    NSInteger inputStart;
    NSInteger inputEnd;
    NSDate *inputStartDate;
    NSDate *inputEndDate;
}

@property (strong) IBOutlet NSPopUpButton *sitesPopupButton;
@property (strong) IBOutlet NSTextField *keywordTextField;
@property (strong) IBOutlet NSTextField *filterLabel;
@property (strong) IBOutlet NSTextField *filterStartLabel;
@property (strong) IBOutlet NSTextField *filterEndLabel;
@property (strong) IBOutlet NSTextField *filterStartTextField;
@property (strong) IBOutlet NSTextField *filterEndTextField;
@property (strong) IBOutlet NSDatePicker *filterStartDatePicker;
@property (strong) IBOutlet NSDatePicker *filterEndDatePicker;
@property (strong) IBOutlet NSTextField *errorLabel;

@end

@implementation MRBSitesImageUrlFetchViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUIAndData];
}
- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [[NSApplication sharedApplication] stopModalWithCode:self.response];
}

#pragma mark - Configure
- (void)setUIAndData {
    selectedRadioButtonTag = 10;
    siteUrls = @[@"https://gelbooru.com/index.php?page=dapi&s=post&q=index", @"https://rule34.xxx/index.php?page=dapi&s=post&q=index"];
}

#pragma mark - Radio Buttons
- (IBAction)radioButtonPressed:(NSButton *)sender {
    selectedRadioButtonTag = sender.tag;
    
    self.filterLabel.hidden = sender.tag == 10;
    self.filterStartLabel.hidden = sender.tag == 10;
    self.filterEndLabel.hidden = sender.tag == 10;
    self.filterStartTextField.hidden = sender.tag != 11 && sender.tag != 13;
    self.filterEndTextField.hidden = sender.tag != 11 && sender.tag != 13;
    self.filterStartDatePicker.hidden = sender.tag != 12;
    self.filterEndDatePicker.hidden = sender.tag != 12;
    
    self.filterLabel.stringValue = sender.tag == 13 ? @"请输入筛选条件(页码从1开始)" : @"请输入筛选条件";
    
    NSString *unitDesc = @"";
    switch (sender.tag) {
        case 11: {
            unitDesc = @"ID";
        }
            break;
        case 12: {
            unitDesc = @"日期";
        }
            break;
        case 13: {
            unitDesc = @"页码";
        }
            break;
        default:
            break;
    }
    self.filterStartLabel.stringValue = [NSString stringWithFormat:@"起始%@", unitDesc];
    self.filterEndLabel.stringValue = [NSString stringWithFormat:@"终止%@", unitDesc];
}

#pragma mark - IBAction
- (IBAction)fetchButtonPressed:(NSButton *)sender {
    self.errorLabel.hidden = YES;
    
    if (self.keywordTextField.stringValue.length == 0) {
        self.errorLabel.hidden = NO;
        self.errorLabel.stringValue = @"请输入关键字";
        return;
    }
    
    if (selectedRadioButtonTag == 11) {
        // ID默认从1开始，截止到100000000
        if (self.filterStartTextField.stringValue.length == 0) {
            self.filterStartTextField.stringValue = @"1";
        }
        if (self.filterEndTextField.stringValue.length == 0) {
            self.filterEndTextField.stringValue = @"100000000";
        }
    }
    if (selectedRadioButtonTag == 13) {
        // 页码默认从第1页开始，截止到第200页
        if (self.filterStartTextField.stringValue.length == 0) {
            self.filterStartTextField.stringValue = @"1";
        }
        if (self.filterEndTextField.stringValue.length == 0) {
            self.filterEndTextField.stringValue = @"200";
        }
    }
    
    if (selectedRadioButtonTag == 11 || selectedRadioButtonTag == 13) {
        NSCharacterSet *noNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if (self.filterStartTextField.stringValue.length > 0 && [self.filterStartTextField.stringValue rangeOfCharacterFromSet:noNumberSet].location != NSNotFound) {
            self.errorLabel.hidden = NO;
            self.errorLabel.stringValue = @"起始条件需要输入数字";
            return;
        }
        if (self.filterEndTextField.stringValue.length > 0 && [self.filterEndTextField.stringValue rangeOfCharacterFromSet:noNumberSet].location != NSNotFound) {
            self.errorLabel.hidden = NO;
            self.errorLabel.stringValue = @"终止条件需要输入数字";
            return;
        }
    }
    
    inputStart = self.filterStartTextField.integerValue;
    inputEnd = self.filterEndTextField.integerValue;
    inputStartDate = self.filterStartDatePicker.dateValue;
    inputEndDate = self.filterEndDatePicker.dateValue;
    
    if ((selectedRadioButtonTag == 11 || selectedRadioButtonTag == 13) && inputEnd <= inputStart) {
        self.errorLabel.hidden = NO;
        self.errorLabel.stringValue = @"终止数字必须大于起始数字";
        return;
    }
    if (selectedRadioButtonTag == 12 && [inputEndDate isEarlierThanOrEqualTo:inputStartDate]) {
        self.errorLabel.hidden = NO;
        self.errorLabel.stringValue = @"终止时间必须晚于起始时间";
        return;
    }
    
    MRBSitesImageUrlFetchModel *model = [[MRBSitesImageUrlFetchModel alloc] initWithMode:selectedRadioButtonTag
                                                                                     url:siteUrls[self.sitesPopupButton.indexOfSelectedItem]
                                                                                 keyword:self.keywordTextField.stringValue
                                                                              inputStart:inputStart
                                                                                inputEnd:inputEnd
                                                                          inputStartDate:inputStartDate
                                                                            inputEndDate:inputEndDate];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MRBWillStartFetchSiteTagResource" object:model];
    
//    [[NSApplication sharedApplication] stopModalWithCode:self.response];
}

@end
