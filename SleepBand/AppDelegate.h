//
//  AppDelegate.h
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarViewController.h"
#import "SearchDeviceViewController.h"
/**
 *  这边添加闹钟工具类
 */
#import "AlarmClockTool.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong)TabBarViewController *mainTabBar;
@property (nonatomic,strong)UINavigationController *mainNavigation;

@property (nonatomic,retain)AlarmClockTool * alarmClockTool;//这边采用appDelegate强引用

//登录注册
-(void)setRootViewControllerForLogin;
//搜索
-(void)setRootViewControllerForSearch;
//睡眠界面
-(void)setRootViewControllerForSleep;
//报告界面
-(void)setRootViewControllerForReport;
//闹钟界面
-(void)setRootViewControllerForClock;
//个人界面
-(void)setRootViewControllerForMe;

//报告界面
//-(void)setRootViewControllerForReportMain;

@end

