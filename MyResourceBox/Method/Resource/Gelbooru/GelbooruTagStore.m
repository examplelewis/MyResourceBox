//
//  GelbooruTagStore.m
//  MyResourceBox
//
//  Created by 龚宇 on 18/12/14.
//  Copyright © 2018 gongyuTest. All rights reserved.
//

#import "GelbooruTagStore.h"
#import "XMLReader.h"
#import "HttpManager.h"

@interface GelbooruTagStore () {
    NSString *tagsFolderPath; // Tags 文件夹的路径
    NSString *neededTagsFolderPath; // NeededTags 文件夹的路径
    NSArray *neededTagsKeys; // NeededTags 的首字母
    NSArray *neededTagsFilePaths; // NeededTags 按照首字母排序后的文件路径
    
    NSArray *neededTags; // 多个数组，按照 neededTagsKeys 的顺序排列
    NSInteger pid;
    
    NSArray *animeTags;
    NSArray *gameTags;
    NSArray *hTags;
}

@end

@implementation GelbooruTagStore

static GelbooruTagStore *request;
+ (GelbooruTagStore *)defaultManager {
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        request = [[GelbooruTagStore alloc] init];
    });
    
    return request;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        tagsFolderPath = [rootPath stringByAppendingPathComponent:@"同步文档/MyResourceBox/Tags"];
        neededTagsFolderPath = [rootPath stringByAppendingPathComponent:@"同步文档/MyResourceBox/Tags/NeededTags"];
        
        NSAssert([[FileManager defaultManager] isContentExistAtPath:tagsFolderPath], @"Tags 文件夹不存在");
        NSAssert([[FileManager defaultManager] isContentExistAtPath:neededTagsFolderPath], @"NeededTags 文件夹不存在");
        
        neededTagsKeys = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"~other"];
        
        [self readNeededTags];
        [self readTypedTags];
    }
    
    return self;
}

- (void)readNeededTags {
    if ([[FileManager defaultManager] getFilePathsInFolder:neededTagsFolderPath].count == 0) {
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < neededTagsKeys.count; i++) {
        NSString *key = neededTagsKeys[i];
        
        NSString *destPath = [neededTagsFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", key]];
        NSString *value = [NSString stringWithContentsOfFile:destPath encoding:NSUTF8StringEncoding error:nil];
        NSArray *values = [value componentsSeparatedByString:@"\n"];
        
        [array addObject:values];
    }
    
    neededTags = [NSArray arrayWithArray:array];
}
- (void)readTypedTags {
    NSString *animeTagsStr = [[NSString alloc] initWithContentsOfFile:@"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/AnimeTags.txt" encoding:NSUTF8StringEncoding error:nil];
    animeTags = [animeTagsStr componentsSeparatedByString:@"\n"];
    NSString *gameTagsStr = [[NSString alloc] initWithContentsOfFile:@"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/GameTags.txt" encoding:NSUTF8StringEncoding error:nil];
    gameTags = [gameTagsStr componentsSeparatedByString:@"\n"];
    NSString *hTagsStr = [[NSString alloc] initWithContentsOfFile:@"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/HTags.txt" encoding:NSUTF8StringEncoding error:nil];
    hTags = [hTagsStr componentsSeparatedByString:@"\n"];
}

#pragma mark - 查找需要的 Copyright 标签
- (NSString *)getNeededCopyrightTags:(NSArray *)tags {
    NSMutableArray *results = [NSMutableArray array]; // 包含的有用的 tag
    
    for (NSInteger i = 0; i < tags.count; i++) {
        NSString *tag = tags[i];
        
        if (tag.length == 0) {
            continue;
        }
        
        // 通过 tag 的首字母来获取在 neededTagsKeys 数组中的位置，同样也是所需数组在 neededTags 中的位置
        // 如果找不到，说明可能在 ~other 那个数组里面
        NSString *firstLetter = [tag substringWithRange:NSMakeRange(0, 1)];
        NSInteger index = [neededTagsKeys indexOfObject:firstLetter];
        if (index == NSNotFound) {
            index = neededTagsKeys.count - 1;
        }
        
        NSArray *letterArray = [NSArray arrayWithArray:neededTags[index]];
        if ([letterArray containsObject:tag]) {
            [results addObject:tag];
        }
    }
    
    return [results componentsJoinedByString:@"+"];
}
- (BOOL)checkTagsHasNeededCopyright:(NSArray *)tags {
    return [self getNeededCopyrightTags:tags].length > 0;
}

#pragma mark - 查找感兴趣的标签[动漫/游戏]
- (NSString *)getAnimeTags:(NSString *)tags {
    NSMutableArray *results = [NSMutableArray array]; // 包含的有用的 tag
    
    for (NSInteger i = 0; i < animeTags.count; i++) {
        NSString *animeTag = animeTags[i]; // 本地存储的 tag，tag 本身可能不全
        
        if ([tags containsString:animeTag]) {
            [results addObject:animeTag];
        }
    }
    
    return [results componentsJoinedByString:@"+"];
}
- (NSString *)getGameTags:(NSString *)tags {
    NSMutableArray *results = [NSMutableArray array]; // 包含的有用的 tag
    
    for (NSInteger i = 0; i < gameTags.count; i++) {
        NSString *gameTag = gameTags[i]; // 本地存储的 tag，tag 本身可能不全
        
        if ([tags containsString:gameTag]) {
            [results addObject:gameTag];
        }
    }
    
    return [results componentsJoinedByString:@"+"];
}
- (NSString *)getHTags:(NSString *)tags {
    NSMutableArray *results = [NSMutableArray array]; // 包含的有用的 tag
    
    for (NSInteger i = 0; i < hTags.count; i++) {
        NSString *hTag = hTags[i]; // 本地存储的 tag，tag 本身可能不全
        
        if ([tags containsString:hTag]) {
            [results addObject:hTag];
        }
    }
    
    return [results componentsJoinedByString:@"+"];
}

#pragma mark - 移除标签
// 去除无用的 webm 标签
- (NSString *)removeUselessWebmTags:(NSString *)tags {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *tagComp = [tags componentsSeparatedByString:@" "];
    
    for (NSInteger i = 0; i < tagComp.count; i++) {
        NSString *tag = tagComp[i];
        
        if ([tag containsString:@"boy"] || [tag containsString:@"girl"]) {
            continue;
        }
        if ([tag isEqualToString:@"animated"] || [tag isEqualToString:@"webm"] || [tag isEqualToString:@"tagme"] || [tag isEqualToString:@"photo"] || [tag isEqualToString:@"audio"]) {
            continue;
        }
        if ([tag containsString:@"censored"]) {
            continue;
        }
        if ([tag isEqualToString:@"asian"]) {
            continue;
        }
        
        [result addObject:tag];
    }
    
    NSString *resultStr = [result componentsJoinedByString:@" "];
    if (resultStr.length > 230) {
        resultStr = [resultStr substringToIndex:230];
    }
    
    return resultStr;
}

@end
