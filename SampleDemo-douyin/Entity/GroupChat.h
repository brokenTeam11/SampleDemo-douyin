//
//  GroupChat.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/24.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"
#import "Visitor.h"
#import "PictureInfo.h"

@protocol GroupChat;

@interface GroupChat : BaseModel
@property (nonatomic , copy) NSString              *id;
@property (nonatomic , copy) NSString              *msg_type;
@property (nonatomic , copy) NSString              *msg_content;
@property (nonatomic , strong) Visitor             *visitor;
@property (nonatomic , strong) PictureInfo         *pic_original;
@property (nonatomic , strong) PictureInfo         *pic_large;
@property (nonatomic , strong) PictureInfo         *pic_medium;
@property (nonatomic , strong) PictureInfo         *pic_thumbnail;
@property (nonatomic , assign) NSInteger           create_time;

//处理聊天所需数据
@property (nonatomic , assign) NSInteger                    taskId;
@property (nonatomic , assign) BOOL                         isTemp;
@property (nonatomic , assign) BOOL                         isFailed;
@property (nonatomic , assign) BOOL                         isCompleted;
@property (nonatomic , assign) CGFloat                      percent;
@property (nonatomic , strong) UIImage                      *picImage;
@property (nonatomic , assign) CGSize                       contentSize;
@property (nonatomic , assign) CGFloat                      cellHeight;
@property (nonatomic , strong) NSMutableAttributedString    *cellAttributedString;

/*
 instancetype的作用，就是使那些非关联返回类型的方法返回所在类的类型！
 */

-(instancetype)initImageChat:(UIImage *)image;

-(instancetype)initTextChat:(NSString *)text;

-(instancetype)updateTempImageChat:(GroupChat *)chat;

-(instancetype)updateTempText:(GroupChat *)chat;

@end
