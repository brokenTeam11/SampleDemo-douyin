//
//  BaseResponse.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/18.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "JSONModel.h"

@interface BaseResponse : JSONModel

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger has_more;
@property (nonatomic, assign) NSInteger total_count;

@end

