//
//  MRBFileManager.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MRBFileManager.h"

@interface MRBFileManager () {
    NSFileManager *fm;
}

@end

@implementation MRBFileManager

#pragma mark -- 生命周期方法 --
/**
 *  单例模式方法
 *
 *  返回一个初始化后的对象
 */
static MRBFileManager *inputInstance;
+ (MRBFileManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inputInstance = [[MRBFileManager alloc] init];
    });
    
    return inputInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        fm = [NSFileManager defaultManager];
    }
    
    return self;
}

#pragma mark -- 增 --
/**
 *  在某个位置创建一个新的文件夹
 *
 *  @param folderPath 目标路径
 *
 *  @return 创建成功返回YES，创建失败或者文件夹已存在返回NO
 */
- (BOOL)createFolderAtPathIfNotExist:(NSString *)folderPath {
    if ([fm fileExistsAtPath:folderPath]) {
        return YES;
    } else {
        NSError *error;
        if ([fm createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return YES;
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"创建文件夹：%@ 时失败，错误原因：\n%@", folderPath, [error localizedDescription]];
            return NO;
        }
    }
}

#pragma mark -- 删 --
/**
 *  将单个文件移动到废纸篓中
 *
 *  @param filePath  目标文件的路径
 *  @param resultURL 移动之后的路径
 *
 *  @return 移动成功返回YES，反之返回NO
 */
- (BOOL)trashFileAtPath:(NSString *)filePath resultItemURL:(NSURL *)resultURL {
    NSError *error;
    if ([fm trashItemAtURL:[NSURL fileURLWithPath:filePath] resultingItemURL:&resultURL error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 已经被删除", filePath.lastPathComponent];
        return YES;
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"删除文件 %@ 时出现错误：%@", filePath.lastPathComponent, [error localizedDescription]];
        return NO;
    }
}
/**
 *  将单个文件移动到废纸篓中
 *
 *  @param fileURL   目标文件的路径
 *  @param resultURL 移动之后的路径
 *
 *  @return 移动成功返回YES，反之返回NO
 */
- (BOOL)trashFileAtURL:(NSURL *)fileURL resultItemURL:(NSURL *)resultURL {
    NSError *error;
    if ([fm trashItemAtURL:fileURL resultingItemURL:&resultURL error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 已经被删除", fileURL.path.lastPathComponent];
        return YES;
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"删除文件 %@ 时出现错误：%@", fileURL.path.lastPathComponent, [error localizedDescription]];
        return NO;
    }
}
/**
 *  将多个文件移动到废纸篓中
 *
 *  @param filePaths   需要移动到废纸篓的文件, UnzippedFile类型
 */
- (void)trashFilesAtPaths:(NSArray<NSURL *> *)filePaths {
    [[NSWorkspace sharedWorkspace] recycleURLs:filePaths completionHandler:^(NSDictionary<NSURL *,NSURL *> * _Nonnull newURLs, NSError * _Nullable error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"文件移动到废纸篓失败：\n%@", [error localizedDescription]];
//#warning 这边应该加一个NSAlert
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"文件移动到废纸篓成功"];
        }
    }];
}

#pragma mark -- 转 --
/**
 *  将数组中NSString类型的路径转换成NSURL类型
 *
 *  @param paths 包含NSString类型路径的数组
 *
 *  @return 包含NSURL类型路径的数组
 */
- (NSArray<NSURL *> *)convertFilePathsArrayToFileURLsArray:(NSArray<NSString *> *)paths {
    NSMutableArray<NSURL *> *results = [NSMutableArray array];
    
    for (NSString *path in paths) {
        NSURL *url = [NSURL fileURLWithPath:path];
        [results addObject:url];
    }
    
    return [NSArray arrayWithArray:results];
}
/**
 *  将数组中NSURL类型的路径转换成NSString类型
 *
 *  @param urls 包含NSURL类型路径的数组
 *
 *  @return 包含NSString类型路径的数组
 */
- (NSArray<NSString *> *)convertFileURLsArrayToFilePathsArray:(NSArray<NSURL *> *)urls {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    
    for (NSURL *url in urls) {
        NSString *path = url.path;
        [results addObject:path];
    }
    
    return [NSArray arrayWithArray:results];
}

#pragma mark -- 移 --
/**
 *  将文件移动到特定的位置(路径为NSString类型)
 *
 *  @param oriPath  源文件路径
 *  @param destPath 目标文件路径
 */
- (void)moveItemAtPath:(NSString *)oriPath toDestPath:(NSString *)destPath {
    NSError *error;
    if (![fm moveItemAtPath:oriPath toPath:destPath error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"移动文件：%@ 时发生错误：%@", oriPath, [error localizedDescription]];
    }
}
/**
 *  将文件移动到特定的位置(路径为NSURL类型)
 *
 *  @param oriURL  源文件路径
 *  @param destURL 目标文件路径
 */
- (void)moveItemAtURL:(NSURL *)oriURL toDestURL:(NSURL *)destURL {
    NSError *error;
    if (![fm moveItemAtURL:oriURL toURL:destURL error:&error]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"移动文件：%@ 时发生错误：%@", oriURL.path, [error localizedDescription]];
    }
}
/**
 *  将文件移动到特定的位置(路径为NSString类型)
 *
 *  @param oriPath  源文件路径
 *  @param destPath 目标文件路径
 *  @param error 错误
 */
- (void)moveItemAtPath:(NSString *)oriPath toDestPath:(NSString *)destPath error:(NSError **)error {
    [fm moveItemAtPath:oriPath toPath:destPath error:error];
}
/**
 *  将文件移动到特定的位置(路径为NSURL类型)
 *
 *  @param oriURL  源文件路径
 *  @param destURL 目标文件路径
 *  @param error 错误
 */
- (void)moveItemAtURL:(NSURL *)oriURL toDestURL:(NSURL *)destURL error:(NSError **)error {
    [fm moveItemAtURL:oriURL toURL:destURL error:error];
}

#pragma mark -- 查 --
/**
 *  判断一个文件夹/文件是否存在
 *
 *  @param contentPath 文件夹/文件路径
 *
 *  @return 存在返回YES，反之返回NO
 */
- (BOOL)isContentExistAtPath:(NSString *)contentPath {
    return [fm fileExistsAtPath:contentPath];
}
/**
 *  判断该路径的内容是否是文件夹
 *
 *  @param contentPath 内容路径
 *
 *  @return 是文件夹返回YES，反之返回NO
 */
- (BOOL)contentIsFolderAtPath:(NSString *)contentPath {
    BOOL isFolder = NO;
    [fm fileExistsAtPath:contentPath isDirectory:&isFolder];
    return isFolder;
}
/**
 *  返回某一个文件夹内所有文件路径(不包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有文件路径(不包括子文件夹)
 */
- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [fm contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *fileName in contents) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [fm fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
/**
 *  返回某一个文件夹内特定的文件路径(不包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *  @param extensions 需要筛选的特定文件类型
 *
 *  @return 返回所有符合条件的文件路径(不包括子文件夹)
 */
- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [fm contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *extension in extensions) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [[evaluatedObject pathExtension] caseInsensitiveCompare:extension] == NSOrderedSame;
        }];
        
        NSArray *filteredArray = [contents filteredArrayUsingPredicate:predicate];
        for (NSString *fileName in filteredArray) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
            
            [results addObject:filePath];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
/**
 *  返回某一个文件夹内文件夹的路径(不包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有文件夹的路径(不包括子文件夹)
 */
- (NSArray<NSString *> *)getFolderPathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    
    NSArray *contents = [fm contentsOfDirectoryAtPath:folderPath error:nil];
    if (contents.count == 1) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有在：%@ 中获取到解压好的文件，已跳过", folderPath];
        return nil;
    }
    
    for (NSString *fileName in contents) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [fm fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
/**
 *  返回某一个文件夹内所有文件路径(包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有文件路径(包括子文件夹)
 */
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [fm subpathsOfDirectoryAtPath:folderPath error:nil]; //所有的文件【递归】
    
    for (NSString *fileName in contents) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [fm fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
/**
 *  返回某一个文件夹内特定的文件路径(包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *  @param extensions 需要筛选的特定文件类型
 *
 *  @return 返回所有符合条件的文件路径(包括子文件夹)
 */
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *contents = [fm subpathsOfDirectoryAtPath:folderPath error:nil]; //所有的文件【递归】
    
    for (NSString *extension in extensions) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [[evaluatedObject pathExtension] caseInsensitiveCompare:extension] == NSOrderedSame;
        }];
        
        NSArray *filteredArray = [contents filteredArrayUsingPredicate:predicate];
        for (NSString *fileName in filteredArray) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
            
            [results addObject:filePath];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
/**
 *  返回某一个文件夹内所有文件夹的路径(包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有子文件夹的路径(包括子文件夹)
 */
- (NSArray<NSString *> *)getSubFoldersPathInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    
    NSArray *subpaths = [fm subpathsOfDirectoryAtPath:folderPath error:nil]; //所有的文件【递归】
    if (subpaths.count == 1) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有在：%@ 中获取到解压好的文件，已跳过", folderPath];
        return nil;
    }
    
    for (NSString *fileName in subpaths) {
        if ([fileName hasSuffix:@"DS_Store"]) {
            continue;
        }
        
        NSString *folder = [folderPath stringByAppendingPathComponent:fileName];
        BOOL folderFlag = YES;
        [fm fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [NSArray arrayWithArray:results];
}
/**
 *  获取一个内容的所有属性
 *
 *  @param path 内容路径
 *
 *  @return 返回该内容的所有属性
 */
- (NSDictionary *)getAllAttributesOfItemAtPath:(NSString *)path {
    NSError *error;
    NSDictionary *dict = [fm attributesOfItemAtPath:path error:&error];
    return [NSDictionary dictionaryWithDictionary:dict];
}
/**
 *  获取一个内容的特定属性
 *
 *  @param path      内容路径
 *  @param attribute 属性名
 *
 *  @return 返回该内容的特定属性
 */
- (id)getSpecificAttributeOfItemAtPath:(NSString *)path attribute:(NSString *)attribute {
    return [self getAllAttributesOfItemAtPath:path][attribute];
}
/**
 *  查看一个文件夹是否是空的文件夹
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 空文件夹返回YES，反之返回NO
 */
- (BOOL)isEmptyFolderAtPath:(NSString *)folderPath {
    NSArray *contents = [self getFilePathsInFolder:folderPath];
    return contents.count == 0;
}

@end
