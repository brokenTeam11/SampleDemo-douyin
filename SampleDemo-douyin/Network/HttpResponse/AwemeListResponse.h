//
//  AwemeListResponse.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/24.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseResponse.h"
#import "Aweme.h"

@interface AwemeListResponse : BaseResponse

@property(nonatomic, copy) NSArray<Aweme *> <Aweme> *data;

@end
