//
//  Visitor.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/18.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseModel.h"
#import "PictureInfo.h"


@interface Visitor : BaseModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *udid;
@property (nonatomic, strong) PictureInfo *avatar_thumbnail;
@property (nonatomic, strong) PictureInfo *avatar_medium;
@property (nonatomic, strong) PictureInfo *avatar_large;
-(NSString *)formatUDID;

@end
