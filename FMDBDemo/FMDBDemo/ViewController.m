//
//  ViewController.m
//  FMDBDemo
//
//  Created by wanglei on 2018/9/26.
//  Copyright © 2018年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import "StudentDB.h"

@interface ViewController ()

@property (nonatomic, weak) StudentDB *sDB;
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
        self.sDB = [StudentDB sharedInstance];
    } else {
#if 0   // 增
        [self.sDB insertWithID:[self getSID] name:[self getName] age:[self getAge]];
#elif 0 // 删
        [self.sDB removeWithID:20011];
#elif 1 // 改
        [self.sDB updateWithID:20004 age:888];
#elif 0 // 查
        NSArray *resArray = [self.sDB allStudents];
        NSLog(@"allStudents : \n%@", resArray);
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
