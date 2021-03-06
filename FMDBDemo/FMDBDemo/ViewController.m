//
//  ViewController.m
//  FMDBDemo
//
//  Created by wanglei on 2018/9/26.
//  Copyright © 2018年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import "StudentDB_FMDatabase.h"
#import "StudentDB_FMDatabaseQueue.h"

@interface ViewController ()

//@property (nonatomic, weak) StudentDB_FMDatabase *sDB;
@property (nonatomic, weak) StudentDB_FMDatabaseQueue *sDB;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.sDB == nil) {
        self.sDB = [StudentDB_FMDatabaseQueue sharedInstance];
    } else {
#if 0   // 增
        [self.sDB insertWithID:[self getSID] name:[self getName] age:[self getAge]];
#elif 0 // 删
//        [self.sDB removeWithID:20011];
        [self.sDB removeAllStudents];
#elif 1 // 改
        [self.sDB updateWithID:20004 age:888];
#elif 0 // 查
//        NSArray *resArray = [self.sDB allStudents];
        NSArray *resArray = [self.sDB allStudentsBeyond19];
        NSLog(@"allStudents : \n%@", resArray);
#elif 0 // 删除表
        [self.sDB dropStudentTable];
#endif
//        [self.sDB updateWith:4000 name:@"Jack" age:22];
    }

}

- (NSInteger)getSID
{
    static NSInteger sid = 20000;
    sid++;
    return sid;
}

- (NSString *)getName
{
    static NSInteger count = 0;
    count++;
    return [NSString stringWithFormat:@"obama%02ld", count];
}

- (NSInteger)getAge
{
    return arc4random() % 4 + 17;
}

@end
