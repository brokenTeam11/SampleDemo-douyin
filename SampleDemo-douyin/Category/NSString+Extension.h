//
//  NSString+Extension.h
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/25.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Extension)

- (CGSize)singleLineSizeWithAttributeText:(UIFont *)font;

- (CGSize)multiLineSizeWithAttributeText:(CGFloat)width font:(UIFont *)font;

- (CGSize)singleLineSizeWithText:(UIFont *)font;

- (NSString *)md5;

- (NSURL *)urlScheme:(NSString *)scheme;

+ (NSString *)formatCount:(NSInteger)count;

+ (NSDictionary *)readJson2DicWithFileName:(NSString *)fileName;

+ (NSString *)currentTime;

@end
