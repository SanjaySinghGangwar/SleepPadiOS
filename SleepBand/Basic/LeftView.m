//
//  LeftView.m
//  SleepBand
//
//  Created by admin on 2019/2/12.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "LeftView.h"
#import "AppDelegate.h"

@implementation LeftView
-(instancetype)init
{
    if(self = [super init]){
        
        [self setUI];
    }
    return self;
}


-(void)setUI
{
    WS(weakSelf);
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor lightGrayColor];
    bgView.alpha = 0.5;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(weakSelf);
    }];
    [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView)]];
    
    
    //
    self.menuView = [[UIView alloc]init];
    [self addSubview:self.menuView];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset(kStatusBarHeight+44+32);
        make.left.equalTo(weakSelf);
        make.width.equalTo(@365.5);
        make.height.equalTo(@472);
    }];
    [self.menuView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView)]];
    
    
    //
    UIImageView *menuBgIv = [[UIImageView alloc]init];
    menuBgIv.image = [UIImage imageNamed:@"menu_bg"];
    [self.menuView addSubview:menuBgIv];
    [menuBgIv mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.equalTo(weakSelf.menuView);
        
    }];
    
    
    //
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.menuView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.menuView.mas_top).offset(118);
        make.left.mas_equalTo(weakSelf.menuView.mas_left).offset(34);
        make.width.equalTo(@154);
        make.height.equalTo(@1);
        
    }];
    
    
    //
    UIView *sleepView = [[UIView alloc]init];
    [self.menuView addSubview:sleepView];
    [sleepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@215);
        make.height.equalTo(@54);
    }];
    [sleepView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushSleepView)]];
    
    
    //
    UIImageView *sleepIv = [[UIImageView alloc]init];
    sleepIv.image = [UIImage imageNamed:@"menu_icon_sleep"];
    [sleepView addSubview:sleepIv];
    [sleepIv mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(sleepView.mas_left).offset(6);
        make.centerY.equalTo(sleepView);
        make.width.height.equalTo(@31);
        
    }];
    
    //
    UILabel *sleepL = [[UILabel alloc]init];
    sleepL.textAlignment = NSTextAlignmentLeft;
    sleepL.textColor = [UIColor whiteColor];
    sleepL.font = [UIFont systemFontOfSize:14];
    sleepL.text = NSLocalizedString(@"SMVC_Title", nil);
    [sleepView addSubview:sleepL];
    [sleepL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(sleepIv.mas_right).offset(22);
        make.right.mas_equalTo(sleepView.mas_right).offset(0);
        make.centerY.height.equalTo(sleepView);
        
    }];
    
    //
    UIView *sleepLineView = [[UIView alloc]init];
    sleepLineView.backgroundColor = [UIColor whiteColor];
    [self.menuView addSubview:sleepLineView];
    [sleepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(sleepView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@242);
        make.height.equalTo(@1);
        
    }];
    
    
    UIView *reportView = [[UIView alloc]init];
    [self.menuView addSubview:reportView];
    [reportView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(sleepLineView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@265);
        make.height.equalTo(@54);
        
    }];
    [reportView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushReportView)]];
    
    UIImageView *reportIv = [[UIImageView alloc]init];
    reportIv.image = [UIImage imageNamed:@"menu_icon_report"];
    [reportView addSubview:reportIv];
    [reportIv mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(reportView.mas_left).offset(6);
        make.centerY.equalTo(reportView);
        make.width.height.equalTo(@31);
        
    }];
    
    UILabel *reportL = [[UILabel alloc]init];
    reportL.textAlignment = NSTextAlignmentLeft;
    reportL.textColor = [UIColor whiteColor];
    reportL.font = [UIFont systemFontOfSize:14];
    reportL.text = NSLocalizedString(@"RMVC_Title", nil);
    [reportView addSubview:reportL];
    [reportL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(reportIv.mas_right).offset(22);
        make.right.mas_equalTo(reportView.mas_right).offset(0);
        make.centerY.height.equalTo(reportView);
        
    }];
    
    UIView *reportLineView = [[UIView alloc]init];
    reportLineView.backgroundColor = [UIColor whiteColor];
    [self.menuView addSubview:reportLineView];
    [reportLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(reportView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@312);
        make.height.equalTo(@1);
        
    }];
    
    
    UIView *alarmView = [[UIView alloc]init];
    [self.menuView addSubview:alarmView];
    [alarmView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(reportLineView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@270);
        make.height.equalTo(@54);
        
    }];
    [alarmView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushAlarmView)]];
    
    UIImageView *alarmIv = [[UIImageView alloc]init];
    alarmIv.image = [UIImage imageNamed:@"menu_icon_alarm"];
    [alarmView addSubview:alarmIv];
    [alarmIv mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(alarmView.mas_left).offset(6);
        make.centerY.equalTo(alarmView);
        make.width.height.equalTo(@31);
        
    }];
    
    
    //闹钟
    UILabel *alarmL = [[UILabel alloc]init];
    alarmL.textAlignment = NSTextAlignmentLeft;
    alarmL.textColor = [UIColor whiteColor];
    alarmL.font = [UIFont systemFontOfSize:14];
    alarmL.text = NSLocalizedString(@"ACMVC_Title", nil);
    [alarmView addSubview:alarmL];
    [alarmL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(alarmIv.mas_right).offset(22);
        make.right.mas_equalTo(alarmView.mas_right).offset(0);
        make.centerY.height.equalTo(alarmView);
    }];
    
    UIView *alarmLineView = [[UIView alloc]init];
    alarmLineView.backgroundColor = [UIColor whiteColor];
    [self.menuView addSubview:alarmLineView];
    [alarmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(alarmView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@270);
        make.height.equalTo(@1);
        
    }];
    
    UIView *meView = [[UIView alloc]init];
    [self.menuView addSubview:meView];
    [meView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(alarmLineView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@242);
        make.height.equalTo(@54);
        
    }];
    [meView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushMeView)]];
    
    UIImageView *meIv = [[UIImageView alloc]init];
    meIv.image = [UIImage imageNamed:@"menu_icon_me"];
    [meView addSubview:meIv];
    [meIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(meView.mas_left).offset(6);
        make.centerY.equalTo(meView);
        make.width.height.equalTo(@31);
    }];
    
    UILabel *meL = [[UILabel alloc]init];
    meL.textAlignment = NSTextAlignmentLeft;
    meL.textColor = [UIColor whiteColor];
    meL.font = [UIFont systemFontOfSize:14];
    meL.text = NSLocalizedString(@"PMVC_Title", nil);
    [meView addSubview:meL];
    [meL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(meIv.mas_right).offset(22);
        make.right.mas_equalTo(meView.mas_right).offset(0);
        make.centerY.height.equalTo(meView);
    }];
    
    UIView *meLineView = [[UIView alloc]init];
    meLineView.backgroundColor = [UIColor whiteColor];
    [self.menuView addSubview:meLineView];
    [meLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(meView.mas_bottom).offset(0);
        make.left.equalTo(lineView);
        make.width.equalTo(@242);
        make.height.equalTo(@1);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    float centerX = self.menuView.bounds.size.width/2;
    float centerY = self.menuView.bounds.size.height/2;
    float x = 0;
    float y = 0;
    CGAffineTransform trans = GetCGAffineTransformRotateAroundPoint(centerX,centerY ,x,y,50.0/180.0*M_PI);
    self.menuView.transform = trans;
    
}


CGAffineTransform  GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle)
{
    x = x - centerX; //计算(x,y)从(0,0)为原点的坐标系变换到(CenterX ，CenterY)为原点的坐标系下的坐标
    y = y - centerY; //(0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样
    
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}

//显示左边
-(void)showView
{
    WS(weakSelf);
    self.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        weakSelf.menuView.transform = CGAffineTransformIdentity;
        
//        float centerX = weakSelf.menuView.bounds.size.width/2;
//        float centerY = weakSelf.menuView.bounds.size.height/2;
//        NSLog(@"showView:%f,%f",centerX,centerY);
//        weakSelf.leftMenuBool = NO;
    }];
}

//隐藏左边
-(void)hiddenView
{
    WS(weakSelf);
    if (!self.leftMenuBool)
    {
//        [UIView animateWithDuration:0.3f animations:^{
            float centerX = weakSelf.menuView.bounds.size.width/2;
            float centerY = weakSelf.menuView.bounds.size.height/2;
//            NSLog(@"hiddenView:%f,%f",centerX,centerY);
            float x = 0;
            float y = 0;
            CGAffineTransform trans = GetCGAffineTransformRotateAroundPoint(centerX,centerY ,x,y,50.0/180.0*M_PI);
            self.menuView.transform = trans;
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.5f animations:^{
                self.hidden = YES;
//            }];
//        }];
    }
    //    else{
    //        [self showView];
    //    }
}


-(void)pushSleepView
{
    [self hiddenView];
    self.selectControllerBlock(LeftMenuType_Sleep);
}

-(void)pushReportView
{
    [self hiddenView];
    self.selectControllerBlock(LeftMenuType_Report);
    
}

-(void)pushAlarmView
{
    [self hiddenView];
    self.selectControllerBlock(LeftMenuType_Clock);
}

-(void)pushMeView
{
    [self hiddenView];
    self.selectControllerBlock(LeftMenuType_Me);
}

@end
