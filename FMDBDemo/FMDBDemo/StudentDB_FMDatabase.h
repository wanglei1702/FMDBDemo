//
//  StudentDB.h
//  FMDBDemo
//
//  Created by wanglei on 2018/9/26.
//  Copyright © 2018年 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StudentDatabase.h"

/**
 Student数据库 直接操作 FMDatabase 不考虑线程安全（不用FMDatabaseQueue）
 */
@interface StudentDB_FMDatabase : NSObject <StudentDatabase>

@end
