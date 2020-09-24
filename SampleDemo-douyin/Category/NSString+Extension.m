//
//  NSString+Extension.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/25.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "NSString+Extension.h"
#import  <CommonCrypto/CommonDigest.h>
#import <CoreText/CTFramesetter.h>
#import <CoreText/CTFont.h>
#import <CoreText/CTStringAttributes.h>

@implementation NSString (Extension)

// 计算单行文本行高、支持包含emoji表情符的计算。开头空格、自定义插入的文本图片不纳入计算范围
- (CGSize)singleLineSizeWithAttributeText:(UIFont *)font{
    
}

//- (CGSize)multiLineSizeWithAttributeText:(CGFloat)width font:(UIFont *)font{
//
//}
//
//- (CGSize)singleLineSizeWithText:(UIFont *)font{
//
//}
//- (NSString *)md5{
//
//}
//
//- (NSURL *)urlScheme:(NSString *)scheme{
//
//}
//
//+ (NSString *)formatCount:(NSInteger)count{
//
//}
//
//+ (NSDictionary *)readJson2DicWithFileName:(NSString *)fileName{
//
//}
//
//+ (NSString *)currentTime{
//
//}

@end
