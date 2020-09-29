//
//  WebPImage.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/29.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "WebPImage.h"

@implementation WebPFrame
@end

@implementation WebPImage

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    _imageData = data;
    _curDisplayIndex = 0;
    _curDecodeIndex = 0;
    _frameCount = -1;
    // NSMutableArray可变对象数组
    _frames = [NSMutableArray array];
    
    [self decodeWebPFramesInfo:_imageData];
    return self;
}

- (WebPFrame *)curDisplayFrame {
    if (_frames.count > 0) {
        _curDisplayIndex = _curDisplayIndex % _frames.count;
        return _frames[_curDisplayIndex];
    }
    return nil;
}

-(UIImage *)curDisplayImage{
    if (_frames.count > 0) {
        _curDisplayIndex = _curDisplayIndex % _frames.count;
        return _frames[_curDisplayIndex].image;
    }
    return nil;
}

- (WebPFrame *)decodeCurFrame{
    // 指令@synchronized()通过对一段代码的使用进行加锁。其他试图执行该段代码的线程都会被阻塞，直到加锁线程退出执行该段被保护的代码段，也就是说@synchronized()代码块中的最后一条语句已经被执行完毕的时候。
    if (_frames.count > 0) {
        @synchronized (self) {
            _curDecodeIndex = _curDecodeIndex % _frames.count;
            _curDisplayFrame = _frames[_curDecodeIndex];
            _curDisplayFrame.image = [self decodeWebPImageAtIndex:_curDecodeIndex++];
        }
    }
    return nil;
}

- (void)incrementCurDisplayIndex{
    _curDecodeIndex++;
}

- (BOOL)isAllFrameDecoded{
    for (NSInteger i = _frames.count - 1; i >= 0; i--) {
        if (!_frames[i].image) {
            return NO;
        }
    }
    return YES;
}

-(NSArray<UIImage *> *)images {
    NSMutableArray *images = [NSMutableArray array];
    for (WebPFrame *frame in _frames) {
        [images addObject:frame.image];
    }
    return images;
}

- (CGFloat)curDisplayFrameDuration{
    if (_frames.count > 0) {
        NSInteger index = _curDisplayIndex % _frames.count;
        return _frames[index].duration;
    }
    return 0;
}



static void freeWebpFrameImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

#pragma mark -
- (void) decodeWebPFramesInfo:(NSData *)imageData {
    WebPData data;
    WebPDataInit(&data);
    
    data.bytes = (const uint8_t *)[imageData bytes];
    data.size = [imageData length];
    
    WebPDemuxer *demux = WebPDemux(&data);
    
    uint32_t flags = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS);
    
    if (flags & ANIMATION_FLAG) {
        WebPIterator iter;
        if (WebPDemuxGetFrame(demux, 1, &iter)) {
            CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
            
            do{
                WebPFrame *webPFrame = [WebPFrame new];
                webPFrame.duration = iter.duration / 1000.0f;
                webPFrame.webPData = iter.fragment;
                webPFrame.width = iter.width;
                webPFrame.height = iter.height;
                webPFrame.has_alpha = iter.has_alpha;
                [_frames addObject:webPFrame];
            } while (WebPDemuxNextFrame(&iter));
            _frameCount = _frames.count;
            
            CGColorSpaceRelease(colorSpaceRef);
            WebPDemuxReleaseIterator(&iter);
        }
    }
    WebPDemuxDelete(demux);
}

#pragma mark -
- (UIImage *)decodeWebPImageAtIndex:(NSInteger)index{
    WebPFrame *webPFrame = _frames[index];
    WebPData frame = webPFrame.webPData;
    
    WebPDecoderConfig config;
    WebPInitDecoderConfig(&config);
    
    config.input.height = webPFrame.height;
    config.input.width = webPFrame.width;
    config.input.has_alpha = webPFrame.has_alpha;
    config.input.has_animation = 1;
    config.options.no_fancy_upsampling = 1;
    config.options.bypass_filtering = 1;
    config.options.use_threads = 1;
    config.output.colorspace = MODE_RGBA;
    config.output.width = webPFrame.width;
    config.output.height = webPFrame.height;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    VP8StatusCode status = WebPDecode(frame.bytes, frame.size, &config);
    if (status != VP8_STATUS_OK) {
        CGColorSpaceRelease(colorSpaceRef);
        return nil;
    }
    int imageWidth, imageHeight;
    uint8_t *data = WebPDecodeRGBA(frame.bytes, frame.size, &imageWidth, &imageHeight);
    if (data == NULL) {
        CGColorSpaceRelease(colorSpaceRef);
        return nil;
    }
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, imageWidth * imageHeight * 4, freeWebpFrameImageData);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, 4 * imageWidth, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    //    CGFloat scaleRatio = image.size.width / image.size.height;
    //    CGFloat scaleWidth = ScreenWidth / 3;
    //    CGFloat scaleHeight = scaleWidth / scaleRatio;
    //    UIGraphicsBeginImageContext(CGSizeMake(scaleWidth, scaleHeight));
    //    [image drawInRect:CGRectMake(0.0, 0.0, scaleWidth, scaleHeight)];
    //    image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorSpaceRef);
    WebPFreeDecBuffer(&config.output);
    return image;
}
    
@end
