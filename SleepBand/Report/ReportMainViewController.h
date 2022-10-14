//
//  ReportMainViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawView.h"

typedef NS_ENUM(NSInteger,DateType)
{
    DateType_Day = 0,
    DateType_Week,
    DateType_Month
    
};

typedef NS_ENUM(NSInteger,WeekMonthCustomType)
{
    WeekMonthCustomType_AverageHeartRate,  //平均心率
    WeekMonthCustomType_AverageRespiratoryRate, //平均呼吸率
    WeekMonthCustomType_TurnOver,   //翻身/体动
    WeekMonthCustomType_AverageLengthOfSleepStages,    //日均入睡时长
    WeekMonthCustomType_SleepLatency,    //入睡时间
    WeekMonthCustomType_GetUpTime,    //起床时间
    WeekMonthCustomType_FrequencyOfWakeUp,    //清醒次数
    WeekMonthCustomType_FrequencyOfBedAway    //离床次数
    
};

@interface ReportMainViewController : UIViewController

@end
