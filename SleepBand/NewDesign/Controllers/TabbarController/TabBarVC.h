//
//  TabBarVC.h
//  SleepBand
//
//  Created by Mac on 27/12/22.
//  Copyright © 2022 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarVC : UITabBarController

@property (nonatomic,assign)NSInteger index;
@property (nonatomic,strong)NSArray *normalImages;
@property (nonatomic,strong)NSArray *selectedImages;
@property (nonatomic,strong)UIView *tabBarView;


@property (nonatomic,strong)UINavigationController *homeNVC;
@property (nonatomic,strong)HomeVC *homeVC;

@property (nonatomic,strong)UINavigationController *journalNVC;
@property (nonatomic,strong)JournalVC *journalVC;

@property (nonatomic,strong)UINavigationController *dashboardNVC;
@property (nonatomic,strong)DashboardVC *dashboardVC;

@property (nonatomic,strong)UINavigationController *settingsNVC;
@property (nonatomic,strong)SettingsVC *settingsVC;


@end
