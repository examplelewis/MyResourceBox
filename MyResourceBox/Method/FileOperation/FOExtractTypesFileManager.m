//
//  FOExtractTypesFileManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/07/25.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "FOExtractTypesFileManager.h"
#import "FOExtractTypesFileModel.h"

@interface FOExtractTypesFileManager () {
    NSString *rootFolder;
    NSArray *specificTypes;
    NSMutableArray *models;
}

@end

@implementation FOExtractTypesFileManager

- (void)startExtractingSpecificTypes:(NSArray *)types {
    if (types && types.count > 0) {
        specificTypes = [NSArray arrayWithArray:types];
    } else {
        NSString *input = [AppDelegate defaultVC].inputTextView.string;
        if (input.length == 0) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"请输入需要提取的类型，多个类型请用英文逗号,分开"];
            return;
        }
        
        specificTypes = [input componentsSeparatedByString:@","];
    }
    
    [self chooseRootFolder];
}
- (void)chooseRootFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"选择需要提取的文件夹"];
    panel.prompt = @"选择";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    panel.directoryURL = [NSURL fileURLWithPath:@"/Users/Mercury/Downloads"];
    
    [panel beginSheetModalForWindow:[AppDelegate defaultWindow] completionHandler:^(NSInteger result) {
        if (result == 1) {
            NSURL *fileUrl = [panel URLs].firstObject;
            self->rootFolder = [fileUrl path];
            [[MRBLogManager defaultManager] showLogWithFormat:@"已选择路径：%@", self->rootFolder];
            
            [self startExtracting];
        }
    }];
}

- (void)startExtracting {
    [[MRBLogManager defaultManager] showLogWithFormat:@"提取 %@ 类型的文件，流程即将开始", [specificTypes componentsJoinedByString:@" ,"]];
    
    models = [NSMutableArray array];
    NSArray *subPaths = [[MRBFileManager defaultManager] getSubFilePathsInFolder:rootFolder];
    
    NSInteger totalCount = 0;
    for (NSInteger i = 0; i < subPaths.count; i++) {
        NSString *subfilePath = subPaths[i];
        if (![specificTypes containsObject:subfilePath.pathExtension]) {
            continue;
        }
        
        totalCount += 1;
        
//        FOExtractTypesFileModel *model = [FOExtractTypesFileModel new];
//        model.type = subfilePath.pathExtension;
//        model.original = subfilePath;
//        model.rootFolder = rootFolder;
//        [model setupData];
//
//        if (![[MRBFileManager defaultManager] isContentExistAtPath:model.containerFolder]) {
//            [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:model.containerFolder];
//        }
//        [[MRBFileManager defaultManager] moveItemAtPath:model.original toDestPath:model.target];
    }
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"提取 %@ 类型的文件，流程已经结束", [specificTypes componentsJoinedByString:@" ,"]];
}
- (void)startMoving {
    
}

@end
