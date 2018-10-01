//
//  Macros.h
//  FMDBDemo
//
//  Created by wanglei on 2018/10/1.
//  Copyright © 2018 wanglei. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define FILE_PATH_IN_DOCUMENT(file) ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(file)])

/// 数据库文件名
#define STUDENT_DB_FILE_NAME @"student.sqlite"
/// 数据库文件完整路径
#define STUDENT_DB_FILE_PATH (FILE_PATH_IN_DOCUMENT(STUDENT_DB_FILE_NAME))
/// 表名 : student
#define STUDENT_DB_TABLE_STUDENT @"student"

#endif /* Macros_h */
