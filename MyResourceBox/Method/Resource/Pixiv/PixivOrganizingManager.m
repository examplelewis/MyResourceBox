//
//  PixivOrganizingManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/04/30.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PixivOrganizingManager.h"

@implementation PixivOrganizingManager

+ (void)organizePixivPhotos {
    NSString *folderPath = [AppDelegate defaultVC].inputTextView.string;
    if (folderPath.length == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"请输入Pixiv用户根目录的文件夹路径"];
        return;
    }
    
    NSArray *filePaths = [[MRBFileManager defaultManager] getFilePathsInFolder:folderPath];
    NSArray *pixivIds = [filePaths bk_map:^id(NSString *filePath) {
        return [filePath.lastPathComponent substringWithRange:NSMakeRange(0, 8)];
    }];
    NSOrderedSet *pixivIdSet = [NSOrderedSet orderedSetWithArray:pixivIds];
    pixivIds = pixivIdSet.array;
    
    for (NSInteger i = 0; i < pixivIds.count; i++) {
        NSString *pixivId = pixivIds[i];
        NSArray *filter = [filePaths bk_select:^BOOL(NSString *filePath) {
            return [filePath containsString:pixivId];
        }];
        
        NSString *pixivIdFolderPath = [folderPath stringByAppendingPathComponent:pixivId];
        [[MRBFileManager defaultManager] createFolderAtPathIfNotExist:pixivIdFolderPath];
        
        [filter bk_each:^(NSString *filePath) {
            NSString *fileName = filePath.lastPathComponent;
            NSString *destPath = [pixivIdFolderPath stringByAppendingPathComponent:fileName];
            
            [[MRBFileManager defaultManager] moveItemAtPath:filePath toDestPath:destPath];
        }];
    }
}

@end
