//
//  DeviantartUserManager.m
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import "DeviantartUserManager.h"
#import "DeviantartHeader.h"

@interface DeviantartUserManager () {
    NSDictionary *loginInfo;
    NSDictionary *deviantartPrefs;
    AFHTTPSessionManager *manager;
    
    NSInteger galleryOffset;
    NSString *cursor;
    NSTimeInterval previousTime;
    
    NSMutableArray *galleryResult;
    NSMutableArray *galleryResultUrls;
}

@end

@implementation DeviantartUserManager

- (instancetype)init {
    self = [super init];
    if (self) {
        manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        // timeout
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 10.0f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        if ([[FileManager defaultManager] isContentExistAtPath:loginInfoFilePath]) {
            loginInfo = [[NSDictionary alloc] initWithContentsOfFile:loginInfoFilePath];
        }
        
        if ([[FileManager defaultManager] isContentExistAtPath:deviantartPrefsFilePath]) {
            deviantartPrefs = [[NSDictionary alloc] initWithContentsOfFile:deviantartPrefsFilePath];
            previousTime = [deviantartPrefs[@"publishedTime"] doubleValue];
        }
    }
    
    return self;
}

- (void)prepareFetchingUserGallery {
    WS(weakSelf);
    if (loginInfo && [[NSDate dateWithTimeIntervalSince1970:[loginInfo[@"expires_at"] doubleValue]] isLaterThan:[NSDate date]]) {
        [self fetchingUserGalleryAfterRefreshingToken];
    } else {
        [self refreshToken:^{
            [weakSelf fetchingUserGalleryAfterRefreshingToken];
        }];
    }
}
- (void)fetchingUserGalleryAfterRefreshingToken {
    galleryOffset = 0;
    galleryResult = [NSMutableArray array];
    galleryResultUrls = [NSMutableArray array];
    
    [self fetchUserGallery];
}

/**
 * @brief 刷新 Token
 */
- (void)refreshToken:(void(^)(void))successBlock {
    [[MRBLogManager defaultManager] showLogWithFormat:@"正在刷新 Deviantart Token"];
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/oauth2/token?client_id=9258&client_secret=61c80feafecec5591f799f14be74c109&grant_type=refresh_token&refresh_token=%@", loginInfo[@"refresh_token"]];
    //    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/oauth2/token?client_id=9258&client_secret=61c80feafecec5591f799f14be74c109&grant_type=refresh_token&refresh_token=c28df5ccb8c2f867a27f8352d2cb4b465541f00b"];
    
    WS(weakSelf);
    [manager GET:url parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SS(strongSelf);
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        [info setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"refresh_time"];
        [info setObject:@([[NSDate date] timeIntervalSince1970] + [info[@"expires_in"] integerValue]) forKey:@"expires_at"];
        
        strongSelf->loginInfo = [NSDictionary dictionaryWithDictionary:info];
        [strongSelf->loginInfo writeToFile:loginInfoFilePath atomically:YES];
        
        [[MRBLogManager defaultManager] showLogWithFormat:@"已获取到新的 token，保存到 DeviantartLoginInfo.plist 文件中"];
        
        if (successBlock) {
            successBlock();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"刷新 Deviantart Token 失败，可能是 refresh_token 已经过期，请参考 OAuth 2 Step 1: User Authorization 重新获取 Authorization Code"];
    }];
}


/**
 * @brief 获取用户的 Gallery
 */
- (void)fetchUserGallery {
    [[MRBLogManager defaultManager] showLogWithFormat:@"正在加载Gallery: %ld - %ld", galleryOffset + 1, galleryOffset + 24];
    NSString *url = [NSString stringWithFormat:@"https://www.deviantart.com/api/v1/oauth2/gallery/all?username=%@&offset=%ld&limit=24&access_token=%@&mature_content=true", [AppDelegate defaultVC].inputTextView.string, galleryOffset, loginInfo[@"access_token"]];
    
    WS(weakSelf);
    [manager GET:url parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SS(strongSelf);
        
        NSDictionary *response = [NSDictionary dictionaryWithDictionary:responseObject];
        NSArray *results = [NSArray arrayWithArray:response[@"results"]];
        DDLogInfo(@"Deviantart User Gallery Results: %@", results);
        [strongSelf->galleryResult addObjectsFromArray:results];
        
        for (NSInteger i = 0; i < results.count; i++) {
            NSDictionary *gallery = results[i];
            
            if ([gallery[@"is_downloadable"] boolValue] && gallery[@"content"] && gallery[@"content"][@"src"]) {
                NSString *src = gallery[@"content"][@"src"];
                [strongSelf->galleryResultUrls addObject:src];
            }
        }
        [MRBUtilityManager exportArray:strongSelf->galleryResultUrls atPath:[NSString stringWithFormat:@"/Users/Mercury/Downloads/DeviantartUser【%@】Gallery.txt", [AppDelegate defaultVC].inputTextView.string]];
        
        if ([response[@"has_more"] boolValue]) {
            strongSelf->galleryOffset = [response[@"next_offset"] integerValue];
            [strongSelf fetchUserGallery];
        } else {
            [[MRBLogManager defaultManager] showLogWithFormat:@"用户: %@ 的 Gallery 加载完成", [AppDelegate defaultVC].inputTextView.string];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[MRBLogManager defaultManager] showLogWithFormat:@"加载 Gallery 出错"];
    }];
}

@end

/**
 * OAuth 2 Step 1: User Authorization
 * 直接复制到浏览器打开即可
 * https://www.deviantart.com/settings/applications?scope=browse%20feed&redirect_uri=https%3A%2F%2Fsns.whalecloud.com%2Fsina2%2Fcallback&response_type=code&client_id=9258
 * 第一次的结果:
 * https://sns.whalecloud.com/sina2/callback?code=83b56cb3390914c1229de3ccf037be64dff8c83a&state=
 */

/**
 * OAuth 2 Step 2: Getting A User Access Token
 * https://www.deviantart.com/oauth2/token?client_id=9258&client_secret=61c80feafecec5591f799f14be74c109&grant_type=authorization_code&code=2ae0dcffc990bb5e2f9f8cdd4e25f4e3caf0204a&redirect_uri=https://sns.whalecloud.com/sina2/callback
 */
