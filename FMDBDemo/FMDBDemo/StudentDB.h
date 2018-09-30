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

#pragma mark - 增
/// 插入一条数据，如果已经存在(sID)，则替换
- (void)insertWithID:(NSInteger)sID name:(NSString *)name age:(NSInteger)age;

#pragma mark - 删
/// 根据sID删除一条数据
- (void)removeWithID:(NSInteger)sID;

#pragma mark - 改
/// 根据sID修改age
- (void)updateWithID:(NSInteger)sID age:(NSInteger)age;

#pragma mark - 查
/// 查询所有学生数据
- (NSArray<NSDictionary *> *)allStudents;

/// 插入数据
//- (void)updateWith:(NSInteger)studentID name:(NSString *)name age:(NSInteger)age;

@end
