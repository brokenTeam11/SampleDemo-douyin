//
//  WebPQueueManager.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/30.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "WebPQueueManager.h"

@interface WebPQueueManager ()
@property (nonatomic, assign) NSInteger maxQueueCount;          // 最大执行中的NSOperationQueue数量
@property (nonatomic, strong) NSMutableArray<NSOperationQueue *> *requestQueueArray; // 用于存储NSOperationQueue的数量
@end

@implementation WebPQueueManager
// WebPQueueManager单例
+ (WebPQueueManager *)sharedWebPQueueManager {
    static dispatch_once_t onceToken;
    static WebPQueueManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [WebPQueueManager new];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestQueueArray = [NSMutableArray array];
        _maxQueueCount = 5;
    }
    return self;
}

// 添加NSOperationQueue队列
- (void)addQueue:(NSOperationQueue *)queue {
    @synchronized (_requestQueueArray) {
        if ([_requestQueueArray containsObject:queue]) {
            NSInteger index = [_requestQueueArray indexOfObject:queue];
            [_requestQueueArray replaceObjectAtIndex:index withObject:queue];
        } else {
            [_requestQueueArray addObject:queue];
            [queue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
        }
        [self processQueue];
    }
}

// 取消指定NSOperationQueue队列
- (void)cancelQueue:(NSOperationQueue *)queue {
    @synchronized (_requestQueueArray) {
        if ([_requestQueueArray containsObject:queue]) {
            [queue cancelAllOperations];
            [_requestQueueArray removeObject:queue];
        }
    }
}

//挂起NSOperationQueue队列
- (void)suspendQueue:(NSOperationQueue *)queue suspended:(BOOL)suspended {
    @synchronized (_requestQueueArray) {
        if ([_requestQueueArray containsObject:queue]) {
            [queue setSuspended:suspended];
        }
    }
}

// 对当前并发的所有队列进行处理,保证正在执行的队列数量不超过最大执行的队列数
- (void)processQueue {
    @synchronized (_requestQueueArray) {
        [_requestQueueArray enumerateObjectsUsingBlock:^(NSOperationQueue *_Nonnull queue, NSUInteger idx, BOOL *_Nonnull stop) {
            if (idx < self.maxQueueCount) {
                [self suspendQueue:queue suspended:NO];
            } else {
                [self suspendQueue:queue suspended:YES];
            }
        }];
    }
}

// 移除任务已经完成的队列，并更新当前正在执行的队列
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"operations"]) {
        NSOperationQueue *queue = object;
        if ([queue.operations count] == 0) {
            @synchronized (_requestQueueArray) {
                [_requestQueueArray removeObject:queue];
            }
            [self processQueue];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/* dealloc方法的重写

一般会重写dealloc方法,在这里释放相关资源,dealloc就是对象的遗言
一旦重写了dealloc方法, 就必须调用[super dealloc],并且放在最后面调用
*/
-(void)dealloc{
    for (NSOperationQueue *queue in _requestQueueArray) {
        [queue removeObserver:self forKeyPath:@"operations"];
    }
}

@end
