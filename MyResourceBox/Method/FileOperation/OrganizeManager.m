//
//  OrganizeManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "OrganizeManager.h"

@interface OrganizeManager () {
    
}

@property (copy) NSString *plistPath;

@end

@implementation OrganizeManager

- (instancetype)initWithPlistPath:(NSString *)plistPath {
    self = [super init];
    if (self) {
        NSAssert([plistPath.pathExtension isEqualToString:@"plist"], @"Plist文件有问题");
        _plistPath = plistPath;
    }
    
    return self;
}

- (void)startOrganizing {
    //先判断有没有plist文件
    if (![[MRBFileManager defaultManager] isContentExistAtPath:self.plistPath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"plist不存在，请查看对应的文件夹"];
        return;
    }
    
    // 根据plist文件判断需要整理的内容，如果文件夹存在那么直接整理
    NSString *folderName = @"";
    NSString *plistName = self.plistPath.lastPathComponent.stringByDeletingPathExtension;
    if ([plistName isEqualToString:@"JDlingyuRenameInfo"]) {
        folderName = @"绝对领域";
    } else if ([plistName isEqualToString:@"LofterRenameInfo"]) {
        folderName = @"Lofter";
    } else if ([plistName isEqualToString:@"weiboStatuses"]) {
        folderName = @"微博";
    } else if ([plistName isEqualToString:@"tumblrStatuses"]) {
        folderName = @"Tumblr";
    }
    NSString *folderPath = [NSString stringWithFormat:@"/Users/Mercury/Downloads/%@/", folderName];
    
    // 如果文件夹存在，那么直接对文件夹进行处理
    if ([[MRBFileManager defaultManager] isContentExistAtPath:folderPath]) {
        [self organizingImageFile:folderPath];
    } else {
        //显示NSOpenPanel
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setMessage:@"选择下载文件夹"];
        panel.prompt = @"选择";
        panel.canChooseDirectories = YES;
        panel.canCreateDirectories = NO;
        panel.canChooseFiles = NO;
        panel.allowsMultipleSelection = NO;
        
        [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
            if (result == 1) {
                NSURL *fileUrl = [panel URLs].firstObject;
                NSString *filePath = [fileUrl path];
                [[MRBLogManager defaultManager] showLogWithFormat:@"已选择图片文件夹路径：%@", filePath];
                
                [self organizingImageFile:filePath];
            }
        }];
    }
}

- (void)organizingImageFile:(NSString *)rootFolderName {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
    
    // 先查找文件夹里是否有图片文件。如果没有，可能是没有将图片文件移动到文件夹内，目前给出提示
    NSArray *imageFiles = [[MRBFileManager defaultManager] getFilePathsInFolder:rootFolderName specificExtensions:simplePhotoType];
    if (imageFiles.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有在文件夹内找到图片文件，可能是没有将图片文件移动到文件夹内，请检查文件夹"];
        return;
    }
    
    //根据Plist文件整理记录的图片
    for (NSString *folderName in [dict allKeys]) {
        //创建目录文件夹
        NSString *folderPath = [rootFolderName stringByAppendingPathComponent:folderName];
        [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:folderPath];
        
        //获取图片文件路径并且移动文件
        NSArray *array = [NSArray arrayWithArray:dict[folderName]];
        for (NSString *url in array) {
            NSString *filePath = [rootFolderName stringByAppendingPathComponent:url.lastPathComponent];
            NSString *destPath = [folderPath stringByAppendingPathComponent:url.lastPathComponent];
            
            [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
        }
    }
    [[MRBLogManager defaultManager] showLogWithFormat:@"所有图片已经整理完成"];
    
    // 删除 plist 文件
    [[MRBFileManager defaultManager] trashFileAtPath:self.plistPath resultItemURL:nil];
    
    [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.25f];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishOrganizing)]) {
        [self.delegate didFinishOrganizing];
    }
}

- (void)showAlert {
    MRBAlert *alert = [[MRBAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
    [alert setMessage:@"图片资源已整理完成" infomation:nil];
    [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
    [alert runModel];
}

@end
