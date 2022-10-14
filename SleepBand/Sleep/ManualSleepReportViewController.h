//
//  ManualSleepReportViewController.h
//  SleepBand
//
//  Created by admin on 2018/9/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualSleepReportViewController : UIViewController

@property (strong,nonatomic)NSDate * manualStartDate; //点击开始睡眠的时间
@property (strong,nonatomic)NSDate * manualEndDate; //点击结束睡眠的时间

@end
