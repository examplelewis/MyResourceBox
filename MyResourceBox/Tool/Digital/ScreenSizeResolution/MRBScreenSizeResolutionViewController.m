//
//  MRBScreenSizeResolutionViewController.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/07.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBScreenSizeResolutionViewController.h"
#import "NSString+MRBString.h"

@interface MRBScreenSizeResolutionViewController ()

@property (strong) IBOutlet NSTextField *sizeScreenInput;
@property (strong) IBOutlet NSTextField *sizeRatioLeftInput;
@property (strong) IBOutlet NSTextField *sizeRatioRightInput;
@property (strong) IBOutlet NSTextView *sizeResultTextView;

@property (strong) IBOutlet NSTextField *ppiScreenInput;
@property (strong) IBOutlet NSTextField *ppiResolutionLeftInput;
@property (strong) IBOutlet NSTextField *ppiResolutionRightInput;
@property (strong) IBOutlet NSTextView *ppiResultTextView;

@end

@implementation MRBScreenSizeResolutionViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [[NSApplication sharedApplication] stopModalWithCode:self.response];
}

#pragma mark - IBAction
- (IBAction)calcSize:(NSButton *)sender {
    NSCharacterSet *noDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    BOOL screenInputValid = [_sizeScreenInput.stringValue rangeOfCharacterFromSet:noDigitsSet].location == NSNotFound && [_sizeScreenInput.stringValue countOfSubString:@"."] <= 1 && _sizeScreenInput.floatValue > 0; // 只包含数字和小数点，且小数点的个数不超过 1 个，且对应的数字大于 0
    if (!screenInputValid) {
        _sizeResultTextView.string = @"屏幕尺寸输入不合法：必须为大于 0 的小数";
        _sizeResultTextView.textColor = [NSColor systemRedColor];
        
        return;
    }
    
    BOOL leftInputValid = [_sizeRatioLeftInput.stringValue rangeOfCharacterFromSet:noDigitsSet].location == NSNotFound && [_sizeRatioLeftInput.stringValue countOfSubString:@"."] <= 1 && _sizeRatioLeftInput.floatValue > 0; // 只包含数字和小数点，且小数点的个数不超过 1 个，且对应的数字大于 0
    BOOL rightInputValid = [_sizeRatioRightInput.stringValue rangeOfCharacterFromSet:noDigitsSet].location == NSNotFound && [_sizeRatioRightInput.stringValue countOfSubString:@"."] <= 1 && _sizeRatioRightInput.floatValue > 0; // 只包含数字和小数点，且小数点的个数不超过 1 个，且对应的数字大于 0
    if (!leftInputValid || !rightInputValid) {
        _sizeResultTextView.string = @"屏幕比例输入不合法：必须为大于 0 的小数";
        _sizeResultTextView.textColor = [NSColor systemRedColor];
        
        return;
    }
    
    CGFloat size = _sizeScreenInput.floatValue;
    CGFloat ratioLeft = _sizeRatioLeftInput.floatValue;
    CGFloat ratioRight = _sizeRatioRightInput.floatValue;
    CGFloat hypotenuse = sqrt(ratioLeft * ratioLeft + ratioRight * ratioRight); // 斜边
    CGFloat largeInch = size * MAX(ratioLeft, ratioRight) / hypotenuse;
    CGFloat smallInch = size * MIN(ratioLeft, ratioRight) / hypotenuse;
    CGFloat largeCM = size * MAX(ratioLeft, ratioRight) / hypotenuse * 2.54;
    CGFloat smallCM = size * MIN(ratioLeft, ratioRight) / hypotenuse * 2.54;
    CGFloat largeMM = size * MAX(ratioLeft, ratioRight) / hypotenuse * 25.4;
    CGFloat smallMM = size * MIN(ratioLeft, ratioRight) / hypotenuse * 25.4;
    
    NSString *sizeDesc = [NSString stringWithFormat:@"尺寸：\t%@ 英寸", _sizeScreenInput.stringValue];
    NSString *ratioDesc = [NSString stringWithFormat:@"比例：\t%@ : %@", _sizeRatioLeftInput.stringValue, _sizeRatioRightInput.stringValue];
    NSString *inchHDesc = [NSString stringWithFormat:@"\t%.2f 英寸 × %.2f 英寸", largeInch, smallInch];
    NSString *cmHDesc = [NSString stringWithFormat:@"\t%.1f cm × %.1f cm", largeCM, smallCM];
    NSString *mmHDesc = [NSString stringWithFormat:@"\t%.0f mm × %.0f mm", largeMM, smallMM];
    NSString *inchVDesc = [NSString stringWithFormat:@"\t%.2f 英寸 × %.2f 英寸", smallInch, largeInch];
    NSString *cmVDesc = [NSString stringWithFormat:@"\t%.1f cm × %.1f cm", smallCM, largeCM];
    NSString *mmVDesc = [NSString stringWithFormat:@"\t%.0f mm × %.0f mm", smallMM, largeMM];
    _sizeResultTextView.string = [NSString stringWithFormat:@"%@\n%@\n横屏：\n%@\n%@\n%@\n竖屏：\n%@\n%@\n%@", sizeDesc, ratioDesc, inchHDesc, cmHDesc, mmHDesc,inchVDesc, cmVDesc, mmVDesc];
    _sizeResultTextView.textColor = [NSColor textColor];
}
- (IBAction)calcPPI:(NSButton *)sender {
    NSCharacterSet *noDigitsSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    BOOL screenInputValid = [_ppiScreenInput.stringValue rangeOfCharacterFromSet:noDigitsSet].location == NSNotFound && [_ppiScreenInput.stringValue countOfSubString:@"."] <= 1 && _ppiScreenInput.floatValue > 0; // 只包含数字和小数点，且小数点的个数不超过 1 个，且对应的数字大于 0
    if (!screenInputValid) {
        _ppiResultTextView.string = @"屏幕尺寸输入不合法：必须为大于 0 的小数";
        _ppiResultTextView.textColor = [NSColor systemRedColor];
        
        return;
    }
    
    NSCharacterSet *noNumbersSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    BOOL leftInputValid = [_ppiResolutionLeftInput.stringValue rangeOfCharacterFromSet:noNumbersSet].location == NSNotFound && _ppiResolutionLeftInput.integerValue > 0; // 只包含数字和小数点，且对应的数字大于 0
    BOOL rightInputValid = [_ppiResolutionRightInput.stringValue rangeOfCharacterFromSet:noNumbersSet].location == NSNotFound && _ppiResolutionRightInput.integerValue > 0; // 只包含数字和小数点，且对应的数字大于 0
    if (!leftInputValid || !rightInputValid) {
        _ppiResultTextView.string = @"屏幕分辨率输入不合法：必须为大于 0 的整数";
        _ppiResultTextView.textColor = [NSColor systemRedColor];
        
        return;
    }
    
    CGFloat size = _ppiScreenInput.floatValue;
    NSInteger resolutionLeft = _ppiResolutionLeftInput.integerValue;
    NSInteger resolutionRight = _ppiResolutionRightInput.integerValue;
    CGFloat hypotenuse = sqrt(resolutionLeft * resolutionLeft + resolutionRight * resolutionRight); // 斜边
    CGFloat ppi = hypotenuse / size * 1.0f;
    
    NSString *sizeDesc = [NSString stringWithFormat:@"尺寸：\t%@ 英寸", _ppiScreenInput.stringValue];
    NSString *resolutionDesc = [NSString stringWithFormat:@"分辨率：\t%@ × %@", _ppiResolutionLeftInput.stringValue, _ppiResolutionRightInput.stringValue];
    NSString *ppiDesc = [NSString stringWithFormat:@"PPI：\t%.2f", ppi];
    _ppiResultTextView.string = [NSString stringWithFormat:@"%@\n%@\n%@", sizeDesc, resolutionDesc, ppiDesc];
    _ppiResultTextView.textColor = [NSColor textColor];
}

@end
