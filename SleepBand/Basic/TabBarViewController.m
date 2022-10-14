//
//  TabBarViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@property (strong,nonatomic)BlueToothManager *blueToothManager;

@end

@implementation TabBarViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self getClockArray];
    self.index = 0;
    
    //设置子视图
    [self setupChildControllers];
    
}

//-(void)getClockArray{
//    MSCoreManager *coreManager = [MSCoreManager sharedManager];
//    [coreManager.clockArray removeAllObjects];
//    [coreManager getGetAlarmClockForData:@{@"userId":@(coreManager.userModel.userId),@"bluetooth":coreManager.userModel.bluetooth} WithResponse:^(ResponseInfo *info) {
//        if ([info.code isEqualToString:@"200"]) {
//            if (info.array.count > 0) {
//                for (NSDictionary *dict in info.array) {
//                    AlarmClockModel *model = [AlarmClockModel mj_objectWithKeyValues:dict];
//                    [coreManager.clockArray addObject:model];
//                }
//            }
//        }
//    }];
//}

- (void)setupChildControllers
{
    WS(weakSelf);
    
    self.sleepView = [[SleepMainViewController alloc] init];
    self.sleepNavigation = [[UINavigationController alloc]initWithRootViewController:self.sleepView];
    self.sleepNavigation.view.backgroundColor=[UIColor whiteColor];
    self.sleepNavigation.tabBarItem.title = NSLocalizedString(@"SMVC_Title", nil);
    self.sleepNavigation.tabBarItem.image=[UIImage imageNamed:@"tab_buddy_nor"];
    self.sleepNavigation.navigationBar.hidden = YES;
    
    self.reportView = [[ReportMainViewController alloc] init];
    self.reportNavigation = [[UINavigationController alloc]initWithRootViewController:self.reportView];
    self.reportNavigation.view.backgroundColor=[UIColor whiteColor];
    self.reportNavigation.tabBarItem.title = NSLocalizedString(@"RMVC_Title", nil);
    self.reportNavigation.tabBarItem.image=[UIImage imageNamed:@"tab_buddy_nor"];
    self.reportNavigation.navigationBar.hidden = YES;
    
//    self.reportVC = [[ReportMainVC alloc] init];
//    self.reportNavigation = [[UINavigationController alloc]initWithRootViewController:self.reportVC];
//    self.reportNavigation.view.backgroundColor=[UIColor whiteColor];
//    self.reportNavigation.tabBarItem.title = NSLocalizedString(@"RMVC_Title", nil);
//    self.reportNavigation.tabBarItem.image=[UIImage imageNamed:@"tab_buddy_nor"];
//    self.reportNavigation.navigationBar.hidden = YES;
    
    
    self.alarmClockView = [[AlarmClockMainViewController alloc] init];
    self.alarmClockNavigation = [[UINavigationController alloc]initWithRootViewController:self.alarmClockView];
    self.alarmClockNavigation.view.backgroundColor=[UIColor whiteColor];
    self.alarmClockNavigation.tabBarItem.title = NSLocalizedString(@"ACMVC_Title", nil);
    self.alarmClockNavigation.tabBarItem.image=[UIImage imageNamed:@"tab_buddy_nor"];
    self.alarmClockNavigation.navigationBar.hidden = YES;
    
    
    self.personalView = [[PersonalMainViewController alloc] init];
    self.personalNavigation = [[UINavigationController alloc]initWithRootViewController:self.personalView];
    self.personalNavigation.view.backgroundColor=[UIColor whiteColor];
    self.personalNavigation.tabBarItem.title = NSLocalizedString(@"PMVC_Title", nil);
    self.personalNavigation.tabBarItem.image=[UIImage imageNamed:@"tab_buddy_nor"];
    self.personalNavigation.navigationBar.hidden = YES;
    self.viewControllers=@[self.sleepNavigation,self.reportNavigation,self.alarmClockNavigation,self.personalNavigation];
    
    
    NSArray *titleArray = @[NSLocalizedString(@"SMVC_Title", nil),NSLocalizedString(@"RMVC_Title", nil),NSLocalizedString(@"ACMVC_Title", nil),NSLocalizedString(@"PMVC_Title", nil)];
    
//    self.normalImage = @[@"nav_icon_sleep",@"nav_icon_report",@"nav_icon_clock",@"nav_icon_my"];
//    self.selectedImage = @[@"nav_icon_sleep_pre",@"nav_icon_report_pre",@"nav_icon_clock_pre",@"nav_icon_my_pre"];
    
    //
    self.normalImage = @[@"nav_icon_my",@"nav_icon_report",@"nav_icon_clock",@"nav_icon_sleep"];
    self.selectedImage = @[@"nav_icon_my_pre",@"nav_icon_report_pre",@"nav_icon_clock_pre",@"nav_icon_sleep_pre",];
    
    self.tabBarView = [[UIView alloc]init];
    self.tabBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tabBarView];
    [self.tabBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@(kTabbarHeight+kTabbarSafeHeight));
        
    }];
    
    for(int i = 0 ; i < titleArray.count ; i++)
    {
        UIView *item = [[UIView alloc]init];
        [self.tabBarView addSubview:item];
        item.tag = 10000 + i;
        [item mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.top.equalTo(weakSelf.tabBarView);
            make.width.equalTo(@(kSCREEN_WIDTH/4));
            make.left.mas_equalTo(weakSelf.tabBarView.mas_left).offset(i*(kSCREEN_WIDTH/4));
            make.height.equalTo(@49);
            
        }];
        
        [item addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)]];
        
        UIImageView *icon = [[UIImageView alloc]init];
        if (i == 0) {
            
            icon.image = [UIImage imageNamed:self.selectedImage[i]];
            
        }else{
            
            icon.image = [UIImage imageNamed:self.normalImage[i]];
        }
        [item addSubview:icon];
        icon.tag = 20000 + i;
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(item);
            make.centerX.equalTo(item);
            make.width.equalTo(@50);
            make.height.equalTo(@26);
            
        }];
        
        UILabel *title = [[UILabel alloc]init];
        [item addSubview: title];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:12];
        title.tag = 30000 + i;
        title.text = titleArray[i];
        if (i == 0)
        {
            title.textColor = [UIColor whiteColor];
            
        }else
        {
            title.textColor = [UIColor colorWithHexString:@"#9d9fb3"];
        }
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(icon.mas_bottom).offset(0);
            make.left.right.bottom.equalTo(item);
            
        }];
    }
    
}

-(void)changeViewController:(int)index
{
    if (index != self.index)
    {
        if(self.index == 0)
        {
            self.sleepView.isOpenHrRrNotify = NO;
            [[BlueToothManager shareIsnstance] closeRealTimeHrRrNotify];
        }
        UIImageView *iconSelect = (UIImageView *)[self.view viewWithTag:index + 20000];
        iconSelect.image = [UIImage imageNamed:self.selectedImage[index]];
        
        UILabel *titleSelect = (UILabel *)[self.view viewWithTag:index + 30000];
        titleSelect.textColor = [UIColor whiteColor];
        
        UIImageView *iconSelected = (UIImageView *)[self.view viewWithTag:self.index + 20000];
        iconSelected.image = [UIImage imageNamed:self.normalImage[self.index]];
        
        UILabel *titleSelected = (UILabel *)[self.view viewWithTag:self.index + 30000];
        titleSelected.textColor = [UIColor colorWithHexString:@"#9d9fb3"];
        
        self.index = index;
        self.selectedIndex = self.index;
    }
}

//TabBar点击，切换界面
- (void)click:(UITapGestureRecognizer *)sender
{
    NSInteger select = sender.view.tag-10000;
    if (select != self.index)
    {
        if(self.index == 0)
        {
            self.sleepView.isOpenHrRrNotify = NO;
            [[BlueToothManager shareIsnstance] closeRealTimeHrRrNotify];
        }
        UIImageView *iconSelect = (UIImageView *)[self.view viewWithTag:select + 20000];
        iconSelect.image = [UIImage imageNamed:self.selectedImage[select]];
        
        UILabel *titleSelect = (UILabel *)[self.view viewWithTag:select + 30000];
        titleSelect.textColor = [UIColor whiteColor];
        
        UIImageView *iconSelected = (UIImageView *)[self.view viewWithTag:self.index + 20000];
        iconSelected.image = [UIImage imageNamed:self.normalImage[self.index]];
        
        UILabel *titleSelected = (UILabel *)[self.view viewWithTag:self.index + 30000];
        titleSelected.textColor = [UIColor colorWithHexString:@"#9d9fb3"];
        
        self.index = select;
        self.selectedIndex = self.index;
    }
}

//判断是否需要同步
-(void)judgementWhetherSynchronization
{
    self.blueToothManager = [BlueToothManager shareIsnstance];
    if(self.blueToothManager.isConnect){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //判断同步日期是否为今天，如果不是
        NSDictionary *lastSynchronizationDict = [defaults objectForKey:@"lastSynchronizationTime"];
        
        NSString *lastSynchronizationTime  =  lastSynchronizationDict[[MSCoreManager sharedManager].userModel.deviceCode];
        if (lastSynchronizationTime.length > 0)
        {
            if (![lastSynchronizationTime isEqualToString:[UIFactory dateForNumString:[NSDate date]]]) {
            
            if(self.index != 0){
                
                [self pushFirstNavigationControllerAlert];
                
            }else
            {
                if(self.sleepView.navigationController.viewControllers.count == 1){
                    
                    [self.sleepView synchronization];
                    
                }else
                {
                    [self.blueToothManager closeRealTimeHrRrSampleNotify];
                    [self.sleepView.navigationController popToRootViewControllerAnimated:YES];
                }
            }
          }
        }
    }
}

//弹窗确认,跳转首页同步
-(void)pushFirstNavigationControllerAlert
{
    WS(weakSelf);
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WhetherSynchronization", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf pushFirstNavigationController];
        
    }];
    [actionSheet addAction:ok];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

//设置第一页显示
-(void)pushFirstNavigationController
{
    UIImageView *iconSelect = (UIImageView *)[self.view viewWithTag:0 + 20000];
    iconSelect.image = [UIImage imageNamed:self.selectedImage[0]];
    
    UILabel *titleSelect = (UILabel *)[self.view viewWithTag:0 + 30000];
    titleSelect.textColor = [UIColor whiteColor];
    
    UIImageView *iconSelected = (UIImageView *)[self.view viewWithTag:self.index + 20000];
    iconSelected.image = [UIImage imageNamed:self.normalImage[self.index]];
    
    UILabel *titleSelected = (UILabel *)[self.view viewWithTag:self.index + 30000];
    titleSelected.textColor = [UIColor colorWithHexString:@"#9d9fb3"];
    
    self.index = 0;
    self.selectedIndex = self.index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
