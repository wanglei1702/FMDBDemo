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
        [self.sDB updateWith:4000 name:@"Jack" age:22];
    }

}
@end
