//
//  ToolOperationMethod.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/13.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "ToolOperationMethod.h"
#import "WebArchiveMethod.h"

@implementation ToolOperationMethod

+ (void)configMethod:(NSInteger)cellRow {
    [MRBLogManager resetCurrentDate];
    
    switch (cellRow) {
        case 1: {
            [WebArchiveMethod configMethod:1];
        }
            break;
        case 2: {
            NSArray *movieExts = @[@"mpg", @"mpeg", @"avi", @"mov", /*@"asf", */@"wmv", @"3gp", @"rm", @"rmvb", @"mkv", @"flv", @"f4v", @"webm", @"mp4"];
            for (NSInteger i = 0; i < movieExts.count; i++) {
                NSString *movieExt = movieExts[i];
                [self restoreMovieDefaultApplicationToIINAByExtension:movieExt];
            }
        }
            break;
        case 3: {
            if (![[FileManager defaultManager] isContentExistAtPath:@"/Users/Mercury/Downloads/GoAgentXRules.plist"]) {
                [[MRBLogManager defaultManager] showLogWithFormat:@"下载文件夹中找不到 GoAgentXRules.plist 文件，流程已停止"];
                return;
            }
            
            [self convertGoAgentXRules];
        }
            break;
        default:
            break;
    }
}

+ (void)restoreMovieDefaultApplicationToIINAByExtension:(NSString *)extension {
    CFStringRef exRef = (__bridge CFStringRef)extension;
    CFStringRef exUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, exRef, NULL);
    
    CFURLRef helperApplicationURL = LSCopyDefaultApplicationURLForContentType(exUTI, kLSRolesAll, NULL);
    if (helperApplicationURL == NULL) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"类型：%@ 未注册到系统的Launch Services中，跳过", extension];
        return;
    }
    
    // Check to make sure the registered helper application isn't us
    NSString *helperApplicationPath = [(__bridge NSURL *)helperApplicationURL path];
    NSString *helperApplicationName = [[NSFileManager defaultManager] displayNameAtPath:helperApplicationPath];
    
    if (![helperApplicationName isEqualToString:@"IINA"]) {
        LSSetDefaultRoleHandlerForContentType(exUTI, kLSRolesAll, (__bridge CFStringRef)@"com.colliderli.iina");
        [[MRBLogManager defaultManager] showLogWithFormat:@"类型：%@ 原打开方式为: %@，已修改为 IINA", extension, helperApplicationName];
    } else {
        [[MRBLogManager defaultManager] showLogWithFormat:@"类型：%@ 默认打开方式为IINA，跳过", extension];
    }
    
    CFRelease(helperApplicationURL);
}
+ (void)convertGoAgentXRules {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/Users/Mercury/Downloads/GoAgentXRules.plist"];
    NSArray *objects = [NSArray arrayWithArray:dict[@"$objects"]];
    NSMutableArray *all = [NSMutableArray array]; // 全部
    NSMutableArray *direct = [NSMutableArray array]; // 直接连接
    NSMutableArray *detect = [NSMutableArray array]; // 使用运行中的配置
    for (int i = 0; i < objects.count; i++) {
        if ([objects[i] isKindOfClass:[NSString class]]) {
            NSString *stringObj = (NSString *)objects[i];
            [all addObject:stringObj];
        }
    }
    
    NSIndexSet *dcIndexSet = [all indexesOfObjectsPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToString:@"DirectConnection"];
    }];
    NSIndexSet *adIndexSet = [all indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToString:@"AutoDetect"];
    }];
    
    [dcIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [direct addObject:all[idx + 1]];
    }];
    [adIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [detect addObject:all[idx + 1]];
    }];
    
    if (direct.count == 0) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"可能GoAgentX的存储规则发生了改变，需要修改逻辑，流程已停止"];
        return;
    }
    
    [UtilityFile exportArray:direct atPath:@"/Users/Mercury/Downloads/GoAgentXRules_Direct.txt"];
    [UtilityFile exportArray:detect atPath:@"/Users/Mercury/Downloads/GoAgentXRules_Auto.txt"];
    
    [[MRBLogManager defaultManager] showLogWithFormat:@"流程已结束，请查看：GoAgentXRules_Direct.txt 以及 GoAgentXRules_Auto.txt 两个文件"];
}


@end
