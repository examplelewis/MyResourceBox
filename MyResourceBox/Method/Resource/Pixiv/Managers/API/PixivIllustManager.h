//
//  PixivIllustManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/02/06.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PixivIllustManager : NSObject

- (instancetype)initWithWebpage:(NSString *)webPage;
- (void)fetchIllusts:(void(^)(BOOL success, NSString *errorMsg, NSDictionary *illusts))fetchResult;

@end
