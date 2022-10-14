//
//  ReportMainViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ReportMainViewController.h"
#import "AppDelegate.h"

#import "SelectDateViewController.h"
#import "EditCustomViewController.h"
#import "SleepCurveTool.h"
#import "SleepQualityModel.h"
#import <iconv.h>

#import "XYWReportRangeDataSelectView.h"
#import "XYWDayBackView.h"
#import "XYWWeekBackView.h"

//1300
#define PublicScrollViewHeight 1290

@interface ReportMainViewController ()<XYWReportRangeDataSelectViewDelegate>
@property (strong,nonatomic)XYWReportRangeDataSelectView *reportRangeDataSelectView;//日、周、月选择视图
@property (strong,nonatomic)UIButton *refreshBtn;
@property (assign,nonatomic)NSInteger selectType;// 0 - DateType_Day , 1 - DateType_Week , 2 - DateType_Month
@property (strong,nonatomic)UILabel *dateTitleLabel;//当前选择日期
@property (strong,nonatomic)UILabel *moreLab;//获取更多睡眠数据提示框
@property (strong,nonatomic)UIPageControl *pageControl;//更多睡眠数据分页提示
@property (assign,nonatomic)int dateArrIndex;//当前选择时段

@property (strong,nonatomic)UIView * myScrollView;
@property (strong,nonatomic)XYWDayBackView *dayBackView;
@property (strong,nonatomic)XYWWeekBackView *weekBackView;
@property (strong,nonatomic)XYWWeekBackView *monthBackView;

@property (strong,nonatomic)UIView *dayView;  //日视图
@property (strong,nonatomic)UIView *weekMonthView;  //周，月视图

@property (strong,nonatomic)NSDateFormatter *formatter;
@property (strong,nonatomic)NSDate *selectDate;
@property (strong,nonatomic)NSMutableArray *weekArray;
@property (strong,nonatomic)NSMutableArray *monthArray;

@property (assign,nonatomic)BOOL isConnectDevice;  //是否连接设备
@property (strong,nonatomic)BlueToothManager *blueToothManager;

@property (assign,nonatomic)int totalCount; //总共需要同步的次数
@property (assign,nonatomic)int synchronizationCount; //已同步的次数
@property (strong,nonatomic)LeftView *leftMenuV;

@end

@implementation ReportMainViewController

- (void)dealloc{
    // 移除当前对象监听的事件
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (XYWDayBackView *)dayBackView{
    if (_dayBackView == nil) {
        _dayBackView = [[XYWDayBackView alloc]init];
        _dayBackView.backgroundColor = [UIColor whiteColor];
    }
    return _dayBackView;
}
- (XYWWeekBackView *)weekBackView{
    if (_weekBackView == nil) {
        _weekBackView = [[XYWWeekBackView alloc]init];
        _weekBackView.backgroundColor = [UIColor whiteColor];
    }
    return _weekBackView;
}
- (XYWWeekBackView *)monthBackView{
    if (_monthBackView == nil) {
        _monthBackView = [[XYWWeekBackView alloc]init];
        _monthBackView.backgroundColor = [UIColor whiteColor];
    }
    return _monthBackView;
}

-(NSMutableArray *)weekArray{
    if (_weekArray == nil){
        _weekArray = [[NSMutableArray alloc]init];
    }
    return _weekArray;
}

-(NSMutableArray *)monthArray{
    if (_monthArray == nil){
        _monthArray = [[NSMutableArray alloc]init];
    }
    return _monthArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.mainTabBar.tabBarView.hidden = NO;
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self blueToothManagerBlock];//判断蓝牙连接
    self.dateArrIndex = 0;
    self.selectType = DateType_Day;//设置用户默认选中类型
    self.formatter = [[NSDateFormatter alloc]init];//设置全局默认时间格式
    [self.formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults boolForKey:@"isHaveNewDataForPushToReport"];
    if ([defaults boolForKey:@"isHaveNewDataForPushToReport"]) {
        self.selectDate = [UIFactory NSDateForUTC:[self getNewDataTime]];
    }else{
        self.selectDate = [UIFactory NSDateForUTC:[NSDate date]];//设置当天为默认选中的日期
    }
    //在这里消除新数据的标识符
    [defaults setBool:NO forKey:@"isHaveNewDataForPushToReport"];
    [defaults synchronize];
    
    [self setUI];//构建视图
    
    self.leftMenuV.selectControllerBlock = ^(LeftMenuType type) {
        if (type != LeftMenuType_Report){
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (type == LeftMenuType_Sleep){
                [delegate setRootViewControllerForSleep];
                
            }else if (type == LeftMenuType_Clock){
                [delegate setRootViewControllerForClock];
            }else{
                [delegate setRootViewControllerForMe];
            }
        }
    };
    
}

#pragma mark --获取最近一段数据的日期
- (NSDate*)getNewDataTime{
    
    NSMutableArray *dateSleepQualityArray = [SleepQualityModel searchWithWhere:@{@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
//    dataDate
    SleepQualityModel * sleepQualityModel = dateSleepQualityArray.lastObject;
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[sleepQualityModel.dataDate integerValue]];
    
    return date;
}

#pragma mark --判断蓝牙连接
-(void)blueToothManagerBlock{
    WS(weakSelf);
    self.blueToothManager = [BlueToothManager shareIsnstance];
    self.isConnectDevice = self.blueToothManager.isConnect;
    self.blueToothManager.connectPeripheralBlock = ^(BOOL isSuccess) {
        weakSelf.isConnectDevice = isSuccess;
    };
}

#pragma mark --XYWReportRangeDataSelectViewDelegate
- (void)XYWReportRangeDataSelectViewSelectIndex:(NSInteger)index{
    WS(weakSelf);
    [UIView animateWithDuration:0.3 animations:^{
        [self.myScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.view.mas_left).offset(-kSCREEN_WIDTH*index);
        }];
        [self.myScrollView.superview layoutIfNeeded];//强制绘制
    }];
    
    if (self.selectType == index) return;
    self.selectType = index;
    
    [self xyw_loadData];
}

-(void)tabBarViewHidden{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.mainTabBar.tabBarView.hidden == NO){
        delegate.mainTabBar.tabBarView.hidden = YES;
    }
}

#pragma mark - 日期显示Lab（作用于一天内多段睡眠的时间选择入口）
-(void)dateTitleLabelTap{
    
    //过滤touch事件
    if (self.selectType != DateType_Day) return;//周、月
    if (self.dayBackView.sleepTimeArr.count < 2) return;//一天不足两段睡眠
    //循环切换多段睡眠
    if (self.dateArrIndex >= self.dayBackView.sleepTimeArr.count) {
        self.dateArrIndex = 0;
    }
    
    NSString * dataString = self.dayBackView.sleepTimeArr[self.dateArrIndex];
    [self.dayBackView xyw_refreshDayBackViewWithData:[dataString integerValue]-5*60*60 sizeTime:1];
    self.pageControl.currentPage = self.dateArrIndex;//设置当前页码
    self.dateArrIndex ++;
}

#pragma mark - 选择日期
-(void)selectDataDate{
    WS(weakSelf);
    [self tabBarViewHidden];
    
    SelectDateViewController *selectDate = [[SelectDateViewController alloc]init];
    selectDate.pushDate = self.selectDate;
    selectDate.dateBlock = ^(NSString *date){
        weakSelf.selectDate = [UIFactory NSDateForNoUTC:[weakSelf.formatter dateFromString:date]];
        [weakSelf.dayBackView.sleepTimeArr removeAllObjects];
        [weakSelf xyw_loadData];
    };
    [self.navigationController pushViewController:selectDate animated:YES];//push 日期
}

#pragma mark - 刷新/同步数据
- (void)xyw_syncAllSleepData{
    WS(weakSelf);
    /*同步ble数据*/
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Synchronizationing", nil)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD dismissWithDelay:kDismissWithOutTime];
    //1.清理所有数据
    //    [self.blueToothManager deleteSleepAllDataNotify];
    //3.保存成功回调中，同步睡眠数据到服务器
    self.blueToothManager.syncFinishedBlock = ^(NSArray *timeStringArr, BOOL isFinished) {
        
        if (isFinished && timeStringArr.count>0) {
            
            NSMutableArray * dataArr = [NSMutableArray array];
            
            for (NSString * dataDate in timeStringArr) {
                //time
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                [dict setObject:dataDate forKey:@"time"];
                //dataForSleep
                NSMutableArray *dateSleepQualityArray = [SleepQualityModel searchWithWhere:@{@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode,@"dataDate":dataDate}];
                if (dateSleepQualityArray.count == 1) {
                    SleepQualityModel * sleepQualityModel = dateSleepQualityArray.firstObject;
                    [dict setObject:sleepQualityModel.dataArray forKey:@"dataForSleep"];
                }
                //dataForHeart
                NSMutableArray * dateHeartRateArray = [HeartRateModel searchWithWhere:@{@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode,@"dataDate":dataDate}];
                if (dateHeartRateArray.count==1) {
                    HeartRateModel * heartRateModel = dateHeartRateArray.firstObject;
                    [dict setObject:heartRateModel.dataArray forKey:@"dataForHeart"];
                }
                //dataForBreath
                NSMutableArray * datebreathRateArray = [RespiratoryRateModel searchWithWhere:@{@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode,@"dataDate":dataDate}];
                if (dateHeartRateArray.count==1) {
                    RespiratoryRateModel * respiratoryRateModel = datebreathRateArray.firstObject;
                    [dict setObject:respiratoryRateModel.dataArray forKey:@"dataForBreath"];
                }
                //dataForTurnOver
                NSMutableArray * dateTurnOverArray = [TurnOverModel searchWithWhere:@{@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode,@"dataDate":dataDate}];
                if (dateHeartRateArray.count==1) {
                    TurnOverModel * turnOverModel = dateTurnOverArray.firstObject;
                    [dict setObject:turnOverModel.dataArray forKey:@"dataForTurnOver"];
                }
                [dataArr addObject:dict];
            }
            
            if (dataArr.count > 0) {
                //上传睡眠数据
                [[MSCoreManager sharedManager] postSleepDataFromParams:@{@"data":dataArr} WithResponse:^(ResponseInfo *info) {
                    if([info.code isEqualToString:@"200"]){
                        //上传成功
                        NSLog(@"上传睡眠数据成功");
                        //[SVProgressHUD showSuccessWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        //删除设备数据(睡眠报告)
                        [weakSelf.blueToothManager deleteSleepBandDataNotify];
                    }else{
                        //上传失败
                        [SVProgressHUD showErrorWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    }
                }];
            }else{
                NSLog(@"没有新数据需要上传-报告主页");
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }
        
        else if (isFinished && timeStringArr.count == 0){
            //            NSLog(@"isFinished = %@",isFinished?@"YES":@"NO");
            NSLog(@"没有新数据需要上传-报告主页");
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    };
    //2.读取设备数据并保存数据库
    [self.blueToothManager readSleepAllDataNotifyWithAll:YES];
    //4...
}

#pragma mark - 加载数据
-(void)xyw_loadData{
    
    switch (self.selectType) {
        case DateType_Day:{
            
            [self.dayBackView xyw_refreshDayBackViewWithData:[[UIFactory stringReturnDate:[UIFactory dateForNumString:self.selectDate]] timeIntervalSince1970] sizeTime:86400];
            NSString * dateTitleText;
            if([[NSCalendar currentCalendar] isDateInToday:self.selectDate]){
                dateTitleText = NSLocalizedString(@"RMVC_Today", nil);
            }else if ([[NSCalendar currentCalendar] isDateInYesterday:self.selectDate]){
                dateTitleText = NSLocalizedString(@"RMVC_Yesterday", nil);
            }else{
                dateTitleText = [self.formatter stringFromDate:self.selectDate];
            }
            
            if (self.dayBackView.sleepTimeArr.count>1) {
                //添加下划线
                NSDictionary * underAttribtDic  = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
                NSMutableAttributedString * underAttr = [[NSMutableAttributedString alloc] initWithString:dateTitleText attributes:underAttribtDic];
                self.dateTitleLabel.attributedText = underAttr;
                self.moreLab.hidden = NO;
                self.pageControl.numberOfPages = self.dayBackView.sleepTimeArr.count;//设置总页码数
                self.pageControl.currentPage = self.dayBackView.sleepTimeArr.count - 1;//设置当前页码
            }else{
                self.dateTitleLabel.text = dateTitleText;
                self.moreLab.hidden = YES;
            }
            
            
            
        }
            break;
        case DateType_Week:{
            //周
            [self getWeekDate];//获取日期
            [self.weekBackView xyw_refreshWeekBackViewWithDataArr:self.weekArray];
            self.moreLab.hidden = YES;
        }
            break;
        case DateType_Month:{
            //月
            [self getMonthDate];//获取日期
            [self.monthBackView xyw_refreshWeekBackViewWithDataArr:self.monthArray];
            self.moreLab.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    self.pageControl.hidden = self.moreLab.hidden;
}

#pragma mark ---获取月日期
//获取月日期
-(void)getMonthDate{
    [self.monthArray removeAllObjects];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *dateTimeString = [formatter stringFromDate:self.selectDate];
    
    int year = [[dateTimeString substringWithRange:NSMakeRange(0, 4)] intValue];
    int month = [[dateTimeString substringWithRange:NSMakeRange(5, 2)] intValue];
    NSString *dateString = [NSString stringWithFormat:@"%d-%02d-01",year,month];

    NSLog(@"获取月日期 dateString=%@",dateString);
    NSDate * firstDate = [UIFactory NSDateForUTC:[formatter dateFromString:dateString]];
    
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit: NSCalendarUnitMonth
                                  forDate:firstDate];
    int date = [[UIFactory dateForNumString:firstDate] intValue];
    
    for (int i = 0 ; i < range.length ; i++){
        [self.monthArray addObject:[NSString stringWithFormat:@"%d",date+i]];
    }
    self.dateTitleLabel.text = [NSString stringWithFormat:@"%d/%02d",year,month];
}

#pragma mark --获取周日期
//获取周日期
-(void)getWeekDate{
    [self.weekArray removeAllObjects];
    NSString *stringDate = [UIFactory dateForNumString:self.selectDate];
    
    int weekday = [UIFactory dayReturnWeekday:[NSString stringWithFormat:@"%@%@01",[stringDate substringWithRange:NSMakeRange(0, 4)],[stringDate substringWithRange:NSMakeRange(4, 2)]]];
    NSDate *today = self.selectDate; //Get a date object for today's date
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:today];
    NSInteger count = days.length;
    
    if((count+weekday-1)%7 == 0){
        for (int i = 0 ; i <(count+weekday)/7; i++){
            NSString *week = [UIFactory dateForNumString:[UIFactory dateForBeforeStrDate:[NSString stringWithFormat:@"%@%@01",[stringDate substringWithRange:NSMakeRange(0, 4)],[stringDate substringWithRange:NSMakeRange(4, 2)]] withDay:[NSString stringWithFormat:@"%d",7*i] withMonth:0]];
            
            int weekday = [UIFactory dayReturnWeekday:week];
            NSDate *weekStartDay = [UIFactory dateForBeforeStrDate:week withDay:[NSString stringWithFormat:@"%d",0-weekday+2] withMonth:nil];
            NSString *weekStartDayString = [UIFactory dateForNumString:weekStartDay];
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            BOOL isSelectWeek = NO;
            
            for(int j = 0  ; j <7 ; j++){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                NSDate *weekDay = [UIFactory dateForBeforeStrDate:weekStartDayString withDay:[NSString stringWithFormat:@"%d",j+1] withMonth:nil];
                
                
                NSString *currentTimeString = [formatter stringFromDate:weekDay];
                NSString *currentString = [NSString stringWithFormat:@"%@",[currentTimeString substringWithRange:NSMakeRange(0, 10)]];
                NSDate *currentDate =  [formatter dateFromString:currentString];
                
                NSString *selectTimeString = [formatter stringFromDate:self.selectDate];
                NSString *selectString = [NSString stringWithFormat:@"%@",[selectTimeString substringWithRange:NSMakeRange(0, 10)]];
                NSDate *selectDate =  [formatter dateFromString:selectString];
                
                if ([currentDate compare:selectDate] == NSOrderedSame){
                    isSelectWeek = YES;
                }
                NSString *weekDayString = [UIFactory dateForNumString:weekDay];
                [arr addObject:weekDayString];
            }
            
            if (isSelectWeek == YES){
                [self.weekArray addObjectsFromArray:arr];
            }
            [arr removeAllObjects];
            arr = nil;
        }
        
    }else{
        for (int i = 0 ; i <(count+weekday)/7+1; i++){
            NSString *week = [UIFactory dateForNumString:[UIFactory dateForBeforeStrDate:[NSString stringWithFormat:@"%@%@01",[stringDate substringWithRange:NSMakeRange(0, 4)],[stringDate substringWithRange:NSMakeRange(4, 2)]] withDay:[NSString stringWithFormat:@"%d",7*i+1] withMonth:0]];
            //
            int weekday = [UIFactory dayReturnWeekday:week];
            NSDate *weekStartDay = [UIFactory dateForBeforeStrDate:week withDay:[NSString stringWithFormat:@"%d",0-weekday+2] withMonth:nil];
            //            NSDate *weekEndDay = [UIFactory dateForBeforeDate:week withDay:[NSString stringWithFormat:@"%d",8-weekday] withMonth:nil];
            NSString *weekStartDayString = [UIFactory dateForNumString:weekStartDay];
            
            //            NSString *weekEndDayString = [UIFactory dateForNumString:weekEndDay];
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            BOOL isSelectWeek = NO;
            
            for(int j = 0; j < 7; j ++){
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                NSDate *weekDay = [UIFactory dateForBeforeStrDate:weekStartDayString withDay:[NSString stringWithFormat:@"%d",j+1] withMonth:nil];
                
                //当前时间
                NSString *currentTimeString = [formatter stringFromDate:weekDay];
                NSString *currentString = [NSString stringWithFormat:@"%@",[currentTimeString substringWithRange:NSMakeRange(0, 10)]];
                NSDate *currentDate =  [formatter dateFromString:currentString];
                
                //选择时间
                NSString *selectTimeString = [formatter stringFromDate:self.selectDate];
                NSString *selectString = [NSString stringWithFormat:@"%@",[selectTimeString substringWithRange:NSMakeRange(0, 10)]];
                NSDate *selectDate =  [formatter dateFromString:selectString];
                
                if ([currentDate compare:selectDate] == NSOrderedSame) {
                    
                    isSelectWeek = YES;
                }
                NSString *weekDayString = [UIFactory dateForNumString:weekDay];
                [arr addObject:weekDayString];
            }
            if (isSelectWeek == YES) {
                [self.weekArray addObjectsFromArray:arr];
            }
            [arr removeAllObjects];
            arr = nil;
        }
    }
    self.dateTitleLabel.text = [NSString stringWithFormat:@"%@ - %@",[NSString stringWithFormat:@"%@/%@",[self.weekArray[0] substringWithRange:NSMakeRange(4, 2)],[self.weekArray[0] substringWithRange:NSMakeRange(6, 2)]],    [NSString stringWithFormat:@"%@/%@",[self.weekArray[6] substringWithRange:NSMakeRange(4, 2)],[self.weekArray[6] substringWithRange:NSMakeRange(6, 2)]]];
}

#pragma mark --左栏btn
-(void)menuBtnTouch{
    if (self.leftMenuV.hidden){
        [self.leftMenuV showView];
    }else{
        [self.leftMenuV hiddenView];
    }
}

#pragma mark - 设置界面UI
- (UIScrollView *)setPublicScrollView:(UIScrollView*)scrollView{
    scrollView.contentSize = CGSizeMake(0, PublicScrollViewHeight);//滚动范围的大小
    scrollView.directionalLockEnabled = YES; //只能一个方向滑动
    scrollView.showsVerticalScrollIndicator =YES; //垂直方向的滚动指示
    scrollView.pagingEnabled = NO; //是否翻页
    scrollView.scrollEnabled = YES;//控制控件是否能滚动
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;//滚动指示的风格
    scrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
    scrollView.bounces = NO;//控制控件遇到边框是否反弹
    
    return scrollView;
}

-(void)setUI{
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
    [self.refreshBtn addTarget:self action:@selector(xyw_syncAllSleepData) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+(44-25.5)/2);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-20-25.5-12);
        make.width.equalTo(@25.5);
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
        make.width.equalTo(@25.5);
        make.height.equalTo(@25.5);
    }];
    
    self.reportRangeDataSelectView = [[XYWReportRangeDataSelectView alloc]init];
    self.reportRangeDataSelectView.delegate = self;
    [self.view addSubview:self.reportRangeDataSelectView];
    [self.reportRangeDataSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(weakSelf.view);
        make.height.equalTo(@110);//16+43.5+20+16+13.5
    }];
    
    self.dateTitleLabel = [[UILabel alloc]init];
    [self.reportRangeDataSelectView addSubview:self.dateTitleLabel];
    self.dateTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    self.dateTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.dateTitleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    self.dateTitleLabel.text = [self.formatter stringFromDate:self.selectDate];
    self.dateTitleLabel.userInteractionEnabled = YES;
    [self.dateTitleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateTitleLabelTap)]];
    [self.dateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@65.0);
        make.height.equalTo(@16);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(50);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-50);
    }];
    
    self.moreLab = [[UILabel alloc]init];
    [self.reportRangeDataSelectView addSubview:self.moreLab];
    self.moreLab.text = NSLocalizedString(@"RMVC_MoreData",nil);
    self.moreLab.font = [UIFont systemFontOfSize:10 weight:UIFontWeightLight];
    self.moreLab.textAlignment = NSTextAlignmentCenter;
    self.moreLab.textColor = [UIColor grayColor];
    self.moreLab.hidden = YES;
    self.moreLab.userInteractionEnabled = YES;
    [self.moreLab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateTitleLabelTap)]];
    [self.moreLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.dateTitleLabel.mas_bottom);
        make.height.equalTo(@14);
        make.centerX.equalTo(weakSelf.dateTitleLabel);
        make.width.equalTo(weakSelf.dateTitleLabel);
    }];
    
    self.pageControl = [[UIPageControl alloc] init];
    [self.reportRangeDataSelectView addSubview:self.pageControl];
    self.pageControl.numberOfPages = 1;//设置总页码数
    self.pageControl.currentPage = 0;//设置当前页码
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"#e5e4df"];//设置所有页码点的颜色(未选中)
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#1b86a4"];//设置当前页码点颜色(选中)
    self.pageControl.hidesForSinglePage = YES;//当只有一页时，是否要隐藏
    self.pageControl.userInteractionEnabled = NO;//关闭交互
    self.pageControl.hidden = self.moreLab.hidden;
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.moreLab.mas_bottom);
        make.height.equalTo(@15);
        make.centerX.equalTo(weakSelf.moreLab);
        make.width.equalTo(weakSelf.moreLab);
    }];
    
    self.myScrollView = [[UIView alloc]init];
    [self.view addSubview:self.myScrollView];
    self.myScrollView.backgroundColor = [UIColor whiteColor];
    [self.myScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.width.equalTo(@(kSCREEN_WIDTH*3));
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom);
        make.top.mas_equalTo(weakSelf.reportRangeDataSelectView.mas_bottom);
    }];

    UIScrollView *dayBackScrollView = [[UIScrollView alloc]init];
    [self.myScrollView addSubview:[self setPublicScrollView:dayBackScrollView]];
    [dayBackScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(kSCREEN_WIDTH *0));
        make.width.equalTo(@(kSCREEN_WIDTH));
        make.bottom.mas_equalTo(weakSelf.myScrollView.mas_bottom);
        make.top.mas_equalTo(weakSelf.myScrollView.mas_top);
    }];
    
    UIScrollView *weekBackScrollView = [[UIScrollView alloc]init];
    [self.myScrollView addSubview:[self setPublicScrollView:weekBackScrollView]];
    [weekBackScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(kSCREEN_WIDTH *1));
        make.width.equalTo(@(kSCREEN_WIDTH));
        make.bottom.mas_equalTo(weakSelf.myScrollView.mas_bottom);
        make.top.mas_equalTo(weakSelf.myScrollView.mas_top);
    }];
    
    UIScrollView *monthBackScrollView = [[UIScrollView alloc]init];
    [self.myScrollView addSubview:[self setPublicScrollView:monthBackScrollView]];
    [monthBackScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(kSCREEN_WIDTH *2));
        make.width.equalTo(@(kSCREEN_WIDTH));
        make.bottom.mas_equalTo(weakSelf.myScrollView.mas_bottom);
        make.top.mas_equalTo(weakSelf.myScrollView.mas_top);
    }];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"ASSVC_Title", nil)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
//    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ASSVC_Title", nil)];
    [SVProgressHUD dismissWithDelay:2];
    
    //底部image
    UIImage * bottomImg = [UIImage imageNamed:@"search_bg_bottom"];

    [dayBackScrollView addSubview:self.dayBackView];
    [self.dayBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.equalTo(@(kSCREEN_WIDTH));
        make.height.equalTo(@(PublicScrollViewHeight));
    }];
    UIImageView *bottomImageV0 = [[UIImageView alloc]init];
    bottomImageV0.image = bottomImg;
    [self.myScrollView addSubview:bottomImageV0];
    [bottomImageV0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.dayBackView.mas_bottom).offset(-101);
        make.left.mas_equalTo(weakSelf.dayBackView.mas_left);
        make.width.equalTo(@(kSCREEN_WIDTH));
        make.height.equalTo(@101);
    }];
    
    self.leftMenuV = [[LeftView alloc]init];
    [self.view addSubview:self.leftMenuV];
    [self.leftMenuV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.equalTo(weakSelf.view);
        
    }];
    self.leftMenuV.hidden = YES;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        [weekBackScrollView addSubview:self.weekBackView];
        [self.weekBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@0);
            make.width.mas_equalTo(kSCREEN_WIDTH);
            make.height.equalTo(@(PublicScrollViewHeight));
        }];
        UIImageView *bottomImageV1 = [[UIImageView alloc]init];
        bottomImageV1.image = bottomImg;
        [self.myScrollView addSubview:bottomImageV1];
        [bottomImageV1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.weekBackView.mas_bottom).offset(-101);
            make.left.mas_equalTo(weakSelf.weekBackView.mas_left);
            make.width.equalTo(@(kSCREEN_WIDTH));
            make.height.equalTo(@101);
        }];
        
        [monthBackScrollView addSubview:self.monthBackView];
        [self.monthBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@0);
            make.width.mas_equalTo(kSCREEN_WIDTH);
            make.height.equalTo(@(PublicScrollViewHeight));
        }];
        UIImageView *bottomImageV2 = [[UIImageView alloc]init];
        bottomImageV2.image = bottomImg;
        [self.myScrollView addSubview:bottomImageV2];
        [bottomImageV2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.monthBackView.mas_bottom).offset(-101);
            make.left.mas_equalTo(weakSelf.monthBackView.mas_left);
            make.width.equalTo(@(kSCREEN_WIDTH));
            make.height.equalTo(@101);
        }];
        
        [self xyw_loadData];
        
    });
    
}





@end
