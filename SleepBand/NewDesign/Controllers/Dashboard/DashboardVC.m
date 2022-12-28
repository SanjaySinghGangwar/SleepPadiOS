//
//  DashboardVC.m
//  SleepBand
//
//  Created by Mac on 27/12/22.
//  Copyright © 2022 admin. All rights reserved.
//

#import "DashboardVC.h"
#import "AppDelegate.h"

#import "SleepCurveTool.h"
#import "SleepQualityModel.h"
#import <iconv.h>

#import "XYWReportRangeDataSelectViewNew.h"
#import "XYWDayBackView.h"
#import "XYWWeekBackView.h"

#define PublicScrollViewHeight 1290

@interface DashboardVC ()<XYWReportRangeDataSelectViewNewDelegate>

@property (strong,nonatomic)XYWReportRangeDataSelectViewNew *reportRangeDataSelectView;
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

@end

@implementation DashboardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"#120B29"]];
    
    self.dateArrIndex = 0;
    self.selectType = DateType_Day;//设置用户默认选中类型
    self.formatter = [[NSDateFormatter alloc]init];//设置全局默认时间格式
    [self.formatter setDateFormat:@"yyyy-MM-dd"];
    
    self.selectDate = [UIFactory NSDateForUTC:[NSDate date]];//设置当天为默认选中的日期

    [self setUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
}

- (void)dealloc{
    // 移除当前对象监听的事件
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (XYWDayBackView *)dayBackView{
    if (_dayBackView == nil) {
        _dayBackView = [[XYWDayBackView alloc]init];
        _dayBackView.backgroundColor = [UIColor clearColor];
    }
    return _dayBackView;
}
- (XYWWeekBackView *)weekBackView{
    if (_weekBackView == nil) {
        _weekBackView = [[XYWWeekBackView alloc]init];
        _weekBackView.backgroundColor = [UIColor clearColor];
    }
    return _weekBackView;
}
- (XYWWeekBackView *)monthBackView{
    if (_monthBackView == nil) {
        _monthBackView = [[XYWWeekBackView alloc]init];
        _monthBackView.backgroundColor = [UIColor clearColor];
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

#pragma mark --XYWReportRangeDataSelectViewNewDelegate
- (void)XYWReportRangeDataSelectNewViewSelectIndex:(NSInteger)index{
    WS(weakSelf);
    [UIView animateWithDuration:0.3 animations:^{
        [self.myScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.view.mas_left).offset(-kSCREEN_WIDTH*index);
        }];
        [self.myScrollView.superview layoutIfNeeded];
    }];
    
    if (self.selectType == index) return;
    self.selectType = index;
    
   // [self xyw_loadData];
}

#pragma mark -

- (UIScrollView *)setPublicScrollView:(UIScrollView*)scrollView{
    scrollView.contentSize = CGSizeMake(0, PublicScrollViewHeight);
    scrollView.directionalLockEnabled = YES;
    scrollView.showsVerticalScrollIndicator =YES;
    scrollView.pagingEnabled = NO;
    scrollView.scrollEnabled = YES;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    
    return scrollView;
}

-(void)setUI{
    WS(weakSelf);
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"Dashboard";
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(12);
        make.height.equalTo(@40);
        make.width.equalTo(@200);
    }];
    
    UIView *borderView = [[UIView alloc]init];
    borderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:borderView];
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(2);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@(kSCREEN_WIDTH - 12));
        make.height.equalTo(@2);
    }];
    
    self.reportRangeDataSelectView = [[XYWReportRangeDataSelectViewNew alloc]init];
    self.reportRangeDataSelectView.delegate = self;
    [self.view addSubview:self.reportRangeDataSelectView];
    [self.reportRangeDataSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(weakSelf.view);
        make.height.equalTo(@65.0);
    }];
    
    self.myScrollView = [[UIView alloc]init];
    [self.view addSubview:self.myScrollView];
    self.myScrollView.backgroundColor = [UIColor clearColor];
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
    
    
    UIImage * bottomImg = [UIImage imageNamed:@"search_bg_bottom"];

    [dayBackScrollView addSubview:self.dayBackView];
    [self.dayBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.equalTo(@(kSCREEN_WIDTH));
        make.height.equalTo(@(PublicScrollViewHeight));
    }];
    
    
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

#pragma mark - 加载数据
-(void)xyw_loadData{
    
    switch (self.selectType) {
        case DateType_Day:{
            [self.dayBackView xyw_refreshDayBackViewWithData:[[UIFactory stringReturnDate:[UIFactory dateForNumString:self.selectDate]] timeIntervalSince1970] sizeTime:86400];
        }
            break;
        case DateType_Week:{
            //周
            //[self getWeekDate];//获取日期
            //[self.weekBackView xyw_refreshWeekBackViewWithDataArr:self.weekArray];
            //self.moreLab.hidden = YES;
        }
            break;
        case DateType_Month:{
            //月
            //[self getMonthDate];//获取日期
            //[self.monthBackView xyw_refreshWeekBackViewWithDataArr:self.monthArray];
            //self.moreLab.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    //self.pageControl.hidden = self.moreLab.hidden;
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
