//
//  BlueToothTool.h
//  QLife
//
//  Created by admin on 2018/4/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlueToothTool : NSObject

//将传入的NSData类型转换成NSString并返回
+(NSString*)hexadecimalString:(NSData *)data;

//将传入的NSString类型转换成ASCII码并返回
+(NSData*)dataWithString:(NSString *)string;

//十进制转16进制
+ (NSString *)getHexByDecimal:(NSInteger)decimal;


+(int)hexadecimalToDecimal:(NSString *)string;

//十六进制转换为普通字符串
+ (NSString *)stringFromHexString:(NSString *)hexString;


@end
