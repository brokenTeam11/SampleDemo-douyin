//
//  PictureInfo.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/18.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "BaseModel.h"

@interface PictureInfo : BaseModel

@property (nonatomic, copy) NSString *file_id;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, copy) NSString *type;

@end
