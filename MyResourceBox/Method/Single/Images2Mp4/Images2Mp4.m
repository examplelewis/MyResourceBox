//
//  Images2Mp4.m
//  MyResourceBox
//
//  Created by 龚宇 on 18/07/26.
//  Copyright © 2018年 gongyuTest. All rights reserved.
//

#import "Images2Mp4.h"
#import "HJImagesToVideo.h"
#import "ImageManager.h"

@interface Images2Mp4 () {
    NSString *rootFolder;
    NSArray *folders;
    NSInteger currentIndex;
    NSMutableArray *failure;
}

@end

@implementation Images2Mp4

- (instancetype)initWithRootFolder:(NSString *)root {
    self = [super init];
    if (self) {
        rootFolder = root;
    }
    
    return self;
}

- (void)readAllFiles {
    NSArray *subFolders = [[FileManager defaultManager] getFolderPathsInFolder:rootFolder];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    folders = [subFolders sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    }];
}

- (void)startTranscoding {
    currentIndex = 0;
    failure = [NSMutableArray array];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"转码操作开始"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startSingleTranscoding];
    });
}

- (void)startSingleTranscoding {
    if (currentIndex == folders.count) {
        [self finishTranscoding];
        return;
    }
    
    NSDictionary *folder = [self getSingleFolderImages];
    NSArray *images = folder[@"images"];
    NSString *path = [rootFolder stringByAppendingPathComponent:folder[@"folder"]];
    path = [path stringByAppendingString:@".mp4"];
    NSSize size = [folder[@"size"] sizeValue];
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"开始处理第 %ld 个文件夹: %@", currentIndex, path];
    
    [HJImagesToVideo videoFromImages:images toPath:path withSize:size withFPS:10 animateTransitions:YES withCallbackBlock:^(BOOL success) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"第 %ld 个文件夹: %@ 处理 %@", self->currentIndex + 1, path, success ? @"成功" : @"失败"];
        if (!success) {
            [self->failure addObject:path];
        }
        
        self->currentIndex += 1;
        [self startSingleTranscoding];
    }];
}

- (void)finishTranscoding {
    if (failure.count > 0) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"转码过程中出现部分错误，请查看: /Users/Mercury/Downloads/Image2Mp4Failure.txt"];
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@", [UtilityFile convertResultArray:failure]];
        [UtilityFile exportArray:failure atPath:@"/Users/Mercury/Downloads/Image2Mp4Failure.txt"];
    }
    
    [[UtilityFile sharedInstance] showLogWithFormat:@"转码操作结束"];
}

- (NSDictionary *)getSingleFolderImages {
    NSString *subFolder = folders[currentIndex];
    NSString *subFolderName = subFolder.lastPathComponent.stringByDeletingPathExtension;
    
    NSArray *originalImagePaths = [[FileManager defaultManager] getFilePathsInFolder:subFolder];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSArray *imagePaths = [originalImagePaths sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    }];
    
    NSSize size = [[ImageManager defaultManager] getActualImageSizeWithPhotoAtPath:imagePaths[0]];
    
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger j = 0; j < imagePaths.count; j++) {
        NSString *imagePath = imagePaths[j];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
        [images addObject:image];
    }
    
    return @{@"folder": subFolderName, @"images": images, @"size": [NSValue valueWithSize:size]};
}

@end
