//
//  FOFolderManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "FOFolderManager.h"

@implementation FOFolderManager

+ (void)prepareCopyingFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要复制层级的文件夹"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择需要复制层级的文件夹：%@", panel.URLs);
                
                [self copyFolderClass:panel.URL.absoluteString];
            });
        }
    }];
}
+ (void)copyFolderClass:(NSString *)rootFolderPath {
    if ([rootFolderPath hasPrefix:@"file://"]) {
        rootFolderPath = [rootFolderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    rootFolderPath = [rootFolderPath stringByRemovingPercentEncoding];
    [[MRBLogManager defaultManager] showLogWithFormat:@"复制文件夹的层级, 流程开始"];
    
    NSString *targetFolderPath = rootFolderPath;
    if ([targetFolderPath hasSuffix:@"/"]) {
        targetFolderPath = [targetFolderPath substringToIndex:targetFolderPath.length - 1];
    }
    targetFolderPath = [targetFolderPath stringByAppendingString:@" 复制/"];
    [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:targetFolderPath];
    
    NSArray *subFolders = [[MRBFileManager defaultManager] getSubFoldersPathInFolder:rootFolderPath];
    for (NSInteger i = 0; i < subFolders.count; i++) {
        NSString *subFolder = subFolders[i];
        NSString *targetSubFolder = [subFolder stringByReplacingOccurrencesOfString:rootFolderPath withString:targetFolderPath];
        
        [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:targetSubFolder];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"复制文件夹的层级, 流程结束"];
}

@end
