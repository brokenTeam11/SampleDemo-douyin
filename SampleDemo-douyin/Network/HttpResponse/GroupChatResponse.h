//
//  GroupChatResponse.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/24.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseResponse.h"
#import "GroupChat.h"

@interface GroupChatResponse : BaseResponse

@property(nonatomic, copy) GroupChat *data;

@end
