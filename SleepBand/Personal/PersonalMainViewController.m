//
//  PersonalMainViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "PersonalMainViewController.h"
#import "UniversalTableViewCell.h"
#import "AccountViewController.h"
#import "AppDelegate.h"
#import "PersonalInformationViewController.h"
#import "MyDeviceViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "SleepAdviceViewController.h"
#import "InformationViewController.h"

@interface PersonalMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *myTableView;
@property (strong, nonatomic)NSArray *menuArray;
@property (strong, nonatomic)UIButton *blueToothBtn;
@property (strong, nonatomic)LeftView *leftMenuV;
@property (strong, nonatomic)BlueToothManager *blueToothManager;
@property (strong, nonatomic)MSCoreManager *corehManager;
@property (strong, nonatomic)UILabel *nameLabel;
@property (strong, nonatomic)AlertView *alertView;
@end

@implementation PersonalMainViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.mainTabBar.tabBarView.hidden = NO;
    
    [self setBlueTooth];
}

- (void)setBlueTooth{
    WS(weakSelf);
    self.blueToothManager.connectPeripheralBlock = ^(BOOL isSuccess) {
        if (weakSelf) {
            if(isSuccess)
            {
                weakSelf.blueToothBtn.selected = YES;
                
            }else
            {
                if (!weakSelf.blueToothManager.isManualCancelConnect)
                {
                    weakSelf.blueToothBtn.selected = NO;
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BTM_FailToConnectPeripheral", nil)];
                }
            }
        }
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.corehManager = [MSCoreManager sharedManager];
    self.blueToothManager = [BlueToothManager shareIsnstance];
    self.menuArray = @[NSLocalizedString(@"PMVC_SynchronousDataTitle", nil),NSLocalizedString(@"PMVC_MyDeviceTitle", nil),NSLocalizedString(@"PMVC_AccountTitle", nil),NSLocalizedString(@"PMVC_PersonalInformationTitle", nil),NSLocalizedString(@"PMVC_HelpTitle", nil),NSLocalizedString(@"PMVC_SleepAdviceTitle", nil),NSLocalizedString(@"PMVC_FeedbackTitle", nil),NSLocalizedString(@"PMVC_AboutTitle", nil)];
    
    [self setUI];
    
    self.leftMenuV.selectControllerBlock = ^(LeftMenuType type)
    {
        if (type != LeftMenuType_Me) {
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (type == LeftMenuType_Report) {
                
                [delegate setRootViewControllerForReport];
                
            }else if (type == LeftMenuType_Sleep){
                
                [delegate setRootViewControllerForSleep];
                
            }else{
                
                [delegate setRootViewControllerForClock];
            }
        }
    };
}

//获取服务器数据保存至DB
-(void)getSeverSleepData{
    WS(weakSelf);
    NSInteger size = 100;
    NSInteger time = (NSInteger)[[NSDate date] timeIntervalSince1970];
    time = time - size * 3600 * 24;
    //从服务器获取睡眠数据 time-记录开始时间 size-天数
    [[MSCoreManager sharedManager] getSleepDataFromParams:@{@"time":[NSNumber numberWithInteger:time],@"size":[NSNumber numberWithInteger:size]} WithResponse:^(ResponseInfo *info) {
        if([info.code isEqualToString:@"200"]){
            //获取成功
            NSLog(@"获取服务器睡眠数据成功");
            NSArray * dataArr = [info.data objectForKey:@"list"];
            if (dataArr.count > 0) {
                [weakSelf saveServerSleepDataWith:dataArr];
                NSLog(@"保存服务器睡眠数据至数据库成功");
                
            }
            [SVProgressHUD showSuccessWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            
        }else{
            //获取失败
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
    
}

//保存服务器睡眠数据至db
-(void)saveServerSleepDataWith:(NSArray*)dataArr{
    NSString * deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
    for (int i = 0; i<dataArr.count; i++) {
        NSDictionary * dataDict = dataArr[i];
        NSString * time = [dataDict objectForKey:@"time"];
        NSArray * arr;
        //睡眠质量
        arr = [SleepQualityModel searchWithWhere:@{@"dataDate":time,@"deviceName":deviceName}];
        if (arr.count == 0 && ![[dataDict objectForKey:@"dataForSleep"] isKindOfClass:[NSNull class]]){
            SleepQualityModel * sleepQualityModel = [[SleepQualityModel alloc]init];
            sleepQualityModel.deviceName = deviceName;
            sleepQualityModel.dataDate = time;
            sleepQualityModel.dataArray = [dataDict objectForKey:@"dataForSleep"];
            [sleepQualityModel saveToDB];
        }
        //心率
        arr = [HeartRateModel searchWithWhere:@{@"dataDate":time,@"deviceName":deviceName}];
        if (arr.count == 0 && ![[dataDict objectForKey:@"dataForHeart"] isKindOfClass:[NSNull class]]){
            HeartRateModel * heartRateModel = [[HeartRateModel alloc]init];
            heartRateModel.deviceName = deviceName;
            heartRateModel.dataDate = time;
            heartRateModel.dataArray = [dataDict objectForKey:@"dataForHeart"];
            [heartRateModel saveToDB];
        }
        //呼吸率
        arr = [RespiratoryRateModel searchWithWhere:@{@"dataDate":time,@"deviceName":deviceName}];
        if (arr.count == 0 && ![[dataDict objectForKey:@"dataForBreath"] isKindOfClass:[NSNull class]]){
            RespiratoryRateModel * respiratoryRateModel = [[RespiratoryRateModel alloc]init];
            respiratoryRateModel.deviceName = deviceName;
            respiratoryRateModel.dataDate = time;
            respiratoryRateModel.dataArray = [dataDict objectForKey:@"dataForBreath"];
            [respiratoryRateModel saveToDB];
        }
        //翻身
        arr = [TurnOverModel searchWithWhere:@{@"dataDate":time,@"deviceName":deviceName}];
        if (arr.count == 0 && ![[dataDict objectForKey:@"dataForTurnOver"] isKindOfClass:[NSNull class]]){
            TurnOverModel * turnOverModel = [[TurnOverModel alloc]init];
            turnOverModel.deviceName = deviceName;
            turnOverModel.dataDate = time;
            turnOverModel.dataArray = [dataDict objectForKey:@"dataForTurnOver"];
            [turnOverModel saveToDB];
        }
        
    }
    
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setType:CellType_Arrows];
    cell.lineView.hidden = NO;
    cell.titleLabel.text = self.menuArray[indexPath.row];
    return cell;
}
-(void)tabBarViewHidden{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.mainTabBar.tabBarView.hidden == NO) {
        delegate.mainTabBar.tabBarView.hidden = YES;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    switch (indexPath.row) {
        case PersonalType_SynchronousData:{
            [self getSeverSleepData];//获取服务器数据保存至DB
        }
            break;
        case PersonalType_MyDevice:{
            MyDeviceViewController *device = [[MyDeviceViewController alloc]init];
            [self tabBarViewHidden];
            [self.navigationController pushViewController:device animated:YES];
        }
            break;
        case PersonalType_Account:{
            AccountViewController *account = [[AccountViewController alloc]init];
            [self tabBarViewHidden];
            [self.navigationController pushViewController:account animated:YES];
        }
            break;
        case PersonalType_PersonalInformation:{
            PersonalInformationViewController *information = [[PersonalInformationViewController alloc]init];
            information.personalInformationNameBlock = ^(NSString *string) {
                weakSelf.nameLabel.text = [NSString stringWithFormat:@"%@!",string];
            };
            [self tabBarViewHidden];
            [self.navigationController pushViewController:information animated:YES];
        }
            break;
        case PersonalType_Help:{
            HelpViewController *help = [[HelpViewController alloc]init];
            [self tabBarViewHidden];
            [self.navigationController pushViewController:help animated:YES];
        }
            break;
        case PersonalType_SleepAdvice:{
            SleepAdviceViewController *sleepAdvice = [[SleepAdviceViewController alloc]init];
            [self tabBarViewHidden];
            [self.navigationController pushViewController:sleepAdvice animated:YES];
        }
            break;
        case PersonalType_Feedback:{
            InformationViewController *info = [[InformationViewController alloc]init];
            info.navTitleStr = self.menuArray[indexPath.row];
            info.isFeedback = YES;
            [self tabBarViewHidden];
            [self.navigationController pushViewController:info animated:YES];
        }
            break;
        case PersonalType_About:{
            AboutViewController *about = [[AboutViewController alloc]init];
            [self tabBarViewHidden];
            [self.navigationController pushViewController:about animated:YES];
        }
            break;
        default:
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
}
-(void)menuBtnTouch{
    if (self.leftMenuV.hidden) {
        [self.leftMenuV showView];
    }else{
        [self.leftMenuV hiddenView];
    }
}
-(void)blueTooth:(UIButton *)sender{
    if (!sender.selected) {
        //连接蓝牙
        [self connectPeripheral];
    }else{
        //断开蓝牙
        WS(weakSelf);
        //弹窗确认，断开设备连接
        [self.alertView showAlertWithType:AlertType_Disconnect title:NSLocalizedString(@"BTM_DeviceFailToConnect", nil) menuArray:nil];
        self.alertView.alertOkBlock = ^(AlertType type){
            if (type == AlertType_Disconnect && weakSelf.blueToothManager.isConnect) {
                [weakSelf.blueToothManager cancelConnect];//断开连接
            }
        };
    }
}
-(void)connectPeripheral{
    if(self.blueToothManager.centralManagerState == 5){
//        [SVProgressHUD showWithStatus:NSLocalizedString(@"BTM_DeviceMonitoring", nil)];
//        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        if (self.blueToothManager.currentPeripheral) {
            [self.blueToothManager connectCurrentPeripheral];
        }else{
            [self.blueToothManager scanAllPeripheral];
        }
    }else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothClose", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}
#pragma mark - 设置界面UI
-(void)setUI{
    WS(weakSelf);
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    self.blueToothBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.blueToothBtn setImage:[UIImage imageNamed:@"sleep_icon_ununited"] forState:UIControlStateNormal];
    [self.blueToothBtn setImage:[UIImage imageNamed:@"sleep_icon_connect"] forState:UIControlStateSelected];
    if (self.blueToothManager.isConnect)
    {
        self.blueToothBtn.selected = YES;
        
    }else
    {
       self.blueToothBtn.selected = NO;
    }
    [self.view addSubview:self.blueToothBtn];
    [self.blueToothBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(0);
        make.height.equalTo(@44);
        make.width.equalTo(@54);
    }];
    [self.blueToothBtn addTarget:self action:@selector(blueTooth:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *hiLabel = [[UILabel alloc]init];
    hiLabel.text = NSLocalizedString(@"PMVC_Hi", nil);
    hiLabel.textColor = [UIColor colorWithHexString:@"#9ED0DB"];
    hiLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightBold];
    [self.view addSubview:hiLabel];
    CGSize hiTextSize = [hiLabel.text sizeWithAttributes:@{NSFontAttributeName:hiLabel.font}];
    [hiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+60);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.width.equalTo(@(hiTextSize.width+1));
        make.height.equalTo(@29);
    }];
    
    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.text = [NSString stringWithFormat:@"%@!",self.corehManager.userModel.userName];
    self.nameLabel.textColor = [UIColor colorWithHexString:@"#9ED0DB"];
    self.nameLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightBold];
    [self.view addSubview:self.nameLabel];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+60);
        make.left.mas_equalTo(hiLabel.mas_right).offset(0);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.height.equalTo(@29);
    }];
    
    UIView *lineView = [[UIView alloc]init];
    [self.view addSubview:lineView];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#d8d5d3"];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+119);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.height.equalTo(@1);
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
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.myTableView];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.bounces = NO;
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+120);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-101);
    }];
    
    UIView *footerView = [[UIView alloc]init];
    self.myTableView.tableFooterView = footerView;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.myTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    self.leftMenuV = [[LeftView alloc]init];
    [self.view addSubview:self.leftMenuV];
    [self.leftMenuV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(weakSelf.view);
    }];
    self.leftMenuV.hidden = YES;
    
    self.alertView = [[AlertView alloc]init];
//    [self.view addSubview:self.alertView];
//    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.bottom.equalTo(weakSelf.view);
//    }];
    
}
-(void)setUI2{
    WS(weakSelf);
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.myTableView];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.bounces = NO;
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarHeight);
    }];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 218)];
    self.myTableView.tableHeaderView = headerView;
    
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"my_icon"]];
    [headerView addSubview:logo];
    float width = 88;
    //    logo.layer.cornerRadius = width/2;
    //    logo.backgroundColor = [UIColor whiteColor];
    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerView);
        make.width.height.equalTo(@(width));
    }];
    
    UIView *footerView = [[UIView alloc]init];
    self.myTableView.tableFooterView = footerView;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.myTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
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
