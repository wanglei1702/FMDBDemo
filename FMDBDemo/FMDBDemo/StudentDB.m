//
//  StudentDB.m
//  FMDBDemo
//
//  Created by wanglei on 2018/9/26.
//  Copyright © 2018年 wanglei. All rights reserved.
//

#import "StudentDB.h"
#import <FMDB/FMDB.h>

#define FILE_PATH_IN_DOCUMENT(file) ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(file)])

/// 数据库文件名
#define STUDENT_DB_FILE_NAME @"student.sqlite"
/// 数据库文件完整路径
#define STUDENT_DB_FILE_PATH (FILE_PATH_IN_DOCUMENT(STUDENT_DB_FILE_NAME))
/// 表名 : student
#define STUDENT_DB_TABLE_STUDENT @"student"

/// 单例对象
static dispatch_once_t onceToken;
static StudentDB *instance = nil;

@interface StudentDB ()

@property (nonatomic, strong) FMDatabase *fmDatabase;

@end

@implementation StudentDB

- (void)dealloc
{
    [self.fmDatabase close];
}

+ (instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        instance = [[StudentDB alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fmDatabase = [[FMDatabase alloc] initWithPath:STUDENT_DB_FILE_PATH];
        NSLog(@"STUDENT_DB_FILE_PATH : %@", STUDENT_DB_FILE_PATH);
        BOOL success = [self.fmDatabase open];
        NSLog(@"student database open %@ !", success ? @"成功" : @"失败");
        
        if (success == NO) {
            NSError *lastError = [self.fmDatabase lastError];
            NSInteger errorCode = [self.fmDatabase lastErrorCode];
            NSLog(@"lastERror : %@\nerrorCode : %@", lastError, @(errorCode));
            return nil;
        }
        
        [self createStudentTable];
    }
    return self;
}

+ (void)destroy
{
    onceToken = 0;
    instance = nil;
}

#pragma mark - 创建表

/// 创建表：student
- (void)createStudentTable
{
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (serial INTEGER PRIMARY KEY AUTOINCREMENT, id INTEGER UNIQUE, name TEXT, age INTEGER)", STUDENT_DB_TABLE_STUDENT];
    BOOL res = [self.fmDatabase executeUpdate:sql];
    NSLog(@"创建表 : %@ %@", STUDENT_DB_TABLE_STUDENT, res ? @"成功" : @"失败");
    
    // 给已存在的表添加新字段age（如果不存在的话）
    if ([self.fmDatabase columnExists:@"age" inTableWithName:STUDENT_DB_TABLE_STUDENT] == NO) {
        NSString *addAgeSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN age INTEGER DEFAULT(0)", STUDENT_DB_TABLE_STUDENT];
        [self.fmDatabase executeUpdate:addAgeSql];
//        self.fmDatabase updatefor
    }
}

#pragma mark - 增加数据

/*
 "INSERT OR REPLACE" 和 "UPDATE" 的区别：
 "INSERT OR REPLACE" : 插入一条新的数据， 若已经存在相同的PRIMARY KEY或 UNIQUE，则先删除旧的数据，再插入新的
 "UPDATE" ：
*/
/// 插入数据,
- (void)updateWith:(NSInteger)studentID name:(NSString *)name age:(NSInteger)age
{
    BOOL res = NO;
    NSString *sql = nil;
    
#if 0 // 方式 1，（这里为了演示，忽略了传入的参数，值写死）
    sql = @"INSERT OR REPLACE INTO student (id, name, age) VALUES (20007, 'trump', 71)";
    res = [self.fmDatabase executeUpdate:sql];
#elif 1 // 方式 2， UPDATE 已经存在的更新, SET, WHERE
    sql = @"UPDATE student SET age = 1234567";
    res = [self.fmDatabase executeUpdate:sql];
#elif 0 // 实现方式 1
    sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (?, ?, ?)", STUDENT_DB_TABLE_STUDENT];
    // 后面的参数必须是 id 类型，不可以是基础数据类型
    res = [self.fmDatabase executeUpdate:sql, @(20002), @"Steve", @(18)];
#elif 0 // 实现方式 2
    
#endif
    NSLog(@"插入 %@ %@", name, res ? @"成功" : @"失败");
}










@end
