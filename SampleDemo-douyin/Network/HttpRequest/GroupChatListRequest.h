//
//  GroupChatListRequest.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseRequest.h"

@interface GroupChatListRequest : BaseRequest

@property(nonatomic, assign) NSInteger page;
@property(nonatomic, assign) NSInteger size;

@end

