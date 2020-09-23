//
//  AwemeListRequest.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/17.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseRequest.h"

@interface AwemeListRequest : BaseRequest

@property(nonatomic, assign) NSInteger page;
@property(nonatomic, assign) NSInteger size;
@property(nonatomic, copy) NSString *uid;

@end
