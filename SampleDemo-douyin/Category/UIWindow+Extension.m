//
//  UIWindow+Extension.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/24.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "UIWindow+Extension.h"
#import "objc/runtime.h"

@implementation UIWindow (Extension)

+(void)showTips:(NSString *) text{
    /*
     `objc_getAssociatedObject`让一个对象和另一个对象关联起来，即一个对象保持对另一个对象的引用，并可以获取这个对象。关键字是一个void类型的指针。每个关键字必须是唯一的，通常都是会采用静态变量来作为关键字。
     */
    UITextView *tips = objc_getAssociatedObject(self, &tipsKey);
    if(tips) {
        [self dismiss];
        [NSThread sleepForTimeInterval:0.5f];
    }
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGFloat maxWidth = 200;
    CGFloat maxHeight = window.frame.size.height - 200;
    CGFloat commonInset = 10;
    
    UIFont *font = [UIFont systemFontOfSize:12];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    //  NSMakeRange是一个结构体类型，包含两个参数，位置和长度。表示字符串要传进来从哪里开始的位置和需要的长度。
    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    /*
       CGFloat: 浮点值的基本类型
       CGPoint: 表示一个二维坐标系中的点
       CGSize: 表示一个矩形的宽度和高度
       CGRect: 表示一个矩形的位置和大小
       */
     CGRect rect = [string boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    CGSize size = CGSizeMake(ceil(rect.size.width), ceil(rect.size.height < maxHeight ? rect.size.height : maxHeight));
    
    CGRect textFrame = CGRectMake(window.frame.size.width/2 - (size.width + commonInset * 2)/2, window.frame.size.height - (size.height + commonInset * 2) - 100, size.width + commonInset * 2, size.height + commonInset * 2);
    tips = [[UITextView alloc] initWithFrame:textFrame];
    tips.text = text;
    tips.font = font;
    tips.textColor = [UIColor whiteColor];
    tips.backgroundColor = [UIColor blackColor];
    tips.layer.cornerRadius = 5;
    tips.editable = NO;
    tips.selectable = NO;
    tips.scrollEnabled = NO;
    tips.textContainer.lineFragmentPadding = 0;
    // 上左下右
    tips.contentInset = UIEdgeInsetsMake(commonInset, commonInset, commonInset, commonInset);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handlerGuestrue:)];
    [window addGestureRecognizer:tap];
    [window addSubview:tips];
    // objc_setAssociatedObject来把一个对象与另外一个对象进行关联。该函数需要四个参数：源对象，关键字，关联的对象和一个关联策略。
    // objc_setAssociatedObject/objc_getAssociatedObject  实现 动态向类中添加 方法
    //    关键策略是一个enum值
    //    OBJC_ASSOCIATION_ASSIGN = 0,      <指定一个弱引用关联的对象>
    //    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,<指定一个强引用关联的对象>
    //    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,  <指定相关的对象复制>
    //    OBJC_ASSOCIATION_RETAIN = 01401,      <指定强参考>
    //    OBJC_ASSOCIATION_COPY = 01403    <指定相关的对象复制>
    objc_setAssociatedObject(self, &tapKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &tipsKey, tips, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // performSelector: withObject:是在iOS中的一种方法调用方式。他可以向一个对象传递任何消息，而不需要在编译的时候声明这些方法。所以这也是runtime的一种应用方式。
    // `afterDelay`这个方法其实是增加了一个定时器，而这时aSelector应该是被添加到了队列的最后面，所以要等当前调用此方法的函数执行完毕后，selector方法才会执行。
    // 调用方法
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0f];
}

#pragma mark -method
+(void)_handlerGuestrue:(UIGestureRecognizer *) sender {
    if (!sender || !sender.view)
        return;
    [self dismiss];
    //取消执行方法，必须与调用方法的参数一致，否则不能取消成功.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
}

#pragma mark - dismiss

/*
 typedef的关键字，可以使用此关键字为类型指定新名称
 */
+(void) dismiss {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &tapKey);
    [window removeGestureRecognizer:tap];
    
    UITextView *tips = objc_getAssociatedObject(self, &tipsKey);
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        tips.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [tips removeFromSuperview];
    }];
}

@end
