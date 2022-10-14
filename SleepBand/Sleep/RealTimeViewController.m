//
//  RealTimeViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/16.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "RealTimeViewController.h"
#import "AppDelegate.h"
#import "DrawView.h"

#define drawViewHeight 240

@interface RealTimeViewController ()

@property (copy,nonatomic)NSString *heartRateValueStr;
@property (strong,nonatomic)UILabel *heartRateValueL;
@property (copy,nonatomic)NSString *respiratoryRateValueStr;
@property (strong,nonatomic)UILabel *respiratoryRateValueL;
@property (strong,nonatomic)BlueToothManager *manager;
@property (strong,nonatomic)NSMutableArray *hrSampleArray;
@property (strong,nonatomic)NSMutableArray *rrSampleArray;
@property (strong,nonatomic)DrawView *hrSampleView;
@property (strong,nonatomic)DrawView *rrSampleView;

//report
//@property (strong,nonatomic)DrawView *rtSampleView;


@end

@implementation RealTimeViewController

-(BlueToothManager *)manager
{
    if (_manager == nil)
    {
        _manager = [BlueToothManager shareIsnstance];
    }
    return _manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hrSampleArray = [[NSMutableArray alloc]init];
    self.rrSampleArray = [[NSMutableArray alloc]init];
    
    [self setUI];
    
    WS(weakSelf);
    self.manager.HrRrBlock = ^(NSString *HR, NSString *RR)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (HR == nil)
            {
                weakSelf.heartRateValueStr = @"--";
                
            }else
            {
                weakSelf.heartRateValueStr = [HR isEqualToString:@"0"] ? @"--":HR;
                
            }
            if (RR == nil)
            {
                weakSelf.respiratoryRateValueStr = @"--";
                
            }else
            {
                weakSelf.respiratoryRateValueStr = [RR isEqualToString:@"0"] ? @"--":RR;
            }
            
            [weakSelf setHeartRateValue];//心率
            
            [weakSelf setRespiratoryRateValue];//呼吸率
            
        });
    };
    
   [self getHrRrSample];
}


#pragma mark --获取心率/呼吸率实时采样值
//获取心率/呼吸率实时采样值
-(void)getHrRrSample
{
    WS(weakSelf);
    self.manager.HrRrSampleBlock = ^(NSArray *HRSample, NSArray *RRSample)
    {
        
        NSLog(@"实时 HRSample=%ld,RRSample=%ld",HRSample.count,RRSample.count);
        [weakSelf.hrSampleView addData:HRSample];//心率
        
        [weakSelf.rrSampleView addData:RRSample];//呼吸率
    
    };
    // 心率/呼吸率绘图(打开)
    [self.manager openRealTimeHrRrSampleNotify];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.manager openRealTimeHrRrNotify];
    });
}

#pragma mark --返回
-(void)back{
    [self.manager closeRealTimeHrRrNotify];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //心率/呼吸率绘图(关闭)
        [self.manager closeRealTimeHrRrSampleNotify];
    });
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark --UI
-(void)setUI
{
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"signup_icon_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(0);
        make.width.equalTo(@54);
        make.height.equalTo(@44);
        
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"RTVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
         
    }];
    
    UIView *hrTitleView = [[UIView alloc]init];
    [self.view addSubview:hrTitleView];
    
    UIImageView *hrTitleIV = [[UIImageView alloc]init];
    [hrTitleView addSubview:hrTitleIV];
    hrTitleIV.image = [UIImage imageNamed:@"realtime_icon_heartrate"];
    [hrTitleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.equalTo(hrTitleView);
        make.width.height.equalTo(@15);
        
    }];
    
    UILabel *hrTitleL = [[UILabel alloc]init];
    [hrTitleView addSubview:hrTitleL];
    hrTitleL.text = NSLocalizedString(@"RTVC_HeartRateTitle", nil);
    hrTitleL.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    hrTitleL.textAlignment = NSTextAlignmentCenter;
    hrTitleL.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    
    CGSize hrTitleSize = [hrTitleL.text sizeWithAttributes:@{NSFontAttributeName:hrTitleL.font}];
    [hrTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(15+6+hrTitleSize.width+1));
        make.height.equalTo(@15);
        make.centerX.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+20);
        
    }];
    
    [hrTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(hrTitleSize.width+1));
        make.centerY.equalTo(hrTitleView);
        make.left.mas_equalTo(hrTitleIV.mas_right).offset(6);
        
    }];
    
    UIImageView *hrBgImageV = [[UIImageView alloc]init];
//    hrBgImageV.backgroundColor = [UIColor red];
    hrBgImageV.image = [UIImage imageNamed:@"realtime_bg_heartrate"];
    [self.view addSubview:hrBgImageV];
    [hrBgImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@232);
        
    }];
    
    self.heartRateValueL = [[UILabel alloc]init];
    [self.view addSubview:self.heartRateValueL];
    self.heartRateValueL.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    self.heartRateValueL.textAlignment = NSTextAlignmentRight;
    
    //测试数据
    self.heartRateValueStr = @"--";
    
    [self setHeartRateValue];//心率
    
    [self.heartRateValueL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(hrBgImageV.mas_right).offset(-250);
        make.top.mas_equalTo(hrBgImageV.mas_top).offset(56);
        make.right.mas_equalTo(hrBgImageV.mas_right).offset(-50);
        make.height.equalTo(@15);

    }];
    //横线宽度272
    
    
    //画实时心率-线
    self.hrSampleView = [[DrawView alloc]init];
    self.hrSampleView.isRR = NO;
    [self.hrSampleView drawSampleView];//心率-线
    [self.view addSubview:self.hrSampleView];
    [self.hrSampleView mas_makeConstraints:^(MASConstraintMaker *make)
     {
        make.top.mas_equalTo(hrBgImageV.mas_top).offset(89);
        make.width.equalTo(@272);
        make.centerX.equalTo(hrBgImageV);
        make.height.equalTo(@105);
         
    }];
    
    
    //呼吸率
    UIView *rrTitleView = [[UIView alloc]init];
    [self.view addSubview:rrTitleView];
    
    UIImageView *rrTitleIV = [[UIImageView alloc]init];
    [rrTitleView addSubview:rrTitleIV];
    rrTitleIV.image = [UIImage imageNamed:@"realtime_icon_breath"];
    [rrTitleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.equalTo(rrTitleView);
        make.width.height.equalTo(@15);
        
    }];
    
    UILabel *rrTitleL = [[UILabel alloc]init];
    [rrTitleView addSubview:rrTitleL];
    rrTitleL.text = NSLocalizedString(@"RTVC_RespiratoryRateTitle", nil);
    rrTitleL.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    rrTitleL.textAlignment = NSTextAlignmentCenter;
    rrTitleL.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    
    CGSize rrTitleSize = [rrTitleL.text sizeWithAttributes:@{NSFontAttributeName:rrTitleL.font}];
    [rrTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(15+6+rrTitleSize.width+1));
        make.height.equalTo(@15);
        make.centerX.equalTo(weakSelf.view);
        make.top.mas_equalTo(hrBgImageV.mas_bottom).offset(20);
        
    }];
    
    
    [rrTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@(rrTitleSize.width+1));
        make.centerY.equalTo(rrTitleView);
        make.left.mas_equalTo(rrTitleIV.mas_right).offset(6);
        
    }];
    
    
    UIImageView *rrBgImageV = [[UIImageView alloc]init];
    rrBgImageV.image = [UIImage imageNamed:@"realtime_bg_breath"];
    [self.view addSubview:rrBgImageV];
    [rrBgImageV mas_makeConstraints:^(MASConstraintMaker *make)
     {
        make.top.mas_equalTo(hrBgImageV.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@232);
         
    }];
    
    self.respiratoryRateValueL = [[UILabel alloc]init];
    [self.view addSubview:self.respiratoryRateValueL];
    self.respiratoryRateValueL.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    self.respiratoryRateValueL.textAlignment = NSTextAlignmentRight;
    //测试数据
    self.respiratoryRateValueStr = @"--";
    
    [self setRespiratoryRateValue];//呼吸率
    
    [self.respiratoryRateValueL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(rrBgImageV.mas_right).offset(-250);
        make.top.mas_equalTo(rrBgImageV.mas_top).offset(56);
        make.right.mas_equalTo(rrBgImageV.mas_right).offset(-50);
        make.height.equalTo(@15);
        
    }];
    
    //画实时呼吸率-线
    self.rrSampleView = [[DrawView alloc]init];
    self.rrSampleView.isRR = YES;
    [self.rrSampleView drawSampleView];//呼吸率-线
    [self.view addSubview:self.rrSampleView];
    
    [self.rrSampleView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.mas_equalTo(rrBgImageV.mas_top).offset(89);
        make.width.equalTo(@272);
        make.centerX.equalTo(rrBgImageV);
        make.height.equalTo(@105);
        
    }];
    
    //底部image
    if (kSCREEN_WIDTH > 320) {
        UIImageView *bottomImageV = [[UIImageView alloc]init];
        bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
        [self.view addSubview:bottomImageV];
        [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
             make.centerX.equalTo(weakSelf.view);
             make.width.equalTo(@375);
             make.height.equalTo(@101);
             
         }];
    }
    
    
    
    
}

#pragma mark -- 心率
-(void)setHeartRateValue
{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",self.heartRateValueStr,NSLocalizedString(@"SMVC_HeartRateUnit", nil)]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:15.0]
                          range:NSMakeRange(0, self.heartRateValueStr.length)];
    if (NSLocalizedString(@"SMVC_HeartRateUnit", nil).length == 3) {
        
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:10.0]
                              range:NSMakeRange(self.heartRateValueStr.length,3)];
        
    }else
    {
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:10.0]
                              range:NSMakeRange(self.heartRateValueStr.length,5)];
    }
    self.heartRateValueL.attributedText = AttributedStr;
    
}

#pragma mark --呼吸率
-(void)setRespiratoryRateValue
{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",self.respiratoryRateValueStr,NSLocalizedString(@"SMVC_HeartRateUnit", nil)]];
    
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:15.0]
                          range:NSMakeRange(0, self.heartRateValueStr.length)];
    
    if (NSLocalizedString(@"SMVC_HeartRateUnit", nil).length == 3)
    {
        
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:10.0]
                              range:NSMakeRange(self.respiratoryRateValueStr.length,3)];
    }else
    {
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:10.0]
                              range:NSMakeRange(self.respiratoryRateValueStr.length,5)];
        
    }
    self.respiratoryRateValueL.attributedText = AttributedStr;
    
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
