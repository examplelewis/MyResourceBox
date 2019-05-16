//
//  MRBSQLiteManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRBSQLiteManager : NSObject

/**
 *  备份数据库文件
 */
+ (void)backupDatabaseFile;
/**
 *  还原数据库文件
 */
+ (void)restoreDatebaseFile;
/**
 *  去除数据库中重复的内容
 */
+ (void)removeDuplicatesFromDatabase;

@end
