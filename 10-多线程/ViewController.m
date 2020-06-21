//
//  ViewController.m
//  10-多线程
//
//  Created by 刘光强 on 2020/2/11.
//  Copyright © 2020 guangqiang.liu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// 同步串行
void syncSerialTest() {
    // 创建一个串行队列，一个挨着一个的执行任务
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    
    // 同步执行任务，在当前主线程上执行任务，没有开启新线程(不具备开启异步线程的能力)
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务1+++顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务2---顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
}

// 同步并发
void syncConcurrentTest() {
    // 创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 同步执行任务，在当前主线程上执行任务，没有开启新线程(不具备开启异步线程的能力)
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务1+++顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务2---顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
}

// 异步串行
void asyncSerialTest() {
    // 创建一个串行队列，一个挨着一个的执行任务
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    
    // 异步执行任务
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务1+++顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务2---顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
}

// 异步并发
void asyncConcurrentTest() {
    // 创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 异步执行任务
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务1+++顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务2---顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
}

// 异步主队列(dispatch_get_main_queue是一种特殊的串行队列)
void asyncMainQueue() {
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务1---顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
    
    dispatch_queue_t queue2 = dispatch_get_main_queue();
    dispatch_async(queue2, ^{
        for (NSInteger i = 0; i < 10; i ++) {
            NSLog(@"执行任务2---顺序%ld-%@", (long)i, [NSThread currentThread]);
        }
    });
}

void syncLock() {
    NSLog(@"任务1");
    
    // 创建一个主队列，串行队列有FIFO的特点
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 同步执行任务，立即在当前主线程执行任务，任务不执行完后面的代码就会不会执行
    dispatch_sync(queue, ^{
        NSLog(@"任务1");
    });
    
    NSLog(@"任务3");
}

void asyncLock() {
    NSLog(@"任务1");
    
    // 创建一个主队列，FIFO
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 异步执行任务，不要求任务立即执行
    dispatch_async(queue, ^{
        NSLog(@"任务1");
    });
    
    NSLog(@"任务3");
}

void asyncGroup() {
    // 创建线程组
    dispatch_group_t group = dispatch_group_create();
    
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 添加任务1到group
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 5; i ++) {
            NSLog(@"任务1 == %zd ---%@",i, [NSThread currentThread]);
        }
    });
    
    // 添加任务2到group
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 5; i ++) {
            NSLog(@"任务2 == %zd ---%@",i, [NSThread currentThread]);
        }
    });
    
    // 等group前面的任务都执行完后，再执行notify中的任务3
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSInteger i = 0; i < 5; i ++) {
                NSLog(@"任务3 == %zd ---%@",i, [NSThread currentThread]);
            }
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
@end
