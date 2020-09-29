//
//  WebPImage.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/29.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "decode.h"
#import "demux.h"
#import "mux_types.h"

@interface WebPFrame : NSObject
// `nonatomic`指定合成存取方法是否为原子操作
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) CGFloat duration;
@property(nonatomic, assign) WebPData webPData;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat has_alpha;

@end

@interface WebPImage : UIImage

@property (nonatomic, copy) NSData *imageData;
@property (nonatomic, strong) WebPFrame *curDisplayFrame;
@property (nonatomic, strong) UIImage *curDisplayImage;
@property (nonatomic, assign) NSInteger curDisplayIndex;
@property (nonatomic, assign) NSInteger curDecodeIndex;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, strong) NSMutableArray<WebPFrame *> *frames;

- (CGFloat)curDisplayFrameDuration;
- (WebPFrame *)decodeCurFrame;
- (void)incrementCurDisplayIndex;
- (BOOL)isAllFrameDecoded;

@end

