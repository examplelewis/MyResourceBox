//
//  DeviceInfo.h
//  MyToolBox
//
//  Created by 龚宇 on 16/11/01.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MacModelType) {
    MacModelTypeUndefined,
    MacModelTypeMacMini2014,
    MacModelTypeMacBookAir2012,
    MacModelTypeMacBookPro2014
};

@interface DeviceInfo : NSObject

@property (copy, readonly) NSString *model;
@property (assign, readonly) MacModelType modelType;
@property (nonatomic, copy) NSString *path_root_folder;

+ (DeviceInfo *)sharedDevice;

@end
