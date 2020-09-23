//
//  DeleteCommentRequest.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseRequest.h"

@interface DeleteCommentRequest : NSObject

@property(nonatomic, copy) NSString *cid;
@property(nonatomic, copy) NSString *udid;

@end

