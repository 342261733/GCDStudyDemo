//
//  LockClasses.m
//  GCDStudyDemo
//
//  Created by QFPayShadowMan on 16/7/12.
//  Copyright © 2016年 xnq. All rights reserved.
//

#import "LockClasses.h"
#import <pthread/pthread.h>
#import <libkern/OSAtomic.h>

@implementation LockClasses
@synthesize hello;

- (void)testLock {
//    [self testSynchronized];
//    [self testDispatch_semaphore];
//    [self testNSLock];
//    [self testRecursiveLock];
//    [self testNSConditionLock];
//    [self testNSCondition];
//    [self testPhread_mutex];
//    [self testPthread_mutexRecursive];
//    [self testOSSpinLock];
}

// @synchronized
- (void)testSynchronized {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@" ------ 线程的操作1开始 ------ ");
        sleep(1.0);
        NSLog(@" ------ 线程的操作1结束 ------ ");
        
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@" ------ 线程的操作2开始 ------ ");
        sleep(1.0);
        NSLog(@" ------ 线程的操作2结束 ------ ");
    });
    
    NSObject *obj = [[NSObject alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (obj) {
            NSLog(@" ------ 需要线程同步的操作3开始 ------ ");
            sleep(1.0);
            NSLog(@" ------ 需要线程同步的操作3结束 ------ ");
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (obj) {
            NSLog(@" ------ 需要线程同步的操作4开始 ------ ");
            sleep(1.0);
            NSLog(@" ------ 需要线程同步的操作4结束 ------ ");
        }
    });
}

// dispatch_semaphore
- (void)testDispatch_semaphore {
    dispatch_semaphore_t signal = dispatch_semaphore_create(1);
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(signal, overTime); // 相当于-1 release
        NSLog(@" ------ 需要线程同步的操作1开始 ------ ");
        sleep(1.0);
        NSLog(@" ------ 需要线程同步的操作1结束 ------ ");
        dispatch_semaphore_signal(signal); // 相当于 +1 retain
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(signal, overTime);
        NSLog(@" ------ 需要线程同步的操作2开始 ------ ");
        sleep(1.0);
        NSLog(@" ------ 需要线程同步的操作2结束 ------ ");
        dispatch_semaphore_signal(signal);
    });
}

- (void)testNSLock {
    NSLock *lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lockBeforeDate:[NSDate date]];
        NSLog(@" ------ 需要线程同步的操作1开始 ------ ");
        sleep(5.0); // 1.0 下面可以获取锁的操作
        NSLog(@" ------ 需要线程同步的操作1结束 ------ ");
        [lock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.0);
        if ([lock tryLock]) {
            NSLog(@" 锁可用的操作 ");
            [lock unlock];
        }
        else {
            NSLog(@" 锁不可用的状态 ");
        }
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:3.0];
        if ([lock lockBeforeDate:date]) { // 尝试在未来的3s内获取锁，并阻塞该线程，如果3s内获取不到恢复线程，返回NO，不会阻塞该线程
            NSLog(@" 没有超时，获得锁 ");
        }
        else {
            NSLog(@" 超时，没有获得锁 ");
        }
        
        for (int i=0; i<10; i++) {
            NSLog(@"finally invoke  %d", i);
            sleep(1.0);
        }
    });
}

- (void)testRecursiveLock { // 递归锁
    [self testQuestDeadLock]; // 死锁
    NSRecursiveLock *reLock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveMethod)(int);
        RecursiveMethod = ^(int value) {
            [reLock lock];
            if (value > 0) {
                NSLog(@"NSRecursiveLock value = %d",value);
                sleep(1);
                RecursiveMethod(value - 1);
            }
            [reLock unlock];
        };
        RecursiveMethod(5);
    });
}

- (void)testQuestDeadLock {
    // 死锁解析：RecursiveMethod是递归调用的。所以每次进入这个block时，都会去加一次锁，而从第二次开始，由于锁已经被使用了且没有解锁，所以它需要等待锁被解除，这样就导致了死锁，线程被阻塞住了。
    NSLock *reLock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveMethod)(int);
        RecursiveMethod = ^(int value) {
            [reLock lock];
            if (value > 0) {
                NSLog(@"NSLock value = %d",value);
                sleep(1);
                RecursiveMethod(value - 1);
            }
            [reLock unlock];
        };
        RecursiveMethod(5);
    });
}

- (void)testNSConditionLock {  //
    NSMutableArray *products = [NSMutableArray array];
    
    NSInteger has_data = 1;
    NSInteger no_data = 0;
    
    NSConditionLock *conditionLock = [[NSConditionLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [conditionLock lockWhenCondition:no_data];
            [products addObject:[[NSObject alloc] init]];
            NSLog(@" Add a product , All is %zi ", products.count);
            [conditionLock unlockWithCondition:has_data];
            sleep(1);
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            NSLog(@" Wait for product ");
            [conditionLock lockWhenCondition:has_data];
            [products removeObjectAtIndex:0];
            NSLog(@" Minus a product ");
            [conditionLock unlockWithCondition:no_data];
        }
    });
}

- (void)testNSCondition { //
    NSCondition *condition = [[NSCondition alloc] init];
    NSMutableArray *arrProducts = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [condition lock];
            if (arrProducts.count == 0) {
                NSLog(@" Wait for product ");
                [condition wait]; // 等待
            }
            [arrProducts removeObjectAtIndex:0];
            NSLog(@" Minus a product ");
            [condition unlock];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [condition lock];
            [arrProducts addObject:[[NSObject alloc] init]];
            NSLog(@" Add a produce , all is %zi ", arrProducts.count);
            [condition signal]; // 发送信号的方式，在一个线程唤醒另外一个线程的等待。
            [condition unlock];
            sleep(1);
        }
    });
}

- (void)testPhread_mutex {
    __block pthread_mutex_t theLock;
    pthread_mutex_init(&theLock, NULL);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&theLock);
        NSLog(@"  ------ 需要线程同步的操作1开始 ------  ");
        sleep(1.0);
        NSLog(@"  ------ 需要线程同步的操作1结束 ------  ");
        pthread_mutex_unlock(&theLock);
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&theLock);
        NSLog(@"  ------ 需要线程同步的操作2开始 ------  ");
        sleep(1.0);
        NSLog(@"  ------ 需要线程同步的操作2结束 ------  ");
        pthread_mutex_unlock(&theLock);
    });
}

// 递归锁
- (void)testPthread_mutexRecursive {
    __block pthread_mutex_t theBlock;
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&theBlock, &attr);
    pthread_mutexattr_destroy(&attr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void(^RecursiveMethod)(int);
        RecursiveMethod = ^(int value) {
            pthread_mutex_lock(&theBlock);
            if (value > 0) {
                NSLog(@"value is %d",value);
                RecursiveMethod(value - 1);
            }
            pthread_mutex_unlock(&theBlock);
        };
        RecursiveMethod(5);
    });
}

- (void)testOSSpinLock {
    __block OSSpinLock theLock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        NSLog(@"  ------ 需要线程同步的操作1开始 ------  ");
        sleep(1.0);
        NSLog(@"  ------ 需要线程同步的操作1结束 ------  ");
        OSSpinLockUnlock(&theLock);
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        NSLog(@"  ------ 需要线程同步的操作2开始 ------  ");
        sleep(1.0);
        NSLog(@"  ------ 需要线程同步的操作2结束 ------  ");
        OSSpinLockUnlock(&theLock);
    });
}

@end
