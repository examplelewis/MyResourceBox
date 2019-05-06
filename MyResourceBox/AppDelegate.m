//
//  AppDelegate.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/16.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "AppDelegate.h"
#import "FileManager.h"
#import <TMAPIClient.h>
#import "HttpManager.h"

#import "AnalysisMethod.h"
#import "BCYMethod.h"
#import "ExHentaiManager.h"
#import "GelbooruMethod.h"
//#import "LofterMethod.h"
#import "JDLingyuMethod.h"
#import "PixivMethod.h"
#import "TumblrMethod.h"
#import "WeiboMethod.h"
//#import "WNACGMethod.h"
#import "WorldCosplayMethod.h"
#import "DeviantartMethod.h"

#import "OrganizingDayFolder.h"
#import "WebArchiveMethod.h"
#import "DownloadMethod.h"
#import "FileTools.h"
#import "Images2Mp4.h"
#import "OrganizingPhotos.h"

#import "CatchCrashManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSMenuItem *buildTimeItem;
@property (weak) IBOutlet NSMenuItem *buildVerItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 注册异常处理函数
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [[UserInfo defaultUser] configureData];
    
    [self setLogger];
    [self setBuildTime];
    [self setTumblr];
    
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

+ (AppDelegate *)defaultDelegate {
    return (AppDelegate *)[[NSApplication sharedApplication] delegate];
}
+ (ViewController *)defaultVC {
    AppDelegate *dele = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [dele configureController];
    
    if (!dele.currentVC) {
        DDLogError(@"-----没有返回正确的contentViewController!-----");
        NSAssert(dele.currentVC, @"-----没有返回正确的contentViewController!-----");
        return nil;
    }
    
    return dele.currentVC;
}
+ (NSWindow *)defaultWindow {
    AppDelegate *dele = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [dele configureWindow];
    
    if (!dele.currentWindow) {
        DDLogError(@"-----没有返回正确的window!-----");
        NSAssert(dele.currentWindow, @"-----没有返回正确的window!-----");
        return nil;
    }
    
    return dele.currentWindow;
}

#pragma mark -- action --
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
- (IBAction)processingLofter:(NSMenuItem *)sender {
//    [[LofterMethod defaultMethod] configMethod:sender.tag];
}
- (IBAction)processingJDLingyu:(NSMenuItem *)sender {
    [[JDLingyuMethod defaultMethod] configMethod:sender.tag];
}
- (IBAction)processingPixiv:(NSMenuItem *)sender {
    [PixivMethod configMethod:sender.tag];
}
- (IBAction)processingTumblr:(NSMenuItem *)sender {
    [[TumblrMethod defaultMethod] configMethod:sender.tag];
}
- (IBAction)processingWeibo:(NSMenuItem *)sender {
    [[WeiboMethod defaultMethod] configMethod:sender.tag];
}
- (IBAction)processingWNACG:(NSMenuItem *)sender {
//    [[WNACGMethod defaultMethod] configMethod:sender.tag];
}
- (IBAction)processingWorldCosplay:(NSMenuItem *)sender {
    [WorldCosplayMethod configMethod:sender.tag];
}
- (IBAction)processingTool:(NSMenuItem *)sender {
    switch (sender.tag) {
        case 1: {
            [[OrganizingDayFolder defaultInstance] start];
        }
            break;
        case 2: {
            [[FileTools new] configMethod:1];
        }
            break;
        case 3: {
            [[OrganizingPhotos new] configMethod:1];
        }
            break;
        case 4: {
            [[OrganizingPhotos new] configMethod:2];
        }
            break;
        case 5: {
            [[FileTools new] configMethod:2];
        }
            break;
        case 11: {
            [WebArchiveMethod configMethod:1];
        }
            break;
        case 12: {
            [UtilityFile resetCurrentDate];
            
            NSArray *movieExts = @[@"mpg", @"mpeg", @"avi", @"mov", /*@"asf", */@"wmv", @"3gp", @"rm", @"rmvb", @"mkv", @"flv", @"f4v", @"webm", @"mp4"];
            for (NSInteger i = 0; i < movieExts.count; i++) {
                NSString *movieExt = movieExts[i];
                [self restoreMovieDefaultApplicationToIINAByExtension:movieExt];
            }
        }
            break;
        case 13: {
            if (![[FileManager defaultManager] isContentExistAtPath:@"/Users/Mercury/Downloads/GoAgentXRules.plist"]) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"下载文件夹中找不到 GoAgentXRules.plist 文件，流程已停止"];
                return;
            }
            
            [self convertGoAgentXRules];
        }
            break;
        case 21: {
            if (self.currentVC.inputTextView.string.length == 0) {
                [[UtilityFile sharedInstance] showLogWithFormat:@"请输入根文件夹的地址"];
                return;
            }
            
            Images2Mp4 *instance = [[Images2Mp4 alloc] initWithRootFolder:self.currentVC.inputTextView.string];
            [instance readAllFiles];
            [instance startTranscoding];
        }
            break;
        default:
            break;
    }
}
- (IBAction)processingDownload:(NSMenuItem *)sender {
    [DownloadMethod configMethod:sender.tag];
}
- (IBAction)processingDeviantart:(NSMenuItem *)sender {
    [[DeviantartMethod defaultMethod] configMethod:sender.tag];
}


#pragma mark -- help --
- (IBAction)openHelpingDocument:(NSMenuItem *)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"帮助文档.txt"]]) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开帮助文档文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"打开帮助文档时发生错误，打开失败"];
    }
}
- (IBAction)openLogFile:(NSMenuItem *)sender {
    NSString *logsFolder = [UserInfo defaultUser].path_root_folder;
    NSDate *latestCreationDate = [NSDate dateWithYear:2000 month:1 day:1]; //新建一个NSDate对象，用于判断并查找最新创建的日志文件
    
    NSArray *logsFile = [[FileManager defaultManager] getFilePathsInFolder:logsFolder specificExtensions:@[@"log"]];
    NSString *latestFilePath = @"";
    for (NSString *filePath in logsFile) {
        NSDate *creationDate = [[FileManager defaultManager] getSpecificAttributeOfItemAtPath:filePath attribute:NSFileCreationDate];
        if ([creationDate isLaterThan:latestCreationDate]) {
            latestCreationDate = creationDate;
            latestFilePath = filePath;
        }
    }
    
    if (![[NSWorkspace sharedWorkspace] openFile:latestFilePath]) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开日志文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"打开日志文件时发生错误，打开失败"];
    }
}
- (IBAction)openAuthorizationFile:(NSMenuItem *)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"Authorization.plist"]]) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开授权文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"打开授权文件时发生错误，打开失败"];
    }
}
- (IBAction)openPreferenceFile:(NSMenuItem *)sender {
    if (![[NSWorkspace sharedWorkspace] openFile:[[UserInfo defaultUser].path_root_folder stringByAppendingPathComponent:@"Preference.plist"]]) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"打开配置文件时发生错误，打开失败" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"打开配置文件时发生错误，打开失败"];
    }
}

#pragma mark -- 通知方法 --
- (void)didGetCode:(NSNotification *)notif {
    for (NSWindow *window in [NSApplication sharedApplication].windows) {
        if (![window.windowController isMemberOfClass:[NSWindowController class]]) {
            [window close];
            
            break;
        }
    }
    
    [self processCode:(NSString *)[notif object]];
}

#pragma mark -- 辅助方法 --
- (void)setLogger {
    //在系统上保持一周的日志文件
    NSString *logDirectory = [UserInfo defaultUser].path_root_folder;
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
- (void)setTumblr {
    [TMAPIClient sharedInstance].OAuthConsumerKey = [UserInfo defaultUser].tumblr_OAuth_Consumer_Key;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = [UserInfo defaultUser].tumblr_OAuth_Consumer_Secret;
    [TMAPIClient sharedInstance].OAuthToken = [UserInfo defaultUser].tumblr_OAuth_Token;
    [TMAPIClient sharedInstance].OAuthTokenSecret = [UserInfo defaultUser].tumblr_OAuth_Token_Secret;
}
- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    [self processCode:[urlString componentsSeparatedByString:@"code="].lastObject];
}
- (void)processCode:(NSString *)code {
    [UserInfo defaultUser].weibo_code = code;
    [[UserInfo defaultUser] saveAuthDictIntoPlistFile];
    
    [[HttpManager sharedManager] getWeiboTokenWithStart:nil success:^(NSDictionary *dic) {
        [UserInfo defaultUser].weibo_token = dic[@"access_token"];
        [UserInfo defaultUser].weibo_expires_at_date = [NSDate dateWithTimeIntervalSinceNow:[dic[@"expire_in"] integerValue]];
        [[UserInfo defaultUser] saveAuthDictIntoPlistFile];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"成功获取到Token信息：%@", dic];
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:errorTitle infomation:errorMsg];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
        
        [[UtilityFile sharedInstance] showLogWithFormat:@"获取Token信息发生错误：%@，原因：%@", errorTitle, errorMsg];
    }];
}
- (void)restoreMovieDefaultApplicationToIINAByExtension:(NSString *)extension {
    CFStringRef exRef = (__bridge CFStringRef)extension;
    CFStringRef exUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, exRef, NULL);
    
    CFURLRef helperApplicationURL = LSCopyDefaultApplicationURLForContentType(exUTI, kLSRolesAll, NULL);
    if (helperApplicationURL == NULL) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"类型：%@ 未注册到系统的Launch Services中，跳过", extension];
        return;
    }
    
    // Check to make sure the registered helper application isn't us
    NSString *helperApplicationPath = [(__bridge NSURL *)helperApplicationURL path];
    NSString *helperApplicationName = [[NSFileManager defaultManager] displayNameAtPath:helperApplicationPath];
    
    if (![helperApplicationName isEqualToString:@"IINA"]) {
        LSSetDefaultRoleHandlerForContentType(exUTI, kLSRolesAll, (__bridge CFStringRef)@"com.colliderli.iina");
        [[UtilityFile sharedInstance] showLogWithFormat:@"类型：%@ 原打开方式为: %@，已修改为 IINA", extension, helperApplicationName];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"类型：%@ 默认打开方式为IINA，跳过", extension];
    }
    
    CFRelease(helperApplicationURL);
}
- (void)convertGoAgentXRules {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/Users/Mercury/Downloads/GoAgentXRules.plist"];
    NSArray *objects = [NSArray arrayWithArray:dict[@"$objects"]];
    NSMutableArray *all = [NSMutableArray array]; // 全部
    NSMutableArray *direct = [NSMutableArray array]; // 直接连接
    NSMutableArray *detect = [NSMutableArray array]; // 使用运行中的配置
    for (int i = 0; i < objects.count; i++) {
        if ([objects[i] isKindOfClass:[NSString class]]) {
            NSString *stringObj = (NSString *)objects[i];
            [all addObject:stringObj];
        }
    }
    
    NSIndexSet *dcIndexSet = [all indexesOfObjectsPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToString:@"DirectConnection"];
    }];
    NSIndexSet *adIndexSet = [all indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToString:@"AutoDetect"];
    }];
    
    [dcIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [direct addObject:all[idx + 1]];
    }];
    [adIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [detect addObject:all[idx + 1]];
    }];
    
    if (direct.count == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"可能GoAgentX的存储规则发生了改变，需要修改逻辑，流程已停止"];
        return;
    }
    
    [UtilityFile exportArray:direct atPath:@"/Users/Mercury/Downloads/GoAgentXRules_Direct.txt"];
    [UtilityFile exportArray:detect atPath:@"/Users/Mercury/Downloads/GoAgentXRules_Auto.txt"];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"流程已结束，请查看：GoAgentXRules_Direct.txt 以及 GoAgentXRules_Auto.txt 两个文件"];
}

@end
