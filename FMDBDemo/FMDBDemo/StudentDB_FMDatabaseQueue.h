//
//  StudentDB_FMDatabaseQueue.h
//  FMDBDemo
//
//  Created by wanglei on 2018/10/1.
//  Copyright © 2018 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StudentDatabase.h"

NS_ASSUME_NONNULL_BEGIN


/**
 数据库操作，考虑线程安全(FMDatabaseQueue)
 */
@interface StudentDB_FMDatabaseQueue : NSObject <StudentDatabase>

@end

NS_ASSUME_NONNULL_END
