//
//  BlueToothTool.m
//  QLife
//
//  Created by admin on 2018/4/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "BlueToothTool.h"

@implementation BlueToothTool

//将传入的NSData类型转换成NSString并返回
+(NSString*)hexadecimalString:(NSData *)data
{
    
    NSString* result;
    
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    
    if(!dataBuffer){
        
        return nil;
        
    }
    
    NSUInteger dataLength = [data length];
    
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for(int i = 0; i < dataLength; i++){
        
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    result = [NSString stringWithString:hexString];
    
    return result;
    
}

//将传入的NSString类型转换成ASCII码并返回
+(NSData*)dataWithString:(NSString *)string
{
    unsigned char *bytes = (unsigned char *)[string UTF8String];
    
    NSInteger len = string.length;
    
    return [NSData dataWithBytes:bytes length:len];
    
}

//十进制转换十六进制
+ (NSString *)getHexByDecimal:(NSInteger)decimal
{
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
    
}

//字节数组转字符串
+(int)byteToString:(Byte*)byte andLength:(int)length
{
    NSData *data = [NSData dataWithBytes:byte length:length];
    const unsigned char * dataBuffer = (const unsigned char*)[data bytes];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:([data length] *2)];
    for (int i = 0; i < [data length]; i++)
    {
        [hexString appendString:[NSString stringWithFormat:@"%02lx",(unsigned long)dataBuffer[i]]];
    }
    return [self hexadecimalToDecimal:[hexString substringWithRange:NSMakeRange(2, 2)]];
    
}

//十六进制转十进制
+(int)hexadecimalToDecimal:(NSString *)string
{
    
    NSString *str2 = [string substringWithRange:NSMakeRange(1, 1)];
    NSString *str3 = [string substringWithRange:NSMakeRange(0, 1)];
    if ([str2 isEqualToString:@"a"]) {
        return (10 + [str3 intValue]*16);
    }else if ([str2 isEqualToString:@"b"]){
        return (10 + [str3 intValue]*16 +1);
    }else if ([str2 isEqualToString:@"c"]){
        return (10 + [str3 intValue]*16 +2);
    }else if ([str2 isEqualToString:@"d"]){
        return (10 + [str3 intValue]*16 +3);
    }else if ([str2 isEqualToString:@"e"]){
        return (10 + [str3 intValue]*16 +4);
    }else if ([str2 isEqualToString:@"f"]){
        return (10 + [str3 intValue]*16 +5);
    }
    else{
        return ([str3 intValue]*16 +[str2 intValue]);
    }
}

+ (NSString *)stringFromHexString:(NSString *)hexString
{ //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    
    for (int i = 0; i < [hexString length] - 1; i += 2)
    {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
}

@end
