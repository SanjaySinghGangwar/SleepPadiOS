//
//  SleepMainViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RealTimeViewController.h"

@interface SleepMainViewController : UIViewController

@property (assign,nonatomic)BOOL isOpenHrRrNotify;  //是否打开实时心率/呼吸率开关
//@property (assign,nonatomic)BOOL isNeedSynchronization;  //是否需要同步
@property (assign,nonatomic)BOOL isPushView;//是否跳转
@property (strong,nonatomic)UIButton * sleepBtn;

-(void)synchronization; //同步
-(void)deviceDisconnectState;
-(void)addSleepAnimation;
-(void)removeSleepAnimation;

@end
