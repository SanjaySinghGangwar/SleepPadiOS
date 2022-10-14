//
//  AlarmClockTableViewCell.h
//  SleepBand
//
//  Created by admin on 2018/7/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmClockModel.h"

/**
 闹钟页面，星期
 */
typedef NS_ENUM(NSInteger,WeekType){
    WeekType_Sunday,
    WeekType_Monday,
    WeekType_Tuesday,
    WeekType_Wednesday,
    WeekType_Thursday,
    WeekType_Friday,
    WeekType_Saturday
};

typedef void(^switchBlock)(BOOL isOn);

@interface AlarmClockTableViewCell : UITableViewCell
@property (strong,nonatomic) UILabel *timeLabel;  //时间
@property (strong,nonatomic) UILabel *tagLabel;  //智能闹钟
@property (strong,nonatomic) UILabel *repeatLabel; //重复
@property (strong,nonatomic) UIImageView *deviceIV;  //手机/设备图标
@property (strong,nonatomic) UIButton *switchBtn;
@property (strong,nonatomic) UILabel *horizontalLineLabel;  //水平线
@property (copy,nonatomic) switchBlock switchBlock;

-(void)setClockValue:(AlarmClockModel *)model;
@end
