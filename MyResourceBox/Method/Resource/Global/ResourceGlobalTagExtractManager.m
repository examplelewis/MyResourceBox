//
//  ResourceGlobalTagExtractManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/10.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ResourceGlobalTagExtractManager.h"
#import "XMLReader.h"

static NSString * const kGelbooruTagXMLFilePath = @"/Users/Mercury/Documents/Tool/DanbooruDownloader/tags.xml";
static NSString * const kNeededTagsFolderPath = @"/Users/Mercury/Documents/同步文档/MyResourceBox/Tags/NeededTags";

@interface ResourceGlobalTagExtractManager () {
    NSArray *firstLetters;
    NSArray *neededTagsName; // 包括 copyright 和 character 的标签
}

@end

@implementation ResourceGlobalTagExtractManager

- (void)prepareExtracting {
    if (![[FileManager defaultManager] isContentExistAtPath:kGelbooruTagXMLFilePath]) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"%@ 文件不存在", kGelbooruTagXMLFilePath.lastPathComponent];
        return;
    }
    
    [self startReading];
}

- (void)startReading {
    NSError *xmlError = nil;
    NSData *xmlData = [NSData dataWithContentsOfFile:kGelbooruTagXMLFilePath];
    NSDictionary *baseXMLDict = [XMLReader dictionaryForXMLData:xmlData error:&xmlError];
    if (xmlError) {
        [[UtilityFile sharedInstance] showLogWithFormat:@"xml 文件解析错误: %@", xmlError.localizedDescription];
        return;
    }
    
    NSArray *allTags = baseXMLDict[@"tags"][@"tag"];
    
    NSPredicate *type3Predicate = [NSPredicate predicateWithFormat:@"type = '3'"]; // type == 3 表明是一个 copyright 的标签
    NSPredicate *type4Predicate = [NSPredicate predicateWithFormat:@"type = '4'"]; // type == 4 表明是一个 character 的标签
    
    NSArray *copyrightTags = [allTags filteredArrayUsingPredicate:type3Predicate];
    NSArray *characterTags = [allTags filteredArrayUsingPredicate:type4Predicate];
    
    NSArray *copyrightTagsName = [copyrightTags valueForKey:@"name"];
    NSArray *characterTagsName = [characterTags valueForKey:@"name"];
    neededTagsName = [copyrightTagsName arrayByAddingObjectsFromArray:characterTagsName];
    
    [UtilityFile exportArray:neededTagsName atPath:@"/Users/Mercury/Documents/同步文档/MyResourceBox/Tags/neededTagsName.txt"];
    
    [self startExtracting];
}
- (void)startExtracting {
    [[FileManager defaultManager] createFolderAtPathIfNotExist:kNeededTagsFolderPath];
    firstLetters = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"~other"];
    
    NSMutableArray *other = [NSMutableArray arrayWithArray:neededTagsName];
    for (NSInteger i = 0; i < firstLetters.count - 1; i++) {
        NSString *key = firstLetters[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", key];
        NSArray *values = [neededTagsName filteredArrayUsingPredicate:predicate];
        [other removeObjectsInArray:values];
        
        NSString *destPath = [kNeededTagsFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", key]];
        [UtilityFile exportArray:values atPath:destPath];
    }
    
    NSString *destPath = [kNeededTagsFolderPath stringByAppendingPathComponent:@"~other.txt"];
    [UtilityFile exportArray:other atPath:destPath];
}

@end
