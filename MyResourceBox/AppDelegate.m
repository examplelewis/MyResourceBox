//
//  AppDelegate.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "AppDelegate.h"
#import "MRBFileManager.h"
#import "MRBHttpManager.h"

#import "AnalysisMethod.h"
#import "BCYMethod.h"
#import "ExHentaiManager.h"
#import "GelbooruMethod.h"
#import "JDLingyuMethod.h"
#import "PixivMethod.h"
#import "WeiboMethod.h"
#import "Rule34Method.h"
#import "WorldCosplayMethod.h"
#import "DeviantartMethod.h"

#import "FileOperationMethod.h"
#import "WebArchiveMethod.h"
#import "DownloadMethod.h"
#import "MRBSitesOrganization.h"
#import "ToolOperationMethod.h"
#import "PictureOperationMethod.h"
#import "MRBMediaOperationMethod.h"

#import "MRBDigital.h"
#import "MRBTemp.h"
#import "MRBResourceSites.h"

#import "MRBCatchCrashManager.h"
#import "ResourceOrganizeMethod.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSMenuItem *buildTimeItem;
@property (weak) IBOutlet NSMenuItem *buildVerItem;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 注册异常处理函数
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [[MRBUserManager defaultManager] configureData];
    
    [self setLogger];
    [self setBuildTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCode:) name:@"WeiboTokenDidGet" object:nil];
}
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self configureController];
    [self configureWindow];
}
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES; //点击窗口左上方的关闭按钮退出应用程序
}

#pragma mark - Configure
- (void)configureController {
    if (!_currentVC) {
        _currentVC = (ViewController *)[NSApplication sharedApplication].mainWindow.contentViewController;
    }
}
- (void)configureWindow {
    if (!_currentWindow) {
        _currentWindow = [NSApplication sharedApplication].mainWindow;
    }
}

#pragma mark - Instance
+ (AppDelegate *)defaultDelegate {
    return (AppDelegate *)[[NSApplication sharedApplication] delegate];
}
+ (ViewController *)defaultVC {
    __block AppDelegate *dele;
    dispatch_main_sync_safe(^() {
        dele = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    });
    
    [dele configureController];
    
    if (!dele.currentVC) {
        DDLogError(@"-----没有返回正确的contentViewController!-----");
        NSAssert(dele.currentVC, @"-----没有返回正确的contentViewController!-----");
        return nil;
    }
    
    return dele.currentVC;
}
+ (NSWindow *)defaultWindow {
    __block AppDelegate *dele;
    dispatch_main_sync_safe(^() {
        dele = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    });
    
    [dele configureWindow];
    
    if (!dele.currentWindow) {
        DDLogError(@"-----没有返回正确的window!-----");
        NSAssert(dele.currentWindow, @"-----没有返回正确的window!-----");
        return nil;
    }
    
    return dele.currentWindow;
}

#pragma mark - Target
// Resource
- (IBAction)processingAnalysis:(NSMenuItem *)sender {
    [AnalysisMethod configMethod:sender.tag];
}
- (IBAction)processingBCY:(NSMenuItem *)sender {
    [BCYMethod configMethod:sender.tag];
}
- (IBAction)processingExHentai:(NSMenuItem *)sender {
    [[ExHentaiManager defaultManager] configMethod:sender.tag];
}
- (IBAction)processingGelbooru:(NSMenuItem *)sender {
    [GelbooruMethod configMethod:sender.tag];
}
- (IBAction)processingJDLingyu:(NSMenuItem *)sender {
    [JDLingyuMethod configMethod:sender.tag];
}
- (IBAction)processingPixiv:(NSMenuItem *)sender {
    [PixivMethod configMethod:sender.tag];
}
- (IBAction)processingRule34:(NSMenuItem *)sender {
    [Rule34Method configMethod:sender.tag];
}
- (IBAction)processingWeibo:(NSMenuItem *)sender {
    [WeiboMethod configMethod:sender.tag];
}
- (IBAction)processingWorldCosplay:(NSMenuItem *)sender {
    [WorldCosplayMethod configMethod:sender.tag];
}
- (IBAction)processingTool:(NSMenuItem *)sender {
    [ToolOperationMethod configMethod:sender.tag];
}
- (IBAction)processingDownload:(NSMenuItem *)sender {
    [DownloadMethod configMethod:sender.tag];
}
- (IBAction)processingDeviantart:(NSMenuItem *)sender {
    [DeviantartMethod configMethod:sender.tag];
}
- (IBAction)processingSitesOrganization:(NSMenuItem *)sender {
    [MRBSitesOrganization configMethod:sender.tag];
}
- (IBAction)processingFileOperation:(NSMenuItem *)sender {
    [FileOperationMethod configMethod:sender.tag];
}
- (IBAction)processingResourceOrganize:(NSMenuItem *)sender {
    [ResourceOrganizeMethod configMethod:sender.tag];
}
- (IBAction)processingPictureOperation:(NSMenuItem *)sender {
    [PictureOperationMethod configMethod:sender.tag];
}
- (IBAction)processingDigital:(NSMenuItem *)sender {
    [MRBDigital configMethod:sender.tag];
}
- (IBAction)processingResourceSites:(NSMenuItem *)sender {
    [MRBResourceSites configMethod:sender.tag];
}
- (IBAction)processingTemp:(NSMenuItem *)sender {
    [MRBTemp configMethod:sender.tag];
}
- (IBAction)processingMediaOperation:(NSMenuItem *)sender {
    [MRBMediaOperationMethod configMethod:sender.tag];
}


#pragma mark - Help
- (IBAction)openHelpingDocument:(NSMenuItem *)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"帮助文档.txt"]]) {
        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开帮助文档文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"打开帮助文档时发生错误，打开失败"];
    }
}
- (IBAction)openLogFile:(NSMenuItem *)sender {
    NSString *logsFolder = [MRBUserManager defaultManager].path_root_folder;
    NSDate *latestCreationDate = [NSDate dateWithYear:2000 month:1 day:1]; //新建一个NSDate对象，用于判断并查找最新创建的日志文件
    
    NSArray *logsFile = [[MRBFileManager defaultManager] getFilePathsInFolder:logsFolder specificExtensions:@[@"log"]];
    NSString *latestFilePath = @"";
    for (NSString *filePath in logsFile) {
        NSDate *creationDate = [[MRBFileManager defaultManager] getSpecificAttributeOfItemAtPath:filePath attribute:NSFileCreationDate];
        if ([creationDate isLaterThan:latestCreationDate]) {
            latestCreationDate = creationDate;
            latestFilePath = filePath;
        }
    }
    
    if (![[NSWorkspace sharedWorkspace] openFile:latestFilePath]) {
        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开日志文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"打开日志文件时发生错误，打开失败"];
    }
}
- (IBAction)openAuthorizationFile:(NSMenuItem *)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"Authorization.plist"]]) {
        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开授权文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"打开授权文件时发生错误，打开失败"];
    }
}
- (IBAction)openPreferenceFile:(NSMenuItem *)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"Preference.plist"]]) {
        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开配置文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"打开配置文件时发生错误，打开失败"];
    }
}

#pragma mark - Notification
- (void)didGetCode:(NSNotification *)notif {
    for (NSWindow *window in [NSApplication sharedApplication].windows) {
        if (![window.windowController isMemberOfClass:[NSWindowController class]]) {
            [window close];
            
            break;
        }
    }
    
    [self processCode:(NSString *)[notif object]];
}

#pragma mark - Setter
- (void)setLogger {
    //在系统上保持一周的日志文件
    NSString *logDirectory = [MRBUserManager defaultManager].path_root_folder;
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logDirectory];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7; // 7 days rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    
    [DDLog addLogger:fileLogger];
    
#pragma mark RELEASE 的时候不需要添加 console 日志，只保留文件日志
#ifdef DEBUG
    NSLog(@"logDirectory: %@", logDirectory);
    
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [DDLog addLogger:ttyLogger]; // console 日志
#endif
}
- (void)setBuildTime {
    NSString *dateStr = [NSString stringWithUTF8String:__DATE__];
    NSString *timeStr = [NSString stringWithUTF8String:__TIME__];
    NSString *str = [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    df.dateFormat = @"MMM dd yyyy HH:mm:ss";
    
    NSDate *date = [df dateFromString:str];
    self.buildTimeItem.title = [date formattedDateWithFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.buildVerItem.title = [NSString stringWithFormat:@"%@ (%@)", version, build];
}

#pragma mark - Other
- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    [self processCode:[urlString componentsSeparatedByString:@"code="].lastObject];
}
- (void)processCode:(NSString *)code {
    [MRBUserManager defaultManager].weibo_code = code;
    [[MRBUserManager defaultManager] saveAuthDictIntoPlistFile];
    
    [[MRBHttpManager sharedManager] getWeiboTokenWithStart:nil success:^(NSDictionary *dic) {
        [MRBUserManager defaultManager].weibo_token = dic[@"access_token"];
        [MRBUserManager defaultManager].weibo_expires_at_date = [NSDate dateWithTimeIntervalSinceNow:[dic[@"expire_in"] integerValue]];
        [[MRBUserManager defaultManager] saveAuthDictIntoPlistFile];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"成功获取到Token信息：%@", dic];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取Token信息发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}

@end
