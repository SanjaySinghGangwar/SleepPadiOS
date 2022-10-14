//
//  MyDeviceViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "MyDeviceViewController.h"
#import "UniversalTableViewCell.h"
#import "DeviceModel.h"
#import "SearchDeviceViewController.h"
#import "AppDelegate.h"
#import "DeviceUpdateViewController.h"

@interface MyDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)UITableView *deviceTableView;
@property (strong,nonatomic)NSArray *menuArray;
@property (strong,nonatomic)DeviceModel *model;
@property (strong,nonatomic)BlueToothManager *blueToothManager;
@property (strong,nonatomic)MSCoreManager *coreManager;
@property (copy,nonatomic)NSString *hardwareVersion;
@property (copy,nonatomic)NSString *softwareVersion;
@property (assign,nonatomic)int battery;//设备电池电量
@property (assign,nonatomic)BOOL isCharge;//设备充电状态
@property (strong,nonatomic)AlertView *alertView;
@end

@implementation MyDeviceViewController
-(BlueToothManager *)blueToothManager{
    if (_blueToothManager == nil) {
        _blueToothManager = [BlueToothManager shareIsnstance];
    }
    return _blueToothManager;
}
- (void)viewDidLoad
{
    WS(weakSelf);
    [super viewDidLoad];
    
    self.coreManager = [MSCoreManager sharedManager];
    self.menuArray = @[NSLocalizedString(@"MDVC_BatteryTitle", nil),NSLocalizedString(@"MDVC_FirmwareTitle", nil),NSLocalizedString(@"MDVC_IDTitle", nil),NSLocalizedString(@"MDVC_BlueToothTitle", nil)];
    [self setUI];
    if (![BlueToothManager shareIsnstance].isConnect)
    {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        
    }else
    {
        self.blueToothManager.versionBlock = ^(NSString *hardwareVersion, NSString *softwareVersion) {
            
            weakSelf.hardwareVersion = hardwareVersion;
            weakSelf.softwareVersion = softwareVersion;
            NSString * versionNumberStr = [NSString stringWithFormat:@"v%@_%@",weakSelf.hardwareVersion,weakSelf.softwareVersion];
            //设备升级
            [weakSelf.coreManager getDeviceUpdateForData:@{@"versionNumber":versionNumberStr} WithResponse:^(ResponseInfo *info) {
                if ([info.code isEqualToString:@"200"]) {
                    [SVProgressHUD dismiss];
                    NSLog(@"info.data = %@",info.data);
//                    NSRange range = [info.data[@"versionNumber"] rangeOfString:@"_"];
//                    weaksSelf.updateVersion = [info.data[@"versionNumber"] substringFromIndex:range.location+1];
//                    weaksSelf.updateVersionLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"MDVC_NewestVersion", nil),[info.data objectForKey:@"versionNumber"]];
                    
                    NSNumber * boolNum = info.data[@"hasNewVersion"];
                    BOOL hasNewVersion = [boolNum boolValue];
                    if (hasNewVersion) {
                        //弹窗确认，固件升级
                        [weakSelf.alertView showAlertWithType:AlertType_UpData title:NSLocalizedString(@"MDVC_NewestVersionAlert", nil) menuArray:nil];
                        weakSelf.alertView.alertOkBlock = ^(AlertType type){
                            if (type == AlertType_UpData) {
                                //跳转到固件升级页面
                                DeviceUpdateViewController *update = [[DeviceUpdateViewController alloc]init];
                                update.hardwareVersion = weakSelf.hardwareVersion;
                                update.softwareVersion = weakSelf.softwareVersion;
                                update.updateBlock = ^(NSString *updateVersion) {
                                    weakSelf.softwareVersion = updateVersion;
                                    [weakSelf.deviceTableView reloadData];
                                };
                                [weakSelf.navigationController pushViewController:update animated:YES];
                            }
                        };
                    }else{
                        //当前为最新版本
                    }
                    
                }else{
                    [SVProgressHUD showErrorWithStatus:info.message];
                    [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                }
            }];
            
            
        };
        self.blueToothManager.batteryBlock = ^(int battery, BOOL isCharge)
        {
            weakSelf.battery = battery;
            weakSelf.isCharge = isCharge;
            [weakSelf.deviceTableView reloadData];
            
            if (battery < 10 && !isCharge) {
                //低电量弹框提醒
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WhetherBatteryCharging", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                }];
                [actionSheet addAction:ok];
                [weakSelf presentViewController:actionSheet animated:YES completion:nil];
            }
        };
        
        [self.blueToothManager getDeviceVersions];
        
//        [SVProgressHUD show];
    }
}
#pragma mark - 删除设备
-(void)deleteDevice{
    WS(weakSelf);
    //弹窗确认，删除设备
    [self.alertView showAlertWithType:AlertType_UnBind title:NSLocalizedString(@"MDVC_DeleteDeviceAlert", nil) menuArray:nil];
    self.alertView.alertOkBlock = ^(AlertType type){
        if (type == AlertType_UnBind) {
            if (weakSelf.blueToothManager.isConnect) {
                [weakSelf xyw_syncAllSleepData];
            }else{
                [weakSelf unBind];
            }
            
        }
    };
//    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MDVC_DeleteDeviceAlert", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakSelf unBind];
//    }];
//    [actionSheet addAction:cancel];
//    [actionSheet addAction:ok];
//    [self presentViewController:actionSheet animated:YES completion:nil];
}
-(void)unBind{
    WS(weakSelf);
    NSLog(@"网络请求中...开始解绑设备...-状态码：6");
    [self.coreManager postUnBindDeviceForData:nil WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            NSLog(@"解除绑定成功");
            
            if(weakSelf.blueToothManager.isConnect){
                NSLog(@"解除绑定成功 -- 清除本地db");
                [weakSelf.blueToothManager  deleteSleepAllDataNotify];
                NSLog(@"解除绑定成功 -- 断开连接");
                [weakSelf.blueToothManager manualCancelConnect];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"" forKey:@"lastConnectDevice"];
            [defaults synchronize];
            weakSelf.coreManager.userModel.deviceCode = @"";
            
            [SVProgressHUD showSuccessWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime completion:^{
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [app setRootViewControllerForSearch];
            }];
            
        }else{
//            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"OperationError", nil)];
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            NSLog(@"解除绑定失败");
        }
    }];
}

#pragma mark - 同步数据
- (void)xyw_syncAllSleepData{
    WS(weakSelf);
    /*同步ble数据*/
    [SVProgressHUD showWithStatus:NSLocalizedString(@"MDVC_DeleteDevice", nil)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD dismissWithDelay:kDismissWithOutTime];
    //1.清理所有数据
    //    [self.blueToothManager deleteSleepAllDataNotify];
    //3.保存成功回调中，同步睡眠数据到服务器
    self.blueToothManager.syncFinishedBlock = ^(NSArray *timeStringArr, BOOL isFinished) {
        
        if (isFinished) {
            NSLog(@"数据接收并解析完成，同步睡眠数据到服务器-状态码：2");
            
        }
        
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
                        NSLog(@"上传睡眠数据成功-状态码：3");
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        //删除设备数据(解绑设备)
                        [weakSelf.blueToothManager deleteSleepBandDataNotify];
                        [weakSelf unBind];//解绑设备
                    }else{
                        //上传失败
                        [SVProgressHUD showErrorWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    }
                }];
            }else{
                NSLog(@"没有新数据需要上传-状态码：4");
                [weakSelf unBind];//解绑设备
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }
        
        else if (isFinished && timeStringArr.count == 0){
            NSLog(@"没有新数据需要上传-状态码：5");
            
            [weakSelf unBind];//解绑设备
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    };
    //2.读取设备数据并保存数据库
    [self.blueToothManager readSleepAllDataNotifyWithAll:YES];
    NSLog(@"开始读取设备数据，发送读取设备数据指令(52)-状态码：1");
    
    //4...
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.menuArray.count;
    //屏蔽蓝牙地址
    return 3;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.menuArray[indexPath.row];
    cell.lineView.hidden = NO;
    if (indexPath.row == 0) {
        [cell setType:CellType_Vaule];
        
        if (self.isCharge) {
            if (self.battery == 100) {
                cell.valueLabel.text = [NSString stringWithFormat:@"%d%%",self.battery];
            }else{
                cell.valueLabel.text = NSLocalizedString(@"MDVC_BatteryCharge", nil);
            }
        }else{
            cell.valueLabel.text = [NSString stringWithFormat:@"%d%%",self.battery];
        }
        
//        NSString * chargeString1 = self.isCharge?@"🔋":@"";//ϟ 🔋 ⚡
//        NSString * chargeString2 = self.isCharge?NSLocalizedString(@"MDVC_BatteryCharge", nil):@"";
//        NSString * chargeString3 = self.isCharge?@"":[NSString stringWithFormat:@"%d%%",self.battery];
//        NSString * chargeString4 = self.isCharge&&self.battery==100?[NSString stringWithFormat:@"%d%%",self.battery]:@"";
//        cell.valueLabel.text = [NSString stringWithFormat:@"%@%@%@%@",chargeString1,chargeString2,chargeString3,chargeString4];
//        cell.valueLabel.text = [NSString stringWithFormat:@"%d%%%@",self.battery,chargeString];
    }else if (indexPath.row == 1){
        [cell setType:CellType_VauleArrows];
        if (self.softwareVersion.length > 0) {
            cell.valueLabel.text = [NSString stringWithFormat:@"V%@_%@",self.hardwareVersion,self.softwareVersion];
        }
    }else if (indexPath.row == 2){
        [cell setType:CellType_Vaule];
        if (self.blueToothManager.currentPeripheral.name.length > 0) {
            cell.valueLabel.text = self.blueToothManager.currentPeripheral.name;
        }else{
            cell.valueLabel.text = [MSCoreManager sharedManager].userModel.deviceCode;
        }
    }else{
        [cell setType:CellType_Vaule];
//        cell.valueLabel.text = @"fa:fa:fs:sa";
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        WS(weakSelf);
        if (self.softwareVersion.length > 0) {
            DeviceUpdateViewController *update = [[DeviceUpdateViewController alloc]init];
            update.hardwareVersion = self.hardwareVersion;
            update.softwareVersion = self.softwareVersion;
            update.updateBlock = ^(NSString *updateVersion) {
                weakSelf.softwareVersion = updateVersion;
                [weakSelf.deviceTableView reloadData];
            };
            [self.navigationController pushViewController:update animated:YES];
        }
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
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
    titleLabel.text = NSLocalizedString(@"PMVC_MyDeviceTitle", nil);
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
    
    self.deviceTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.deviceTableView];
    self.deviceTableView.backgroundColor = [UIColor clearColor];
    self.deviceTableView.showsVerticalScrollIndicator = NO;
    self.deviceTableView.delegate = self;
    self.deviceTableView.dataSource = self;
    self.deviceTableView.bounces = NO;
    [self.deviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-101);
    }];
    
    self.deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.deviceTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH-68, 250)];
    //footerView.backgroundColor = [UIColor redColor];
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake((kSCREEN_WIDTH-68)/2-22.5, 42+150, 45, 36);
    [deleteBtn setImage:[UIImage imageNamed:@"me_btn_unbounddevice"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteDevice) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:deleteBtn];
    
    UILabel *deleteBtnTitleL = [[UILabel alloc]initWithFrame:CGRectMake((kSCREEN_WIDTH-68)/2-50, 88+150, 100, 12)];
    deleteBtnTitleL.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    deleteBtnTitleL.textColor = [UIColor colorWithHexString:@"#575756"];
    deleteBtnTitleL.textAlignment = NSTextAlignmentCenter;
    deleteBtnTitleL.text = NSLocalizedString(@"MDVC_DeleteDevice", nil);
    [footerView addSubview:deleteBtnTitleL];
    
    self.deviceTableView.tableFooterView = footerView;
    
    
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
    titleLabel.text = NSLocalizedString(@"PMVC_MyDeviceTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.deviceTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.deviceTableView];
    self.deviceTableView.backgroundColor = [UIColor clearColor];
    self.deviceTableView.showsVerticalScrollIndicator = NO;
    self.deviceTableView.delegate = self;
    self.deviceTableView.dataSource = self;
    self.deviceTableView.bounces = NO;
    [self.deviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarHeight);
    }];
    
    self.deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.deviceTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(kMargin*2, 55, kSCREEN_WIDTH-kMargin*4, 45);
    deleteBtn.backgroundColor = [UIColor whiteColor];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    deleteBtn.layer.cornerRadius = textFieldCornerRadius;
    [deleteBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [deleteBtn setTitle:NSLocalizedString(@"MDVC_DeleteDevice", nil) forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteDevice) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:deleteBtn];
    self.deviceTableView.tableFooterView = footerView;
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
