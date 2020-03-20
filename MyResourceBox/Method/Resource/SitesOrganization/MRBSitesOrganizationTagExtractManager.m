//
//  MRBSitesOrganizationTagExtractManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/10.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBSitesOrganizationTagExtractManager.h"
#import "XMLReader.h"

static NSString * const kGelbooruTagXMLFilePath = @"/Users/Mercury/Documents/Tool/DanbooruDownloader/tags.xml";
static NSString * const kNeededTagsTxtPath = @"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/NeededTags.txt";
static NSString * const kNeededTagsPlistPath = @"/Users/Mercury/Documents/同步文档/MyResourceBox/FetchResource/NeededTags.plist";

@interface MRBSitesOrganizationTagExtractManager () {
    NSArray *neededTags; // 包括 copyright 和 character 的标签
}

@end

@implementation MRBSitesOrganizationTagExtractManager

- (void)prepareExtracting {
    if (![[MRBFileManager defaultManager] isContentExistAtPath:kGelbooruTagXMLFilePath]) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"%@ 文件不存在", kGelbooruTagXMLFilePath.lastPathComponent];
        return;
    }
    
    [self startReading];
    [self startExtracting];
}

- (void)startReading {
    NSError *xmlError = nil;
    NSData *xmlData = [NSData dataWithContentsOfFile:kGelbooruTagXMLFilePath];
    NSDictionary *baseXMLDict = [XMLReader dictionaryForXMLData:xmlData error:&xmlError];
    if (xmlError) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"xml 文件解析错误: %@", xmlError.localizedDescription];
        return;
    }
    
    NSArray *allTags = baseXMLDict[@"tags"][@"tag"];
    
    NSPredicate *type3Predicate = [NSPredicate predicateWithFormat:@"type = '3'"]; // type == 3 表明是一个 copyright 的标签
    NSPredicate *type4Predicate = [NSPredicate predicateWithFormat:@"type = '4'"]; // type == 4 表明是一个 character 的标签
    
    NSArray *copyrightTags = [allTags filteredArrayUsingPredicate:type3Predicate];
    NSArray *characterTags = [allTags filteredArrayUsingPredicate:type4Predicate];
    
    NSArray *copyrightTagsName = [copyrightTags valueForKey:@"name"];
    NSArray *characterTagsName = [characterTags valueForKey:@"name"];
    neededTags = [copyrightTagsName arrayByAddingObjectsFromArray:characterTagsName];
    
    [MRBUtilityManager exportArray:neededTags atPath:kNeededTagsTxtPath];
}
- (void)startExtracting {
    NSArray *firstLetters = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableArray *other = [NSMutableArray arrayWithArray:neededTags];
    
    for (NSInteger i = 0; i < firstLetters.count; i++) {
        NSString *key = firstLetters[i];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable string, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [string hasPrefix:key] || [string hasPrefix:[key uppercaseString]];
        }];
        NSArray *values = [neededTags filteredArrayUsingPredicate:predicate];
        
        [other removeObjectsInArray:values];
        [result setValue:values forKey:key];
    }
    [result setValue:other forKey:@"~other"];
    
    [MRBUtilityManager exportDictionary:result atPlistPath:kNeededTagsPlistPath];
}

@end
