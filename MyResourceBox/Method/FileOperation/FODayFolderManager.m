//
//  FODayFolderManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "FODayFolderManager.h"
#import "FileManager.h"
#import "ImageManager.h"

@implementation FODayFolderManager

+ (void)start {
    [UtilityFile resetCurrentDate];
    [[UtilityFile sharedInstance] showLogWithFormat:@"整理Day文件夹：流程准备开始"];
    
    [self moveGIFFileToProperFolder];
}
+ (void)moveGIFFileToProperFolder {
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t g = dispatch_group_create();
    NSArray<NSString *> *fromGifFilePaths = [[FileManager defaultManager] getFilePathsInFolder:@"/Users/Mercury/Pictures/Day" specificExtensions:@[@"gif"]];
    
    for (NSInteger i = 0; i < fromGifFilePaths.count; i++) {
        dispatch_group_async(g, q, ^{
            NSString *oriPath = fromGifFilePaths[i];
            NSString *destPath = [oriPath stringByReplacingOccurrencesOfString:@"/Users/Mercury/Pictures/Day" withString:@"/Users/Mercury/CloudStation/网络图片/动图"];
            
            [[FileManager defaultManager] moveItemAtPath:oriPath toDestPath:destPath];
        });
    }
    
    WS(weakSelf);
    dispatch_group_notify(g, q, ^{
        [[UtilityFile sharedInstance] showLogWithFormat:@"移动GIF：流程已经结束"];
        
        dispatch_main_sync_safe(^{
            [weakSelf trashSmallSizedPhotos];
        });
    });
}
+ (void)trashSmallSizedPhotos {
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t g = dispatch_group_create();
    NSArray<NSString *> *imageFilePaths = [[FileManager defaultManager] getFilePathsInFolder:@"/Users/Mercury/Pictures/Day" specificExtensions:@[@"jpg", @"jpeg", @"png"]];
    
    for (NSInteger i = 0; i < imageFilePaths.count; i++) {
        dispatch_group_async(g, q, ^{
            NSString *imageFilePath = imageFilePaths[i];
            NSSize size = [ImageManager getActualImageSizeWithPhotoAtPath:imageFilePath];
            if (size.width < 801 && size.height < 801) {
                NSString *destFilePath = [imageFilePath stringByReplacingOccurrencesOfString:@"/Users/Mercury/Pictures/Day" withString:@"/Users/Mercury/.Trash"];
                
                [[FileManager defaultManager] moveItemAtPath:imageFilePath toDestPath:destFilePath];
            }
        });
    }
    
    WS(weakSelf);
    dispatch_group_notify(g, q, ^{
        [[UtilityFile sharedInstance] showLogWithFormat:@"删除小尺寸图片：流程已经结束"];
        
        dispatch_main_sync_safe(^{
            [weakSelf moveFilesToSpecificFolder];
        });
    });
}
+ (void)moveFilesToSpecificFolder {
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t g = dispatch_group_create();
    NSArray<NSString *> *fromImageFilePaths = [[FileManager defaultManager] getFilePathsInFolder:@"/Users/Mercury/Pictures/Day" specificExtensions:@[@"jpg", @"jpeg", @"png"]];
    
    for (NSInteger i = 0; i < fromImageFilePaths.count; i++) {
        dispatch_group_async(g, q, ^{
            NSString *oriFilePath = fromImageFilePaths[i];
            NSDate *creationDate = (NSDate *)[[FileManager defaultManager] getSpecificAttributeOfItemAtPath:oriFilePath attribute:NSFileCreationDate];
            NSInteger integer = [creationDate weekday];
            integer--;
            if (integer == 0) integer = 7;
            
            NSString *destFilePath = [NSString stringWithFormat:@"/Users/Mercury/Pictures/Day/%ld/%@", integer, oriFilePath.lastPathComponent];
            
            [[FileManager defaultManager] moveItemAtPath:oriFilePath toDestPath:destFilePath];
        });
    }
    
    dispatch_group_notify(g, q, ^{
        [[UtilityFile sharedInstance] showLogWithFormat:@"移动图片：流程已经结束"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"整理Day文件夹：流程已经结束"];
    });
}

@end
