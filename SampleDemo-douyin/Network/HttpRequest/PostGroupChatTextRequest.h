//
//  PostGroupChatTextRequest.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseRequest.h"

@interface PostGroupChatTextRequest : BaseRequest

@property(nonatomic, copy) NSString *udid;
@property(nonatomic, copy) NSString *text;

@end

