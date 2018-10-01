//
//  StudentDB_FMDatabaseQueue.m
//  FMDBDemo
//
//  Created by wanglei on 2018/10/1.
//  Copyright © 2018 wanglei. All rights reserved.
//

#import "StudentDB_FMDatabaseQueue.h"
#import <FMDB/FMDB.h>
#import "Macros.h"

@interface StudentDB_FMDatabaseQueue ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation StudentDB_FMDatabaseQueue

#pragma mark - StudentDatabase

/// 获取单例对象（创建数据库文件和表，如果不存在的话）
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static StudentDB_FMDatabaseQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:STUDENT_DB_FILE_PATH];
        NSLog(@"STUDENT_DB_FILE_PATH : \n%@", STUDENT_DB_FILE_PATH);
        [self createStudentTable];
    }
    return self;
}

#pragma mark - 增
/// 插入一条数据，如果已经存在(sID)，则替换
- (void)insertWithID:(NSInteger)sID name:(NSString *)name age:(NSInteger)age
{
    __block NSString *sql = nil;
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
#if 1   // 方式 1
        sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (?, ?, ?)", STUDENT_DB_TABLE_STUDENT];
        res = [db executeUpdate:sql, @(sID), name, @(age)];
#elif 0 // 方式 2
        sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (%%@, %%@, %%@)", STUDENT_DB_TABLE_STUDENT];
        res = [db executeUpdateWithFormat:sql, @(sID), name, @(age)];
#elif 0 // 方式3, 字段的值直接写到sql语句中
        sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, name, age) VALUES (20027, 'obama27', 20)", STUDENT_DB_TABLE_STUDENT];
        res = [db executeUpdate:sql];
#endif
        
        NSLog(@"插入 sID : %@, name : %@ %@ !", @(sID), name, res ? @"成功" : @"失败");
    }];
}

#pragma mark - 删
/// 根据sID删除一条数据
- (void)removeWithID:(NSInteger)sID
{
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sID)];
        BOOL res = [db executeUpdate:sql];
        NSLog(@"删除 id : %@ %@ !", @(sID), res ? @"成功" : @"失败");
    }];
}

/// 删除所有row
- (void)removeAllStudents
{
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", STUDENT_DB_TABLE_STUDENT];
        BOOL res = [db executeUpdate:sql];
        NSLog(@"删除student中的所有row %@ !", res ? @"成功" : @"失败");
    }];
}

#pragma mark - 改
/// 根据sID修改age
- (void)updateWithID:(NSInteger)sID age:(NSInteger)age
{
    __block BOOL res = NO;
    BOOL exist = NO;
    exist = [self checkExistSID:sID];

    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = nil;
#if 0 // 不管是否存在这条数据，都直接执行修改；若数据不存在，改语句执行之后数据库不会有变化
        sql = [NSString stringWithFormat:@"UPDATE %@ SET age = ? WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sID)];
        res = [db executeUpdate:sql, @(age)];
#elif 1 // 先判断是否存在这条数据，如果存在则修改，否则增加一条数据
        if (exist) {
            // 存在
            sql = [NSString stringWithFormat:@"UPDATE %@ SET age = ? WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sID)];
            res = [db executeUpdate:sql, @(age)];
        } else {
            // 不存在, 则插入
            sql = [NSString stringWithFormat:@"INSERT INTO %@ (id, age) VALUES (?, ?)", STUDENT_DB_TABLE_STUDENT];
            res = [db executeUpdate:sql, @(sID), @(age)];
        }
#endif
    }];
    NSLog(@"修改 id : %@ 为 age : %@ %@", @(sID), @(age), res ? @"成功" : @"失败");
    
#if 0
    // 事务, inTransaction
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        
    }];
#endif
    
#if 0
    // 测试线程安全（串行队列）, 在不同线程去访问 FMDatabase, 串行执行，不会发生资源抢夺
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            for (NSInteger i = 0; i < 1000; i++) {
                NSLog(@"for 2 - %@ - %@", @(i), [NSThread currentThread]);
            }
        }];
    });
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        for (NSInteger i = 0; i < 1000; i++) {
            NSLog(@"for 1 - %@ - %@", @(i), [NSThread currentThread]);
        }
    }];
#endif
}

#pragma mark - 查
/// 查询所有学生数据，按数据库中的物理顺序
- (NSArray<NSDictionary *> *)allStudents
{
    NSMutableArray<NSDictionary *> *resArray = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", STUDENT_DB_TABLE_STUDENT];
        //    BOOL res = [self.fmDatabase executeUpdate:sql];
        FMResultSet *resSet = [db executeQuery:sql];
        while ([resSet next]) {
            NSInteger sid = [resSet longForColumn:@"id"];
            NSString *name = [resSet stringForColumn:@"name"];
            NSInteger age = [resSet longForColumn:@"age"];
            NSDictionary *dict = @{@"id" : @(sid),
                                   @"name" : name,
                                   @"age" : @(age)};
            [resArray addObject:dict];
        }
    }];
    
    return resArray;

}

/// 根据id (UNIQUE) 查数据，没有查到返回 nil
- (nullable NSDictionary *)studentWithSID:(NSInteger)sid
{
    // 仅查询指定字段
    __block NSDictionary *sDict = nil;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT id, name FROM %@ WHERE id = %@", STUDENT_DB_TABLE_STUDENT, @(sid)];
        FMResultSet *resSet = [db executeQuery:sql];
        while ([resSet next]) {
            // 仅取出 id 和 name
            NSInteger sid = [resSet longForColumn:@"id"];
            NSString *name = [resSet stringForColumn:@"name"];
            NSInteger age = [resSet longForColumn:@"age"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : @(sid),
                                                                                        @"age" : @(age) // 查询语句中没有指定查询age字段，所以这里取出来是默认值0; FMDB Warning: I could not find the column named 'age'.
                                                                                        }];
            if (name) {
                [dict setObject:name forKey:@"name"];
            }
            sDict = dict;
        }
    }];
    return sDict;
}

/// 查询所有年龄大于等于19的row，且结果按年龄从大到小排序，若年龄相同则按id从大到小排序
- (NSArray<NSDictionary *> *)allStudentsBeyond19
{
    NSMutableArray<NSDictionary *> *resArray = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT id, name, age FROM %@ WHERE age >= 19 ORDER BY age DESC, id ASC", STUDENT_DB_TABLE_STUDENT];
        FMResultSet *resSet = [db executeQuery:sql];
        
        while ([resSet next]) {
            NSInteger sid = [resSet longForColumn:@"id"];
            NSString *name = [resSet stringForColumn:@"name"];
            NSInteger age = [resSet longForColumn:@"age"];
            NSDictionary *dict = @{@"id" : @(sid),
                                   @"name" : name,
                                   @"age" : @(age)};
            [resArray addObject:dict];
        }
    }];
    
    return resArray;
}

#pragma mark - 删表
/// 删除表student
- (void)dropStudentTable
{
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@", STUDENT_DB_TABLE_STUDENT];
        BOOL res = [db executeUpdate:sql];
        NSLog(@"删除表 %@ %@", STUDENT_DB_TABLE_STUDENT, res ? @"成功" : @"失败");
    }];
}

#pragma mark - Private Methods

/// 创建表：student
- (void)createStudentTable
{
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (serial INTEGER PRIMARY KEY AUTOINCREMENT, id INTEGER UNIQUE, name TEXT, age INTEGER)", STUDENT_DB_TABLE_STUDENT];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL res = [db executeUpdate:sql];
        NSLog(@"创建表 : %@ %@", STUDENT_DB_TABLE_STUDENT, res ? @"成功" : @"失败");
        
        // 给已存在的表添加新字段age（如果不存在的话）
        if ([db columnExists:@"age" inTableWithName:STUDENT_DB_TABLE_STUDENT] == NO) {
            NSString *addAgeSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN age INTEGER DEFAULT(0)", STUDENT_DB_TABLE_STUDENT];
            [db executeUpdate:addAgeSql];
        }
    }];
    /*
    // 事物处理，可回滚
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (有错误) {
            roolBack = YES;
            return;
        }
    }];
    */
}

- (BOOL)checkExistSID:(NSInteger)sid
{
    return ([self studentWithSID:sid] != nil);
}

@end
