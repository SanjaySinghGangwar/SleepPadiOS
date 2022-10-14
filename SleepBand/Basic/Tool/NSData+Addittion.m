//
//  NSData+Addittion.m
//  QLife
//
//  Created by 李晓博 on 2017/6/29.
//  Copyright © 2017年 李晓博. All rights reserved.
//

#import "NSData+Addittion.h"
#import "NSString+Plus.h"

@implementation NSData (Addittion)
+(NSData *)timerDate
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *confromTimespStr = [formatter stringFromDate:date];
    NSArray* timeDate = [confromTimespStr componentsSeparatedByString:@"-"];
    NSString* yyyy = timeDate[0];
    NSString* MM = timeDate[1];
    NSString* dd = timeDate[2];
    NSString* HH = timeDate[3];
    NSString* mm = timeDate[4];
    NSString* ss = timeDate[5];

    Byte bytes[128];
    bytes[0] = yyyy.intValue & 0xff;
    bytes[1] = (yyyy.intValue >> 8) & 0xff;
    
    MM = [NSString ToHex:MM.intValue];
    dd = [NSString ToHex:dd.intValue];
    HH = [NSString ToHex:HH.intValue];
    mm = [NSString ToHex:mm.intValue];
    if (MM.intValue < 10 ) {
        MM = [NSString stringWithFormat:@"0%@",MM];
    }
    if (dd.intValue < 10 ) {
        dd = [NSString stringWithFormat:@"0%@",dd];
    }
    if (HH.intValue < 10 ) {
        HH = [NSString stringWithFormat:@"0%@",HH];
    }
    if (mm.intValue < 10 ) {
        mm = [NSString stringWithFormat:@"0%@",mm];
    }
    if (ss.intValue < 10 ) {
        ss = [NSString stringWithFormat:@"0%@",ss];
    }
    NSString* timeStr = [NSString stringWithFormat:@"%@%@%@%@%@",MM,dd,HH,mm,ss];
    NSString *hexString = [timeStr lowercaseString]; //16进制字符串
    int j=2;
      ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length]-1;i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
//        DebugLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:7];
    
    return newData;

}

@end
