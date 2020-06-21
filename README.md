# 09-多线程之GCD

我们平时在项目开发过程中经常会用到多线程相关的技术，经常会使用多线程来进行网络请求和数据传输等操作，OC中创建多线程主要有以下几种方式：

* pthread
* NSThread
* GCD
* NSOperation

这四种创建多线程区别对比如图：

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200210-231036@2x.png)

我们在平时的项目开发过程中，使用最多的创建多线程的方式就是`GCD`，接下来我们看下`GCD`的常见用法

`GCD`有两种执行任务的方式：

* dispatch_snyc(同步执行任务)：任务在当前主线程中执行，并没有开启新线程(dispatch_snyc不具备开启异步线程的能力)
* dispatch_async(异步执行任务)：任务在子线程中执行，dispatch_async会开启一个异步子线程(dispatch_async具备开启新线程的能力)

`GCD`队列(queue)也分为两种类型：

* 串行队列(Serial Dispatch Queue)：多个任务一个挨着一个的有序执行，上一个任务执行完接着执行下一个任务
* 并发队列(Concurrent Dispatch Queue)：多个任务并发(同时)执行，自动开启多个线程来同时执行任务

上面我们提到了两个概念

* 任务：可以理解为是多线程需要做的事情，在`GCD`中任务就是对应的`block`代码块内需要执行的代码，任务又分为`同步`和`异步`，`同步`和`异步`的主要区别在于是否具备开启新线程的能力
	* 同步：任务在当前主线程中执行，不具备开启新线程的能力
	* 异步：任务在新开启的子线程中执行，具备开启新线程的能力
	
* 队列：可以理解为是控制多个任务的执行顺序
	* 串行：多个任务一个挨着一个的有序执行，上一个任务执行完接着执行下一个任务
	* 并发：多个任务并发(同时)执行，会自动开启多个线程来同时执行任务

总结如下图：

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200211-134810@2x.png)

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200211-134832@2x.png)

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200211-134853@2x.png)

接下来我们先用代码验证同步执行任务的情况，代码如下：

`同步串行`

```
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
```

`同步并发`

```
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
```

`异步串行`

```
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
```

`异步并发`

```
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
```

从上面的测试代码打印我们可以看到，当我们使用`dispatch_snyc`同步执行任务，任务在当前主线程执行，没有开启新的子线程，不管是串行队列还是并发队列，最终任务都是一个挨一个的串行执行

当我们使用`dispatch_async`异步执行任务时，任务会在新开启的子线程中执行，如果是串行队列，多个任务还是一个挨一个的串行执行，如果是并发队列，则此时多个任务是并发同时执行

注意：当我们使用`dispatch_async`异步执行任务，但是此时的队列如果是`dispatch_get_main_queue`主队列，则此时并没有开启新的子线程，任务任然是在当前主线程中执行，代码如下：

```
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
```

总结如图：

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200211-135057@2x.png)

我们再来看一个使用`dispatch_sync`造成线程死锁的示例，代码如下：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"任务1");
    
    // 主队列，串行队列有FIFO特点，也就是先进先出
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 同步执行任务，立即在当前主线程执行任务，任务不执行完后面的代码就会不会执行
    dispatch_sync(queue, ^{
        NSLog(@"任务2");
    });
    
    NSLog(@"任务3");
}
```

上面的代码就造成了线程死锁，因为`dispatch_sync`特点是要求任务在当前主线程立即执行完任务2，任务2不执行完后面的代码就不会执行，但是当前线程任务3还没有执行完，不能够执行任务2，这样就导致了任务2等任务3执行完，任务3等任务2执行完，产生死锁

注意：串行队列有FIFO特点，在本示例中，执行`viewDidLoad`函数也是当前线程的一个任务，是在任务2之前进入到队列中排队执行的任务

如图：

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200211-174230@2x.png)

我们将上面的`dispatch_sync`同步执行任务改为`dispatch_async`异步执行任务就不会产生死锁，示例代码如下：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   NSLog(@"任务1");
   
   // 主队列，串行队列有FIFO特点，也就是先进先出
   dispatch_queue_t queue = dispatch_get_main_queue();
   
   // 异步执行任务，不要求任务立即执行
   dispatch_async(queue, ^{
       NSLog(@"任务1");
   });
   
   NSLog(@"任务3");
}
```

接下来我们再来看下线程组`dispatch_group_t`的基本用法，假设我们需要实现下面这个需求：异步并发执行任务1和任务2，等任务1和任务2都执行完后在回到主线程执行任务3，这里就可以借助线程组来实现，代码如下：

```
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
```


讲解示例Demo地址：[https://github.com/guangqiang-liu/09-GCD]()


## 更多文章
* ReactNative开源项目OneM(1200+star)：**[https://github.com/guangqiang-liu/OneM](https://github.com/guangqiang-liu/OneM)**：欢迎小伙伴们 **star**
* iOS组件化开发实战项目(500+star)：**[https://github.com/guangqiang-liu/iOS-Component-Pro]()**：欢迎小伙伴们 **star**
* 简书主页：包含多篇iOS和RN开发相关的技术文章[http://www.jianshu.com/u/023338566ca5](http://www.jianshu.com/u/023338566ca5) 欢迎小伙伴们：**多多关注，点赞**
* ReactNative QQ技术交流群(2000人)：**620792950** 欢迎小伙伴进群交流学习
* iOS QQ技术交流群：**678441305** 欢迎小伙伴进群交流学习