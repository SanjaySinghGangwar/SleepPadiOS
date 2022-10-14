//
//  AutoSleepSettingViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/24.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AutoSleepSettingViewController.h"

@interface AutoSleepSettingViewController ()

@property (strong,nonatomic)UIView *datePickerView;
@property (strong,nonatomic)UIDatePicker *datePicker;
@property (strong,nonatomic)UIButton *switchBtn;

@end

@implementation AutoSleepSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];
    
    [self getAutoSleepTime];
    
}

-(void)getAutoSleepTime
{
    NSString *sleepTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"sleepTime"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:sleepTime];
    [self.datePicker setDate:date animated:NO];
}

#pragma mark - 保存sd
-(void)save
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSString *dateStr = [formatter  stringFromDate:self.datePicker.date];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dateStr forKey:@"sleepTime"];
    
    //发送通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"sleepTime" object:dateStr userInfo:nil];
    
    if([[defaults objectForKey:@"AutoSleepMonitor"] intValue] != self.switchBtn.selected){
        
        [defaults setObject:[NSString stringWithFormat:@"%d",self.switchBtn.selected] forKey:@"AutoSleepMonitor"];
        [center postNotificationName:@"AutoSleepMonitor" object:[NSString stringWithFormat:@"%d",self.switchBtn.selected] userInfo:nil];
        
    }
    [defaults synchronize];
    
    [self back];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setDatePickerViewUI
{
    WS(weakSelf);
    
    UIView *pickerBgView = [[UIView alloc]init];
    pickerBgView.backgroundColor = [UIColor whiteColor];
    pickerBgView.alpha = kAlpha;
    [self.view addSubview:pickerBgView];
    [pickerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+83);
        make.height.equalTo(@34);
    }];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.backgroundColor = [UIColor clearColor];
    //    //设置地区: zh-中国 
    //    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    [self.datePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    [self.datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.height.equalTo(@(200));
    }];
    //清楚分割线
    //    [self clearSeparatorWithView:self.datePicker];
}

-(void)dateChange:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSString *dateStr = [NSString stringWithFormat:@"%@:00",[[formatter  stringFromDate:sender.date] substringToIndex:2]];
    NSDate *date = [formatter dateFromString:dateStr];
    [self.datePicker setDate:date animated:NO];
}

-(void)setUI
{
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.bottom.right.equalTo(weakSelf.view);
        
    }];
    
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
    titleLabel.text = NSLocalizedString(@"ASSVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
        
    }];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:saveButton];
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(0);
        make.width.equalTo(@50);
        make.height.equalTo(@44);
        
    }];
    
    [self setDatePickerViewUI];
    
    UIView *autoView = [[UIView alloc]init];
    autoView.alpha = kAlpha;
    autoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:autoView];
    [autoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+244);
        make.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@(textFieldHeight));
        
    }];
    
    UILabel *autoTitle = [[UILabel alloc]init];
    [self.view addSubview:autoTitle];
    autoTitle.textAlignment = NSTextAlignmentLeft;
    autoTitle.textColor = [UIColor whiteColor];
    autoTitle.text = NSLocalizedString(@"ASSVC_Title", nil);
    autoTitle.font = [UIFont systemFontOfSize:16];
    [autoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(autoView.mas_left).offset(kMargin);
        make.top.equalTo(autoView);
        make.height.equalTo(@(textFieldHeight));
        make.width.equalTo(@200);
        
    }];
    
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.switchBtn];
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"clock_switch_off"] forState:UIControlStateNormal];
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"clock_switch_on"] forState:UIControlStateSelected];
    [self.switchBtn addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@38.5);
        make.height.equalTo(@27.5);
        make.centerY.equalTo(autoView);
        make.right.mas_equalTo(autoView.mas_right).offset(-10);
        
    }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.switchBtn.selected = [[defaults objectForKey:@"AutoSleepMonitor"] intValue];
    
    UILabel *messageTitle = [[UILabel alloc]init];
    [self.view addSubview:messageTitle];
    messageTitle.textAlignment = NSTextAlignmentLeft;
    messageTitle.textColor = [UIColor whiteColor];
    messageTitle.text = NSLocalizedString(@"ASSVC_Message", nil);
    messageTitle.font = [UIFont systemFontOfSize:14];
    [messageTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
        make.top.mas_equalTo(autoView.mas_bottom).offset(10);
        make.height.equalTo(@20);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
        
    }];
    
}

-(void)switchBtn:(UIButton *)sender
{
    sender.selected = sender.selected ? NO:YES;
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
