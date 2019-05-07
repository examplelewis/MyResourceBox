//
//  OrganizeManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OrganizeManagerDelegate <NSObject>

- (void)didFinishOrganizing;

@end

@interface OrganizeManager : NSObject

@property (weak) id <OrganizeManagerDelegate> delegate;

- (instancetype)initWithPlistPath:(NSString *)plistPath;

- (void)startOrganizing;

@end
