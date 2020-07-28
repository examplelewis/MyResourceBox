//
//  MRBUserManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/02.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MRBUserManager.h"

@interface MRBUserManager () {
    NSMutableDictionary *authDict;
    NSMutableDictionary *prefDict;
}

@end

@implementation MRBUserManager

#pragma mark -- 初始化数据存取方法 --
+ (MRBUserManager *)defaultManager {
    static dispatch_once_t onceToken;
    static MRBUserManager *user = nil;
    
    dispatch_once(&onceToken, ^{
        user = [[MRBUserManager alloc] init];
    });
    
    return user;
}

#pragma mark -- 设置方法 --
- (void)configureData {
    authDict = [NSMutableDictionary dictionaryWithContentsOfFile:[[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"Authorization.plist"]];
    prefDict = [NSMutableDictionary dictionaryWithContentsOfFile:[[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"Preference.plist"]];
    
    [self configureWeiboInfo];
    [self configureWebArchiveInfo];
}
- (void)configureWeiboInfo {
    _weibo_url = authDict[@"weibo_url"];
    _weibo_code = authDict[@"weibo_code"];
    _weibo_token = authDict[@"weibo_token"];
    _weibo_expires_at = authDict[@"weibo_expires_at"];
    _weibo_expires_at_date = [NSDate dateWithString:_weibo_expires_at formatString:@"yyyy-MM-dd HH:mm:ss"];
    _weibo_boundary_id = authDict[@"weibo_boundary_id"];
    _weibo_boundary_text = authDict[@"weibo_boundary_text"];
    _weibo_boundary_author = authDict[@"weibo_boundary_author"];
}
- (void)configureWebArchiveInfo {
    _web_archive_mime_type = [NSArray arrayWithArray:prefDict[@"web_archive_mime_type"]];
}

#pragma mark -- 存取方法 --
- (void)setWeibo_url:(NSString *)weibo_url {
    _weibo_url = [weibo_url copy];
    authDict[@"weibo_url"] = _weibo_url;
}
- (void)setWeibo_code:(NSString *)weibo_code {
    _weibo_code = [weibo_code copy];
    authDict[@"weibo_code"] = _weibo_code;
}
- (void)setWeibo_token:(NSString *)weibo_token {
    _weibo_token = [weibo_token copy];
    authDict[@"weibo_token"] = _weibo_token;
}
- (void)setWeibo_expires_at:(NSString *)weibo_expires_at {
    _weibo_expires_at = [weibo_expires_at copy];
    _weibo_expires_at_date = [NSDate dateWithString:_weibo_expires_at formatString:@"yyyy-MM-dd HH:mm:ss"];
    authDict[@"weibo_expires_at"] = _weibo_expires_at;
}
- (void)setWeibo_expires_at_date:(NSDate *)weibo_expires_at_date {
    _weibo_expires_at_date = weibo_expires_at_date;
    _weibo_expires_at = [_weibo_expires_at_date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    authDict[@"weibo_expires_at"] = _weibo_expires_at;
}
- (void)setWeibo_boundary_id:(NSString *)weibo_boundary_id {
    _weibo_boundary_id = [weibo_boundary_id copy];
    authDict[@"weibo_boundary_id"] = _weibo_boundary_id;
}
- (void)setWeibo_boundary_text:(NSString *)weibo_boundary_text {
    _weibo_boundary_text = [weibo_boundary_text copy];
    authDict[@"weibo_boundary_text"] = _weibo_boundary_text;
}
- (void)setWeibo_boundary_author:(NSString *)weibo_boundary_author {
    _weibo_boundary_author = weibo_boundary_author;
    authDict[@"weibo_boundary_author"] = _weibo_boundary_author;
}
- (NSString *)path_root_folder {
    if (!_path_root_folder) {
        if ([MRBDeviceManager defaultManager].modelType == MacModelTypeMacMini2014) {
            _path_root_folder = @"/Users/Mercury/OneDrive/同步文件夹/同步文档/MyResourceBox";
        } else {
            _path_root_folder = @"/Users/Mercury/OneDrive/同步文件夹/同步文档/MyResourceBox";
        }
    }
    return _path_root_folder;
}

#pragma mark -- 辅助方法 --
- (void)saveAuthDictIntoPlistFile {
    [authDict writeToFile:[[MRBUserManager defaultManager].path_root_folder stringByAppendingPathComponent:@"Authorization.plist"] atomically:YES];
}
- (BOOL)mimeTypeExistsInFormats:(NSString *)format {
    return [_web_archive_mime_type containsObject:format];
}

@end
