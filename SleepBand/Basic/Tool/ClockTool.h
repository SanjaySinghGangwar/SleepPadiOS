//
//  ClockTool.h
//  SleepBand
//
//  Created by admin on 2018/9/3.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClockTool : NSObject
//添加推送
+(void)addNotification:(AlarmClockModel*)model;
//删除推送
+(void)deleteNotification:(AlarmClockModel*)model;
+(void)logNotification;
@end
