//
//  StudentDB.h
//  FMDBDemo
//
//  Created by wanglei on 2018/9/26.
//  Copyright © 2018年 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Student数据库 直接操作 FMDatabase 不考虑线程安全（不用FMDatabaseQueue）
 */
@interface StudentDB : NSObject

+ (instancetype)sharedInstance;

/// 插入数据
- (void)updateWith:(NSInteger)studentID name:(NSString *)name age:(NSInteger)age;

@end
