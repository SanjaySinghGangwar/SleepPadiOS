//
//  SearchDeviceViewController.m
//  QLife
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SearchDeviceViewController.h"
#import "DeviceCell.h"
#import "AppDelegate.h"
#import "PeripheralModel.h"


@interface SearchDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) BlueToothManager *manager;
@property (nonatomic,strong) NSMutableArray *deviceArray;
@property (nonatomic,strong) IBOutlet UITableView *deviceTableView;
@property (nonatomic,assign) BOOL isSelect;
@property (copy,nonatomic)NSString *macAddress;
@property (strong,nonatomic)NSTimer *sendTimer;
@property (assign,nonatomic)int sendTime;
@property (strong,nonatomic)UIImageView *topView;

@property (strong,nonatomic)NSArray *imageArray;
@property (assign,nonatomic)int imageNum;

@end

@implementation SearchDeviceViewController
-(void)dealloc{
    [self.sendTimer invalidate];
    self.sendTimer = nil;
}
-(NSMutableArray *)deviceArray{
    if (_deviceArray == nil) {
        _deviceArray = [[NSMutableArray alloc]init];
    }
    return _deviceArray;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self scanDevice];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.manager = [BlueToothManager shareIsnstance];
    self.manager.isScan = NO;
    self.sendTime = 15;
    [self.manager.scanPeripheralArray removeAllObjects];
    [self setUI];
    WS(weakSelf);
    [self.deviceArray removeAllObjects];
    self.manager.scanPeripheralBlock = ^(PeripheralModel *model) {
        
        if (weakSelf.deviceArray.count == 0) {
            NSLog(@"第一次添加蓝牙信号源 name = %@ ,macAddress = %@",model.peripheral.name,model.macAddress);
            [weakSelf.deviceArray addObject:model];
        }else{
            NSArray * midArr = weakSelf.deviceArray;
            BOOL isSameModel = NO;
            for (int i = 0; i < midArr.count; i++) {
                PeripheralModel * oldModel = midArr[i];
                if ([model.peripheral.name isEqualToString:oldModel.peripheral.name]) {
                    isSameModel = YES;
                    [weakSelf.deviceArray replaceObjectAtIndex:i withObject:model];
                    NSLog(@"查重蓝牙信号：覆盖 name = %@ ,macAddress = %@",model.peripheral.name,model.macAddress);
                }
            }
            if (!isSameModel) {
                NSLog(@"查重蓝牙信号：添加 name = %@ ,macAddress = %@",model.peripheral.name,model.macAddress);
                [weakSelf.deviceArray addObject:model];
            }
        }
        
        [weakSelf refreshTableView];
        
    };
    
}
#pragma mark - 刷新
-(void)refresh{
    [self.manager stopScan];
    [self.deviceArray removeAllObjects];
    [self.deviceTableView reloadData];
    [self scanDevice];
}
-(void)scanDevice{
    if(!self.manager.isScan){
//        [self test2];
        [self.manager scanAllPeripheral];
    }
//    else{
//        [self.manager stopScan];
//        [self.manager scanAllPeripheral];
//    }
}
-(void)refreshTableView{
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.deviceTableView reloadData];
    });
}
#pragma mark - 倒数
-(void)countDown{
    if (self.sendTime == 1) {
        [self.sendTimer setFireDate:[NSDate distantFuture]];
        self.sendTime = 15;
        self.isSelect = NO;
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BTM_FailToConnectPeripheral", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
        [self refresh];
    }else{
        if (self.sendTime == 15) {
        }
        self.sendTime -- ;
    }
    
}

- (IBAction)btnCancelClicked:(id)sender {
    [self backClick];
}

- (IBAction)btnRefreshClicked:(id)sender {
    [self refresh];
}

-(void)backClick{
    //关闭蓝牙搜索
    //    if(self.isPushWithLogin){
    //        [self.manager stopScan];
    //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //        [defaults setBool:NO forKey:@"isLogin"];
    //        [defaults synchronize];
    //        [self.navigationController popToRootViewControllerAnimated:YES];
    //        //返回到登录页面
    //    }else{
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }
    WS(weakSelf);
    //弹窗确认，并退出登录
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AVC_Logout", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.manager stopScan];
        BlueToothManager *manager = [BlueToothManager shareIsnstance];
        if(manager.isConnect){
            [manager manualCancelConnect];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"0" forKey:@"isLogin"];
        [defaults synchronize];
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([delegate.window.rootViewController.childViewControllers[0] isKindOfClass: [LoginViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [delegate setRootViewControllerForLogin];
        }
    }];
    [actionSheet addAction:cancel];
    [actionSheet addAction:ok];
    [self presentViewController:actionSheet animated:YES completion:nil];
}
//绑定设备
-(void)bindDevice:(NSDictionary *)dict WithMacAddress:(NSString*)macAddress{
    WS(weakSelf);
    [[MSCoreManager sharedManager] postBindDeviceForData:dict WithResponse:^(ResponseInfo *info) {
        if([info.code isEqualToString:@"200"]){
            NSLog(@"绑定设备成功");
            [MSCoreManager sharedManager].userModel.deviceCode = macAddress;
            
            if (self.manager.isConnect) {
                [self xyw_syncAllSleepData];//同步ble数据
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isOpenHrRrNotify"];
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate setRootViewControllerForSleep];
            
        }else{
            NSLog(@"绑定设备失败");
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            if (weakSelf.manager.isConnect) {
                weakSelf.manager.isManualCancelConnect = YES;
                [weakSelf.manager cancelConnect];
            }
        }
    }];
}

#pragma mark - 同步ble数据
- (void)xyw_syncAllSleepData{
    WS(weakSelf);
    /*同步ble数据（绑定设备后同步数据）*/
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Synchronizationing", nil)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD dismissWithDelay:kDismissWithOutTime];
    //1.清理所有数据 （这里要同步的是全部，所以要清除本地DB）
    [self.manager deleteSleepAllDataNotify];
    //3.保存成功回调中，同步睡眠数据到服务器
    self.manager.syncFinishedBlock = ^(NSArray *timeStringArr, BOOL isFinished) {
        
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
                        NSLog(@"上传睡眠数据成功-搜索主页");
                        //[SVProgressHUD showSuccessWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        //删除设备数据(绑定设备)
                        [weakSelf.manager deleteSleepBandDataNotify];
                    }else{
                        //上传失败
                        [SVProgressHUD showErrorWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    }
                }];
            }else{
                NSLog(@"没有新数据需要上传-搜索主页");
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }
        
        else if (isFinished && timeStringArr.count == 0){
            //            NSLog(@"isFinished = %@",isFinished?@"YES":@"NO");
            NSLog(@"没有新数据需要上传-搜索主页");
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    };
    //2.读取设备数据并保存数据库
    [self.manager readSleepAllDataNotifyWithAll:YES];
    //4...
}

//检查蓝牙状态
-(void)checkBlueToothState{
    
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.lineView.hidden = NO;
//    [cell setType:CellType_Arrows];
    PeripheralModel *model = self.deviceArray[indexPath.row];
    CBPeripheral *peripheral = model.peripheral;
    cell.deviceLabel.text = peripheral.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sendTimer == nil) {
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    [self.sendTimer setFireDate:[NSDate date]];
    WS(weakSelf);
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    if (self.manager.centralManagerState == 5) {
        self.isSelect = YES;
        PeripheralModel *model = self.deviceArray[indexPath.row];
        CBPeripheral *peripheral = model.peripheral;
        self.macAddress = model.macAddress;
        self.manager.connectPeripheralBlock = ^(BOOL isSuccess) {
            [weakSelf.sendTimer setFireDate:[NSDate distantFuture]];
            weakSelf.sendTime = 15;
            [SVProgressHUD dismiss];
            if (isSuccess) {
                NSDictionary * headerDic = [[NSDictionary alloc]initWithObjectsAndKeys:weakSelf.macAddress,@"deviceCode", nil];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:weakSelf.macAddress forKey:@"lastConnectDevice"];
                [defaults synchronize];
                [weakSelf bindDevice:headerDic WithMacAddress:weakSelf.macAddress];
            }else{
                weakSelf.isSelect = NO;
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BTM_FailToConnectPeripheral", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        };
        [self.manager connectPeripheral:peripheral];
        
    }{
        if (!self.isSelect) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothClose", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }
    //    });
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}
-(void)setUI{
    WS(weakSelf);
    self.deviceTableView.backgroundColor = [UIColor clearColor];
    self.deviceTableView.showsVerticalScrollIndicator = NO;
    self.deviceTableView.delegate = self;
    self.deviceTableView.dataSource = self;
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DeviceCell"];
    self.deviceTableView.estimatedRowHeight = 50;
    self.deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.deviceTableView.tableFooterView = [[UIView alloc] initWithFrame: CGRectZero];
    return;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
//    UIImageView *bgImageView = [[UIImageView alloc]init];
//    bgImageView.image = [UIImage imageNamed:@"bg"];
//    [self.view addSubview:bgImageView];
//    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.equalTo(weakSelf.view);
//    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"signup_icon_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
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
    titleLabel.text = NSLocalizedString(@"SDVC_SearchTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
        
    }];
    
    UIImageView *bottomImageView = [[UIImageView alloc]init];
    bottomImageView.image = [UIImage imageNamed:@"signup_bg_bottom"];
    [self.view addSubview:bottomImageView];
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
    }];
    
    
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"search_motion" withExtension:@"gif"]; //加载GIF图片
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef) fileUrl, NULL);           //将GIF图片转换成对应的图片源
    size_t frameCout = CGImageSourceGetCount(gifSource);                                         //获取其中图片源个数，即由多少帧图片组成
    NSMutableArray *frames = [[NSMutableArray alloc] init];                                      //定义数组存储拆分出来的图片
    for (size_t i = 0; i < frameCout; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL); //从GIF图片中取出源图片
        UIImage *imageName = [UIImage imageWithCGImage:imageRef];                  //将图片源转换成UIimageView能使用的图片源
        [frames addObject:imageName];                                              //将图片加入数组中
        CGImageRelease(imageRef);
    }
//    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight+44+(128-41.75), 375, 256)];
    UIImageView *gifImageView = [[UIImageView alloc] init];
    gifImageView.animationImages = frames; //将图片数组加入UIImageView动画数组中
    gifImageView.animationDuration = 1; //每次动画时长
    [gifImageView startAnimating];         //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
    [self.view addSubview:gifImageView];
    [gifImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@256);
        
    }];
    
    //圆形图案
    self.topView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.topView];
    [self.topView setImage:[UIImage imageNamed:@"search_icon"]];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+(128-35));
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@70);
        make.height.equalTo(@70);
    }];
    
    
    
    self.deviceTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview: self.deviceTableView];
    [self.deviceTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight + 44 +256);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(33);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-33);
        make.bottom.mas_equalTo(bottomImageView.mas_top).offset(-40);
    }];
    
    [self.view layoutIfNeeded];
    
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 33)];
    self.deviceTableView.tableHeaderView = tableHeaderView;
    UILabel *headerTitle = [[UILabel alloc]init];
    headerTitle.font = [UIFont systemFontOfSize:15];;
    [tableHeaderView addSubview:headerTitle];
    [headerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tableHeaderView.mas_left).offset(0);
        make.top.right.equalTo(tableHeaderView);
        make.height.equalTo(@15);
    }];
    headerTitle.textAlignment = NSTextAlignmentLeft;
    headerTitle.textColor = [UIColor colorWithHexString:@"#1B86A4"];
    headerTitle.text = NSLocalizedString(@"SDVC_HeaderTitle", nil);
    
    UIView *headerV = [[UILabel alloc]init];
    headerV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [tableHeaderView addSubview:headerV];
    [headerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(tableHeaderView);
        make.height.equalTo(@1);
    }];
    //    self.deviceTableView.tableHeaderView.hidden = YES;
    
    UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 40)];
    self.deviceTableView.tableFooterView = tableFooterView;
    [tableFooterView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refresh)]];
    
    UIImageView *refreshV = [[UIImageView alloc]initWithFrame:CGRectZero];
    [tableFooterView addSubview:refreshV];
    [refreshV setImage:[UIImage imageNamed:@"searchdevice_refresh"]];
    [refreshV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tableFooterView.mas_left).offset(0);
        make.centerY.equalTo(tableFooterView);
        make.width.equalTo(@14);
        make.height.equalTo(@14);
    }];
    
    UILabel *footerTitle = [[UILabel alloc]init];
    [tableFooterView addSubview:footerTitle];
    [footerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(refreshV.mas_right).offset(6);
        make.top.bottom.equalTo(tableFooterView);
        make.right.mas_equalTo(tableFooterView.mas_right).offset(-30);
    }];
    footerTitle.textAlignment = NSTextAlignmentLeft;
    footerTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    footerTitle.textColor = [UIColor colorWithHexString:@"#575756"];
    footerTitle.text = NSLocalizedString(@"SDVC_RefreshTitle", nil);
    

    
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
