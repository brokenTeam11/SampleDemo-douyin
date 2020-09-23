//
//  CommentListResponse.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/24.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseResponse.h"
#import "Comment.h"

@interface CommentListResponse : BaseResponse

@property(nonatomic, copy) NSArray<Comment> *data;

@end
