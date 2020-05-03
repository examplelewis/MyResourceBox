//
//  MRBResourceGlobalTagManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/10.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBResourceGlobalTagManager.h"

static NSString * const kResourceTagsFilePath = @"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/ResourceTags.plist";
static NSString * const kNeededTagsFilePath = @"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/NeededTags.plist";
static NSString * const kNeededTagsTxtFilePath = @"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/NeededTags.txt";
static NSString * const kRenameUselessTagsFilePath = @"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/RenameUselessTags.plist";

@interface MRBResourceGlobalTagManager () {
    NSString *neededTagsFolderPath; // NeededTags 文件夹的路径
    NSArray *neededTagsKeys; // NeededTags 的首字母
    NSArray *animeTags;
    NSArray *gameTags;
    NSArray *hTags;
    
    
    
    NSDictionary *neededTags;
    NSSet *neededTagsSet;
    
    NSArray *gelbooruAnimeTags;
    NSArray *gelbooruGameTags;
    NSArray *gelbooruHTags;
    
    NSArray *rule34AnimeTags;
    NSArray *rule34GameTags;
    NSArray *rule34HTags;
    
    NSSet *gelbooruAnimeTagsSet;
    NSSet *gelbooruGameTagsSet;
    NSSet *gelbooruHTagsSet;
    
    NSSet *rule34AnimeTagsSet;
    NSSet *rule34GameTagsSet;
    NSSet *rule34HTagsSet;
    
    NSArray *renameUselessTags;
}

@end


@implementation MRBResourceGlobalTagManager

#pragma mark - Lifecycle
static MRBResourceGlobalTagManager *request;
+ (MRBResourceGlobalTagManager *)defaultManager {
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        request = [[MRBResourceGlobalTagManager alloc] init];
    });
    
    return request;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self readAndExtract];
    }
    
    return self;
}

#pragma mark - Logic
- (void)readAndExtract {
    // resouceTags
    NSDictionary *resouceTags = [NSDictionary dictionaryWithContentsOfFile:kResourceTagsFilePath];
    NSArray *defaultAnimeTags = resouceTags[@"defaultAnime"];
    NSArray *defaultGameTags = resouceTags[@"defaultGame"];
    NSArray *defaultHTags = resouceTags[@"defaultH"];
    NSArray *gelbooruAnimeAdd = resouceTags[@"gelbooruAnimeAdd"];
    NSArray *gelbooruAnimeRemove = resouceTags[@"gelbooruAnimeRemove"];
    NSArray *gelbooruGameAdd = resouceTags[@"gelbooruGameAdd"];
    NSArray *gelbooruGameRemove = resouceTags[@"gelbooruGameRemove"];
    NSArray *gelbooruHAdd = resouceTags[@"gelbooruHAdd"];
    NSArray *gelbooruHRemove = resouceTags[@"gelbooruHRemove"];
    NSArray *rule34AnimeAdd = resouceTags[@"rule34AnimeAdd"];
    NSArray *rule34AnimeRemove = resouceTags[@"rule34AnimeRemove"];
    NSArray *rule34GameAdd = resouceTags[@"rule34GameAdd"];
    NSArray *rule34GameRemove = resouceTags[@"rule34GameRemove"];
    NSArray *rule34HAdd = resouceTags[@"rule34HAdd"];
    NSArray *rule34HRemove = resouceTags[@"rule34HRemove"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF BEGINSWITH '//')"];
    
    NSMutableArray *mutableGelbooruAnimeTags = [NSMutableArray arrayWithArray:defaultAnimeTags];
    [mutableGelbooruAnimeTags addObjectsFromArray:gelbooruAnimeAdd];
    [mutableGelbooruAnimeTags removeObjectsInArray:gelbooruAnimeRemove];
    [mutableGelbooruAnimeTags filterUsingPredicate:predicate];
    [self removeSpaceInTagsFromArray:mutableGelbooruAnimeTags];
    gelbooruAnimeTags = [mutableGelbooruAnimeTags copy];
    gelbooruAnimeTagsSet = [NSSet setWithArray:gelbooruAnimeTags];
    
    NSMutableArray *mutableGelbooruGameTags = [NSMutableArray arrayWithArray:defaultGameTags];
    [mutableGelbooruGameTags addObjectsFromArray:gelbooruGameAdd];
    [mutableGelbooruGameTags removeObjectsInArray:gelbooruGameRemove];
    [mutableGelbooruGameTags filterUsingPredicate:predicate];
    [self removeSpaceInTagsFromArray:mutableGelbooruGameTags];
    gelbooruGameTags = [mutableGelbooruGameTags copy];
    gelbooruGameTagsSet = [NSSet setWithArray:gelbooruGameTags];
    
    NSMutableArray *mutableGelbooruHTags = [NSMutableArray arrayWithArray:defaultHTags];
    [mutableGelbooruHTags addObjectsFromArray:gelbooruHAdd];
    [mutableGelbooruHTags removeObjectsInArray:gelbooruHRemove];
    [mutableGelbooruHTags filterUsingPredicate:predicate];
    [self removeSpaceInTagsFromArray:mutableGelbooruHTags];
    gelbooruHTags = [mutableGelbooruHTags copy];
    gelbooruHTagsSet = [NSSet setWithArray:gelbooruHTags];
    
    NSMutableArray *mutableRule34AnimeTags = [NSMutableArray arrayWithArray:defaultAnimeTags];
    [mutableRule34AnimeTags addObjectsFromArray:rule34AnimeAdd];
    [mutableRule34AnimeTags removeObjectsInArray:rule34AnimeRemove];
    [mutableRule34AnimeTags filterUsingPredicate:predicate];
    [self removeSpaceInTagsFromArray:mutableRule34AnimeTags];
    rule34AnimeTags = [mutableRule34AnimeTags copy];
    rule34AnimeTagsSet = [NSSet setWithArray:rule34AnimeTags];
    
    NSMutableArray *mutableRule34GameTags = [NSMutableArray arrayWithArray:defaultGameTags];
    [mutableRule34GameTags addObjectsFromArray:rule34GameAdd];
    [mutableRule34GameTags removeObjectsInArray:rule34GameRemove];
    [mutableRule34GameTags filterUsingPredicate:predicate];
    [self removeSpaceInTagsFromArray:mutableRule34GameTags];
    rule34GameTags = [mutableRule34GameTags copy];
    rule34GameTagsSet = [NSSet setWithArray:rule34GameTags];
    
    NSMutableArray *mutableRule34HTags = [NSMutableArray arrayWithArray:defaultHTags];
    [mutableRule34HTags addObjectsFromArray:rule34HAdd];
    [mutableRule34HTags removeObjectsInArray:rule34HRemove];
    [mutableRule34HTags filterUsingPredicate:predicate];
    [self removeSpaceInTagsFromArray:mutableRule34HTags];
    rule34HTags = [mutableRule34HTags copy];
    rule34HTagsSet = [NSSet setWithArray:rule34HTags];
    
    
    // renameUselessTags
    NSArray *uselessTag = [NSArray arrayWithContentsOfFile:kRenameUselessTagsFilePath];
    NSMutableArray *mutableRenameUselessTags = [NSMutableArray array];
    for (NSInteger i = 0; i < uselessTag.count; i++) {
        if (![uselessTag[i] isKindOfClass:[NSArray class]]) {
            continue;
        }
        
        [mutableRenameUselessTags addObjectsFromArray:((NSArray *)uselessTag[i])];
    }
    [self removeSpaceInTagsFromArray:mutableRenameUselessTags];
    renameUselessTags = [mutableRenameUselessTags copy];
    
    
    // neededTags
    neededTags = [NSDictionary dictionaryWithContentsOfFile:kNeededTagsFilePath];
    NSString *neededTagString = [NSString stringWithContentsOfFile:kNeededTagsTxtFilePath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *mutableNeededTagsArray = [NSMutableArray arrayWithArray:[neededTagString componentsSeparatedByString:@"\n"]];
    [self removeSpaceInTagsFromArray:mutableNeededTagsArray];
    neededTagsSet = [NSSet setWithArray:[mutableNeededTagsArray copy]];
}

- (void)removeSpaceInTagsFromArray:(NSMutableArray *)array {
    for (NSInteger i = 0; i < array.count; i++) {
        NSString *tag = array[i];
        array[i] = [tag stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

#pragma mark - 查找需要的 Copyright 标签
- (NSString *)extractUsefulTagsFromTagsString:(NSString *)tagStr {
//    NSArray *tags = [tagStr componentsSeparatedByString:@" "];
//    NSMutableArray *usefulTags = [NSMutableArray array];
//    NSCharacterSet *alphabetAndNumberSet = [NSCharacterSet alphanumericCharacterSet];
//
//    for (NSInteger i = 0; i < tags.count; i++) {
//        NSString *tag = tags[i];
//        NSString *tagFirstLetter = [tag substringToIndex:1];
//
//        NSArray *sourceArray;
//        if ([tagFirstLetter rangeOfCharacterFromSet:alphabetAndNumberSet].location == NSNotFound) {
//            sourceArray = neededTags[@"~other"];
//        } else {
//            sourceArray = neededTags[tagFirstLetter];
//        }
//
//        if ([sourceArray indexOfObject:tag] != NSNotFound) {
//
//        }
//    }
     
    NSArray *tagsArray = [tagStr componentsSeparatedByString:@" "];
    tagsArray = [tagsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]]; // 去除 空字符串 的 tag
    NSMutableSet *tags = [NSMutableSet setWithArray:tagsArray];
    [tags intersectSet:neededTagsSet];
    
    return [tags.allObjects componentsJoinedByString:@"+"];
}
- (BOOL)didHaveUsefulTagsFromTagsString:(NSString *)tagStr {
    return [self extractUsefulTagsFromTagsString:tagStr].length > 0;
}

#pragma mark - 查找感兴趣的标签[动漫/游戏]
- (NSString *)extractAnimeTagsFromTags:(NSString *)tags atSite:(MRBResourceGlobalTagSite)site {
//    NSMutableArray *results = [NSMutableArray array]; // 包含的有用的 tag
//
//    for (NSInteger i = 0; i < animeTags.count; i++) {
//        NSString *animeTag = animeTags[i]; // 本地存储的 tag，tag 本身可能不全
//
//        if ([tags containsString:animeTag]) {
//            [results addObject:animeTag];
//        }
//    }
//
//    return [results componentsJoinedByString:@"+"];
    
    NSMutableSet *tagsSet = [NSMutableSet setWithArray:[tags componentsSeparatedByString:@" "]];
    switch (site) {
        case MRBResourceGlobalTagSiteGelbooru: {
            [tagsSet intersectSet:gelbooruAnimeTagsSet];
        }
            break;
        case MRBResourceGlobalTagSiteRule34: {
            [tagsSet intersectSet:rule34AnimeTagsSet];
        }
            break;
        default: {
            [tagsSet removeAllObjects];
        }
            break;
    }
    
    return [tagsSet.allObjects componentsJoinedByString:@"+"];
}
- (NSString *)extractGameTagsFromTags:(NSString *)tags atSite:(MRBResourceGlobalTagSite)site {
//    NSMutableArray *results = [NSMutableArray array]; // 包含的有用的 tag
//
//    for (NSInteger i = 0; i < gameTags.count; i++) {
//        NSString *gameTag = gameTags[i]; // 本地存储的 tag，tag 本身可能不全
//
//        if ([tags containsString:gameTag]) {
//            [results addObject:gameTag];
//        }
//    }
//
//    return [results componentsJoinedByString:@"+"];
    
    NSMutableSet *tagsSet = [NSMutableSet setWithArray:[tags componentsSeparatedByString:@" "]];
    switch (site) {
        case MRBResourceGlobalTagSiteGelbooru: {
            [tagsSet intersectSet:gelbooruGameTagsSet];
        }
            break;
        case MRBResourceGlobalTagSiteRule34: {
            [tagsSet intersectSet:rule34GameTagsSet];
        }
            break;
        default: {
            [tagsSet removeAllObjects];
        }
            break;
    }
    
    return [tagsSet.allObjects componentsJoinedByString:@"+"];
}
- (NSString *)extractHTagsFromTags:(NSString *)tags atSite:(MRBResourceGlobalTagSite)site {
//    NSMutableArray *results = [NSMutableArray array]; // 包含的有用的 tag
//
//    for (NSInteger i = 0; i < hTags.count; i++) {
//        NSString *hTag = hTags[i]; // 本地存储的 tag，tag 本身可能不全
//
//        if ([tags containsString:hTag]) {
//            [results addObject:hTag];
//        }
//    }
//
//    return [results componentsJoinedByString:@"+"];
    
    NSMutableSet *tagsSet = [NSMutableSet setWithArray:[tags componentsSeparatedByString:@" "]];
    switch (site) {
        case MRBResourceGlobalTagSiteGelbooru: {
            [tagsSet intersectSet:gelbooruHTagsSet];
        }
            break;
        case MRBResourceGlobalTagSiteRule34: {
            [tagsSet intersectSet:rule34HTagsSet];
        }
            break;
        default: {
            [tagsSet removeAllObjects];
        }
            break;
    }
    
    return [tagsSet.allObjects componentsJoinedByString:@"+"];
}

#pragma mark - 移除标签
// 去除无用的 webm 标签
- (NSString *)removeUselessTagsFromTags:(NSString *)tags {
    NSMutableArray *allTags = [NSMutableArray arrayWithArray:[tags componentsSeparatedByString:@" "]];
    [allTags removeObjectsInArray:renameUselessTags];
    
    NSString *resultStr = [allTags componentsJoinedByString:@" "];
    if (resultStr.length > 230) {
        resultStr = [resultStr substringToIndex:230];
    }
    
    return resultStr;
}

@end
