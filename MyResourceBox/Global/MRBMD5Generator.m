//
//  MRBMD5Generator.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/04/24.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBMD5Generator.h"
#import <CommonCrypto/CommonDigest.h>

//秘钥
static NSString *encryptionKey = @"nha735n197nxn(N′568GGS%d~~9naei';45vhhafdjkv]32rpks;lg,];:vjo(&**&^)";

@implementation MRBMD5Generator

+ (NSString *)md5EncryptMiddleWithString:(NSString *)string {
    NSString *md5 = [self md5:[NSString stringWithFormat:@"%@%@", encryptionKey, string]];
    md5 = [md5 substringWithRange:NSMakeRange(md5.length / 4, md5.length / 2)];
    
    return md5;
}

+ (NSString *)md5EncryptWithString:(NSString *)string {
    return [self md5:[NSString stringWithFormat:@"%@%@", encryptionKey, string]];
}

+ (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

@end
