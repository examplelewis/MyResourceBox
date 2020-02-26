//
//  WeiboPicRootFolderCroppingOperation.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/02/27.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeiboPicRootFolderCroppingOperation : NSOperation

+ (instancetype)operationWithFrom:(NSString *)from to:(NSString *)to ratio:(float)ratio index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
