//
//  MRBDeviceManager.m
//  MyToolBox
//
//  Created by 龚宇 on 16/11/01.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "MRBDeviceManager.h"
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation MRBDeviceManager

static MRBDeviceManager *_sharedDevice;

/**
 *  单例方法
 *
 *  @return 返回的单例
 */
+ (MRBDeviceManager *)sharedDevice {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedDevice = [[MRBDeviceManager alloc] init];
        [_sharedDevice getInfo];
    });
    
    return _sharedDevice;
}

- (void)getInfo {
    // 获取设备的Model
    size_t len = 0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    if (len) {
        char *model = malloc(len * sizeof(char));
        sysctlbyname("hw.model", model, &len, NULL, 0);
        _model = [NSString stringWithUTF8String:model];
        [self convertMacModel];
        free(model);
    } else {
        _model = @"Undefined";
        _modelType = MacModelTypeUndefined;
    }
}

- (void)convertMacModel {
    if ([_model isEqualToString:@"Macmini7,1"]) {
        _modelType = MacModelTypeMacMini2014;
    } else if ([_model isEqualToString:@"MacBookAir5,2"]) {
        _modelType = MacModelTypeMacBookAir2012;
    } else if ([_model isEqualToString:@"MacBookPro11,3"]) {
        _modelType = MacModelTypeMacBookPro2014;
    } else {
        _modelType = MacModelTypeUndefined;
    }
}

- (NSString *)path_root_folder {
    if (!_path_root_folder) {
        if ([MRBDeviceManager sharedDevice].modelType == MacModelTypeMacMini2014) {
            _path_root_folder = @"/Users/Mercury/Documents/同步文档/MyResourceBox";
        } else {
            _path_root_folder = @"/Users/Mercury/Documents/同步文档/MyResourceBox";
        }
    }
    
    return _path_root_folder;
}

@end
