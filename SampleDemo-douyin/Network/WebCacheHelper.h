//
//  WebCacheHelper.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import <UIKit/UIKit.h>

// 缓存清除完毕后的回调block
typedef void (^WebCacheClearCompletedBlock)(NSString *cacheSize);
// 缓存查询完毕后的回调block, data返回类型包括NSString缓存文件路径，NSData格式缓存路径
typedef void (^WebCacheQueryCompletedBlock)(id data, BOOL hasCache);
// 网络资源下载响应返回的回调block
typedef void (^WebDownloadResponseBlock)(NSHTTPURLResponse *response);
// 网络资源下载进度的回调block
typedef void (^WebDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSData *data);
// 网络资源下载完毕后的回调block
typedef void (^WebDownloadCompletedBlock)(NSData *data, NSError *error, BOOL finished);
// 网络资源下载取消后的回调block
typedef void (^WebDownloadCancelBlock)(void);

// 声明网络资源下载类
@class WebDownloadOperation;

// 查询缓存NSOperation任务和下载资源WebDownloadOperation任务合并的类
@interface WebCombineOperation : NSObject
// 网络资源下载取消后的回调
@property(nonatomic, copy) WebDownloadCancelBlock cancelBlock;
// 查询缓存NSOperation任务
@property(nonatomic, strong) NSOperation *cacheOperation;
// 下载网络资源任务
@property(nonatomic, strong) WebDownloadOperation *downloadOperation;
// 取消查询缓存NSOperation任务和下载资源WebDownloadOperation任务
- (void) cancel;
@end

// 处理网络资源缓存类
@interface WebCacheHelper : NSObject
// 单例
+ (WebCacheHelper *) sharedWebCache;


@end
