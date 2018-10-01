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

/// 获取单例对象（创建数据库文件和表，如果不存在的话）
+ (instancetype)sharedInstance;

#pragma mark - 增
/// 插入一条数据，如果已经存在(sID)，则替换
- (void)insertWithID:(NSInteger)sID name:(NSString *)name age:(NSInteger)age;

#pragma mark - 删
/// 根据sID删除一条数据
- (void)removeWithID:(NSInteger)sID;
/// 删除所有row
- (void)removeAllStudents;

#pragma mark - 改
/// 根据sID修改age
- (void)updateWithID:(NSInteger)sID age:(NSInteger)age;

#pragma mark - 查
/// 查询所有学生数据，按数据库中的物理顺序
- (NSArray<NSDictionary *> *)allStudents;
/// 根据id (UNIQUE) 查数据，没有查到返回 nil
- (nullable NSDictionary *)studentWithSID:(NSInteger)sid;
/// 查询所有年龄大于等于19的row，且结果按年龄从大到小排序，若年龄相同则按id从大到小排序
- (NSArray<NSDictionary *> *)allStudentsBeyond19;

#pragma mark - 删表
/// 删除表student
- (void)dropStudentTable;

@end
