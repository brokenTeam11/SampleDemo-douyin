//
//  NetworkHelper.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "NetworkHelper.h"
#import "UIWindow+Extension.h"

NSString *const NetworkStatesChangeNotification = @"NetworkStatesChangeNotification";

NSString *const NetworkDomain = @"com.start.nengqi";

// 请求地址
NSString *const BaseUrl = @"http://116.62.9.17:8080/douyin/";

//创建访客用户接口
NSString *const CreateVisitorPath = @"visitor/create";


//根据用户id获取用户信息
NSString *const FindUserByUidPath = @"user";


//获取用户发布的短视频列表数据
NSString *const FindAwemePostByPagePath = @"aweme/post";
//获取用户喜欢的短视频列表数据
NSString *const FindAwemeFavoriteByPagePath = @"aweme/favorite";


//发送文本类型群聊消息
NSString *const PostGroupChatTextPath = @"groupchat/text";
//发送单张图片类型群聊消息
NSString *const PostGroupChatImagePath = @"groupchat/image";
//发送多张图片类型群聊消息
NSString *const PostGroupChatImagesPath = @"groupchat/images";
//根据id获取指定图片
NSString *const FindImageByIdPath = @"groupchat/image";
//获取群聊列表数据
NSString *const FindGroupChatByPagePath = @"groupchat/list";
//根据id删除指定群聊消息
NSString *const DeleteGroupChatByIdPath = @"groupchat/delete";


//根据视频id发送评论
NSString *const PostComentPath = @"comment/post";
//根据id删除评论
NSString *const DeleteComentByIdPath = @"comment/delete";
//获取评论列表
NSString *const FindComentByPagePath = @"comment/list";


@implementation NetworkHelper

+(AFHTTPSessionManager *)sharedManager{

    static dispatch_once_t once;
    static AFHTTPSessionManager *manager;
    dispatch_once(&once, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 15.0f;
    });
    return manager;
}

#pragma mark - process response data
+(void) processResponseData:(id)responseObject success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSInteger code = -1;
    NSString *message = @"response data error,好像请求的`响应`出错了";
    if ([responseObject isKindOfClass:NSDictionary.class]) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        code = [(NSNumber *)[dic objectForKey:@"code"]integerValue];
        message = (NSString *)[dic objectForKey:@"message"];
    }
    if (code == 0) {
        success(responseObject);
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NetworkDomain code:HttpResquestFailed userInfo:userInfo];
        failure(error);
    }
    
}

#pragma mark - GET
+(NSURLSessionDataTask *) getWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure{
    // NSDictionary 不可变的,一旦创建,内容就不能添加\删除(不能改动)
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager] GET:[BaseUrl stringByAppendingString:urlPath] parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [NetworkHelper processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        // 未连接到网路
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [UIWindow showTips:@"未连接到网络"];
            failure(error);
            return;
        }
        // 当服务器无法响应时，使用本地json数据
        NSString *path = task.originalRequest.URL.path;
        if ([path containsString:FindUserByUidPath]) {
//            success([NSString readJ])
        }
    }];

}
//
//+(NSURLSessionDataTask *) deleteWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure{
//
//}
//
//+(NSURLSessionDataTask *) postWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure{
//
//}
//
//+(NSURLSessionDataTask *) uploadWithUrlPath:(NSString *)urlPath data:(NSData *)data request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure{
//
//}
//
//+(NSURLSessionDataTask *) uploadWithUrlPath:(NSString *)urlPath dataArray:(NSArray<NSData *> *)dataArray request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure{
//
//}
//
////Reachability 可达性
//+(AFNetworkReachabilityManager *) shareReachabilityManager{
//
//}
//
//+ (void) startListening{
//
//}
//
//+ (AFNetworkReachabilityStatus)networkStatus{
//
//}
//
//+ (BOOL) isWifiStatus{
//
//}
//
//+ (BOOL) isNotReachableStatus:(AFNetworkReachabilityStatus)status{
//
//}

@end
