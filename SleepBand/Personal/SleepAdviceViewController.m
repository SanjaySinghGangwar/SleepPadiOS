//
//  SleepAdviceViewController.m
//  SleepBand
//
//  Created by admin on 2018/12/12.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SleepAdviceViewController.h"
#import "UniversalTableViewCell.h"
#import "InformationViewController.h"

@interface SleepAdviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)UITableView *tableView;
@property (strong,nonatomic)NSArray *titleArray;
@property (strong,nonatomic)NSArray *infoArray;
@end

@implementation SleepAdviceViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArray = @[NSLocalizedString(@"SAVC_SleepQualityTitle", nil),NSLocalizedString(@"SAVC_WhatAreTheStagesOfSleepTitle", nil),NSLocalizedString(@"SAVC_NationalSleepFoundationSleepDurationRecommendationsTitle", nil),NSLocalizedString(@"SAVC_AdvicesForFallAsleepQuicklyTitle", nil),NSLocalizedString(@"SAVC_RespiratoryRateTitle", nil),NSLocalizedString(@"SAVC_HeartRateTitle", nil)];
    self.infoArray = @[NSLocalizedString(@"SAVC_Info1", nil),NSLocalizedString(@"SAVC_Info2", nil),NSLocalizedString(@"SAVC_Info3", nil),NSLocalizedString(@"SAVC_Info4", nil),NSLocalizedString(@"SAVC_Info5", nil),NSLocalizedString(@"SAVC_Info6", nil)];
    [self setUI];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.isInfo = YES;
    cell.lineView.hidden = NO;
    [cell setType:CellType_Arrows];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationViewController *info = [[InformationViewController alloc]init];
    info.navTitleStr = NSLocalizedString(@"PMVC_SleepAdviceTitle", nil);
    info.titleStr = self.titleArray[indexPath.row];
    info.valueStr = self.infoArray[indexPath.row];
    [self.navigationController pushViewController:info animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}
-(void)tableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
}
-(void)setUI{
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
    titleLabel.text = NSLocalizedString(@"PMVC_SleepAdviceTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-101);
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    //    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    //    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    logoutBtn.frame = CGRectMake(kMargin*2, 55, kSCREEN_WIDTH-kMargin*4, 45);
    //    logoutBtn.backgroundColor = [UIColor whiteColor];
    //    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    //    logoutBtn.layer.cornerRadius = textFieldCornerRadius;
    //    [logoutBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    //    [logoutBtn setTitle:NSLocalizedString(@"AVC_Logout", nil) forState:UIControlStateNormal];
    //    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    //    [footerView addSubview:logoutBtn];
    //    self.tableView.tableFooterView = footerView;
    
    UIImageView *bottomImageV = [[UIImageView alloc]init];
    bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
    [self.view addSubview:bottomImageV];
    [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
    }];
    
    
    
}

@end
