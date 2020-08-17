//
//  MRBFileNameFindSpecificCharactersManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/08/15.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBFileNameFindSpecificCharactersManager.h"
#import "FileOperationHeader.h"

@interface MRBFileNameFindSpecificCharactersManager ()

@property (copy) NSArray *characters;
@property (strong) NSMutableArray *foundFilePaths;

@end

@implementation MRBFileNameFindSpecificCharactersManager

- (instancetype)initWithCharacters:(nullable id)characters {
    self = [super init];
    if (self) {
        self.foundFilePaths = [NSMutableArray array];
        
        if (!characters) {
            self.characters = [self extractCharactersFromString:[AppDelegate defaultVC].inputTextView.string];
        } else if ([characters isKindOfClass:[NSArray class]] && ((NSArray *)characters).count > 0) {
            self.characters = (NSArray *)characters;
        } else if ([characters isKindOfClass:[NSString class]] && ((NSString *)characters).length > 0) {
            self.characters = [self extractCharactersFromString:(NSString *)characters];
        } else {
            self.characters = [self extractCharactersFromString:[AppDelegate defaultVC].inputTextView.string];
        }
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"获取到 %ld 个字符内容:\n%@", self.characters.count, [self.characters componentsJoinedByString:@" "]];
    }
    
    return self;
}
- (NSArray *)extractCharactersFromString:(NSString *)charStr {
    if (charStr.length == 0) {
        return @[];
    }
    
    NSArray *characters = [charStr componentsSeparatedByString:@" "];
    // 去除重复的字符
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:characters];
    characters = orderedSet.array;
    // 去除特定的字符
    NSArray *uselessChars = @[@""];
    characters = [characters filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable charStr, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [uselessChars indexOfObject:charStr] == NSNotFound;
    }]];
    
    return characters;
}

- (void)selectRootFolder {
    if (self.characters.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何字符，请检查输入框"];
        return;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"请选择需要查找的文件根目录"];
    panel.prompt = @"确定";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogInfo(@"已选择的根目录：%@", panel.URLs.firstObject);
                
                NSString *folderPath = panel.URLs.firstObject.absoluteString;
                folderPath = [folderPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
                folderPath = [folderPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                folderPath = [folderPath stringByRemovingPercentEncoding];
                
                [self startWithRootFolder:folderPath];
            });
        }
    }];
}
- (void)startWithRootFolder:(NSString *)rootFolderPath {
    NSArray<NSString *> *allFilePaths = [[MRBFileManager defaultManager] getSubFilePathsInFolder:rootFolderPath];
    [[MRBLogManager defaultManager] showLogWithFormat:@"即将开始查找 %ld 个文件", allFilePaths.count];
    
    for (NSInteger i = 0; i < allFilePaths.count; i++) {
        BOOL found = NO;
        NSString *filePath = allFilePaths[i];
        NSArray *filePathComponents = filePath.pathComponents;
        
        for (NSInteger j = 0; j < filePathComponents.count; j++) {
            for (NSInteger k = 0; k < self.characters.count; k++) {
                if ([filePathComponents[j] rangeOfString:self.characters[k]].location != NSNotFound) {
                    found = YES;
                    goto outer;
                }
            }
        }
    outer:;
        
        if (found) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已查找到第 %ld 个文件, 文件名包含特定字符: %@", i + 1, filePath];
            [self.foundFilePaths addObject:filePath];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已查找到第 %ld 个文件, 文件名不包含特定字符", i + 1];
        }
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"已经完成查找 %ld 个文件", allFilePaths.count];
    [[MRBLogManager defaultManager] showLogWithFormat:@"共找到 %ld 个包含特定字符的文件", self.foundFilePaths.count];
    
    if (self.foundFilePaths.count > 0) {
        [MRBUtilityManager exportArray:self.foundFilePaths atPath:MRBFileOperationFindSpecificCharactersExportTXTPath];
    }
}

- (void)modifyFileNames {
    if (self.characters.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"没有获得任何字符，请检查输入框"];
        return;
    }
    
    if (![[MRBFileManager defaultManager] isContentExistAtPath:MRBFileOperationFindSpecificCharactersExportTXTPath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 文件不存在，请检查", MRBFileOperationFindSpecificCharactersExportTXTPath];
        return;
    }
    
    NSError *error;
    NSString *filePathsStr = [[NSString alloc] initWithContentsOfFile:MRBFileOperationFindSpecificCharactersExportTXTPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"读取 %@ 文件内的内容失败: %@", MRBFileOperationFindSpecificCharactersExportTXTPath, error.localizedDescription];
        return;
    }
    
    NSArray *filePaths = [filePathsStr componentsSeparatedByString:@"\n"];
    [[MRBLogManager defaultManager] showLogWithFormat:@"即将开始修改 %ld 个文件", filePaths.count];
    
    for (NSInteger i = 0; i < filePaths.count; i++) {
        NSString *filePath = filePaths[i];
        // 如果文件不存在，那么可能是因为之前的操作把文件夹都改掉了
        if (![[MRBFileManager defaultManager] isContentExistAtPath:filePath]) {
            continue;
        }
        NSMutableArray *filePathComponents = [filePath.pathComponents mutableCopy];
        
        // 去除包含 / 的路径
        [filePathComponents filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable charStr, NSDictionary<NSString *,id> * _Nullable bindings) {
            return ![charStr isEqualToString:@"/"];
        }]];
        
        for (NSInteger j = 0; j < filePathComponents.count; j++) {
            for (NSInteger k = 0; k < self.characters.count; k++) {
                if ([filePathComponents[j] rangeOfString:self.characters[k]].location != NSNotFound) {
                    filePathComponents[j] = [filePathComponents[j] stringByReplacingOccurrencesOfString:self.characters[k] withString:@""];
                }
            }
        }
        
        // 补上路径前的 /
        NSString *newFilePath = [@"/" stringByAppendingString:[filePathComponents componentsJoinedByString:@"/"]];
        
        [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:newFilePath];
        [[MRBLogManager defaultManager] showLogWithFormat:@"已修改第 %ld 个文件:\n%@\n%@", i + 1, filePath, newFilePath];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"已经完成修改 %ld 个文件", filePaths.count];
    
    [[MRBFileManager defaultManager] trashFilesAtPaths:@[[NSURL fileURLWithPath:MRBFileOperationFindSpecificCharactersExportTXTPath]]];
}

@end
