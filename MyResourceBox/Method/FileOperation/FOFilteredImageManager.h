//
//  FOFilteredImageManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 19/05/06.
//  Copyright © 2019 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FOFilteredImageManager : NSObject

+ (void)organizingDatabase;
+ (void)prepareOrganizingPhotos;
+ (void)organizingExportPhotos;

@end

NS_ASSUME_NONNULL_END
