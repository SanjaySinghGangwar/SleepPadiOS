//
//  SleepQualityModel.h
//  SleepBand
//
//  Created by admin on 2018/8/14.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepQualityModel : NSObject

@property (copy,nonatomic)NSString *uesrId; //用户ID
@property (copy,nonatomic)NSString *deviceName; //设备名字
@property (copy,nonatomic)NSString *dataDate; //数据日期
@property (strong,nonatomic)NSArray *dataArray; //数据

@property (copy,nonatomic)NSString *awakeTime; //清醒时长
@property (copy,nonatomic)NSString *lightSleepTime; //浅睡时长
@property (copy,nonatomic)NSString *midSleepTime; //中睡时长
@property (copy,nonatomic)NSString *deepSleepTime; //深睡时长
@property (strong,nonatomic)NSArray *sleepCurveArray; //睡眠曲线数组
@property (strong,nonatomic)NSArray *tagArray; //上床下床标记

@end
