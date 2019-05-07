//
//  SQLiteManager.h
//  MyResourceBox
//
//  Created by 龚宇 on 16/11/20.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLiteManager : NSObject

/**
 *  单例模式方法
 *
 *  @return 返回一个初始化后的对象
 */
+ (SQLiteManager *)defaultManager;

/**
 *  备份MyToolBox的数据库文件
 */
- (void)backupBCYDatabase;
/**
 *  还原MyToolBox的数据库文件
 */
- (void)restoreBCYDatebase;
/**
 *  去除数据库中重复的内容
 */
- (void)removeDuplicatesFromDatabase;

@end
