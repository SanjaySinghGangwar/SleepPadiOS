//
//  SelectDateViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/23.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SelectDateViewController.h"
#import "FDCalendar.h"

@interface SelectDateViewController ()

@property (strong,nonatomic)FDCalendar *calendar;

@property (strong,nonatomic)UILabel * sleepTimePromptLab;//睡眠数据提示框

@end

@implementation SelectDateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];
    
    //加载日期第三方库
    self.calendar = [[FDCalendar alloc] initWithCurrentDate:self.pushDate];
    self.calendar.frame = CGRectMake(0, kStatusBarHeight+44, kSCREEN_WIDTH, kSCREEN_HEIGHT-(kStatusBarHeight+44)-(kTabbarSafeHeight+101+40+20));
    [self.view addSubview:self.calendar];
    self.calendar.backgroundColor = [UIColor clearColor];
    self.calendar.datePicker.date =  [UIFactory dateForBeforeDate:self.pushDate withDay:@"0" withMonth:nil];
    [self.calendar setCurrentDate:self.pushDate];
    
    //刷新睡眠数据提示框内容
    [self refreshSleepTimePromptLabTextWithDate:self.pushDate];
    
    WS(weakSelf);
    //选择日期后返回的block
    self.calendar.selectedDateBlock = ^(NSString *date){
        
        weakSelf.date = date;
        
        NSDateFormatter*formatter = [[NSDateFormatter alloc]init];//设默认时间格式
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * selectDate =  [UIFactory NSDateForNoUTC:[formatter dateFromString:date]];
        
        //刷新睡眠数据提示框内容
        [weakSelf refreshSleepTimePromptLabTextWithDate:selectDate];
        
    };
}

#pragma mark - 刷新睡眠数据提示框内容
- (void)refreshSleepTimePromptLabTextWithDate:(NSDate*)selectDate{
    //睡眠段数量
    NSUInteger sleepTiemNum = [self getSleepTimeArrayWithDate:selectDate].count;
    //睡眠总时长为
    NSInteger sleepAllTiem ;
    
    if (sleepTiemNum == 0) {
        self.sleepTimePromptLab.text = NSLocalizedString(@"RMVC_SleepNoData", nil);//NoData
    }else{
        sleepAllTiem = [self getAllSleepTimeWithSleepDataArray:[self getSleepTimeArrayWithDate:selectDate]];
        
        self.sleepTimePromptLab.attributedText = [self getSleepTimePromptLabAttributedTextWith:sleepAllTiem sleepTiemNum:sleepTiemNum];
    }
}

#pragma mark - 获取睡眠数据提示框富文本信息
- (NSMutableAttributedString *)getSleepTimePromptLabAttributedTextWith:(NSInteger) sleepAllTiem sleepTiemNum:(NSInteger)sleepTiemNum{
    
    NSString * sleepTImeString ;
    
    int h = 0;
    int min = 0;
    if (sleepAllTiem >0) {
        h = floor(sleepAllTiem / 60);
        min = sleepAllTiem % 60;
    }
    NSString * hUnit= NSLocalizedString(@"RMVC_Hour", nil);//h
    NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);//min
    NSString * sleepsFor= NSLocalizedString(@"RMVC_SleepsFor", nil);//Sleeps for 段睡眠共
    
    sleepTImeString = [NSString stringWithFormat:@"%02d%@%02d%@",h,hUnit,min,minUnit];
    
    NSString * sleepPromptLabStr = [NSString stringWithFormat:@"%@%@%@",[NSString stringWithFormat:@"%d",(int)sleepTiemNum],sleepsFor,sleepTImeString];
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:sleepPromptLabStr];
    [AttributedStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:23.0],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#1b86a3"]} range:NSMakeRange(sleepPromptLabStr.length-minUnit.length-2, 2)];
    [AttributedStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:23.0],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#1b86a3"]} range:NSMakeRange(sleepPromptLabStr.length-minUnit.length-2*2-hUnit.length, 2)];
    [AttributedStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:23.0],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#1b86a3"]} range:NSMakeRange(0, [NSString stringWithFormat:@"%d",(int)sleepTiemNum].length)];
 
    return AttributedStr;
}

#pragma mark - 获取睡眠段数组
- (NSMutableArray *)getSleepTimeArrayWithDate:(NSDate *)selectDate{
    
    NSMutableArray * sleepTimeArr = [NSMutableArray array];//睡眠段时间戳数组
    NSMutableArray * sleepDataArray = [NSMutableArray array];//睡眠段数据数组
    
    NSInteger beginTime = [[UIFactory stringReturnDate:[UIFactory dateForNumString:selectDate]] timeIntervalSince1970];
    beginTime += 5*60*60;
    NSInteger endTime = beginTime + 86400;
    
    NSMutableArray *dateSleepQualityArray = [SleepQualityModel searchWithWhere:@{@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    
    if (dateSleepQualityArray.count == 0) {
        return sleepDataArray;
    }else{
        
        for (int i = 0; i < dateSleepQualityArray.count; i++) {
            SleepQualityModel * model = dateSleepQualityArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([model.dataDate integerValue]<endTime &&
                [model.dataDate integerValue]>=beginTime &&
                ![sleepTimeArr containsObject:model.dataDate]) {
                
                [sleepTimeArr addObject:model.dataDate];
                [sleepDataArray addObject:model.dataArray];
                
            }
        }
        
    }
    return sleepDataArray;
}

#pragma mark - 获取睡眠总时长
- (NSInteger)getAllSleepTimeWithSleepDataArray:(NSArray *)sleepDataArray{
    NSInteger allStateTime = 0;//总时长
    for (NSArray * model_dataArray in sleepDataArray) {
        for (NSDictionary * dict in model_dataArray) {
            //状态时长
            NSString * stateTimeStr = [dict objectForKey:@"stateTime"];
            allStateTime = allStateTime + [stateTimeStr integerValue];
            
        }
    }
    
    return allStateTime;
}

#pragma mark - 确定按钮
-(void)sure
{
    if(self.calendar.datePickerView.frame.size.height ==0)
    {
        if (self.date.length != 0)
        {
            self.dateBlock(self.date);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUI
{
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //返回btn
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"signup_icon_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(0);
        make.width.equalTo(@54);
        make.height.equalTo(@44);
        
    }];
    
    //确定btn
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:confirmButton];
    [confirmButton addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-5);
        if (NSLocalizedString(@"Submit", nil).length == 6) {
           
            make.width.equalTo(@60);
            
        }else
        {
            make.width.equalTo(@44);
        }
        
        make.height.equalTo(@44);
        
    }];
    
    //选择日期
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"SDVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
        
    }];
    
    UIImageView *bottomImageV = [[UIImageView alloc]init];
    bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
    [self.view addSubview:bottomImageV];
    [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
        
    }];
    
    UILabel *sleepTimePromptLab = [[UILabel alloc]init];
    [self.view addSubview:sleepTimePromptLab];
    sleepTimePromptLab.backgroundColor = [UIColor clearColor];
    sleepTimePromptLab.font = [UIFont systemFontOfSize:14.0];
    sleepTimePromptLab.textColor = kControllerTitleColor;
    sleepTimePromptLab.textAlignment = NSTextAlignmentCenter;
    self.sleepTimePromptLab = sleepTimePromptLab;
    [self.sleepTimePromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(bottomImageV.mas_top).offset(-20);
        make.height.equalTo(@40);
        make.left.equalTo(@15);
        make.right.equalTo(@-15);
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
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
