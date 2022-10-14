//
//  TabBarViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController
@property (nonatomic,strong)UIView *tabBarView;
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,strong)UINavigationController *sleepNavigation;
@property (nonatomic,strong)UINavigationController *reportNavigation;
@property (nonatomic,strong)UINavigationController *alarmClockNavigation;
@property (nonatomic,strong)UINavigationController *personalNavigation;
@property (nonatomic,strong)SleepMainViewController *sleepView;
@property (nonatomic,strong)ReportMainViewController *reportView;

//@property (nonatomic,strong)ReportMainVC *reportVC;

@property (nonatomic,strong)AlarmClockMainViewController *alarmClockView;
@property (nonatomic,strong)PersonalMainViewController *personalView;
@property (nonatomic,strong)NSArray *normalImage;
@property (nonatomic,strong)NSArray *selectedImage;
//弹窗确认,跳转首页同步
-(void)pushFirstNavigationControllerAlert;
//判断是否需要同步
-(void)judgementWhetherSynchronization;
-(void)pushFirstNavigationController;
-(void)changeViewController:(int)index;
@end
