//
//  MRBFileNameFindSpecificCharactersManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 20/08/15.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBFileNameFindSpecificCharactersManager : NSObject

- (instancetype)initWithCharacters:(nullable id)characters;
- (void)selectRootFolder;

- (void)modifyFileNames;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
