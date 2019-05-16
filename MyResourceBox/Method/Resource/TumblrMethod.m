//
//  TumblrMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/01.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "TumblrMethod.h"
#import <TMAPIClient.h>
#import "TumblrPhotoObject.h"
#import "TumblrVideoObject.h"
#import "DownloadQueueManager.h"
#import "OrganizeManager.h"

typedef NS_ENUM(NSUInteger, TumblrResourceType) {
    TumblrResourceTypeFavor,
    TumblrResourceTypePhoto,
    TumblrResourceTypeVideo
};

@interface TumblrMethod () {
    NSMutableDictionary *tumblrStatuses;
    NSMutableArray *tumblrResults;
    NSString *blogName;
    NSInteger fetchCount;
    TumblrResourceType type;
}

@end

static NSString * const tumblrResultTxtFilePath = @"/Users/Mercury/Downloads/tumblrResult.txt";
static NSString * const tumblrStatusPlistFilePath = @"/Users/Mercury/Downloads/tumblrStatuses.plist";

@implementation TumblrMethod

static TumblrMethod *method;
+ (TumblrMethod *)defaultMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method = [[TumblrMethod alloc] init];
    });
    
    return method;
}

- (void)configMethod:(NSInteger)cellRow {
    [self resetPref];
    
    switch (cellRow) {
        case 1: {
            // 删除 txt 文件
            if ([[FileManager defaultManager] isContentExistAtPath:tumblrResultTxtFilePath]) {
                [[FileManager defaultManager] trashFileAtPath:tumblrResultTxtFilePath resultItemURL:nil];
            }
            
            OrganizeManager *manager = [[OrganizeManager alloc] initWithPlistPath:tumblrStatusPlistFilePath];
            [manager startOrganizing];
        }
            break;
        case 2: {
            type = TumblrResourceTypeFavor;
            [self getFavoritePhotos];
        }
            break;
        case 3: {
            type = TumblrResourceTypeFavor;
            [self getFavoriteVideos];
        }
            break;
        case 4: {
            type = TumblrResourceTypePhoto;
            [self getUserPhotos];
        }
            break;
        case 5: {
            type = TumblrResourceTypeVideo;
            [self getUserVideos];
        }
            break;
        case 6: {
            type = TumblrResourceTypePhoto;
            [self getUserFavorPhotos];
        }
            break;
        case 7: {
            type = TumblrResourceTypeVideo;
            [self getUserFavorVideos];
        }
            break;
        default:
            break;
    }
}
- (void)resetPref {
    [MRBLogManager resetCurrentDate];
    tumblrStatuses = [NSMutableDictionary dictionary];
    tumblrResults = [NSMutableArray array];
    blogName = [AppDelegate defaultVC].inputTextView.string;
    fetchCount = 0;
    [AppDelegate defaultVC].progress.doubleValue = 0.0f;
}

#pragma mark -- 收藏方法 --
- (void)getFavoritePhotos {
    [[TMAPIClient sharedInstance] likes:@{@"offset":@(fetchCount)} callback:^(id obj, NSError *error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取收藏列表接口发生错误：%@", [error localizedDescription]];
            return;
        }
        
        NSArray *list = [NSArray arrayWithArray:obj[@"liked_posts"]];
        self->fetchCount = self->fetchCount + list.count;
        
        for (NSInteger i = 0; i < list.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:list[i]];
            if (![dict[@"type"] isEqualToString:@"photo"]) {
                continue;
            }
            
            TumblrPhotoObject *object = [[TumblrPhotoObject alloc] initWithDictionary:dict];
            
            [self->tumblrStatuses setObject:object.img_urls forKey:object.id_str];
            [self->tumblrResults addObjectsFromArray:object.img_urls];
        }
        
        if (list.count == 20) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，继续查找", self->tumblrStatuses.count];
            [self simpleExportResult];
            [self getFavoritePhotos];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，完成查找", self->tumblrStatuses.count];
            [self exportResult];
        }
    }];
}
- (void)getFavoriteVideos {
    [[TMAPIClient sharedInstance] likes:@{@"offset":@(fetchCount)} callback:^(id obj, NSError *error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取收藏列表接口发生错误：%@", [error localizedDescription]];
            return;
        }
        
        NSArray *list = [NSArray arrayWithArray:obj[@"liked_posts"]];
        self->fetchCount = self->fetchCount + list.count;
        
        for (NSInteger i = 0; i < list.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:list[i]];
            if ([dict[@"type"] isEqualToString:@"video"]) {
                TumblrVideoObject *object = [[TumblrVideoObject alloc] initWithDictionary:dict];
                
                // 获取用户收藏的视频中可能会出现获取到其他类型(text, photo, etc.)的内容，需要忽略掉
                if (object.video_url) {
                    [self->tumblrStatuses setObject:object.video_url forKey:object.id_str];
                    [self->tumblrResults addObject:object.video_url];
                }
                
                continue;
            }
            
            if ([dict[@"body"] containsString:@"\"type\":\"video/mp4\""]) {
                NSData *data = [dict[@"body"] dataUsingEncoding:NSUTF8StringEncoding];
                TFHpple *hpple = [TFHpple hppleWithHTMLData:data];
                NSArray *result = [hpple searchWithXPathQuery:@"//figure"];
                TFHppleElement *element = (TFHppleElement *)result.firstObject;
                
                NSData *dataNpfData = [element.attributes[@"data-npf"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dataNpf = [NSJSONSerialization JSONObjectWithData:dataNpfData options:0 error:nil];
                
                NSString *idStr = [NSString stringWithFormat:@"%ld", [dict[@"id"] integerValue]];
                
                [self->tumblrStatuses setObject:dataNpf[@"url"] forKey:idStr];
                [self->tumblrResults addObject:dataNpf[@"url"]];
                
                continue;
            }
            
        }
        
        if (list.count == 20) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，继续查找", self->tumblrStatuses.count];
            [self simpleExportResult];
            [self getFavoriteVideos];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，完成查找", self->tumblrStatuses.count];
            [self exportResult];
        }
    }];
}
- (void)getUserFavorPhotos {
    [[TMAPIClient sharedInstance] likes:blogName parameters:@{@"type":@"photo", @"offset":@(fetchCount)} callback:^(id obj, NSError *error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取用户收藏接口发生错误：%@", [error localizedDescription]];
            return;
        }
        
        NSInteger beforeCount = self->tumblrStatuses.count;
        NSArray *list = [NSArray arrayWithArray:obj[@"liked_posts"]];
        self->fetchCount = self->fetchCount + list.count;

        for (NSInteger i = 0; i < list.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:list[i]];
            TumblrPhotoObject *object = [[TumblrPhotoObject alloc] initWithDictionary:dict];
            
            [self->tumblrStatuses setObject:object.img_urls forKey:object.id_str];
            [self->tumblrResults addObjectsFromArray:object.img_urls];
        }
        
        // 首先得要有新的内容，其次这些新的内容中至少得有一个是之前没有的，两个条件都满足之后再获取新的接口
        if (list.count > 0 && beforeCount < self->tumblrStatuses.count) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，继续查找", self->tumblrStatuses.count];
            [self simpleExportResult];
            [self getUserFavorPhotos];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，完成查找", self->tumblrStatuses.count];
            [self exportResult];
        }
    }];
}
- (void)getUserFavorVideos {
    [[TMAPIClient sharedInstance] likes:blogName parameters:@{@"type":@"video", @"offset":@(fetchCount)} callback:^(id obj, NSError *error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取用户收藏接口发生错误：%@", [error localizedDescription]];
            return;
        }
        
        NSInteger beforeCount = self->tumblrStatuses.count;
        NSArray *list = [NSArray arrayWithArray:obj[@"liked_posts"]];
        self->fetchCount = self->fetchCount + list.count;
        
        for (NSInteger i = 0; i < list.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:list[i]];
            TumblrVideoObject *object = [[TumblrVideoObject alloc] initWithDictionary:dict];
            
            // 获取用户收藏的视频中可能会出现获取到其他类型(text, photo, etc.)的内容，需要忽略掉
            if (object.video_url) {
                [self->tumblrStatuses setObject:object.video_url forKey:object.id_str];
                [self->tumblrResults addObject:object.video_url];
            }
        }
        
        // 首先得要有新的内容，其次这些新的内容中至少得有一个是之前没有的，两个条件都满足之后再获取新的接口
        if (list.count > 0 && beforeCount < self->tumblrStatuses.count) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，继续查找", self->tumblrStatuses.count];
            [self simpleExportResult];
            [self getUserFavorVideos];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，完成查找", self->tumblrStatuses.count];
            [self exportResult];
        }
    }];
}

#pragma mark -- 资源方法 --
- (void)getUserPhotos {
    [[TMAPIClient sharedInstance] posts:blogName type:@"photo" parameters:@{@"offset":@(fetchCount)} callback:^(id obj, NSError *error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取用户图片接口发生错误：%@", [error localizedDescription]];
            return;
        }
        
        NSArray *list = [NSArray arrayWithArray:obj[@"posts"]];
        self->fetchCount = self->fetchCount + list.count;
        
        for (NSInteger i = 0; i < list.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:list[i]];
            TumblrPhotoObject *object = [[TumblrPhotoObject alloc] initWithDictionary:dict];
            
            [self->tumblrStatuses setObject:object.img_urls forKey:object.id_str];
            [self->tumblrResults addObjectsFromArray:object.img_urls];
        }
        
        if (list.count == 20) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，继续查找", self->tumblrStatuses.count];
            [self simpleExportResult];
            [self getUserPhotos];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，完成查找", self->tumblrStatuses.count];
            [self exportResult];
        }
    }];
}
- (void)getUserVideos {
    [[TMAPIClient sharedInstance] posts:blogName type:@"video" parameters:@{@"offset":@(fetchCount)} callback:^(id obj, NSError *error) {
        if (error) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"获取用户视频接口发生错误：%@，当前offset为: %ld", error.localizedDescription, self->fetchCount];
            [self getUserVideos];
            return;
        }
        
        NSArray *list = [NSArray arrayWithArray:obj[@"posts"]];
        self->fetchCount = self->fetchCount + list.count;
        
        for (NSInteger i = 0; i < list.count; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:list[i]];
            TumblrVideoObject *object = [[TumblrVideoObject alloc] initWithDictionary:dict];
            
            // 可能会出现获取到其他类型(text, photo, etc.)的内容，需要忽略掉
            // 可能会出现获取到非Tumblr的视频地址，需要忽略掉
            if (object.video_url && [object.video_type isEqualToString:@"tumblr"]) {
                @synchronized (self->tumblrStatuses) {
                    [self->tumblrStatuses setObject:object.video_url forKey:object.id_str];
                }
                @synchronized (self->tumblrResults) {
                    [self->tumblrResults addObject:object.video_url];
                }
            }
        }
        
        if (list.count == 20) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，继续查找", self->tumblrStatuses.count];
            [self simpleExportResult];
            [self getUserVideos];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"已经获取到%ld条记录中的地址，完成查找", self->tumblrStatuses.count];
            [self exportResult];
        }
    }];
}

#pragma mark -- 辅助方法 --
- (void)simpleExportResult {
    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:tumblrResults];
    tumblrResults = [NSMutableArray arrayWithArray:set.array];
    
    [MRBUtilityManager exportArray:tumblrResults atPath:tumblrResultTxtFilePath];
}
- (void)exportResult {
    if (tumblrResults.count > 0) {
        // 使用NSSet进行一次去重的操作
        NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:tumblrResults];
        tumblrResults = [NSMutableArray arrayWithArray:set.array];
        [MRBUtilityManager exportArray:tumblrResults atPath:tumblrResultTxtFilePath];
        if (type != TumblrResourceTypeVideo) { // 视频文件就不用排列了
            [tumblrStatuses writeToFile:tumblrStatusPlistFilePath atomically:YES];
        }
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"流程已经完成，共抓取了 %ld 条Tumblr Post，其中 %ld 条资源地址被获取到", fetchCount, tumblrResults.count];
        DDLogInfo(@"资源地址是：%@", tumblrResults);
        
        if (type != TumblrResourceTypeVideo) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"1秒后开始下载"];
            [self performSelector:@selector(startDownload) withObject:nil afterDelay:1.0f];
        }
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"未发现可下载的资源"];
        return;
    }
}
- (void)startDownload {
    DownloadQueueManager *manager = [[DownloadQueueManager alloc] initWithUrls:tumblrResults];
    manager.downloadPath = [@"/Users/Mercury/Downloads/Tumblr" stringByAppendingPathComponent:blogName];
    [manager startDownload];
}

@end
