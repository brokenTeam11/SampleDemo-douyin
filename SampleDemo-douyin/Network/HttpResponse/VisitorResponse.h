//
//  VisitorResponse.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/18.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseResponse.h"
#import "Visitor.h"

@interface VisitorResponse : BaseResponse

@property (nonatomic, copy) Visitor *data;

@end

