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
-(NSOperation *)queryURLFromDiskMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension {
    NSOperation *operation = [NSOperation new];
    dispatch_async(_ioQueue, ^{
        if(operation.isCancelled) {
            return;
        }
        NSString *path = [self diskCachePathForKey:key extension:extension];
        if([self.fileManager fileExistsAtPath:path]) {
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
- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key extension:(NSString *)extension{
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
- (NSString *)diskCachePathForKey:(NSString *)key{
    return [self diskCachePathForKey:key extension:nil];
}
// 清除内存和本地磁盘缓存数据
- (void)clearCache:(WebCacheClearCompletedBlock)cacheClearCompletedBlock{
    dispatch_async(_ioQueue, ^{
        [self clearMemoryCache];
        NSString *cacheSize = [self clearDiskCache];
    });
}

// 清除内存缓存数据
- (void)clearMemoryCache{
    [_memCache removeAllObjects];
}

// 清除本地磁盘缓存数据
- (NSString *)clearDiskCache{
    NSArray *contents = [_fileManager contentsOfDirectoryAtPath:_diskCacheDirectoryURL.path error:nil];
    NSEnumerator *enumerator = [contents objectEnumerator];
    NSString *fileName;
    CGFloat folderSize = 0.0f;
    
    while ((fileName = [enumerator nextObject])) {
        NSString *filePath = [_diskCacheDirectoryURL.path stringByAppendingPathComponent:fileName];
        folderSize += [_fileManager attributesOfItemAtPath:filePath error:nil].fileSize;
        [_fileManager removeItemAtPath:filePath error:NULL];
    }
    return [NSString stringWithFormat:@"%.2f", folderSize/1024.0f/1024.0f]; // `@"%.2f"`精度浮点数,且只保留两位小数
}

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
