//
//  ClockTool.m
//  SleepBand
//
//  Created by admin on 2018/9/3.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ClockTool.h"
#import <UserNotifications/UserNotifications.h>

@implementation ClockTool

//添加推送
+(void)addNotification:(AlarmClockModel*)model
{
    NSLog(@"添加推送");
    NSString *alertStr;
    if(model.type == ClockType_General){
        
        alertStr = NSLocalizedString(@"GeneralClockNotificationBody", nil);
        
    }else if (model.type == ClockType_Nurse){
        
        alertStr = NSLocalizedString(@"NurseClockNotificationBody", nil);
        
    }else if (model.type == ClockType_GoToBedEarly){
        
        alertStr = NSLocalizedString(@"GoToBedEarlyClockNotificationBody", nil);
        
    }else{
        
        if (model.isIntelligentWake == NO) {
            
            alertStr = NSLocalizedString(@"GetUpClockNotificationBody", nil);
            
        }else{
            
            alertStr = NSLocalizedString(@"GetUpClockNotificationBody", nil);
        }
    }
    NSString *time = [NSString stringWithFormat:@"添加推送->>>%02d:%02d",model.hour,model.minute];
    
    if (@available(iOS 10.0, *)) {
        for(NSString *weekday in model.repeat){
            NSLog(@"ios10新增推送");
            UNMutableNotificationContent *noContent = [[UNMutableNotificationContent alloc] init];
            
            noContent.body = alertStr;
            UNNotificationSound *sound = [UNNotificationSound defaultSound];
            noContent.sound = sound;
            noContent.categoryIdentifier = time;
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.weekday = [weekday intValue];
            components.hour = model.hour;
            components.minute = model.minute;
            UNCalendarNotificationTrigger *trigger1 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
            
            
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%d %@",model.clockId,weekday] content:noContent trigger:trigger1];
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@  error",error);
                }
            }];
        }
        NSLog(@"添加推送完成->打印当前存在的推送");
        [ClockTool logNotification];
        
    }else
    {
        NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSNumber * weekNumber = @([comps weekday]);
        int weekInt = [weekNumber intValue] -1;
        
        for(NSString *weekday in model.repeat){
            NSString *str = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:[UIFactory dateForBeforeDate:[UIFactory dateForBeforeDate:[NSDate date] withDay:@"-7" withMonth:@"0"] withDay:[NSString stringWithFormat:@"%d",[weekday intValue]-weekInt] withMonth:@"0"]]];
            NSLog(@"ios10以下新增推送");
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //        formatter.dateFormat = @"HH:mm";
            //        NSDate *fireDate = [formatter  dateFromString:time];
            
            
            NSLog(@"str = %@",str);
            
            // 在过去的某个星期内添加需要的本地提醒。并且设置提醒间隔为NSCalendarUnitWeekOfYear，如果添加在未来，那么提醒不会发生。
            
            //        notification.fireDate = fireDate;
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 设置重复的间隔
            notification.repeatInterval = NSCalendarUnitWeekOfYear;//0表示不重复
            
            notification.alertBody =  alertStr;
            notification.applicationIconBadgeNumber = 0;
            notification.soundName = UILocalNotificationDefaultSoundName;
            NSDictionary *userDict = [NSDictionary dictionaryWithObject:@{@"body":alertStr,@"time":time} forKey:projectName];
            notification.userInfo = userDict;
            notification.repeatInterval = NSCalendarUnitDay;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
 
}

//删除推送
+(void)deleteNotification:(AlarmClockModel*)model
{
    NSLog(@"删除推送");
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        NSString *time = [NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for (UNNotificationRequest *request in requests) {
                if ([request.identifier rangeOfString:[NSString stringWithFormat:@"%d ",model.clockId]].length > 0) {
                    [center removePendingNotificationRequestsWithIdentifiers:@[request.identifier]];
                }
            }
            NSLog(@"删除推送完成1->打印当前存在的推送");
            [ClockTool logNotification];
        }];
        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            for (UNNotification *notification in notifications) {
                if ([notification.request.identifier rangeOfString:[NSString stringWithFormat:@"%d ",model.clockId]].length > 0) {
                    [center removeDeliveredNotificationsWithIdentifiers:@[notification.request.identifier]];
                }
            }
            NSLog(@"删除推送完成2->打印当前存在的推送");
            [ClockTool logNotification];
        }];
//        [center removePendingNotificationRequestsWithIdentifiers:@[time]];
//        [center removeDeliveredNotificationsWithIdentifiers:@[time]];
    }else
    {
        NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
        for (UILocalNotification *notification in localNotifications) {
            NSDictionary *userInfo = notification.userInfo;
            if (userInfo) {
                NSDictionary *info = userInfo[projectName];
                if (info != nil) {
                    if ([info[@"time"] isEqualToString:[NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute]]) {
                        [[UIApplication sharedApplication] cancelLocalNotification:notification];
                        break;
                    }
                }
            }
        }
    }
    
    
}

+(void)logNotification{

    if (@available(iOS 10.0, *)) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        [center removeAllDeliveredNotifications];
//        [center removeAllPendingNotificationRequests];

        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for (UNNotificationRequest *request in requests) {
                NSLog(@"request:%@",request);
            }
        }];
        
        [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            for (UNNotification *notification in notifications) {
                NSLog(@"notification:%@",notification);
            }
        }];
        //        center
    }else
    {
        NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
        for (UILocalNotification *notification in localNotifications) {
            NSDictionary *userInfo = notification.userInfo;
            if (userInfo) {
                NSString *info = userInfo[projectName];
                if (info != nil) {
                    NSLog(@"推送:%@",info);
                }
            }
        }
    }
}

@end
