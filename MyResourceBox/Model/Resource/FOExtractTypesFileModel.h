//
//  FOExtractTypesFileModel.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/07/25.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FOExtractTypesFileModel : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *original;
@property (nonatomic, copy) NSString *rootFolder;

@property (nonatomic, copy) NSString *target;
@property (nonatomic, copy) NSString *targetRootFolder;
@property (nonatomic, copy) NSString *containerFolder; // 父文件夹

- (void)setupData;

@end

NS_ASSUME_NONNULL_END
