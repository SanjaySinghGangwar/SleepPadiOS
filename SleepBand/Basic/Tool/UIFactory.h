//
//  UIFactory.h
//  eWatch
//
//  Created by feng on 16/4/22.
//  Copyright © 2016年 feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UIFactory : NSObject

+(NSDate*)returnCurrentDayBefore:(int)num;
+(NSString *)dateForNumString:(NSDate*)date;
+(NSString *)dateForString:(NSDate*)date;
+(NSDate*)stringReturnDate:(NSString *)day;
//NSString返回某天前N天的NSDate
+(NSDate*)dateForBeforeStrDate:(NSString*)date withDay:(NSString *)day withMonth:(NSString *)month;
//NSDate返回某天前N天的NSDate
+(NSDate*)dateForBeforeDate:(NSDate*)date withDay:(NSString *)day withMonth:(NSString *)month;
+(int)dayReturnWeekday:(NSString*)day;
+(UIButton *)navigationBarRightButtonForSynchronize;
+(UIView *)navigationBarRightButtonForRecordList;
+(UIButton *)navigationBarRightButtonForEdit;
+(UIView *)navigationBarRightButtonForAdd;
//返回当前时区时间
+(NSDate *)NSDateForNoUTC:(NSDate *)date;
//返回UTC时间
+(NSDate *)NSDateForUTC:(NSDate *)date;
//判断某个时间是否在某个时间段里面
+(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
//判断某个时间距离现在已经过了多久
+(int)getUTCFormateDate:(NSDate *)newsDateFormatted;
//厘米转英尺
+(NSString *)cmTransformFtIn:(NSString *)oldValue;
//公斤转磅
+(NSString *)kgTransformLb:(NSString *)oldValue;
//英尺转厘米
+(NSString *)ftInTransformCm:(NSString *)oldValue;
//磅转公斤
+(NSString *)lbTransformKg:(NSString *)oldValue;
@end
