//
//  AlarmClockTypeSelectViewController.h
//  SleepBand
//
//  Created by admin on 2018/8/30.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectBlock)(int type);

@interface AlarmClockTypeSelectViewController : UIViewController
@property (assign,nonatomic)ClockType type;
@property (copy,nonatomic)SelectBlock selectBlock;
@end
