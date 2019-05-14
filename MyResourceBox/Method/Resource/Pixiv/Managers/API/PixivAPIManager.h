//
//  PixivAPIManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/01/27.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixivAPIManager : NSObject

+ (void)callPixivApiWithURL:(NSString *)url success:(void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

@end

NS_ASSUME_NONNULL_END
