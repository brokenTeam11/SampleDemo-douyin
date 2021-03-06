//
//  Comment.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/24.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseModel.h"
#import "User.h"
#import "Visitor.h"

@protocol Comment;

@interface Comment :BaseModel
@property (nonatomic , copy) NSString              *cid;
@property (nonatomic , assign) NSInteger           status;
@property (nonatomic , copy) NSString              *text;
@property (nonatomic , assign) NSInteger           digg_count;
@property (nonatomic , assign) NSInteger           create_time;
@property (nonatomic , copy) NSString              *reply_id;
@property (nonatomic , copy) NSString              *aweme_id;
@property (nonatomic , assign) NSInteger           user_digged;
@property (nonatomic , strong) NSMutableArray      *text_extra;
@property (nonatomic , copy) NSString              *user_type;
@property (nonatomic , strong) User                *user;
@property (nonatomic , strong) Visitor             *visitor;

@property (nonatomic , assign) BOOL                isTemp;
@property (nonatomic , assign) NSInteger           taskId;

-(instancetype)init:(NSString *)awemeId text:(NSString *)text taskId:(NSInteger)taskId;

@end
