//
//  AlarmClockEditViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmClockModel.h"

typedef NS_ENUM(NSInteger,EditAlarmClockType){
    EditAlarmClockType_PhoneToPhone,  //旧闹钟手机-新闹钟手机
    EditAlarmClockType_DeviceToPhone,
    EditAlarmClockType_PhoneToDevice,
    EditAlarmClockType_DeviceToDevice
};

typedef void(^editBlock)(BOOL isSuccess);
typedef void(^saveBlock)(AlarmClockModel *model);
typedef void(^backBlock)(void);

@interface AlarmClockEditViewController : UIViewController
@property (nonatomic,strong)AlarmClockModel *oldModel;
@property (nonatomic,strong)AlarmClockModel *changeModel;
@property (copy,nonatomic)saveBlock saveBlock;
@property (copy,nonatomic)editBlock editBlock;
@property (copy,nonatomic)backBlock backBlock;
@property (assign,nonatomic)BOOL isAdd; //是否新增
@property (assign,nonatomic)int intelligentWakeCount; //智能闹钟个数
@property (assign,nonatomic)int deviceClockCount; //设备已存闹钟个数
//@property (assign,nonatomic)BOOL isShow; //页面是否显示中

@end
