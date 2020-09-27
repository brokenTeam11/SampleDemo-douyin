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
@property (nonatomic, copy) WebDownloadCancelBlock cancelBlock;
// 查询缓存NSOperation任务
@property (strong, nonatomic) NSOperation *cacheOperation;
// 下载网络资源任务
@property (strong, nonatomic) WebDownloadOperation     *downloadOperation;
// 取消查询缓存NSOperation任务和下载资源WebDownloadOperation任务
- (void)cancel;
@end

// 处理网络资源缓存类
@interface WebCacheHelper : NSObject
// 单例
+ (WebCacheHelper *)sharedWebCache;
// 根据key值从内存和本地磁盘中查询缓存数据
- (NSOperation *)queryDataFromMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock;
// 根据key值从本地磁盘中查询缓存数据
- (NSOperation *)queryURLFromDiskMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock;
// 根据key值从内存和本地磁盘中查询缓存数据，所查询缓存数据包含指定文件类型
- (NSOperation *)queryDataFromMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension;
// 存储缓存数据到内存和本地磁盘
- (void)storeDataChace:(NSData *)data forKey:(NSString *)key;
// 根据key值从内存和本地磁盘中查询缓存数据，所查询缓存数据包含指定文件类型
- (NSOperation *)queryURLFromDiskMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension;

// 存储缓存数据到本地磁盘
- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key;

- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key extension:(NSString *)extension;

//  清除本地磁盘缓存数据
- (void)clearCache:(WebCacheClearCompletedBlock)cacheClearCompletedBlock;

@end


// 自定义用于下载网络资源的NSOperation任务
@interface WebDownloadOperation : NSOperation <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property(strong, nonatomic) NSURLSession *session;
@property(strong, nonatomic) NSURLSessionTask *dataTask;
@property(strong, nonatomic, readonly) NSURLRequest *request;

// 初始化
- (instancetype)initWithRequest:(NSURLRequest *)request responseBlock:(WebDownloadResponseBlock)responseBlock progressBlock:(WebDownloadProgressBlock)progressBlock completedBlock:(WebDownloadCompletedBlock)completedBlock cancelBlock:(WebDownloadCancelBlock)cancelBlock;

@end


// 自定义网络资源下载器
@interface WebDownloader : NSObject
// 用于处理下载任务的NSOperationQueue队列
@property (nonatomic, strong) NSOperationQueue *downloadConcurrentQueue;
@property (nonatomic, strong) NSOperationQueue *downloadSerialQueue;

@property (nonatomic, strong) NSOperationQueue *downloadBackgroundQueue;
@property (nonatomic, strong) NSOperationQueue *downloadPriorityHighQueue;
// 单例
+ (WebDownloader *)sharedDownloader;

// 下载指定URL网络资源
- (WebCombineOperation *)downloadWithURL:(NSURL *)url
                           progressBlock:(WebDownloadProgressBlock)progressBlock
                          completedBlock:(WebDownloadCompletedBlock)completedBlock
                             cancelBlock:(WebDownloadCancelBlock)cancelBlock;

- (WebCombineOperation *)downloadWithURL:(NSURL *)url
                           progressBlock:(WebDownloadProgressBlock)progressBlock
                          completedBlock:(WebDownloadCompletedBlock)completedBlock
                             cancelBlock:(WebDownloadCancelBlock)cancelBlock
                            isConcurrent:(BOOL)isConcurrent;

- (WebCombineOperation *)downloadWithURL:(NSURL *)url
                           responseBlock:(WebDownloadResponseBlock)responseBlock
                           progressBlock:(WebDownloadProgressBlock)progressBlock
                          completedBlock:(WebDownloadCompletedBlock)completedBlock
                             cancelBlock:(WebDownloadCancelBlock)cancelBlock;

- (WebCombineOperation *)downloadWithURL:(NSURL *)url
                           responseBlock:(WebDownloadResponseBlock)responseBlock
                           progressBlock:(WebDownloadProgressBlock)progressBlock
                          completedBlock:(WebDownloadCompletedBlock)completedBlock
                             cancelBlock:(WebDownloadCancelBlock)cancelBlock
                            isConcurrent:(BOOL)isConcurrent;

- (WebCombineOperation *)downloadWithURL:(NSURL *)url
                           responseBlock:(WebDownloadResponseBlock)responseBlock
                           progressBlock:(WebDownloadProgressBlock)progressBlock
                          completedBlock:(WebDownloadCompletedBlock)completedBlock
                             cancelBlock:(WebDownloadCancelBlock)cancelBlock
                            isBackground:(BOOL)isBackground;

@end
