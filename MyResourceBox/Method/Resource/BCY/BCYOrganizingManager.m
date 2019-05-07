//
//  BCYOrganizingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "BCYOrganizingManager.h"
#import "BCYHeader.h"

@implementation BCYOrganizingManager

+ (void)prepareOrganizing {
    [self checkRootFolderIsExist];
}

// 根据Plist文件将图片整理到对应的文件夹中（第一步，显示NSOpenPanel）
+ (void)checkRootFolderIsExist {
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理半次元下载好的图片：已经准备就绪"];
    
    //先判断有没有plist文件
    if (![[FileManager defaultManager] isContentExistAtPath:BCYRenameInfoPath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"plist不存在，请查看对应的文件夹"];
        return;
    }
    
    // 如果文件夹存在，那么直接对文件夹进行处理
    if ([[FileManager defaultManager] isContentExistAtPath:BCYDefaultDownloadPath]) {
        [self organizingRootFolder:BCYDefaultDownloadPath];
    } else {
        //显示NSOpenPanel
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setMessage:@"选择半次元下载文件夹"];
        panel.prompt = @"选择";
        panel.canChooseDirectories = YES;
        panel.canCreateDirectories = NO;
        panel.canChooseFiles = NO;
        panel.allowsMultipleSelection = NO;
        panel.directoryURL = [NSURL fileURLWithPath:@"/Users/Mercury/Downloads"];
        
        [panel beginSheetModalForWindow:[AppDelegate defaultWindow] completionHandler:^(NSInteger result) {
            if (result == 1) {
                NSURL *fileUrl = [panel URLs].firstObject;
                NSString *filePath = [fileUrl path];
                [[UtilityFile sharedInstance] showLogWithFormat:@"已选择路径：%@", filePath];
                
                [self organizingRootFolder:filePath];
            }
        }];
    }
}
// 根据Plist文件将图片整理到对应的文件夹中（第二步，具体逻辑）
+ (void)organizingRootFolder:(NSString *)rootFolderName {
    FileManager *fm = [FileManager defaultManager];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:BCYRenameInfoPath];
    
    //根据Plist文件整理记录的图片
    NSArray *allKeys = [dict allKeys];
    for (NSString *key in allKeys) {
        //获取文件夹的名字和路径
        NSString *folderName = @"";
        if ([key hasPrefix:@"http://bcy.net"]) {
            NSArray *array = [key componentsSeparatedByString:@"/"];
            folderName = [folderName stringByAppendingString:array[3]];
            folderName = [folderName stringByAppendingString:array[5]];
            folderName = [folderName stringByAppendingString:array[4]];
            folderName = [folderName stringByAppendingString:array[6]];
        } else {
            folderName = key;
        }
        //创建目录文件夹
        NSString *folderPath = [rootFolderName stringByAppendingPathComponent:folderName];
        [fm createFolderAtPathIfNotExist:folderPath];
        
        //获取图片文件路径并且移动文件
        NSArray *array = [NSArray arrayWithArray:dict[key]];
        for (NSString *url in array) {
            NSString *filePath = [rootFolderName stringByAppendingPathComponent:url.lastPathComponent];
            NSString *destPath = [folderPath stringByAppendingPathComponent:url.lastPathComponent];
            
            [fm moveItemAtPath:filePath toDestPath:destPath];
        }
    }
    [[UtilityFile sharedInstance] showLogWithFormat:@"Plist中记录的图片已经整理完成"];
    
    // 新建"未整理"文件夹并将剩下的图片整理到"未整理"文件夹
    NSString *otherFolderName = [rootFolderName stringByAppendingPathComponent:@"未整理"];
    [fm createFolderAtPathIfNotExist:otherFolderName];
    
    NSArray<NSString *> *imageFiles = [fm getFilePathsInFolder:rootFolderName specificExtensions:simplePhotoType];
    for (NSString *filePath in imageFiles) {
        NSString *destPath = [otherFolderName stringByAppendingPathComponent:filePath.lastPathComponent];
        [fm moveItemAtPath:filePath toDestPath:destPath];
    }
    
    [fm trashFileAtPath:BCYRenameInfoPath resultItemURL:nil];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"其他图片已经整理完成"];
    [[UtilityFile sharedInstance] showLogWithFormat:@"所有半次元图片已经整理完成"];
}

@end
