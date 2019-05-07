//
//  FileManager.h
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

@class UnzippedFile;

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

/**
 *  单例模式方法
 *
 *  @return 返回一个初始化后的对象
 */
+ (FileManager *)defaultManager;

/**
 *  在某个位置创建一个新的文件夹
 *
 *  @param folderPath 目标路径
 *
 *  @return 创建成功返回YES，创建失败或者文件夹已存在返回NO
 */
- (BOOL)createFolderAtPathIfNotExist:(NSString *)folderPath;

/**
 *  将单个文件移动到废纸篓中
 *
 *  @param filePath  目标文件的路径
 *  @param resultURL 移动之后的路径
 *
 *  @return 移动成功返回YES，反之返回NO
 */
- (BOOL)trashFileAtPath:(NSString *)filePath resultItemURL:(NSURL *)resultURL;
/**
 *  将单个文件移动到废纸篓中
 *
 *  @param fileURL   目标文件的路径
 *  @param resultURL 移动之后的路径
 *
 *  @return 移动成功返回YES，反之返回NO
 */
- (BOOL)trashFileAtURL:(NSURL *)fileURL resultItemURL:(NSURL *)resultURL;
/**
 *  将文件移动到废纸篓中
 *
 *  @param filePaths   需要移动到废纸篓的文件, UnzippedFile类型
 */
- (void)trashFilesAtPaths:(NSArray<NSURL *> *)filePaths;

/**
 *  将数组中NSString类型的路径转换成NSURL类型
 *
 *  @param paths 包含NSString类型路径的数组
 *
 *  @return 包含NSURL类型路径的数组
 */
- (NSArray<NSURL *> *)convertFilePathsArrayToFileURLsArray:(NSArray<NSString *> *)paths;
/**
 *  将数组中NSURL类型的路径转换成NSString类型
 *
 *  @param urls 包含NSURL类型路径的数组
 *
 *  @return 包含NSString类型路径的数组
 */
- (NSArray<NSString *> *)convertFileURLsArrayToFilePathsArray:(NSArray<NSURL *> *)urls;

/**
 *  将文件移动到特定的位置(路径为NSString类型)
 *
 *  @param oriPath  源文件路径
 *  @param destPath 目标文件路径
 */
- (void)moveItemAtPath:(NSString *)oriPath toDestPath:(NSString *)destPath;
/**
 *  将文件移动到特定的位置(路径为NSURL类型)
 *
 *  @param oriURL  源文件路径
 *  @param destURL 目标文件路径
 */
- (void)moveItemAtURL:(NSURL *)oriURL toDestURL:(NSURL *)destURL;

/**
 *  判断一个文件夹/文件是否存在
 *
 *  @param contentPath 文件夹/文件路径
 *
 *  @return 存在返回YES，反之返回NO
 */
- (BOOL)isContentExistAtPath:(NSString *)contentPath;
/**
 *  判断该路径的内容是否是文件夹
 *
 *  @param contentPath 内容路径
 *
 *  @return 是文件夹返回YES，反之返回NO
 */
- (BOOL)contentIsFolderAtPath:(NSString *)contentPath;
/**
 *  返回某一个文件夹内所有文件路径(不包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有文件路径(不包括子文件夹)
 */
- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath;
/**
 *  返回某一个文件夹内特定的文件路径(不包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *  @param extensions 需要筛选的特定文件类型
 *
 *  @return 返回所有符合条件的文件路径(不包括子文件夹)
 */
- (NSArray<NSString *> *)getFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions;
/**
 *  返回某一个文件夹内文件夹的路径(不包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有文件夹的路径(不包括子文件夹)
 */
- (NSArray<NSString *> *)getFolderPathsInFolder:(NSString *)folderPath;
/**
 *  返回某一个文件夹内所有文件路径(包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有文件路径(包括子文件夹)
 */
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath;
/**
 *  返回某一个文件夹内特定的文件路径(包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *  @param extensions 需要筛选的特定文件类型
 *
 *  @return 返回所有符合条件的文件路径(包括子文件夹)
 */
- (NSArray<NSString *> *)getSubFilePathsInFolder:(NSString *)folderPath specificExtensions:(NSArray<NSString *> *)extensions;
/**
 *  返回某一个文件夹内所有文件夹的路径(包括子文件夹)
 *
 *  @param folderPath 目标文件夹路径
 *
 *  @return 返回所有子文件夹的路径(包括子文件夹)
 */
- (NSArray<NSString *> *)getSubFoldersPathInFolder:(NSString *)folderPath;
/**
 *  获取一个内容的所有属性
 *
 *  @param path 内容路径
 *
 *  @return 返回该内容的所有属性
 */
- (NSDictionary *)getAllAttributesOfItemAtPath:(NSString *)path;
/**
 *  获取一个内容的特定属性
 *
 *  @param path      内容路径
 *  @param attribute 属性名
 *
 *  @return 返回该内容的特定属性
 */
- (id)getSpecificAttributeOfItemAtPath:(NSString *)path attribute:(NSString *)attribute;
/**
 *  查看一个文件夹是否是空的文件夹
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 空文件夹返回YES，反之返回NO
 */
- (BOOL)isEmptyFolderAtPath:(NSString *)folderPath;

@end
