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
+(NSString *)dateForString:(NSDate*)date
{
    return [[NSString stringWithFormat:@"%@",date] substringWithRange:NSMakeRange(0, 10)];
}

//String转date
+(NSDate*)stringReturnDate:(NSString *)day
{
    NSDateComponents *_comps = [[NSDateComponents alloc] init];
    [_comps setDay:[[day substringWithRange:NSMakeRange(6, 2)] intValue]];
    [_comps setMonth:[[day substringWithRange:NSMakeRange(4, 2)] intValue]];
    [_comps setYear:[[day substringWithRange:NSMakeRange(0, 4)] intValue]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *itemDate = [calendar dateFromComponents:_comps];
    return itemDate;
}

//返回某天前N天的date
+(NSDate*)dateForBeforeStrDate:(NSString*)date withDay:(NSString *)day withMonth:(NSString *)month
{
    NSDate *newDate = [self stringReturnDate:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setDay:[day intValue]];
    [adcomps setMonth:[month intValue]];
    return [calendar dateByAddingComponents:adcomps toDate:newDate options:0];
}

//NSDate返回某天前N天的NSDate
+(NSDate*)dateForBeforeDate:(NSDate*)date withDay:(NSString *)day withMonth:(NSString *)month
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setDay:[day intValue]];
    [adcomps setMonth:[month intValue]];
    return [calendar dateByAddingComponents:adcomps toDate:date options:0];
}

//根据某天判断星期几
+(int)dayReturnWeekday:(NSString*)day
{
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
+(NSDate *)NSDateForNoUTC:(NSDate *)date
{
    NSDate *currentDate = date;
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    return [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
}

//返回UTC时间
+(NSDate *)NSDateForUTC:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateTimeString = [formatter stringFromDate:date];
    NSString *dateString = [NSString stringWithFormat:@"%@",[dateTimeString substringWithRange:NSMakeRange(0, 10)]];
    return [formatter dateFromString:dateString];
}

//判断某个时间是否在某个时间段里面
+(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    return YES;
}
//判断某个时间距离现在已经过了多久
+(int)getUTCFormateDate:(NSDate *)newsDateFormatted
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//    NSLog(@"newsDate = %@",newsDate);
//
//    NSDate *newsDateFormatted = [dateFormatter dateFromString:newsDate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    [dateFormatter setTimeZone:timeZone];
    
    NSDate* current_date = [[NSDate alloc] init];
    
    NSTimeInterval time=[current_date timeIntervalSinceDate:newsDateFormatted];//间隔的秒数
    
//    int year =((int)time)/(3600*24*30*12);
//
//    int month=((int)time)/(3600*24*30);
//
    int days=((int)time)/(3600*24);
//    int hours=((int)time)%(3600*24)/3600;
    
//    int minute=((int)time)%(3600*24)/60;
    
//    NSLog(@"time=%f",(double)time);
//    NSString *dateContent;
//    if (year!=0) {
//        dateContent = newsDate;
//    }else if(month!=0){
//        dateContent = [NSString stringWithFormat:@"%@%i%@",@"  ",month,@"个月前"];
//    }else if(days!=0){
//        dateContent = [NSString stringWithFormat:@"%@%i%@",@"  ",days,@"天前"];
//    }else if(hours!=0){
//        dateContent = [NSString stringWithFormat:@"%@%i%@",@"  ",hours,@"小时前"];
//    }else {
//        dateContent = [NSString stringWithFormat:@"%@%i%@",@"  ",minute,@"分钟前"];
//    }
    return days;
}
//厘米转英尺
+(NSString *)cmTransformFtIn:(NSString *)oldValue{
    if (oldValue.length == 0) {
        return oldValue;
    }
    NSRange range = [oldValue rangeOfString:@"cm"];
    int cmValue = (int)roundf([[oldValue substringToIndex:range.location] intValue] * 0.3937);
    int ftValue = cmValue/12;
    int inValue = cmValue%12;
    NSLog(@"%dcm,%dft,%din",cmValue,ftValue,inValue);
    return [NSString stringWithFormat:@"%dft%din",ftValue,inValue];
}
//公斤转磅
+(NSString *)kgTransformLb:(NSString *)oldValue{
    if (oldValue.length == 0) {
        return oldValue;
    }
    NSRange range = [oldValue rangeOfString:@"kg"];
    int kgValue = [[oldValue substringToIndex:range.location] intValue];
    int lbValue = (int)roundf(kgValue * 2.2046);
    NSLog(@"%dkg,%dlb",kgValue,lbValue);
    return [NSString stringWithFormat:@"%dlb",lbValue];
}
//英尺转厘米
+(NSString *)ftInTransformCm:(NSString *)oldValue{
    if (oldValue.length == 0) {
        return oldValue;
    }
    NSRange ftRange = [oldValue rangeOfString:@"ft"];
    int ftValue = [[oldValue substringToIndex:ftRange.location] intValue];
    NSRange inRange = [oldValue rangeOfString:@"in"];
    int inValue = [[oldValue substringWithRange:NSMakeRange(ftRange.location+2, inRange.location-(ftRange.location+ftRange.length))] intValue];
    int ftIn = ftValue*12 + inValue;
    int cmValue = (int)roundf(ftIn*2.54);
    NSLog(@"%dcm,%dft,%din",cmValue,ftValue,inValue);
    return [NSString stringWithFormat:@"%dcm",cmValue];
}
//磅转公斤
+(NSString *)lbTransformKg:(NSString *)oldValue{
    if (oldValue.length == 0) {
        return oldValue;
    }
    if (oldValue.length == 0) {
        return oldValue;
    }
    NSRange range = [oldValue rangeOfString:@"lb"];
    int lbValue = [[oldValue substringToIndex:range.location] intValue];
    int kgValue = (int)roundf(lbValue * 0.4535);
    NSLog(@"%dkg,%dlb",kgValue,lbValue);
    return [NSString stringWithFormat:@"%dkg",kgValue];
}

@end
