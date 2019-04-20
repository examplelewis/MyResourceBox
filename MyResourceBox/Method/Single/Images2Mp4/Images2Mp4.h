//
//  Images2Mp4.h
//  MyResourceBox
//
//  Created by 龚宇 on 18/07/26.
//  Copyright © 2018年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Images2Mp4 : NSObject

- (instancetype)initWithRootFolder:(NSString *)root;
- (void)readAllFiles;
- (void)startTranscoding;

@end
