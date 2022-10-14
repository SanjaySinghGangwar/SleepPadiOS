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
+(NSDate*)dateForBeforeDate:(NSString*)date withDay:(NSString *)day withMonth:(NSString *)month;
+(int)dayReturnWeekday:(NSString*)day;
+(UIButton *)navigationBarRightButtonForSynchronize;
+(UIView *)navigationBarRightButtonForRecordList;
+(UIButton *)navigationBarRightButtonForEdit;
+(UIView *)navigationBarRightButtonForAdd;
//返回当前时区时间
+(NSDate *)NSDateForNoUTC:(NSDate *)date;
//返回UTC时间
+(NSDate *)NSDateForUTC:(NSDate *)date;
@end
