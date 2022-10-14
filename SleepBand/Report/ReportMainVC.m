//
//  ReportMainVC.m
//  SleepBand
//
//  Created by admin on 2019/5/9.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "ReportMainVC.h"
#import "AppDelegate.h"

@interface ReportMainVC ()

@property (strong,nonatomic)UIButton *refreshBtn;
@property (strong,nonatomic)UIButton *dayBtn;
@property (strong,nonatomic)UIButton *weekBtn;
@property (strong,nonatomic)UIButton *monthBtn;
@property (strong,nonatomic)UILabel *dateTitleLabel;
@property (strong,nonatomic)LeftView *leftMenuV;

@property (assign,nonatomic)NSInteger selectType;
@property (strong,nonatomic)UIScrollView *dayScrollView;
@property (strong,nonatomic)UIView *dayProfileView;
@property (strong,nonatomic)UIView *dayView;  //日视图
@property (strong,nonatomic)UIScrollView *weekMonthScrollView;

//天
@property (strong,nonatomic)DrawView *sleepTimeDayView;  //天，睡眠质量
@property (strong,nonatomic)DrawView *averageHeartRateDayView;  //天，心率
@property (strong,nonatomic)DrawView *averageRespiratoryRateDayView;  //天，呼吸率
@property (strong,nonatomic)DrawView *turnOverDayView;  //天，翻身次数

@property (copy,nonatomic)NSString *sleepTime; //用户设置的报告起始时间

@property (strong,nonatomic)BlueToothManager *blueToothManager;

@property (assign,nonatomic)BOOL isConnectDevice;  //是否连接设备

@end

@implementation ReportMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUI];
    
    [self blueToothManagerBlock];
    
    [self notif];//eg  监听
    
    [self ClickleftBtn];
    
    
    [self getUserSleepTime];
    
    
}

#pragma mark --判断蓝牙连接
-(void)blueToothManagerBlock
{
    WS(weakSelf);
    
    self.blueToothManager = [BlueToothManager shareIsnstance];
    
    self.isConnectDevice = self.blueToothManager.isConnect;
    
    self.blueToothManager.connectPeripheralBlock = ^(BOOL isSuccess) {
        
        weakSelf.isConnectDevice = isSuccess;
    };
}

- (void)ClickleftBtn
{
    self.leftMenuV.selectControllerBlock = ^(LeftMenuType type) {
        
        if (type != LeftMenuType_Report)
        {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (type == LeftMenuType_Sleep)
            {
                [delegate setRootViewControllerForSleep];
                
            }else if (type == LeftMenuType_Clock)
            {
                [delegate setRootViewControllerForClock];
                
            }else
            {
                [delegate setRootViewControllerForMe];
            }
        }
    };
}

#pragma mark --报告起始时间
//获取用户设置的报告起始时间
-(void)getUserSleepTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.sleepTime = [defaults stringForKey:@"sleepTime"];
    NSLog(@"...self.sleepTime=%@",self.sleepTime);
    
    //通知监听 sleepTime
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveSleepTimeNotification:) name:@"sleepTime" object:nil];
    
}

#pragma mark--接收睡眠时长信息
//接收睡眠时长信息
-(void)receiveSleepTimeNotification:(NSNotification *)notification
{
    NSString *newSleepTime = notification.object;
    if (![self.sleepTime isEqualToString:newSleepTime])
    {
        self.sleepTime = newSleepTime;
        
        NSLog(@" self.sleepTime=%@",self.sleepTime);
    }
    
}

//eg 监听
- (void)notif
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTab:) name:@"egeg" object:nil];
}

- (void)refreshTab: (NSNotification *) notification
{
    NSLog(@"notification=%@",notification.object);
    
    WS(weakSelf);
//    [weakSelf.sleepTimeDayView drawUniversalDayViewDrawType:SleepDrawDayViewType_AverageHeartRate WithData:notification.object WithHour:5];
    
    //egeg
    [weakSelf.sleepTimeDayView drawUniversalDayViewDrawTe:SleepDrawDayViewType_AverageHeartRate WithData:notification.object WithHour:5];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 设置界面UI
-(void)setUI
{
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];//背景
    
    //左栏菜单
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"sleep_icon_meny"] forState:UIControlStateNormal];
    [self.view addSubview:menuButton];
    [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(0);
        make.height.equalTo(@44);
        make.width.equalTo(@54);
        
    }];
    [menuButton addTarget:self action:@selector(menuBtnTouch) forControlEvents:UIControlEventTouchUpInside];
    
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Report";
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
        
    }];
    
    //刷新按钮
    self.refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.refreshBtn setImage:[UIImage imageNamed:@"report_btn_refresh"] forState:UIControlStateNormal];
    [self.view addSubview:self.refreshBtn];
    [self.refreshBtn addTarget:self action:@selector(refreshTodayData) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+(44-25.5)/2);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-20-25.5-12);
        make.width.equalTo(@(25.5));
        make.height.equalTo(@25.5);
        
    }];
    
    //选择日期按钮
    UIButton *selectDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectDateBtn setImage:[UIImage imageNamed:@"report_btn_calenda"] forState:UIControlStateNormal];
    [self.view addSubview:selectDateBtn];
    [selectDateBtn addTarget:self action:@selector(selectDataDate) forControlEvents:UIControlEventTouchUpInside];
    [selectDateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+(44-25.5)/2);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-20);
        make.width.equalTo(@(25.5));
        make.height.equalTo(@25.5);
        
    }];
    
    //周btn
    self.weekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.weekBtn setTitle:NSLocalizedString(@"RMVC_Week", nil) forState:UIControlStateNormal];
    self.weekBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_none"]];
    self.weekBtn.titleLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight];
    self.weekBtn.selected = NO;
     self.weekBtn.tag = 998;
    [self.weekBtn setTitleColor:[UIColor colorWithHexString:@"#b1aca8"] forState:UIControlStateNormal];
    [self.weekBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.view addSubview:self.weekBtn];
    [self.weekBtn addTarget:self action:@selector(selectDateType:) forControlEvents:UIControlEventTouchUpInside];
    [self.weekBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+16);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@54);
        make.height.equalTo(@43.5);
        
    }];
    
    //天btn
    self.dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dayBtn setTitle:@"Today" forState:UIControlStateNormal];
    self.dayBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_select"]];
    self.dayBtn.titleLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight];
    self.dayBtn.selected = YES;
    self.dayBtn.tag = 999;
    [self.dayBtn setTitleColor:[UIColor colorWithHexString:@"#b1aca8"] forState:UIControlStateNormal];
    [self.dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.view addSubview:self.dayBtn];
    [self.dayBtn addTarget:self action:@selector(selectDateType:) forControlEvents:UIControlEventTouchUpInside];
    [self.dayBtn mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(weakSelf.weekBtn);
         make.right.mas_equalTo(weakSelf.weekBtn.mas_left).offset(-30);
         make.width.equalTo(@54);
         make.height.equalTo(@43.5);
    
     }];
    
    //月btn
    self.monthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.monthBtn setTitle:NSLocalizedString(@"RMVC_Month", nil) forState:UIControlStateNormal];
    self.monthBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_none"]];
    self.monthBtn.titleLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight];
    self.monthBtn.selected = NO;
    self.monthBtn.tag = 1000;
    [self.monthBtn setTitleColor:[UIColor colorWithHexString:@"#b1aca8"] forState:UIControlStateNormal];
    [self.monthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.view addSubview:self.monthBtn];
    [self.monthBtn addTarget:self action:@selector(selectDateType:) forControlEvents:UIControlEventTouchUpInside];
    [self.monthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.weekBtn);
        make.left.mas_equalTo(weakSelf.weekBtn.mas_right).offset(30);
        make.width.equalTo(@54);
        make.height.equalTo(@43.5);
        
    }];
    
    
    self.dateTitleLabel = [[UILabel alloc]init];
    [self.view addSubview:self.dateTitleLabel];
    self.dateTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    self.dateTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.dateTitleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    self.dateTitleLabel.text = @"sleeping time";
    [self.dateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.monthBtn.mas_bottom).offset(20);
        make.height.equalTo(@30);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(50);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-50);
        
    }];
    
     [self setDayViewUI];
    
    //底部image
    UIImageView *bottomImageV = [[UIImageView alloc]init];
    bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
    [self.view addSubview:bottomImageV];
    [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
        
    }];
    
    
    self.leftMenuV = [[LeftView alloc]init];
    [self.view addSubview:self.leftMenuV];
    [self.leftMenuV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.equalTo(weakSelf.view);
        
    }];
    self.leftMenuV.hidden = NO;
    
}

#pragma mark --左栏btn
-(void)menuBtnTouch
{
    if (self.leftMenuV.hidden)
    {
        [self.leftMenuV showView];
        
    }else
    {
        [self.leftMenuV hiddenView];
    }
    
}

#pragma mark - 刷新今天数据
-(void)refreshTodayData
{
    
    
    
}

#pragma mark - 选择日期
-(void)selectDataDate
{
    
}

#pragma mark --btn回调
- (void)selectDateType:(UIButton *)sender
{
    WS(weakSelf);
    if (!sender.selected)
    {
        if (self.selectType == Datetype_Day)
        {
            self.dayBtn.selected = NO;
            self.dayBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_none"]];
            
        }else if(self.selectType == Datetype_Week)
        {
            self.weekBtn.selected = NO;
            self.weekBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_none"]];
            
        }else
        {
            self.monthBtn.selected = NO;
            self.monthBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_none"]];
        }
        
        if (self.dayBtn == sender)//选中日
        {
            if (self.weekMonthScrollView.hidden == NO)
            {
                self.weekMonthScrollView.hidden = YES;
                self.dayScrollView.hidden = NO;
                [self.dayScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                
            }
            self.dayBtn.selected = YES;
            self.dayBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_select"]];
            self.selectType = DateType_Day;
            
        }else if(self.weekBtn == sender)//选中周
        {
            if (self.dayScrollView.hidden == NO)
            {
                self.dayScrollView.hidden = YES;
                self.weekMonthScrollView.hidden = NO;
            }
            if (self.weekMonthScrollView.contentOffset.y != 0)
            {
                [self.weekMonthScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
            self.weekBtn.selected = YES;
            self.weekBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_select"]];
            self.selectType = DateType_Week;
            //            [self loadData];
            
        }else//选中月
        {
            if (self.dayScrollView.hidden == NO)
            {
                self.dayScrollView.hidden = YES;
                self.weekMonthScrollView.hidden = NO;
                
            }
            if (self.weekMonthScrollView.contentOffset.y != 0)
            {
                [self.weekMonthScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
            self.monthBtn.selected = YES;
            self.monthBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_select"]];
            self.selectType = DateType_Month;
            
        }
        
    }
}


#pragma mark --设置日ui
-(void)setDayViewUI
{
    WS(weakSelf);
    
    //日 scarollview
    self.dayScrollView = [[UIScrollView alloc]init];
    self.dayScrollView.bounces = NO;
    self.dayScrollView.showsVerticalScrollIndicator = FALSE;
    // 添加scrollView添加到父视图，并设置其约束
    [self.view addSubview:self.dayScrollView];
    [self.dayScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-110-kTabbarSafeHeight);
        make.top.mas_equalTo(weakSelf.dateTitleLabel.mas_bottom).offset(5);
        
    }];
    
    
    // 设置scrollView的子视图，即过渡视图contentSize，并设置其约束
    self.dayProfileView = [[UIView alloc]init];
    [self.dayScrollView addSubview:self.dayProfileView];
    //self.dayProfileView.backgroundColor = [UIColor blueColor];
    [self.dayProfileView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.bottom.and.right.equalTo(weakSelf.dayScrollView).with.insets(UIEdgeInsetsZero);
        make.width.equalTo(weakSelf.dayScrollView);
        
    }];
    
    
    //日视图
    self.dayView = [[UIView alloc]init];
    [self.dayProfileView addSubview:self.dayView];
    
    self.sleepTimeDayView = [[DrawView alloc]init];
    self.sleepTimeDayView.tag = 1000;//tag
    self.sleepTimeDayView.contentOffsetBlock = ^(UIScrollView *scrollView) {
        
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
        
    };
    [self.dayView addSubview:self.sleepTimeDayView];
    [self.sleepTimeDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@440);
        
    }];
    
    [self.sleepTimeDayView setSleepDayViewUI];//天，睡眠质量视图
    
    //睡眠监测Lab
    UILabel * monitorTitleLabel = [[UILabel alloc]init];
    [self.dayView addSubview:monitorTitleLabel];
    monitorTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    monitorTitleLabel.textAlignment = NSTextAlignmentCenter;
    monitorTitleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    monitorTitleLabel.text = NSLocalizedString(@"RMVC_SleepMonitoring", nil);
    [monitorTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.sleepTimeDayView.mas_bottom).offset(0);
        make.height.equalTo(@14);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
        
    }];
    
    
    //1)天，心率
    self.averageHeartRateDayView = [[DrawView alloc]init];
    [self.dayView addSubview:self.averageHeartRateDayView];
    self.averageHeartRateDayView.tag = 1001;
    self.averageHeartRateDayView.contentOffsetBlock = ^(UIScrollView *scrollView)
    {
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
    };
    
    [self.averageHeartRateDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(monitorTitleLabel.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@(232));
        
    }];
    [self.averageHeartRateDayView setUniversalDayViewUIForDrawType:SleepDrawDayViewType_AverageHeartRate];//传类型
    
    //[self.averageHeartRateDayView drawSampleView];//心率-线
    

    //2)天,呼吸率
    self.averageRespiratoryRateDayView = [[DrawView alloc]init];
    self.averageRespiratoryRateDayView.tag = 1002;//tag
    self.averageRespiratoryRateDayView.contentOffsetBlock = ^(UIScrollView *scrollView) {
        
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
        
    };
    [self.dayView addSubview:self.averageRespiratoryRateDayView];
    [self.averageRespiratoryRateDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.averageHeartRateDayView.mas_bottom).offset(24);
        make.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@(232));
        
    }];
    [self.averageRespiratoryRateDayView setUniversalDayViewUIForDrawType:SleepDrawDayViewType_AverageRespiratoryRate];//传类型
    
    
    //3)天，翻身次数
    self.turnOverDayView = [[DrawView alloc]init];
    [self.dayView addSubview:self.turnOverDayView];
    self.turnOverDayView.tag = 1003;
    self.turnOverDayView.contentOffsetBlock = ^(UIScrollView *scrollView) {
        
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
        
    };
    [self.turnOverDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.averageRespiratoryRateDayView.mas_bottom).offset(24);
        make.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@(232));
        
    }];
    [self.turnOverDayView setUniversalDayViewUIForDrawType:SleepDrawDayViewType_TurnOver];//传类型
    
    
    [self.dayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.equalTo(weakSelf.dayProfileView);
        make.bottom.mas_equalTo(weakSelf.turnOverDayView.mas_bottom).offset(10);
        
    }];
    
    // 设置过渡视图的底边距为最后一个子视图的底部（此设置将影响到scrollView的contentSize）
    [self.dayProfileView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(weakSelf.dayView.mas_bottom).offset(0);
        
    }];
    
    
}

#pragma mark --日报告全局滚动
//日报告全局滚动
-(void)setDayViewScrollViewContentOffset:(UIScrollView*)scrollView
{
    for(int i = 1000 ; i < 1004 ; i++)
    {
        DrawView *drawView = (DrawView *)[self.dayView viewWithTag:i];
        if(scrollView != drawView.scrollDayView)
        {
            drawView.scrollDayView.contentOffset = scrollView.contentOffset;
        }
    }
    
}

@end
