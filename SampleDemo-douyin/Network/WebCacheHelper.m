//
//  WebCacheHelper.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "WebCacheHelper.h"
#import "objc/runtime.h"
#import <CommonCrypto/CommonDigest.h>

@implementation WebCombineOperation
// 取消查询缓存NSOperation任务和下载资源WebDownloadOperation任务
- (void)cancel {
    // 取消查询缓存NSOperation任务
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    // 取消下载资源WebDownloadOperation任务
    if (self.downloadOperation) {
        [self.downloadOperation cancel];
        self.downloadOperation = nil;
    }
    // 任务取消回调
    if (self.cancelBlock) {
        self.cancelBlock();
        _cancelBlock = nil;
    }
}

@end

// 处理网络资源缓存类

@interface WebCacheHelper ()
@property (nonatomic, strong) NSCache *memCache; // 内存缓存
@property (nonatomic, strong) NSFileManager *fileManager; // 文件管理类
@property (nonatomic, strong) NSURL *diskCacheDirectoryURL; // 本地磁盘文件夹路径
// dispatch Queue是执行处理的等待队列。
// Queue 是队列
@property (nonatomic, strong) dispatch_queue_t ioQueue; // 查询缓存任务队列

@end

@implementation WebCacheHelper
// 单例
+ (WebCacheHelper *)sharedWebCache {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

// 初始化
// instancetype的作用，就是使那些非关联返回类型的方法返回所在类的类型！
- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化内存缓存
        _memCache = [NSCache new];
        _memCache.name = @"webCache";
        _memCache.totalCostLimit = 50 * 1024 * 1024;

        // 初始化文件管理类
        _fileManager = [NSFileManager defaultManager];

        // 获取本地磁盘缓存文件夹路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        // lastObject 返回最后一个元素
        NSString *path = [paths lastObject];
        NSString *diskCachePath = [NSString stringWithFormat:@"%@%@", path, @"/webCache"];
        // 判断是否创建本地磁盘文件夹
        BOOL isDirectory = NO;
        BOOL isExisted = [_fileManager fileExistsAtPath:diskCachePath isDirectory:&isDirectory];
        if (!isDirectory || !isExisted) {
            NSError *error;
            [_fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        // 本地磁盘缓存文件夹URL
        _diskCacheDirectoryURL = [NSURL fileURLWithPath:diskCachePath];
        // 初始化查询缓存任务队列
        _ioQueue = dispatch_queue_create("com.start.webcache", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

// 根据key值从内存和本地磁盘中查询缓存数据
- (NSOperation *)queryDataFromMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock {
    return [self queryDataFromMemory:key cacheQueryCompletedBlock:cacheQueryCompletedBlock extension:nil];
}

// 根据key值从内存和本地磁盘中查询缓存数据，所查询缓存数据包含指定文件类型
- (NSOperation *)queryDataFromMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension {
    NSOperation *operation = [NSOperation new];
    dispatch_async(_ioQueue, ^{
        if (operation.isCancelled) {
            return;
        }
        NSData *data = [self dataFromMemoryCache:key];
        if (!data) {
            data = [self dataFromDiskCache:key extension:extension];
        }
        if (!data) {
            [self storeDataToMemoryCache:data key:key];
        }
        if (data) {
            cacheQueryCompletedBlock(data, YES);
        } else {
            cacheQueryCompletedBlock(nil, NO);
        }
    });
    return operation;
}

// 根据key值从本地磁盘中查询缓存数据
- (NSOperation *)queryURLFromDiskMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock {
    return [self queryURLFromDiskMemory:key cacheQueryCompletedBlock:cacheQueryCompletedBlock extension:nil];
}

// 根据key值从内存和本地磁盘中查询缓存数据，所查询缓存数据包含指定文件类型
- (NSOperation *)queryURLFromDiskMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension {
    NSOperation *operation = [NSOperation new];
    dispatch_async(_ioQueue, ^{
        if (operation.isCancelled) {
            return;
        }
        NSString *path = [self diskCachePathForKey:key extension:extension];
        if ([self.fileManager fileExistsAtPath:path]) {
            cacheQueryCompletedBlock(path, YES);
        } else {
            cacheQueryCompletedBlock(path, NO);
        }
    });
    return operation;
}

// 根据key值从内存中查询缓存数据
- (NSData *)dataFromMemoryCache:(NSString *)key {
    return [_memCache objectForKey:key];
}

// 根据key值从本地磁盘中查询缓存数据
- (NSData *)dataFromDiskCache:(NSString *)key {
    return [self dataFromDiskCache:key extension:nil];
}

// 根据key值从本地磁盘中查询缓存数据
- (NSData *)dataFromDiskCache:(NSString *)key extension:(NSString *)extension {
    return [NSData dataWithContentsOfFile:[self diskCachePathForKey:key extension:extension]];
}

// 存储缓存数据到内存和本地磁盘， 所查询缓存数据包含指定问价类型
- (void)storeDataChace:(NSData *)data forKey:(NSString *)key {
    dispatch_async(_ioQueue, ^{
        [self storeDataToMemoryCache:data key:key];
    });
}

// 存储缓存数据到内存
- (void)storeDataToMemoryCache:(NSData *)data key:(NSString *)key {
    if (data && key) {
        [self.memCache setObject:data forKey:key];
    }
}

// 存储缓存数据到本地磁盘
- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key {
    [self storeDataToDiskCache:data key:key extension:nil];
}

// 根据key值从本地磁盘中查询缓存数据， 缓存数据返回路径包含文件类型
- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key extension:(NSString *)extension {
    if (data && key) {
        [_fileManager createFileAtPath:[self diskCachePathForKey:key extension:extension] contents:data attributes:nil];
    }
}

// 获取key值对应的磁盘缓存文件路径， 文件路径包含指定扩展名
- (NSString *)diskCachePathForKey:(NSString *)key extension:(NSString *)extension {
    NSString *fileName = [self md5:key];
    NSString *cachePathForKey = [_diskCacheDirectoryURL URLByAppendingPathComponent:fileName].path;
    if (extension) {
        cachePathForKey = [cachePathForKey stringByAppendingFormat:@".%@", extension];
    }
    return cachePathForKey;
}

// 获取key值对应的磁盘缓存文件路径
- (NSString *)diskCachePathForKey:(NSString *)key {
    return [self diskCachePathForKey:key extension:nil];
}

// 清除内存和本地磁盘缓存数据
- (void)clearCache:(WebCacheClearCompletedBlock)cacheClearCompletedBlock {
    dispatch_async(_ioQueue, ^{
        [self clearMemoryCache];
        NSString *cacheSize = [self clearDiskCache];
        if (cacheClearCompletedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cacheClearCompletedBlock(cacheSize);
            });
        }
    });
}

// 清除内存缓存数据
- (void)clearMemoryCache {
    [_memCache removeAllObjects];
}

// 清除本地磁盘缓存数据
- (NSString *)clearDiskCache {
    NSArray *contents = [_fileManager contentsOfDirectoryAtPath:_diskCacheDirectoryURL.path error:nil];
    NSEnumerator *enumerator = [contents objectEnumerator];
    NSString *fileName;
    CGFloat folderSize = 0.0f;

    while ((fileName = [enumerator nextObject])) {
        NSString *filePath = [_diskCacheDirectoryURL.path stringByAppendingPathComponent:fileName];
        folderSize += [_fileManager attributesOfItemAtPath:filePath error:nil].fileSize;
        [_fileManager removeItemAtPath:filePath error:NULL];
    }
    return [NSString stringWithFormat:@"%.2f", folderSize / 1024.0f / 1024.0f]; // `@"%.2f"`精度浮点数,且只保留两位小数
}

#pragma mark - key值进行md5签名
// key值进行md5签名
- (NSString *)md5:(NSString *)key {
    if (!key) {
        return @"temp";
    }
    const char *str = [key UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end

#pragma mark - 自定义用于下载网络资源的NSOperation任务
// 自定义用于下载网络资源的NSOperation任务
@interface WebDownloadOperation ()
@property (nonatomic, copy) WebDownloadResponseBlock responseBlock; // 下载进度响应block
@property (nonatomic, copy) WebDownloadProgressBlock progressBlock; // 下载进度回调block
@property (nonatomic, copy) WebDownloadCompletedBlock completedBlock; // 下载完成回调block
@property (nonatomic, copy) WebDownloadCancelBlock cancelBlock; // 取消下载回调block
@property (nonatomic, strong) NSMutableData *data; // 用于存储网络资源数据
@property (assign, nonatomic) NSInteger expectedSize; // 网络资源数据总大小
@property (assign, nonatomic) BOOL executing; // 判断NSOperation是否执行
@property (assign, nonatomic) BOOL finished; // 判断NSOperation是否结束
@end

/*
 ------------*****-----------------
 */
#pragma mark -
@implementation WebDownloadOperation
@synthesize executing = _executing; // 指定executing别名为_executing
@synthesize finished = _finished; //指定finished别名为_finished
#pragma mark -  初始化数据
// 初始化数据
- (instancetype)initWithRequest:(NSURLRequest *)request responseBlock:(WebDownloadResponseBlock)responseBlock progressBlock:(WebDownloadProgressBlock)progressBlock completedBlock:(WebDownloadCompletedBlock)completedBlock cancelBlock:(WebDownloadCancelBlock)cancelBlock {
    if ((self = [super init])) {
        _request = [request copy];
        _responseBlock = [responseBlock copy];
        _progressBlock = [progressBlock copy];
        _completedBlock = [completedBlock copy];
        _cancelBlock = [cancelBlock copy];
    }
    return self;
}

#pragma mark - start
- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    // 判断任务执行前是否取消了任务
    if (self.isCancelled) {
        [self done];
        return;
    }
    @synchronized (self) {
        // 创建网络资源下载 请求， 并设置网络请求代理
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 15;
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:NSOperationQueue.mainQueue];
        _dataTask = [_session dataTaskWithRequest:_request];
        [_dataTask resume];
    }
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isAsynchronous {
    return YES;
}

#pragma mark -  取消任务
// 取消任务
- (void)cancel {
    @synchronized (self) {
        [self done];
    }
}

#pragma mark - 更新任务状态
// 更新任务状态
- (void)done {
    [super cancel];
    if (_executing) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _finished = YES;
        _executing = NO;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
        [self reset];
    }
}

#pragma mark - 重置请求数据
// 重置请求数据
- (void)reset {
    if (self.dataTask) {
        [_dataTask cancel];
    }
    if (self.session) {
        [self.session invalidateAndCancel];
        self.session = nil;
    }
}

#pragma mark - 网络资源下载请求获得响应
// 网络资源下载请求获得响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (_responseBlock) {
        _responseBlock(httpResponse);
    }
    NSInteger code = [httpResponse statusCode];
    if (code == 200) {
        completionHandler(NSURLSessionResponseAllow);
        self.data = [NSMutableData new];
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
    } else {
        completionHandler(NSURLSessionResponseCancel);
    }
}

#pragma mark - 网络资源下载请求完毕
// 网络资源下载请求完毕
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if (_completedBlock) {
        if (error) {
            if (error.code == NSURLErrorCancelled) {
                _cancelBlock();
            } else {
                _completedBlock(nil, error, NO);
            }
        } else {
            _completedBlock(self.data, nil, YES);
        }
    }
    [self done];
}
#pragma mark - 接收网络资源下载数据
// 接收网络资源下载数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.data appendData:data];
    if (self.progressBlock) {
        self.progressBlock(self.data.length, self.expectedSize, data);
    }
}

#pragma mark - 网络缓存数据复用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler{
    NSCachedURLResponse *cacheResponse = proposedResponse;
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        cacheResponse = nil;
    }
    if (completionHandler) {
        completionHandler(cacheResponse);
    }
}

@end


/*
 ------------------------------************------------------------------
 */

#pragma mark - 自定义网络资源下载器
