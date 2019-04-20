//
//  WnacgImageRename.m
//  MyToolBox
//
//  Created by 龚宇 on 16/05/02.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "WnacgImageRename.h"

static NSString * const rootFolderPath = @"/Users/Mercury/临时/WNACG";

@interface WnacgImageRename () {
    NSFileManager *fileManager;
    NSString *currentFolderPath;
    NSMutableArray *failedPath;
}

@end

@implementation WnacgImageRename

// -------------------------------------------------------------------------------
//	单例模式
// -------------------------------------------------------------------------------
static WnacgImageRename *instance;
+ (WnacgImageRename *)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WnacgImageRename alloc] init];
    });
    
    return instance;
}

// -------------------------------------------------------------------------------
//	第一步：显示警告框
// -------------------------------------------------------------------------------
- (void)showAlert {
    MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleInformational];
    [alert setMessage:@"文件夹存放地址修改提示" infomation:@"该方法需要提前将漫画文件夹移动到临时文件夹的WNACG文件夹中，是否已移动？"];
    [alert setButtonTitle:@"已移动" keyEquivalent:MyAlertKeyEquivalentReturnKey];
    [alert setButtonTitle:@"未移动" keyEquivalent:MyAlertKeyEquivalentEscapeKey];
    
    [alert showAlertAtMainWindowWithCompletionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case 1000: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getAllFolders];
                });
            }
                break;
            case 1001: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UtilityFile sharedInstance] showLogWithFormat:@"请将漫画文件夹移动到临时文件夹的WNACG文件夹中"];
                });
            }
                break;
            default:
                break;
        }
    }];
}

// -------------------------------------------------------------------------------
//	第二步：获取WNACG内的所有漫画文件夹
// -------------------------------------------------------------------------------
- (void)getAllFolders {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"开始获取所有漫画文件夹"];
    
    failedPath = [NSMutableArray array];
    fileManager = [NSFileManager defaultManager];
    NSMutableArray *allFolders = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:rootFolderPath error:nil]];
    [allFolders removeObject:@".DS_Store"];
    
    for (NSString *folderPath in allFolders) {
        currentFolderPath = [rootFolderPath stringByAppendingPathComponent:folderPath];
        [self processFilename];
    }
    
    [self summary];
}

// -------------------------------------------------------------------------------
//	第三步：获取漫画文件夹中的所有文件，并批量改名
// -------------------------------------------------------------------------------
- (void)processFilename {
    NSInteger longestDigit = 0;
    NSMutableArray *needRenames = [NSMutableArray array];
    NSMutableArray *allFiles = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:currentFolderPath error:nil]];
    [allFiles removeObject:@".DS_Store"];
    
    for (NSString *file in allFiles) {
        NSArray *fileComponents = [file componentsSeparatedByString:@"."];
        
        //如果出现13497992914.png.jpeg类似的文件名，添加到分failedPath数组中，然后直接跳出
        if (fileComponents.count > 2) {
            [failedPath addObject:fileComponents];
            return;
        }
        
        NSString *fileName = fileComponents[0];
        if (fileName.length > longestDigit) {
            longestDigit = fileName.length;
        }
    }
    
    for (NSString *file in allFiles) {
        NSArray *fileComponents = [file componentsSeparatedByString:@"."];
        NSString *fileName = fileComponents[0];
        if (fileName.length < longestDigit) {
            NSDictionary *renameInfo = @{@"fileName":file, @"digit":@(longestDigit - fileName.length)};
            [needRenames addObject:renameInfo];
        }
    }
    
    for (NSDictionary *dict in needRenames) {
        NSInteger digit = [[dict objectForKey:@"digit"] integerValue];
        NSString *originalFilePath = [dict objectForKey:@"fileName"];
        NSArray *components = [originalFilePath componentsSeparatedByString:@"."];
        NSString *fileName = components[0];
        NSString *fileExtension = components[1];
        
        for (NSInteger i = 0; i < digit; i++) {
            fileName = [fileName stringByAppendingString:@"0"];
        }
        NSString *renameFilePath = [fileName stringByAppendingFormat:@".%@", fileExtension];
        
        NSString *totalOriginalPath = [currentFolderPath stringByAppendingPathComponent:originalFilePath];
        NSString *totalRenamePath = [currentFolderPath stringByAppendingPathComponent:renameFilePath];
        
        NSError *error = nil;
        BOOL success = [fileManager moveItemAtPath:totalOriginalPath toPath:totalRenamePath error:&error];
        if (!success && error) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"文件重命名失败：%@", [error localizedDescription]];
        }
    }
}

// -------------------------------------------------------------------------------
//	第四步：总结
// -------------------------------------------------------------------------------
- (void)summary {
    if (failedPath.count > 0) {
        [[UtilityFile sharedInstance] showLogWithTitle:@"有如下文件夹里的内容因为文件名不符合要求而被略过" andFormat:[UtilityFile convertResultArray:failedPath]];
    } else {
        [[UtilityFile sharedInstance] showLogWithFormat:@"所有漫画文件夹内的文件都已经修整过文件名"];
    }
}

@end
