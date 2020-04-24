//
//  MRBMD5Generator.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/24.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBMD5Generator : NSObject

+ (NSString *)md5EncryptMiddleWithString:(NSString *)string;
+ (NSString *)md5EncryptWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
