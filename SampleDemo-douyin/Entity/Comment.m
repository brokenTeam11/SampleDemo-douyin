//
//  Comment.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/24.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype)init:(NSString *)awemeId text:(NSString *)text taskId:(NSInteger)taskId{
    self = [super init];
    if (self) {
        _aweme_id = awemeId;
        _text = text;
        _isTemp = YES;
        _taskId = taskId;
        
        _digg_count = 0;
        _create_time = [[NSDate new] timeIntervalSince1970];
        _user_digged = 0;
    }
    return self;
}

@end
