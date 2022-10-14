//
// Created by HH on 2017/6/27.
// Copyright (c) 2017 李晓博. All rights reserved.
//

#import "NSString+Plus.h"


@implementation NSString (Plus)
- (NSString *)stringWithFormat:(NSString *)format andArguments:(NSArray *)arguments
{
    NSMutableString *result = [NSMutableString new];
    NSArray *components = format ? [format componentsSeparatedByString:@"%@"] : @[@""];
    NSUInteger argumentsCount = [arguments count];
    NSUInteger componentsCount = [components count] - 1;
    NSUInteger iterationCount = argumentsCount < componentsCount ? argumentsCount : componentsCount;
    for (NSUInteger i = 0; i < iterationCount; i++) {
        [result appendFormat:@"%@%@", components[i], arguments[i]];
    }
    [result appendString:[components lastObject]];
    return iterationCount == 0 ? [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : result;
    
}

//10进制转16进制
+(NSString *)ToHex:(int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i =0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid = tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    str = [str lowercaseString];
//    NSData data = [[NSData alloc]init];
//    int32_t c = [da]
    return str;
}

@end
