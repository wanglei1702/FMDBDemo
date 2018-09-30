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

#pragma mark - 增 增加数据
/// 插入一条数据，如果已经存在(id UNIQUE)，则替换
- (void)insertWithID:(NSInteger)sID name:(NSString *)name age:(NSInteger)age
{
    NSString *sql = nil;
    BOOL res = NO;
#if 1   // 方式 1
    sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (?, ?, ?)", STUDENT_DB_TABLE_STUDENT];
    res = [self.fmDatabase executeUpdate:sql, @(sID), name, @(age)];
#elif 0 // 方式 2
    sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (%%@, %%@, %%@)", STUDENT_DB_TABLE_STUDENT];
    res = [self.fmDatabase executeUpdateWithFormat:sql, @(sID), name, @(age)];
#elif 0 // 方式3, 字段的值直接写到sql语句中
    sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (20027, 'obama27', 20)", STUDENT_DB_TABLE_STUDENT];
    res = [self.fmDatabase executeUpdate:sql];
#endif
    
    NSLog(@"插入 sID : %@, name : %@ %@ !", @(sID), name, res ? @"成功" : @"失败");
}

#pragma mark - 删
/// 根据sID删除一条数据
- (void)removeWithID:(NSInteger)sID
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sID)];
    BOOL res = [self.fmDatabase executeUpdate:sql];
    NSLog(@"删除 id : %@ %@ !", @(sID), res ? @"成功" : @"失败");
}

#pragma mark - 改
/// 根据sID修改age
- (void)updateWithID:(NSInteger)sID age:(NSInteger)age
{
    BOOL exist = NO;
    NSString *sql = nil;
    BOOL res = NO;
#if 0 // 不管是否存在这条数据，都直接执行修改；若数据不存在，改语句执行之后数据库不会有变化
    sql = [NSString stringWithFormat:@"UPDATE %@ SET age = ? WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sID)];
    res = [self.fmDatabase executeUpdate:sql, @(age)];
#elif 1 // 先判断是否存在这条数据，如果存在则修改，否则增加一条数据
    exist = [self checkExistSID:sID];
    if (exist) {
        // 存在
        sql = [NSString stringWithFormat:@"UPDATE %@ SET age = ? WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sID)];
        res = [self.fmDatabase executeUpdate:sql, @(age)];
    } else {
        // 不存在, 则插入
        sql = [NSString stringWithFormat:@"INSERT INTO %@ (id, age) VALUES (?, ?)", STUDENT_DB_TABLE_STUDENT];
        res = [self.fmDatabase executeUpdate:sql, @(sID), @(age)];
    }
#endif
    
    NSLog(@"修改 id : %@ 为 age : %@ %@", @(sID), @(age), res ? @"成功" : @"失败");
}

#pragma mark - 查
/// 所有数据
- (NSArray<NSDictionary *> *)allStudents
{
    NSMutableArray<NSDictionary *> *resArray = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", STUDENT_DB_TABLE_STUDENT];
//    BOOL res = [self.fmDatabase executeUpdate:sql];
    FMResultSet *resSet = [self.fmDatabase executeQuery:sql];
    while ([resSet next]) {
        NSInteger sid = [resSet longForColumn:@"id"];
        NSString *name = [resSet stringForColumn:@"name"];
        NSInteger age = [resSet longForColumn:@"age"];
        NSDictionary *dict = @{@"id" : @(sid),
                               @"name" : name,
                               @"age" : @(age)};
        [resArray addObject:dict];
    }
    
    return resArray;
}

/// 根据id (UNIQUE) 查数据，没有查到返回 nil
- (nullable NSDictionary *)studentWithSID:(NSInteger)sid
{
    // 仅查询指定字段
    NSString *sql = [NSString stringWithFormat:@"SELECT id, name FROM %@ WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sid)];
    FMResultSet *resSet = [self.fmDatabase executeQuery:sql];
    while ([resSet next]) {
        // 仅取出 id 和 name
        NSInteger sid = [resSet longForColumn:@"id"];
        NSString *name = [resSet stringForColumn:@"name"];
        NSInteger age = [resSet longForColumn:@"age"];
        NSDictionary *dict = @{@"id" : @(sid),
                               @"name" : name,
                               @"age" : @(age) // 查询语句中没有指定查询age字段，所以这里取出来是默认值0; FMDB Warning: I could not find the column named 'age'.
                               };
        return dict;
    }
    return nil;
}

- (BOOL)checkExistSID:(NSInteger)sid
{
    return ([self studentWithSID:sid] != nil);
}

/// 插入数据,
//- (void)updateWith:(NSInteger)studentID name:(NSString *)name age:(NSInteger)age
//{
//    BOOL res = NO;
//    NSString *sql = nil;
//
//#if 0 // 方式 1，（这里为了演示，忽略了传入的参数，值写死）
//    sql = @"INSERT OR REPLACE INTO student (id, name, age) VALUES (20007, 'trump', 71)";
//    res = [self.fmDatabase executeUpdate:sql];
//#elif 1 // 方式 2， UPDATE 已经存在的更新, SET, WHERE
//    sql = @"UPDATE student SET age = 1234567";
//    res = [self.fmDatabase executeUpdate:sql];
//#elif 0 // 实现方式 1
//    sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (?, ?, ?)", STUDENT_DB_TABLE_STUDENT];
//    // 后面的参数必须是 id 类型，不可以是基础数据类型
//    res = [self.fmDatabase executeUpdate:sql, @(20002), @"Steve", @(18)];
//#elif 0 // 实现方式 2
//
//#endif
//    NSLog(@"插入 %@ %@", name, res ? @"成功" : @"失败");
//}

@end
