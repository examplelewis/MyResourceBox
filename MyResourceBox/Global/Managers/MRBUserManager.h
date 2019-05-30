//
//  MRBUserManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/02.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRBUserManager : NSObject

// 文件地址
@property (nonatomic, copy) NSString *path_root_folder;
// 微博相关
@property (nonatomic, copy) NSString *weibo_code;
@property (nonatomic, copy) NSString *weibo_token;
@property (nonatomic, copy) NSString *weibo_expires_at;
@property (nonatomic, strong) NSDate *weibo_expires_at_date;
@property (nonatomic, copy) NSString *weibo_url;
@property (nonatomic, copy) NSString *weibo_boundary_id;
@property (nonatomic, copy) NSString *weibo_boundary_text;
@property (nonatomic, copy) NSString *weibo_boundary_author;
// WebArchive 相关
@property (nonatomic, copy, readonly) NSArray *web_archive_mime_type;

+ (MRBUserManager *)defaultManager;
- (void)configureData;
- (void)saveAuthDictIntoPlistFile;
- (BOOL)mimeTypeExistsInFormats:(NSString *)mimeType;

@end
