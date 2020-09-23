//
//  Visitor.m
//  SampleDemo-douyin
//
//  Created by 夏能啟 on 2020/9/18.
//  Copyright © 2020 夏能啟. All rights reserved.
//

#import "Visitor.h"

@implementation Visitor

-(NSString *)formatUDID{
    if(_udid.length < 8) return @"************";
    /*
       NSString是一个不可变的字符串对象。这不是表示这个对象声明的变量的值不可变，而是表示它初始化以后，你不能改变该变量所分配的内存中的值，但你可以重新分配该变量所处的内存空间。而NSMutableString是可变的，意味着你可以追加它的内存空间，或者修改它所分配的内存空间中的值。
     */
    NSMutableString *udid = [[NSMutableString alloc] initWithString:_udid];
    [udid replaceCharactersInRange:NSMakeRange(4, udid.length - 8) withString:@"****"];
    return udid;
}

@end
