//
//  WebArchiveArchivingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/05.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "WebArchiveArchivingManager.h"
#import "FileManager.h"
#import "DTWebArchive.h"

@interface WebArchiveArchivingManager () {
    NSArray<NSURL *> *archiveFileURLs;
    NSMutableArray *targetFolderPaths;
}

@end

@implementation WebArchiveArchivingManager

- (void)startArchiving {
    [self chooseFile];
}

#pragma mark -- 具体方法 --
- (void)chooseFile {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要解析的WebArchive文件"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = YES;
    panel.allowedFileTypes = @[@"webarchive"];
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择WebArchive文件：%@", panel.URLs);
                
                [self analyzeChosenFilePath:panel.URLs];
            });
        }
    }];
}
- (void)analyzeChosenFilePath:(NSArray<NSURL *> *)fileURLs {
    archiveFileURLs = [NSArray arrayWithArray:fileURLs];
    targetFolderPaths = [NSMutableArray array];
    
    for (NSURL *fileURL in fileURLs) {
        [self analyzeFileAtPath:fileURL.path];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"流程已经结束"];
    
    //    [self finishAnalyzing];
}
- (void)analyzeFileAtPath:(NSString *)filePath {
    [[UtilityFile sharedInstance] showLogWithFormat:@"开始处理文件：%@", filePath];
    NSString *targetFolderPath = filePath.stringByDeletingPathExtension;
    [targetFolderPaths addObject:targetFolderPath];
    [[FileManager defaultManager] createFolderAtPathIfNotExist:targetFolderPath];
    
    NSData *webArchiveData = [NSData dataWithContentsOfFile:filePath];
    DTWebArchive *archive = [[DTWebArchive alloc] initWithData:webArchiveData];
    for (NSInteger i = 0; i < archive.subresources.count; i++) {
        DTWebResource *resource = (DTWebResource *)archive.subresources[i];
        
        NSString *format = [resource.MIMEType componentsSeparatedByString:@"/"].lastObject;
        //        if (![[UserInfo defaultUser] mimeTypeExistsInFormats:format] || resource.data.length < 25600) { // 忽略 不符合类型 或者 小于25KB 的文件
        //            continue;
        //        }
        
        NSString *filePath = @"";
        if (resource.URL.lastPathComponent) {
            filePath = [targetFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", resource.URL.lastPathComponent.stringByDeletingPathExtension, format]];
        } else if (resource.URL.query) {
            filePath = [targetFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", resource.URL.query.stringByDeletingPathExtension, format]];
        } else {
            filePath = [targetFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.%@", i, format]];
        }
        
        NSError *error;
        if (![resource.data writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"写入文件：%@, 发生错误：%@", filePath, error.localizedDescription];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"写入文件：%@, 成功", filePath];
        }
    }
}
- (void)finishAnalyzing {
    // 删除尺寸过小的图片
    NSArray<NSString *> *imageFilePaths = @[];
    for (NSInteger i = 0; i < targetFolderPaths.count; i++) {
        NSString *targetFolderPath = targetFolderPaths[i];
        NSArray<NSString *> *targetFolderImageFilePaths = [[FileManager defaultManager] getFilePathsInFolder:targetFolderPath specificExtensions:[UserInfo defaultUser].web_archive_mime_type];
        imageFilePaths = [imageFilePaths arrayByAddingObjectsFromArray:targetFolderImageFilePaths];
    }
    
    NSMutableArray<NSURL *> *trashes = [NSMutableArray array];
    for (NSString *filePath in imageFilePaths) {
        if ([self isImageFile:filePath.pathExtension]) {
            NSSize size = [self imageSizeAtPath:filePath];
            if (size.width < 801 && size.height < 801) {
                [trashes addObject:[NSURL fileURLWithPath:filePath]];
            }
        }
    }
    
    [[NSWorkspace sharedWorkspace] recycleURLs:trashes completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
        if (error) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"删除尺寸过小的图片时发生错误：%@", error.localizedDescription];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"成功删除了 %ld 个尺寸过小的图片", newURLs.count];
        }
    }];
    
    // 删除 WebArchive 文件
    [[NSWorkspace sharedWorkspace] recycleURLs:archiveFileURLs completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
        if (error) {
            [[UtilityFile sharedInstance] showLogWithFormat:@"删除 WebArchive 文件时发生错误：%@", error.localizedDescription];
        } else {
            [[UtilityFile sharedInstance] showLogWithFormat:@"成功删除了 %ld 个 WebArchive 文件", newURLs.count];
        }
    }];
}

#pragma mark -- 辅助方法 --
- (NSSize)imageSizeAtPath:(NSString *)photoPath {
    NSImageRep *imageRep = [NSImageRep imageRepWithContentsOfFile:photoPath];
    
    return NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh);
}
- (BOOL)isImageFile:(NSString *)extension {
    return [[Consts simplePhotoType] containsObject:extension];
}

@end
