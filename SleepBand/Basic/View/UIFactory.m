//
//  UIFactory.m
//  eWatch
//
//  Created by feng on 16/4/22.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "UIFactory.h"

@implementation UIFactory
//获取当前日期前N天的日期
+(NSDate*)returnCurrentDayBefore:(int)num{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:+(24*num*60*60)];
    return date;
}
//date转不带“-”的字符串
+(NSString *)dateForNumString:(NSDate*)date
{
    return [[[NSString stringWithFormat:@"%@",date] substringWithRange:NSMakeRange(0, 10)]stringByReplacingOccurrencesOfString:@"-" withString:@""];
}
//date转带“-”的字符串
+(NSString *)dateForString:(NSDate*)date{
    return [[NSString stringWithFormat:@"%@",date] substringWithRange:NSMakeRange(0, 10)];
}
//String转date
+(NSDate*)stringReturnDate:(NSString *)day{
    NSDateComponents *_comps = [[NSDateComponents alloc] init];
    [_comps setDay:[[day substringWithRange:NSMakeRange(6, 2)] intValue]];
    [_comps setMonth:[[day substringWithRange:NSMakeRange(4, 2)] intValue]];
    [_comps setYear:[[day substringWithRange:NSMakeRange(0, 4)] intValue]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *itemDate = [calendar dateFromComponents:_comps];
    return itemDate;
}
//返回某天前N天的date
+(NSDate*)dateForBeforeDate:(NSString*)date withDay:(NSString *)day withMonth:(NSString *)month{
    NSDate *newDate = [self stringReturnDate:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setDay:[day intValue]];
    [adcomps setMonth:[month intValue]];
    return [calendar dateByAddingComponents:adcomps toDate:newDate options:0];
}
//根据某天判断星期几
+(int)dayReturnWeekday:(NSString*)day{
    NSDateComponents *_comps = [[NSDateComponents alloc] init];
    [_comps setDay:[[day substringWithRange:NSMakeRange(6, 2)] intValue]];
    [_comps setMonth:[[day substringWithRange:NSMakeRange(4, 2)] intValue]];
    [_comps setYear:[[day substringWithRange:NSMakeRange(0, 4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *_date = [gregorian dateFromComponents:_comps];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSCalendarUnitWeekday fromDate:_date];
    NSInteger _weekday = [weekdayComponents weekday];
    return (int)_weekday;
}
//返回当前时区时间
+(NSDate *)NSDateForNoUTC:(NSDate *)date{
    NSDate *currentDate = date;
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    return [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
}
//返回UTC时间
+(NSDate *)NSDateForUTC:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateTimeString = [formatter stringFromDate:date];
    NSString *dateString = [NSString stringWithFormat:@"%@",[dateTimeString substringWithRange:NSMakeRange(0, 10)]];
    return [formatter dateFromString:dateString];
}
@end
