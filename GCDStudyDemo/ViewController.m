//
//  ViewController.m
//  GCDStudyDemo
//
//  Created by QFPayShadowMan on 16/6/14.
//  Copyright © 2016年 xnq. All rights reserved.
//

#import "ViewController.h"
#import "LockClasses.h"

@interface ViewController () {
    NSInvocationOperation *_invokeoperation;
    NSOperationQueue *_opQueue;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startTest];
    LockClasses *lcls = [[LockClasses alloc] init];
    [lcls testLock];
}

- (void)startTest {
    // **** GCD *****
    
//    [self testSync];// 同步
//    [self testAsyn];// 异步
//    [self testBarrier];// 调度障碍:并发可以同时多线程同时开始，barrier可以控制多线程顺序结束。
//    [self testGroup];// 调度 组
//    [self testApply];
    // [self testSource];
//    [self testSerialQueue]; // 串行
//    [self testParallel];// 并行
//    
//    [self GCDSynSerial]; // 同步串行
//    [self GCDAsySerial]; // 异步串行
//    [self GCDSynConcurrent]; // 同步并行
//    [self GCDAsyConcurrent]; // 异步并行
    
    // 结束线程？？
    //    dispatch_cancel(dispatch_get_global_queue(0, 0));
    //    dispatch_release(dispatch_get_global_queue(0, 0));
    
    
    // **** NSOperation ****
    
//    [self testNSOperation];
    
    
    // **** NSThread ****
    
//    [self testNSThread];
    
    // [self testThreadLock];

}

- (void)testThreadLock {
    dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1"); // 任务1
    dispatch_async(queue, ^{
        NSLog(@"2"); // 任务2
        dispatch_sync(queue, ^{
            NSLog(@"3"); // 任务3
        });
        NSLog(@"4"); // 任务4
    });
    NSLog(@"5"); // 任务5
}

#pragma mark - GCD

- (void)testSync {
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        for (int i=0; i< 5; i++) {
            NSLog(@"global queue 1 %d",i);
            [NSThread sleepForTimeInterval:1];
            if (i == 9) {
            }
        }
    });
    NSLog(@"have finished queue1");
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        for (int i=0; i< 5; i++) {
            NSLog(@"global queue2 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
    });
    NSLog(@"have finished queue2");
}

- (void)testAsyn {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i=0; i< 5; i++) {
            NSLog(@"global queue1 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
    NSLog(@"have finished queue1");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i=0; i< 5; i++) {
            NSLog(@"global queue2 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
    });
    NSLog(@"have finished queue2");
}

- (void)testBarrier {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^(){
        for (int i=0; i< 5; i++) {
            NSLog(@"dispatch queue1 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
        NSLog(@"\n \n dispatch-1 finished \n \n");
    });
    dispatch_async(concurrentQueue, ^(){
        for (int i=0; i< 5; i++) {
            NSLog(@"dispatch queue2 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
        NSLog(@"\n \n dispatch-2 finished \n \n");
    });
    dispatch_barrier_async(concurrentQueue, ^(){
        for (int i=0; i< 5; i++) {
            NSLog(@"dispatch barrier %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
        NSLog(@"\n \n dispatch-barrier finished \n \n");
    });
    dispatch_async(concurrentQueue, ^(){
        for (int i=0; i< 5; i++) {
            NSLog(@"dispatch queue3 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
        NSLog(@"\n \n dispatch-3 finished \n \n");
    });
    dispatch_async(concurrentQueue, ^(){
        for (int i=0; i< 5; i++) {
            NSLog(@"dispatch queue4 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
        NSLog(@"\n \n dispatch-4 finished \n \n");
    });
}

- (void)testGroup {
    dispatch_queue_t dispatchQueue = dispatch_queue_create("ted.queue.next", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
        for (int i=0; i< 5; i++) {
            NSLog(@"dispatch queue1 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
        NSLog(@"\n \n dispatch-1 finished \n \n");
    });
    dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
        for (int i=0; i< 10; i++) {
            NSLog(@"dispatch queue2 %d",i*2);
            [NSThread sleepForTimeInterval:1];
        }
        NSLog(@"\n \n dispatch-2 finished \n \n");
    });
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        NSLog(@"end");
    });
}

- (void)testApply {
    // 并发提高效率
    NSLog(@"\n \n Starting \n \n");
    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
        dispatch_apply(2, dispatch_get_global_queue(0, 0), ^(size_t index){
            for (int i=0; i< 5; i++) {
                NSLog(@"dispatch queue%ld %d", index, i*2);
                [NSThread sleepForTimeInterval:1.0];
            }
            NSLog(@"\n \n dispatch-%ld finished \n \n", index);
        });
        NSLog(@"\n \n Ending \n \n");
    });
    
//    // 目测效率是一样的。
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        for (int i=0; i< 5; i++) {
//            NSLog(@"global queue1 %d",i*2);
//            [NSThread sleepForTimeInterval:1];
//        }
//        NSLog(@"****** have finished queue1 ******");
//    });
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        for (int i=0; i< 5; i++) {
//            NSLog(@"global queue2 %d",i*2);
//            [NSThread sleepForTimeInterval:1];
//        }
//        NSLog(@"****** have finished queue2 ******");
//    });
}

- (void)testSource {
    dispatch_queue_t queue = dispatch_get_main_queue();
    static dispatch_source_t source = nil;
    __weak __typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
     NSLog(@"I am :%@ , %@",self, weakSelf);
    dispatch_once(&onceToken, ^{
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGSTOP, 0, queue);
        if (source) {
            dispatch_source_set_event_handler(source, ^{ // 断我啊~
                NSLog(@"I am :%@",weakSelf);
            });
            dispatch_resume(source);
        }
    });
}

- (void)testSerialQueue {  // 串行
    NSLog(@" 当前线程是： %@", [NSThread currentThread]);
    
    // 创建一个串行queue
    dispatch_queue_t queue = dispatch_queue_create("hello.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_suspend(queue); // 挂起
    [NSThread sleepForTimeInterval:2.0];
    dispatch_resume(queue); // 继续
    
    //
    dispatch_sync(queue, ^{ // <NSThread: 0x7fdd49703940>{number = 1, name = main}
        sleep(1.0);
        NSLog(@"开启了一个异步线程 当前线程是： %@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{ // <NSThread: 0x7fdd49757630>{number = 2, name = (null)}
        sleep(1.0);
        NSLog(@"开启了一个同步线程 当前线程是： %@", [NSThread currentThread]);
    });
}

- (void)testParallel {
    for (int i = 0; i < 5; i++) {
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%d", i);
    }
    
    NSLog(@"////////// ******* 并行开启 ******* /////////////");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    size_t count = 5;
    dispatch_apply(count, queue, ^(size_t i) {
        sleep(1.0);
        NSLog(@"--%zd",i);
    });
    
    for (int i = 0; i < 5; i ++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"hello %d", i);
        });
    }
    
    for (int i = 0; i < 5; i ++) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"world %d", i);
        });
    }
}

- (void)GCDSynSerial {
    dispatch_queue_t queue = dispatch_queue_create("hello.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 同步执行  串行  方法1 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------同步执行  串行  方法1 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 同步执行  串行  方法2 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------同步执行  串行  方法2 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void)GCDAsySerial {
    dispatch_queue_t queue = dispatch_queue_create("hello.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 异步执行 串行 方法1 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------异步执行 串行 方法1 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 异步执行 串行 方法2 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------异步执行 串行 方法2 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void)GCDSynConcurrent { // 同步的并行跟串行类似
    dispatch_queue_t queue = dispatch_queue_create("hello.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 同步执行 并行 方法1 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------同步执行 并行 方法1 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 同步执行 并行 方法2 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------同步执行 并行 方法2 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void)GCDAsyConcurrent { // 异步的并行可以同时进行，节省时间
    dispatch_queue_t queue = dispatch_queue_create("hello.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 异步执行 并行 方法1 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------异步执行 并行 方法1 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"%@ 异步执行 并行 方法2 ", [NSThread currentThread]);
        for (int i=0; i< 5; i++) {
            NSLog(@"-------异步执行 并行 方法2 %d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
}


#pragma mark - NSOperation

- (void)testNSOperation {
//    [self testSynOperation];// 同步
//    [self testOperationQueue];// 异步
}

- (void)testSynOperation {
    _invokeoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationRun) object:nil];
    [_invokeoperation start];
    
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:@selector(invokeSelector)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:@selector(invokeSelector)];
    NSInvocationOperation *operationInvoke = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [operationInvoke start];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"hello block operation");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"finished block operation ");
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@" block operation 2 ");
    }];
    [blockOperation start];
    
    NSLog(@" ------------- all is finished --------------- ");
}

- (void)testOperationQueue {
    _invokeoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationRun) object:nil];
    
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:@selector(invokeSelector)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:@selector(invokeSelector)];
    NSInvocationOperation *operationInvoke = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"hello block operation");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"block operation invoke end");
    }];

    // 设置依赖关系，将会是执行顺序，blockOperation 然后 operationInvoke 最后 _invokeoperation
    [_invokeoperation addDependency:operationInvoke];
    [operationInvoke addDependency:blockOperation];
    
    _opQueue = [[NSOperationQueue alloc] init];
    [_opQueue addOperation:_invokeoperation];
//    [_invokeoperation cancel]; // 结束_invokeoperation 操作
    [_opQueue addOperation:operationInvoke];
    [_opQueue addOperation:blockOperation];
//    [_opQueue cancelAllOperations]; // 结束所有的操作
    operationInvoke.completionBlock = ^(void) {
        NSLog(@"\n ********* \n operationInvoke finished \n ********* \n");
    };
    blockOperation.completionBlock = ^(void) {
        NSLog(@"\n ********* \n blockOperation finished \n ********* \n");
    };
    _invokeoperation.completionBlock = ^(void) {
        NSLog(@"\n ********* \n _invokeoperation finished \n ********* \n");
    };
    NSLog(@" ------------- all is finished --------------- ");
}

- (void)operationRun {
    NSLog(@"runing ");
    
    for (int i = 0; i < 10; i ++) {
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"------> %d", i);
        if (i == 3) {
            break;
        }
    }
}

- (void)invokeSelector {
    NSLog(@"invoking runing ");
}

#pragma mark - NSThread

- (void)testNSThread {
    [self testInitThread];
}

- (void)testInitThread {
    // method 1
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadRun) object:nil];
    thread.threadPriority = 1.0;
    [thread start];
//    [thread cancel]; // 位置也挺奇怪的
    [thread main]; // 又调用了一次thread的method一次
//    [thread cancel]; // 位置也挺奇怪的
    
//    [NSThread exit]; // 退出线程，下面的线程方法将不会再执行。
    
    // method 2
    [NSThread detachNewThreadSelector:@selector(threadRun2) toTarget:self withObject:nil];
    
    [NSThread currentThread];
    
    [NSThread mainThread];
    
    [NSThread sleepForTimeInterval:1.0];
    NSDate *date = [NSDate dateWithTimeInterval:1.0 sinceDate:[NSDate date]];
    [NSThread sleepUntilDate:date];
    
    [self performSelector:@selector(testPerformOnThread) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
}

- (void)threadRun {
    NSLog(@"nsthread  running ");
    
    NSCondition *codition = [[NSCondition alloc] init]; // 条件锁
    [codition lock];
    
    [codition unlock];
}

- (void)threadRun2 {
    NSLog(@"nsthread 2  running ");
}

- (void)testPerformOnThread {
    NSLog(@" testPerformOnThread ");
}

@end
