//
//  PicResourceTagFetchManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/10.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "PicResourceTagFetchManager.h"
#import "XMLReader.h"
#import "MRBHttpManager.h"

@interface PicResourceTagFetchManager () {
    NSString *preferencePath; // Preference.plist 文件的路径
    NSString *tagsFolderPath; // Tags 文件夹的路径
    NSString *totalTagsFilePath; // tags-gelbooru_com.xml 文件的路径
    NSString *typeTagsFolderPath; // 按照 type 分类后的 xml 文件夹路径
    NSString *neededTagsFolderPath; // NeededTags 文件夹的路径
    NSArray *neededTagsKeys; // NeededTags 的首字母
    NSArray *neededTagsFilePaths; // NeededTags 按照首字母排序后的文件路径
    
    NSArray *neededTags; // 多个数组，按照 neededTagsKeys 的顺序排列
    NSInteger pid;
}

@end

@implementation PicResourceTagFetchManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        preferencePath = [rootPath stringByAppendingPathComponent:@"同步文档/MyResourceBox/Preference.plist"];
        tagsFolderPath = [rootPath stringByAppendingPathComponent:@"同步文档/MyResourceBox/Tags"];
        totalTagsFilePath = [rootPath stringByAppendingPathComponent:@"Tool/DanbooruDownloader/tags.xml"];
        typeTagsFolderPath = [rootPath stringByAppendingPathComponent:@"同步文档/MyResourceBox/Tags/xmls"];
        neededTagsFolderPath = [rootPath stringByAppendingPathComponent:@"同步文档/MyResourceBox/Tags/NeededTags"];
        
        [[FileManager defaultManager] createFolderAtPathIfNotExist:tagsFolderPath];
        [[FileManager defaultManager] createFolderAtPathIfNotExist:typeTagsFolderPath];
        [[FileManager defaultManager] createFolderAtPathIfNotExist:neededTagsFolderPath];
        
        NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencePath];
        pid = [preferences[@"tags_pid"] integerValue];
        neededTagsKeys = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"~other"];
        
        if (![[FileManager defaultManager] isContentExistAtPath:totalTagsFilePath]) {
            MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
            [alert setMessage:@"还没有下载过 Gelbooru 的 Tags，需要下载才能正常使用" infomation:nil];
            [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
            [alert runModel];
        }
    }
    
    return self;
}

- (void)fetchAllTags {
    DDLogInfo(@"正在抓取第 %ld 页 Tags", pid);
    
    [[MRBHttpManager sharedManager] getGelbooruTagsWithPid:pid success:^(NSArray *array) {
        if (array.count == 0) {
            [[MRBLogManager defaultManager] showLogWithFormat:@"所有 Tags 下载完成"];
            [self readyToOrganize];
        } else {
//            NSString *filePath = [allTagsPath stringByReplacingOccurrencesOfString:@"AllTags.plist" withString:[NSString stringWithFormat:@"AllTags_%ld.plist", pid]];
//            BOOL success = [array writeToFile:filePath atomically:YES];
//            if (!success) {
//                [self fetchTagsError:@"将抓取到的 Tags 写入文件失败" msg:@"没有具体错误信息"];
//                [self readyToOrganize];
//                return;
//            }
            
            NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:self->preferencePath];
            preferences[@"tags_pid"] = @(self->pid);
            self->pid += 1;
            
            [self fetchAllTags];
        }
    } failed:^(NSString *errorTitle, NSString *errorMsg) {
        [self fetchTagsError:errorTitle msg:errorMsg];
        //        [self readyToOrganize];
    }];
}
- (void)fetchTagsError:(NSString *)errorTitle msg:(NSString *)errorMsg {
    MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
    [alert setMessage:[NSString stringWithFormat:@"抓取第 %ld 页 Tags 出现错误", pid] infomation:nil];
    [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
    [alert runModel];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"抓取第 %ld 页 Tags 出现错误：[%@ - %@]", pid, errorTitle, errorMsg];
}

- (void)readyToOrganize {
    DDLogInfo(@"所有 Tags 都已经下载完成,1s后开始整合");
    [self performSelector:@selector(organizeAllFetchedTags) withObject:nil afterDelay:1.0f];
}
- (void)organizeAllFetchedTags {
    NSArray<NSString *> *xmls = [[FileManager defaultManager] getFilePathsInFolder:tagsFolderPath];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH '/Users/Mercury/Documents/同步文档/MyResourceBox/Tags/FetchedTags_'"];
    NSArray *filter = [xmls filteredArrayUsingPredicate:predicate];
    if (filter.count == 0) {
        return;
    }
    
    NSString *allXMLString = [NSString stringWithContentsOfFile:totalTagsFilePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *allXMLDict = [XMLReader dictionaryForXMLString:allXMLString error:nil];
    NSArray *allTags = [NSArray arrayWithArray:allXMLDict[@"tags"][@"tag"]];
    NSMutableArray *trashes = [NSMutableArray array];
    for (NSInteger i = 0; i < filter.count; i++) {
        NSString *filePath = filter[i];
        NSArray *tags = [NSArray arrayWithContentsOfFile:filePath];
        allTags = [allTags arrayByAddingObjectsFromArray:tags];
        [trashes addObject:[NSURL fileURLWithPath:filePath]];
    }
    
    // 异步写入 xml 文件
//    BOOL success = [allTags writeToFile:allTagsPath atomically:YES];
//    if (!success) {
//        [[MRBLogManager defaultManager] showLogWithFormat:@"写入所有标签失败"];
//        return;
//    }
//
//    [[FileManager defaultManager] trashFilesAtPaths:trashes];

    [self filterAllTags];
}
- (void)filterAllTags {
    NSString *xmlString = [NSString stringWithContentsOfFile:totalTagsFilePath encoding:NSUTF8StringEncoding error:nil];
    NSError *error = nil;
    NSDictionary *xmlDict = [XMLReader dictionaryForXMLString:xmlString error:&error];
    NSArray *allTags = [NSArray arrayWithArray:xmlDict[@"tags"][@"tag"]];
    
    NSPredicate *generalPd = [NSPredicate predicateWithFormat:@"type = '0'"];
    NSPredicate *artistPd = [NSPredicate predicateWithFormat:@"type = '1'"];
    NSPredicate *metadataPd = [NSPredicate predicateWithFormat:@"type = '2'"];
    NSPredicate *copyrightPd = [NSPredicate predicateWithFormat:@"type = '3'"];
    NSPredicate *characterPd = [NSPredicate predicateWithFormat:@"type = '4'"];
    
    NSArray *generals = [allTags filteredArrayUsingPredicate:generalPd];
    NSArray *artists = [allTags filteredArrayUsingPredicate:artistPd];
    NSArray *metadatas = [allTags filteredArrayUsingPredicate:metadataPd];
    NSArray *copyrights = [allTags filteredArrayUsingPredicate:copyrightPd];
    NSArray *characters = [allTags filteredArrayUsingPredicate:characterPd];
    [self saveToXMLFile:generals filePath:[typeTagsFolderPath stringByAppendingPathComponent:@"0 - general.xml"]];
    [self saveToXMLFile:artists filePath:[typeTagsFolderPath stringByAppendingPathComponent:@"1 - artist.xml"]];
    [self saveToXMLFile:metadatas filePath:[typeTagsFolderPath stringByAppendingPathComponent:@"2 - metadata.xml"]];
    [self saveToXMLFile:copyrights filePath:[typeTagsFolderPath stringByAppendingPathComponent:@"3 - copyright.xml"]];
    [self saveToXMLFile:characters filePath:[typeTagsFolderPath stringByAppendingPathComponent:@"4 - character.xml"]];
    
    NSArray *copyrightNames = [copyrights valueForKey:@"name"];
    NSArray *characterNames = [characters valueForKey:@"name"];
    NSArray *neededName = [copyrightNames arrayByAddingObjectsFromArray:characterNames];
    
    [MRBUtilityManager exportArray:neededName atPath:[tagsFolderPath stringByAppendingPathComponent:@"copyrightName.txt"]];
    
    [self processNeededTags];
}
- (void)processNeededTags {
    // 原始数据
    NSString *copyrightName = [tagsFolderPath stringByAppendingPathComponent:@"copyrightName.txt"];
    NSString *neededString = [[NSString alloc] initWithContentsOfFile:copyrightName encoding:NSUTF8StringEncoding error:nil];
    NSArray *needed = [neededString componentsSeparatedByString:@"\n"];
    
    // 去除 AV 番号
    NSPredicate *withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,5}-[0-9]{1,5}$"]; // ghkb-034
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z][0-9]{1,3}-[0-9]{1,5}$"]; // t28-014
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[0-9]{1,3}[a-z]{1,3}-[0-9]{1,5}$"]; // 17id-012
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,9}-[a-z]{1,9}-[0-9]{1,5}$"]; // tokyo-hot-5740
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,9}-[0-9]{1,9}-[0-9]{1,5}$"]; // carib-060816-180
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,9}-[0-9]{1,5}[a-z]{1,5}$"]; // ibw-492z
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,9}[0-9]{1,9}-[0-9]{1,5}$"]; // kinpatu86-0244
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,4}[0-9]{1,9}$"]; // nkj47
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,4}[0-9]{1,9}-[a-z]{1,4}[0-9]{1,9}$"]; // h0930-ori960
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,9}-[0-9]{1,9}$"]; // maguro-045
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[0-9]{1,9}[a-z]{1,9}-[0-9]{1,9}.{0,10}$"]; // 1pondo-031712_298
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,9}-[0-9]{1,9}.{0,10}$"]; // 1pondo-031712_298
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(av)')"]; // atom_(av)
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    withoutAVPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^[a-z]{1,9}-[a-z]{1,4}[0-9]{1,9}$"]; // blt-r002
    needed = [needed filteredArrayUsingPredicate:withoutAVPd];
    
    // 去除 (company)
    NSPredicate *companyPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(company)')"];
    needed = [needed filteredArrayUsingPredicate:companyPd];

    // 去除 (movie)
    NSPredicate *moviePd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(movie)')"];
    needed = [needed filteredArrayUsingPredicate:moviePd];

    // 去除 (novel)
    NSPredicate *novelPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(novel)')"];
    needed = [needed filteredArrayUsingPredicate:novelPd];

    // 去除 (anime)
    NSPredicate *animePd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(anime)')"];
    needed = [needed filteredArrayUsingPredicate:animePd];

    // 去除 (album)
    NSPredicate *albumPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(album)')"];
    needed = [needed filteredArrayUsingPredicate:albumPd];

    // 去除 (manga)
    NSPredicate *mangaPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(manga)')"];
    needed = [needed filteredArrayUsingPredicate:mangaPd];

    // 去除 (studio)
    NSPredicate *studioPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(studio)')"];
    needed = [needed filteredArrayUsingPredicate:studioPd];

    // 去除 (game)
    NSPredicate *gamePd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(game)')"];
    needed = [needed filteredArrayUsingPredicate:gamePd];

    // 去除 (film)
    NSPredicate *filmPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(film)')"];
    needed = [needed filteredArrayUsingPredicate:filmPd];

    // 去除 (copyright)
    NSPredicate *copyrightPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(copyright)')"];
    needed = [needed filteredArrayUsingPredicate:copyrightPd];

    // 去除 (tv_series)
    NSPredicate *tvseriesPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS '(tv_series)')"];
    needed = [needed filteredArrayUsingPredicate:tvseriesPd];

    // 去除 年份
    NSPredicate *yearPd = [NSPredicate predicateWithFormat:@"NOT (SELF MATCHES %@)", @"^.{1,500}\\([0-9]{1,9}\\)$"]; // (2009)
    needed = [needed filteredArrayUsingPredicate:yearPd];

    // 去除 show)
    NSPredicate *showPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS 'show)')"];
    needed = [needed filteredArrayUsingPredicate:showPd];

    // 去除 disney
    NSPredicate *disneyPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS 'disney')"];
    needed = [needed filteredArrayUsingPredicate:disneyPd];

    // 去除 vocaloid
    NSPredicate *vocaloidPd = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS 'vocaloid')"];
    needed = [needed filteredArrayUsingPredicate:vocaloidPd];
    needed = [needed arrayByAddingObject:@"vocaloid"];
    
    [MRBUtilityManager exportArray:needed atPath:[tagsFolderPath stringByAppendingPathComponent:@"copyrightName - needed.txt"]];
    
    NSMutableArray *other = [NSMutableArray arrayWithArray:needed];
    for (NSInteger i = 0; i < neededTagsKeys.count - 1; i++) {
        NSString *key = neededTagsKeys[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", key];
        NSArray *values = [needed filteredArrayUsingPredicate:predicate];
        [other removeObjectsInArray:values];
        
        NSString *destPath = [neededTagsFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", key]];
        [MRBUtilityManager exportArray:values atPath:destPath];
    }
    
    NSString *destPath = [neededTagsFolderPath stringByAppendingPathComponent:@"~other.txt"];
    [MRBUtilityManager exportArray:other atPath:destPath];
    
    dispatch_main_sync_safe(^() {
        MyAlert *alert = [[MyAlert alloc] initWithAlertStyle:NSAlertStyleCritical];
        [alert setMessage:@"整理Gelbooru的Tag 完成" infomation:nil];
        [alert setButtonTitle:@"好" keyEquivalent:@"\r"];
        [alert runModel];
    });
}
- (void)saveToXMLFile:(NSArray *)data filePath:(NSString *)filePath {
//    NSString *XMLStr = @"<?xml version=\"1.0\"?>";
    
//    GDataXMLElement *rootElement = [GDataXMLNode elementWithName:@"tags"];
//    GDataXMLElement *xsdElement = [GDataXMLNode elementWithName:@"xmlns:xsd" stringValue:@"http://www.w3.org/2001/XMLSchema"];
//    GDataXMLElement *xsiElement = [GDataXMLNode elementWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"];
//    GDataXMLElement *dateElement = [GDataXMLNode elementWithName:@"xmlns:time" stringValue:[[NSDate date] formattedDateWithFormat:@"YYYY-MM-dd HH:mm:ss"]];
//    [rootElement addAttribute:xsdElement];
//    [rootElement addAttribute:xsiElement];
//    [rootElement addAttribute:dateElement];
    
//    for (NSDictionary *dict in data) {
//        GDataXMLElement *tagElement = [GDataXMLNode elementWithName:@"tag"];
//        for (NSString *key in dict.allKeys) {
//            GDataXMLElement *dataElement = [GDataXMLNode elementWithName:key stringValue:dict[key]];
//            [tagElement addAttribute:dataElement];
//        }
//        [rootElement addChild:tagElement];
//    }
    
//    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:rootElement];
//    NSData *xmlData = document.XMLData;
//    NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
//    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"<tag " withString:@"\n  <tag "];
//    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"</tags>" withString:@"\n</tags>"];
    
//    NSLog(@"Saving xml data to %@...", filePath);
//    [xmlString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
//    rootElement = nil;
//    document = nil;
//    xmlData = nil;
//    xmlString = nil;
}

@end
