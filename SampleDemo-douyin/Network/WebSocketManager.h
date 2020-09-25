//
//  WebSocketManager.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义消息通知常量名称
extern NSString *const WebSocketDidReceiveMessageNotification;

@interface WebSocketManager : NSObject

// WebSocketManager 单例
+ (instancetype)shareManager;
// 断开连接
- (void)disConnect;
// 连接
- (void)connect;
// 发送消息
- (void)sendMessage:(id)msg;

@end
