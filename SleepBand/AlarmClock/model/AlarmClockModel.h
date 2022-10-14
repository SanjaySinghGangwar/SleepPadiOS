//
//  AlarmClockModel.h
//  SleepBand
//
//  Created by admin on 2018/7/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>


#define ClockDateFormatter  @"yyyy-MM-dd HH:mm:ss"//24时计时法

//#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])//APPDELEGATE单类

typedef NS_ENUM(NSInteger,ClockType){
    ClockType_General = 0,  //普通闹钟
    ClockType_Nurse, //看护闹钟
    ClockType_GetUp, //起床闹钟
    ClockType_GoToBedEarly //早睡闹钟
};

@interface AlarmClockModel : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic,assign) int clockId;
@property (nonatomic,assign) int hour;
@property (nonatomic,assign) int minute;
@property (nonatomic,assign) BOOL isPhone;
@property (nonatomic,copy) NSString *remark;  //标签
@property (nonatomic,strong) NSArray *repeat;
@property (nonatomic,strong) NSString * repeatStr;
@property (nonatomic,assign) BOOL isOn;  //是否开启
@property (nonatomic,copy)   NSString *music;  //音乐
@property (nonatomic,assign) BOOL isIntelligentWake;  //智能唤醒
@property (nonatomic,assign) int type;  //闹钟类型
@property (nonatomic,assign) int index;  //设备闹钟下标

@property (nonatomic,strong)NSString * clockTimer;      //定时器执行的时间

@property (nonatomic,strong)NSString * clockTitle;      //定时器标题

@property (nonatomic,strong)NSString * clockDescribe;   //闹钟描述

@property (nonatomic,strong)NSString * clockMusic;      //闹钟音乐

/**
 *  存储闹钟事件
 *
 *  @param clockModel 传入对象
 */
+ (void)SaveAlarmClockWithModel:(AlarmClockModel*)clockModel;


/**
 *  移除闹钟事件
 *
 *  @param timer 事件值类型为 .h定义的  ClockDateFormatter
 */
+ (void)RemoveAlarmClockWithTimer:(NSString *)timer;


/**
 *  获取所有的闹钟事件
 *
 *  @return 返回所有闹钟事件的数组
 */
+ (NSArray*)GetAllAlarmClockEvent;

@end
