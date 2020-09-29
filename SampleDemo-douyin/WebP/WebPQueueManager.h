//
//  WebPQueueManager.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/30.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebPQueueManager : NSObject
// WebPQueueManager单例
+(WebPQueueManager *)sharedWebPQueueManager;
// 添加NSOperationQueue队列
-(void)addQueue:(NSOperationQueue *)queue;
// 取消指定NSOperationQueue队列
-(void)cancelQueue:(NSOperationQueue *)queue;
//挂起NSOperationQueue队列
-(void)suspendQueue:(NSOperationQueue *)queue suspended:(BOOL)suspended;
@end

