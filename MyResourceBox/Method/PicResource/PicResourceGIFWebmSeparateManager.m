//
//  PicResourceGIFWebmSeparateManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/13.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PicResourceGIFWebmSeparateManager.h"

@implementation PicResourceGIFWebmSeparateManager

+ (void)choosingRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要分离的根文件夹【一般情况下是 下载 文件夹】"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *chosenRootFolderPath = panel.URLs.firstObject.absoluteString;
                if ([chosenRootFolderPath hasPrefix:@"file://"]) {
                    chosenRootFolderPath = [chosenRootFolderPath substringFromIndex:7];
                }
                DDLogInfo(@"已选择需要分离的根文件夹：%@", chosenRootFolderPath);
                [[UtilityFile sharedInstance] showLogWithFormat:@"已选择需要分离的根文件夹：%@", chosenRootFolderPath];
                
                [self startSeparatingAtFolderPath:chosenRootFolderPath];
            });
        }
    }];
}
+ (void)startSeparatingAtFolderPath:(NSString *)rootFolderPath {
    [[UtilityFile sharedInstance] showLogWithFormat:@"分离 GelbooruDownloader 下载的 gif 和 webm 文件，流程开始"];
    
    NSString *gifRootFolder = [rootFolderPath stringByAppendingString:@" gif"];
    NSString *webmRootFolder = [rootFolderPath stringByAppendingString:@" webm"];
    
    [[FileManager defaultManager] createFolderAtPathIfNotExist:gifRootFolder];
    [[FileManager defaultManager] createFolderAtPathIfNotExist:webmRootFolder];
    
    NSArray *subFolders = [[FileManager defaultManager] getFolderPathsInFolder:rootFolderPath];
    if (subFolders.count == 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 中没有任何文件夹，流程结束", rootFolderPath];
        [[UtilityFile sharedInstance] showLogWithFormat:@"分离 GelbooruDownloader 下载的 gif 和 webm 文件, 流程结束"];
        
        return;
    }
    
    for (NSInteger i = 0; i < subFolders.count; i++) {
        NSString *subFolder = subFolders[i];
        // 如果文件夹名包含 webm 和 gif，那么忽略该文件夹
        if ([subFolder isEqualToString:@"~webm"] || [subFolder isEqualToString:@"webm"] || [subFolder isEqualToString:@"~gif"] || [subFolder isEqualToString:@"gif"]) {
            continue;
        }
        
        NSArray *subFiles = [[FileManager defaultManager] getFolderPathsInFolder:subFolder];
        if (subFiles.count == 0) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 中没有任何文件，跳过", subFolder];
            continue;
        }
        
        
        NSString *gifFolder = [gifRootFolder stringByAppendingPathComponent:subFolder.lastPathComponent];
        NSString *webmFolder = [webmRootFolder stringByAppendingPathComponent:subFolder.lastPathComponent];
        
        [[FileManager defaultManager] createFolderAtPathIfNotExist:gifFolder];
        [[FileManager defaultManager] createFolderAtPathIfNotExist:webmFolder];
        
        for (NSInteger j = 0; j < subFiles.count; j++) {
            NSString *subFile = subFiles[j];
            
            if ([subFile.pathExtension isEqualToString:@"gif"]) {
                NSString *gifFile = [gifFolder stringByAppendingPathComponent:subFile.lastPathComponent];
                [[FileManager defaultManager] moveItemAtPath:subFile toDestPath:gifFile];
            }
            
            if ([subFile.pathExtension isEqualToString:@"webm"]) {
                NSString *webmFile = [webmFolder stringByAppendingPathComponent:subFile.lastPathComponent];
                [[FileManager defaultManager] moveItemAtPath:subFile toDestPath:webmFile];
            }
        }
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"分离 GelbooruDownloader 下载的 gif 和 webm 文件, 流程结束"];
}

@end
