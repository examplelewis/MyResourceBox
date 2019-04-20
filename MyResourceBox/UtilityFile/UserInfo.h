//
//  UserInfo.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/10/02.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

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
// Tumblr相关
@property (nonatomic, copy, readonly) NSString *tumblr_OAuth_Consumer_Key;
@property (nonatomic, copy, readonly) NSString *tumblr_OAuth_Consumer_Secret;
@property (nonatomic, copy, readonly) NSString *tumblr_OAuth_Token;
@property (nonatomic, copy, readonly) NSString *tumblr_OAuth_Token_Secret;
// WebArchive 相关
@property (nonatomic, copy, readonly) NSArray *web_archive_mime_type;

+ (UserInfo *)defaultUser;
- (void)configureData;
- (void)saveAuthDictIntoPlistFile;
- (BOOL)mimeTypeExistsInFormats:(NSString *)mimeType;

@end
