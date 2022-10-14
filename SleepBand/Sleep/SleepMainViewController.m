//
//  SleepMainViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SleepMainViewController.h"
#import "AppDelegate.h"
#import "HelpViewController.h"
#import "ManualSleepReportViewController.h"
#import "AutoSleepSettingViewController.h"


@interface SleepMainViewController ()

@property (strong,nonatomic)UILabel * heartRateLabel; //心率
@property (strong,nonatomic)UILabel * respiratoryRateLabel;  //呼吸率
@property (strong,nonatomic)UILabel * alarmClockLabel;  //闹钟
@property (strong,nonatomic)UILabel * alertLabel; //提醒
@property (strong,nonatomic)UIButton * helpBtn; //帮助按钮
@property (strong,nonatomic)UIView *alarmClockView;
@property (strong,nonatomic)BlueToothManager *manager;
@property (strong,nonatomic)MSCoreManager *coreManager;
@property (assign,nonatomic)int totalCount; //总共需要同步的次数
@property (assign,nonatomic)int synchronizationCount; //已同步的次数
@property (strong,nonatomic)NSDate * manualStartDate; //点击开始睡眠的时间
@property (strong,nonatomic)NSDate * manualEndDate; //点击结束睡眠的时间
@property (assign,nonatomic)int  autoSleepMonitor; //是否打开自动监测睡眠
@property (strong,nonatomic)UIImageView *alarmClockIV;
@property (strong,nonatomic)UIImageView *clockImageV;
@property (strong,nonatomic)UIButton *blueToothBtn;
@property (strong,nonatomic)LeftView *leftMenuV;
@property (strong,nonatomic)AlertView *alertView;
@end

@implementation SleepMainViewController
- (void)dealloc
{
    // 移除当前对象监听的事件
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BlueToothManager *)manager
{
    if (_manager == nil)
    {
        _manager = [BlueToothManager shareIsnstance];
    }
    return _manager;
}

-(void)viewWillAppear:(BOOL)animated
{
    WS(weakSelf);
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    if (self.sleepBtn.selected) {
//        [self removeSleepAnimation];
//        [self addSleepAnimation];
//    }
    [self getclockData];
    [self getSeverSleepData];
    [self setBlueTooth];

}

//页面即将消失
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.isOpenHrRrNotify) {
        
        [self.manager closeRealTimeHrRrNotify];//关闭
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat topPadding = window.safeAreaInsets.top;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        NSLog(@"topPadding = %f,bottomPadding = %f",topPadding,bottomPadding);
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.coreManager = [MSCoreManager sharedManager];
    
    self.isOpenHrRrNotify = [[NSUserDefaults standardUserDefaults] boolForKey:@"isOpenHrRrNotify"];
    
    [self setUI];
    
    WS(weakSelf);
    if (self.manager.isConnect)
    {
        
        [self deviceConnectState];
        
        self.manager.HrRrBlock = ^(NSString *HR, NSString *RR) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //            NSLog(@"%@,%@",HR,RR);
                weakSelf.heartRateLabel.text = HR;
                
                CGSize hrTextSize = [weakSelf.heartRateLabel.text sizeWithAttributes:@{NSFontAttributeName:weakSelf.heartRateLabel.font}];
                
                [weakSelf.heartRateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.width.equalTo(@(hrTextSize.width+1));
                    
                }];
                
                weakSelf.respiratoryRateLabel.text = RR;
                
            });
            
        };
        
        
    }
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(autoSleepMonitorNotification:) name:@"AutoSleepMonitor" object:nil];
    
    self.leftMenuV.selectControllerBlock = ^(LeftMenuType type) {
        if (type != LeftMenuType_Sleep) {
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (type == LeftMenuType_Report) {
                
                [delegate setRootViewControllerForReport];
//                [delegate setRootViewControllerForReportMain];
                
            }else if (type == LeftMenuType_Clock){
                
                [delegate setRootViewControllerForClock];
                
            }else{
                
                [delegate setRootViewControllerForMe];
            }
        }
    };
    
}


-(void)autoSleepMonitorNotification:(NSNotification *)notification
{
    NSString *autoSleepMonitor = notification.object;
    self.autoSleepMonitor = [autoSleepMonitor intValue];
//    if (self.manager.isConnect) {
//        if (!self.autoSleepMonitor) {
//            if (!self.sleepBtn.selected) {
//                self.alertLabel.hidden = YES;
//            }
//        }else{
//            self.alertLabel.hidden = NO;
//        }
//    }
    
}

-(void)setBlueTooth
{
    WS(weakSelf);
    self.manager.HrRrBlock = ^(NSString *HR, NSString *RR) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.isOpenHrRrNotify) {
//                NSLog(@"%@,%@",HR,RR);
                
                weakSelf.heartRateLabel.text = HR;
                CGSize hrTextSize = [weakSelf.heartRateLabel.text sizeWithAttributes:@{NSFontAttributeName:weakSelf.heartRateLabel.font}];
                [weakSelf.heartRateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.width.equalTo(@(hrTextSize.width+1));
                    
                }];
                weakSelf.respiratoryRateLabel.text = RR;
                
            }
        });
    };
    if (self.manager.isConnect) {
        
        if (self.blueToothBtn.selected == NO) {
            
            [self deviceConnectState];
            
        }
        if (self.sleepBtn.selected) {
            [self.manager openRealTimeHrRrNotify];//打开
        }
//        [self judgementWhetherSynchronization];
    }
    if(!self.manager.isConnect && self.blueToothBtn.selected == YES)
    {
        [self deviceDisconnectState];
    }
    self.manager.connectPeripheralBlock = ^(BOOL isSuccess) {
        if (weakSelf) {
            if(isSuccess){
                [weakSelf deviceConnectState];
                
                if (weakSelf.isOpenHrRrNotify == YES) {
                    [weakSelf.manager openRealTimeHrRrNotify];//打开
                    weakSelf.sleepBtn.selected = weakSelf.isOpenHrRrNotify;
                }
                
                NSLog(@"同步ble数据并同步到服务器");
                [weakSelf xyw_syncAllSleepData];//同步ble数据并同步到服务器
                //                [weakSelf judgementWhetherSynchronization];
            }else{
                [weakSelf deviceDisconnectState];
//                weakSelf.isOpenHrRrNotify = NO;
                if (!weakSelf.manager.isManualCancelConnect) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BTM_FailToConnectPeripheral", nil)];
                }
            }
        }
    };
}

//设备连接状态
-(void)deviceConnectState
{
    WS(weakSelf);
    if (weakSelf) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.blueToothBtn.selected = YES;
//            weakSelf.alertLabel.text = NSLocalizedString(@"BTM_DeviceMonitoring", nil);
//            CGSize alertTextSize = [weakSelf.alertLabel.text sizeWithAttributes:@{NSFontAttributeName:weakSelf.alertLabel.font}];
//            [weakSelf.alertLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.equalTo(@(alertTextSize.width+5));
//            }];
//            weakSelf.helpBtn.hidden = YES;
//            if (weakSelf.autoSleepMonitor) {
//                weakSelf.alertLabel.hidden = NO;
//            }else{
//                if (weakSelf.sleepBtn.selected) {
//                    weakSelf.alertLabel.hidden = NO;
//                }else{
//                    weakSelf.alertLabel.hidden = YES;
//                }
//            }
            [weakSelf.respiratoryRateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
               
                make.width.equalTo(@(40));
            }];
            
            weakSelf.heartRateLabel.text = @"-";
            weakSelf.respiratoryRateLabel.text = @"-";
            
        });
        
    }
    
}

//设备断开状态
-(void)deviceDisconnectState
{
    WS(weakSelf);
    if (weakSelf) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blueToothBtn.selected = NO;
//            self.alertLabel.text = NSLocalizedString(@"BTM_FailToConnectPeripheral", nil);
//            CGSize alertTextSize = [self.alertLabel.text sizeWithAttributes:@{NSFontAttributeName:self.alertLabel.font}];
//            [self.alertLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.equalTo(@(alertTextSize.width+5));
//            }];
//            self.alertLabel.hidden = NO;
//            self.helpBtn.hidden = NO;
            self.heartRateLabel.text = @"-";
            self.respiratoryRateLabel.text = @"-";
            [self.respiratoryRateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(80));
            }];
        });
    }
}

//判断是否需要同步
-(void)judgementWhetherSynchronization
{
    NSLog(@"判断是否需要同步!!!!");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //判断同步日期是否为今天，如果不是
    NSDictionary *lastSynchronizationDict = [defaults objectForKey:@"lastSynchronizationTime"];
    if (lastSynchronizationDict != nil) {
        if([[lastSynchronizationDict allKeys] containsObject:[MSCoreManager sharedManager].userModel.deviceCode]){
            NSString *lastSynchronizationTime  =  lastSynchronizationDict[[MSCoreManager sharedManager].userModel.deviceCode];
            if (lastSynchronizationTime.length == 0) {
                //        [defaults setObject:[UIFactory dateForNumString:[NSDate date]] forKey:@"lastSynchronizationTime"];
                //测试
                //        [defaults setObject:@"20180801" forKey:@"lastSynchronizationTime"];
                //        [defaults synchronize];
                [self synchronization];
                
            }else
            {
                //如果上一次同步时间不是今天,就同步
                if (![lastSynchronizationTime isEqualToString:[UIFactory dateForNumString:[UIFactory NSDateForUTC:[NSDate date]]]]) {
                    [self synchronization];
                }
            }
        }else
        {
            [self synchronizationForAll];
        }
    }else
    {
        [self synchronizationForAll];
    }
    //    NSString *lastSynchronizationTime  =  lastSynchronizationDict[[MSCoreManager sharedManager].userModel.bluetooth];
    //    //如果没有同步过,就同步
    //    if (lastSynchronizationTime.length == 0) {
    //        //        [defaults setObject:[UIFactory dateForNumString:[NSDate date]] forKey:@"lastSynchronizationTime"];
    //        //测试
    //        //        [defaults setObject:@"20180801" forKey:@"lastSynchronizationTime"];
    //        //        [defaults synchronize];
    //        [self synchronization];
    //    }else{
    //        //如果上一次同步时间不是今天,就同步
    //        if (![lastSynchronizationTime isEqualToString:[UIFactory dateForNumString:[UIFactory NSDateForUTC:[NSDate date]]]]) {
    //            [self synchronization];
    //        }
    //    }
}

-(void)synchronizationForAll
{
    WS(weakSelf);
    NSLog(@"同步!!!!");
    //    [SVProgressHUD showProgress:0 status:NSLocalizedString(@"Synchronizationing", nil)];
    [SVProgressHUD showProgress:0 status:[NSString stringWithFormat:@"%@0%%", NSLocalizedString(@"Synchronizationing", nil)]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *lastSynchronizationDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"lastSynchronizationTime"]];
    //    NSString *lastSynchronizationTime  =  lastSynchronizationDict[[MSCoreManager sharedManager].userModel.bluetooth];
    self.synchronizationCount = 0;
    //判断某个时间距离现在已经过了多久
    //如果不在7天之内，就同步7天数据
    self.totalCount = 14;
    //同步回调
    self.manager.synchronizationBlock = ^(int count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.synchronizationCount++;
            if (weakSelf.synchronizationCount != weakSelf.totalCount)
            {
                [SVProgressHUD showProgress:(float)weakSelf.synchronizationCount/weakSelf.totalCount status:[NSString stringWithFormat:@"%@%.0f%%", NSLocalizedString(@"Synchronizationing", nil),(float)weakSelf.synchronizationCount/weakSelf.totalCount*100]];
                
            }else
            {
                
                [SVProgressHUD popActivity];
                
                lastSynchronizationDict[[MSCoreManager sharedManager].userModel.deviceCode] = [UIFactory dateForNumString:[NSDate date]];
                [defaults setObject:lastSynchronizationDict forKey:@"lastSynchronizationTime"];
                [defaults synchronize];
                
            }
        });
        
    };
    [self.manager getTurnOverHistoricalData:7];
    
}

-(void)tabBarViewHidden
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.mainTabBar.tabBarView.hidden == NO)
    {
        delegate.mainTabBar.tabBarView.hidden = YES;
    }
}

-(void)getclockData
{
    WS(weakSelf);
    NSLog(@"获取服务器闹钟数据");
    
    [self.coreManager getGetAlarmClockForData:nil WithResponse:^(ResponseInfo *info)
    {
        if ([info.code isEqualToString:@"200"])
        {
            NSArray * list = [info.data objectForKey:@"list"];
            NSLog(@"获取服务器闹钟数据成功,个数为%lu",(unsigned long)list.count);
            if (list.count > 0)
            {
//                weakSelf.alarmClockIV.hidden = NO;
                //                int hour = 0 ;
                //                int minute = 0 ;
                NSString *currentTime = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:[NSDate date]]];
                NSString *hourStr = [currentTime substringWithRange:NSMakeRange(11, 2)];
                NSString *minuteStr = [currentTime substringWithRange:NSMakeRange(14, 2)];
                
                NSSortDescriptor *hourSD = [NSSortDescriptor sortDescriptorWithKey:@"hour" ascending:YES];
                NSSortDescriptor *minuteSD=[NSSortDescriptor sortDescriptorWithKey:@"minute" ascending:YES];
                list = [[list sortedArrayUsingDescriptors:@[hourSD,minuteSD]] mutableCopy];
                
                NSMutableArray * allAlarmClockArr = [NSMutableArray array];
                for (int i = 0; i < list.count; i++)
                {
                    NSDictionary *dict = list[i];
                    NSMutableDictionary * modelDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [modelDict setObject:[dict objectForKey:@"repeat"] forKey:@"repeatStr"];
                    NSMutableArray * repeat = [NSMutableArray array];
                    AlarmClockModel *model = [AlarmClockModel mj_objectWithKeyValues:modelDict];
                    model.clockId = [[modelDict objectForKey:@"id"] intValue];
                    if (model.repeatStr && model.repeatStr.length>0) {
                        for (int j = 0; j<7; j++) {
                            NSString * iStr = [NSString stringWithFormat:@"%d",j];
                            if([model.repeatStr containsString:iStr]) {
                                [repeat addObject:iStr];
                            }
                        }
                    }
                    model.repeat = repeat;
                    [allAlarmClockArr addObject:model];
                    
                }
                weakSelf.clockImageV.hidden = NO;
                //获取距离当前最近的闹钟
                AlarmClockModel * latelyAlarmClockModel = [weakSelf getLatelyAlarmClockWithAlarmClockArr:allAlarmClockArr];
                weakSelf.alarmClockLabel.text = [NSString stringWithFormat:@"%02d:%02d",latelyAlarmClockModel.hour,latelyAlarmClockModel.minute];
                CGSize alarmSize = [weakSelf.alarmClockLabel.text sizeWithAttributes:@{NSFontAttributeName:weakSelf.alarmClockLabel.font}];
                [weakSelf.alarmClockView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(18+9+alarmSize.width+1));
                }];
                [weakSelf.view layoutIfNeeded];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.view setNeedsUpdateConstraints];
                    [UIView animateWithDuration:0.5f animations:^{
                        
                        [weakSelf.clockImageV mas_updateConstraints:^(MASConstraintMaker *make) {
                            
                            make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
                            
                        }];
                        [weakSelf.view layoutIfNeeded];
                    }];
                });
                //刷新本地闹钟（APP内响铃闹钟）
                [weakSelf refreshLocalAlarmClockWithAlarmClockArr:allAlarmClockArr];
            }else
            {
                weakSelf.clockImageV.hidden = YES;
                [weakSelf.clockImageV mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight+61);
                }];
                [weakSelf.view layoutIfNeeded];
//                weakSelf.alarmClockLabel.text = NSLocalizedString(@"SMVC_NoClock", nil);
//                CGSize alarmSize = [weakSelf.alarmClockLabel.text sizeWithAttributes:@{NSFontAttributeName:weakSelf.alarmClockLabel.font}];
//                [weakSelf.alarmClockView mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.width.equalTo(@(18+9+alarmSize.width+1));
//                }];
            }
            
        }else
        {
            //            [SVProgressHUD dismiss];
            NSLog(@"获取服务器闹钟数据失败");
            //            [SVProgressHUD showErrorWithStatus:info.message];
            //            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
        
    }];
    
}

#pragma mark - 同步ble数据
- (void)xyw_syncAllSleepData{
    WS(weakSelf);
    /*同步ble数据*/
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Synchronizationing", nil)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD dismissWithDelay:kDismissWithOutTime];
    //1.清理所有数据 （这里要同步的是部分数据，所以不需要清除本地DB）
//    [self.manager deleteSleepAllDataNotify];
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
                        NSLog(@"上传睡眠数据成功");
                        //[SVProgressHUD showSuccessWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        //删除设备数据(连接设备)
                        [weakSelf.manager deleteSleepBandDataNotify];
                    }else{
                        //上传失败
                        [SVProgressHUD showErrorWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    }
                }];
            }else{
                NSLog(@"没有新数据需要上传-睡眠主页");
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }
        
        else if (isFinished && timeStringArr.count == 0){
//            NSLog(@"isFinished = %@",isFinished?@"YES":@"NO");
            NSLog(@"没有新数据需要上传-睡眠主页");
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
        
        if (isFinished) {
            [weakSelf getDeviceVersions];
        }
    };
    //2.读取设备数据并保存数据库
    [self.manager readSleepAllDataNotifyWithAll:YES];
    //4...
}

- (void)getDeviceVersions{
    WS(weakSelf);
    self.manager.versionBlock = ^(NSString *hardwareVersion, NSString *softwareVersion) {
        //
    };
    self.manager.batteryBlock = ^(int battery, BOOL isCharge) {
        if (battery < 10 && !isCharge) {
            //低电量弹框提醒
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WhetherBatteryCharging", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [actionSheet addAction:ok];
            [weakSelf presentViewController:actionSheet animated:YES completion:nil];
        }
    };
    
    [self.manager getDeviceVersions];
}

#pragma mark - 获取服务器数据保存至DB
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
//            [SVProgressHUD showSuccessWithStatus:info.message];
//            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            
        }else{
            //获取失败
//            [SVProgressHUD showErrorWithStatus:info.message];
//            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
    
}

#pragma mark - 保存服务器睡眠数据至db
-(void)saveServerSleepDataWith:(NSArray*)dataArr{
    NSString * deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
    for (int i = 0; i<dataArr.count; i++) {
        NSDictionary * dataDict = dataArr[i];
        NSString * time = [dataDict objectForKey:@"time"];
        NSArray * arr;
//        NSLog(@"dataDict = %@",dataDict);
//        NSLog(@"时间戳 = %@",[dataDict objectForKey:@"time"]);
//        NSLog(@"睡眠质量 = %@",[dataDict objectForKey:@"dataForSleep"]);
//        NSLog(@"心率 = %@",[dataDict objectForKey:@"dataForHeart"]);
//        NSLog(@"呼吸率 = %@",[dataDict objectForKey:@"dataForBreath"]);
//        NSLog(@"翻身 = %@",[dataDict objectForKey:@"dataForTurnOver"]);
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

#pragma mark - 点击实时数据
-(void)realTime
{
    if (self.manager.isConnect)
    {
        //push  实时
        RealTimeViewController *realTime = [[RealTimeViewController alloc]init];
//        [self tabBarViewHidden];
        [self.navigationController pushViewController:realTime animated:YES];
        
    }else
    {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}

-(void)help
{
    HelpViewController *help = [[HelpViewController alloc]init];
    [self tabBarViewHidden];
    [self.navigationController pushViewController:help animated:YES];
    
}

-(void)setting
{
    [self tabBarViewHidden];
    AutoSleepSettingViewController *setting = [[AutoSleepSettingViewController alloc]init];
    [self.navigationController  pushViewController:setting animated:YES];
}

-(void)connectPeripheral
{
    if(self.manager.centralManagerState == 5)
    {
        
        if (self.manager.currentPeripheral)
        {
            //
//            [SVProgressHUD showWithStatus:NSLocalizedString(@"BTM_DeviceMonitoring", nil)];
//            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            [self.manager connectCurrentPeripheral];
            
        }else
        {
            [self.manager scanAllPeripheral];
        }
        
    }else
    {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothClose", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}

-(void)alarmClock
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate setRootViewControllerForClock];
}

#pragma mark - 点击蓝牙按钮
-(void)blueTooth:(UIButton *)sender
{
    if (!sender.selected) {
        //连接蓝牙
        [self connectPeripheral];
    }else{
        //断开蓝牙
        WS(weakSelf);
        //弹窗确认，断开设备连接
        [self.alertView showAlertWithType:AlertType_Disconnect title:NSLocalizedString(@"BTM_DeviceFailToConnect", nil) menuArray:nil];
        self.alertView.alertOkBlock = ^(AlertType type){
            if (type == AlertType_Disconnect && weakSelf.manager.isConnect) {
                [weakSelf.manager cancelConnect];//断开连接
            }
        };
    }
    
}

-(void)addSleepAnimation
{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    opacityAnimation.duration = 2.0f;
    
    opacityAnimation.autoreverses= NO;
    
    opacityAnimation.repeatCount = MAXFLOAT;
    
    CABasicAnimation * animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation2.fromValue = [NSNumber numberWithDouble:0.8];
    
    animation2.toValue = [NSNumber numberWithDouble:1.3];
    
    animation2.duration= 2.0;
    
    animation2.autoreverses= NO;
    
    animation2.repeatCount= FLT_MAX;  //"forever"
    
    //    animation2.removedOnCompletion= YES;
    
    [self.sleepBtn.layer addAnimation:animation2 forKey:@"scale"];
    [self.sleepBtn.layer addAnimation:opacityAnimation forKey:nil];
}

-(void)removeSleepAnimation
{
    [self.sleepBtn.layer removeAllAnimations];
}

#pragma mark - 点击睡眠按钮
-(void)sleep:(UIButton *)sender
{
    WS(weakSelf);
    if(self.manager.isConnect)
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        if (!sender.selected)
        {
            
            NSLog(@"点击开始");
            self.isOpenHrRrNotify = YES;
            [defaults setBool:self.isOpenHrRrNotify forKey:@"isOpenHrRrNotify"];
            [defaults synchronize];
            [self.manager openRealTimeHrRrNotify];//打开
            
            sender.selected = YES;
//            self.alertLabel.hidden = NO;
            self.manualStartDate = [NSDate date];
//            [self addSleepAnimation];
            
            
        }else
        {
            NSLog(@"点击结束->跳转到报告页面");
            self.isOpenHrRrNotify = NO;
            [defaults setBool:self.isOpenHrRrNotify forKey:@"isOpenHrRrNotify"];
            [defaults synchronize];
            [self.manager closeRealTimeHrRrNotify];//关闭
            self.heartRateLabel.text = @"-";
            self.respiratoryRateLabel.text = @"-";
//            [self removeSleepAnimation];
            sender.selected = NO;
//            if (!self.autoSleepMonitor) {
//                self.alertLabel.hidden = YES;
//            }
//            self.manualEndDate = [NSDate date];
//            NSTimeInterval time = [self.manualStartDate timeIntervalSinceDate:self.manualEndDate];
//            int hours = ((int)time)%(3600*24)/3600;
            
            //计算开始跟结束跨度，大于24小时不生成报告
//            if (hours < 24)
//            {
//
////同步数据
//#if 0
//                ManualSleepReportViewController *manual = [[ManualSleepReportViewController alloc]init];
//                manual.manualStartDate = self.manualStartDate;
//                manual.manualEndDate = self.manualEndDate;
//                [self tabBarViewHidden];
//                [self.navigationController pushViewController:manual animated:YES];
//#endif
//             }
            //点击结束监测后，跳转到报告页面
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults boolForKey:@"isHaveNewDataForPushToReport"];
            //判断是否有新数据
            if ([defaults boolForKey:@"isHaveNewDataForPushToReport"]) {
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SMVC_HaveNewSleepData", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"SMVC_Look", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate setRootViewControllerForReport];
                }];
                [actionSheet addAction:ok];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [actionSheet addAction:cancel];
                [weakSelf presentViewController:actionSheet animated:YES completion:nil];
                
            }
            
            
        }
        
    }else{
        
        if (!sender.selected)
        {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            
        }else
        {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BTM_DeviceNoConnect", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"SMVC_FinishSleep", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                sender.selected = NO;
//                if (!weakSelf.autoSleepMonitor) {
//                    weakSelf.alertLabel.hidden = YES;
//                }
            }];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [actionSheet addAction:cancel];
            [actionSheet addAction:ok];
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        }
        
    }
    
}
//获取距离当前最近的闹钟
-(AlarmClockModel *)getLatelyAlarmClockWithAlarmClockArr:(NSMutableArray*)allAlarmClock{
    
    AlarmClockModel * latelyAlarmClockModel = [[AlarmClockModel alloc]init];
    
    // 获取当前时间
    NSString *currentTime = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:[NSDate date]]];
    NSString *hourStr = [currentTime substringWithRange:NSMakeRange(11, 2)];
    NSString *minuteStr = [currentTime substringWithRange:NSMakeRange(14, 2)];
    
    // 获取今日星期
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];// 指定日历的算法
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];// 1是周日，2是周一 3.以此类推
    NSNumber * weekNumber = @([comps weekday]);
    NSLog(@"今日星期:%@(1是周日，2是周一 3.以此类推)",weekNumber);
    //我们星期选择的控件返还的星期，0是周日，1是周一 2以此类推，所以要-1，再去校验；
    NSString * weekString = [NSString stringWithFormat:@"%d",[weekNumber intValue] - 1];
    
    NSMutableArray * latelyWeekArr = [NSMutableArray array];
    BOOL isFind = NO;
    for (int i = 0; i < 7; i++) {
        if (isFind == NO) {
            for (AlarmClockModel * model in allAlarmClock) {
                if (model.isOn && [model.repeat containsObject:weekString]) {
                    if (i == 0) {
                        if (model.hour *60 + model.minute >= [hourStr intValue] *60 + [minuteStr intValue]) {
                            [latelyWeekArr addObject:model];
                        }
                    }else{
                        [latelyWeekArr addObject:model];
                    }
                }
            }
            if (latelyWeekArr.count>0) {
                isFind = YES;
            }
        }
        weekString = [NSString stringWithFormat:@"%d",(weekString.intValue+1)%6];
    }

    if (latelyWeekArr.count > 1) {
        //升序
        NSArray * sortedArray = [latelyWeekArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            AlarmClockModel * model1 = obj1;
            AlarmClockModel * model2 = obj2;
            if (model1.hour *60 + model1.minute < model2.hour *60 + model2.minute) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
        //firstObjecte为最小值
        latelyAlarmClockModel = sortedArray.firstObject;
    }else{
        latelyAlarmClockModel = latelyWeekArr.firstObject;
    }
    return latelyAlarmClockModel;
}
//刷新本地闹钟（APP内响铃闹钟）
- (void)refreshLocalAlarmClockWithAlarmClockArr:(NSMutableArray*)allAlarmClock{
    
    NSLog(@"刷新本地闹钟（APP内响铃闹钟）");
    NSArray * LocalAlarmClockArr = [AlarmClockModel GetAllAlarmClockEvent];
    
    if (LocalAlarmClockArr.count == 0) {
        NSLog(@"无本地闹钟");
    }else{
        for (AlarmClockModel * model in LocalAlarmClockArr) {
            NSLog(@"model.clockTimer = %@",model.clockTimer);
            [AlarmClockModel RemoveAlarmClockWithTimer:model.clockTimer];
        }
        NSLog(@"移除所有闹钟");
    }
    
    if (allAlarmClock == 0) {
        NSLog(@"没有新闹钟数据");
        return;
    }
    
    NSMutableArray * clockTimerArr = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * timeString = [formatter stringFromDate:[NSDate date]];//当天日期
    // 获取今日星期
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];// 指定日历的算法
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];// 1是周日，2是周一 3.以此类推
    NSNumber * weekNumber = @([comps weekday]);
    NSLog(@"今日星期:%@(1是周日，2是周一 3.以此类推)",weekNumber);
    //我们星期选择的控件返还的星期，0是周日，1是周一 2以此类推，所以要-1，再去校验；
    NSString * weekString = [NSString stringWithFormat:@"%d",[weekNumber intValue] - 1];
    
    for (AlarmClockModel * model in allAlarmClock) {
        
        NSString * selectClockTimer = [NSString stringWithFormat:@"%02d:%02d:00",model.hour,model.minute];
        //查重、响应端、循环周的判断
        if (![clockTimerArr containsObject:selectClockTimer] && model.isPhone && model.isOn && [model.repeat containsObject:weekString]) {
            [clockTimerArr addObject:selectClockTimer];
            model.clockTitle = @"闹钟";
            model.clockDescribe = model.remark;
            model.clockMusic = @"bell_ring.m4a";
            NSString *clockTimer = [timeString stringByReplacingOccurrencesOfString:[[formatter stringFromDate:[NSDate date]] substringFromIndex:timeString.length-8] withString:selectClockTimer];
            NSLog(@"APP内响铃闹钟 响铃时间 : %@",clockTimer);
            model.clockTimer = clockTimer;
            [AlarmClockModel SaveAlarmClockWithModel:model];
        }
    }
    
    
    
    
    
}

#pragma mark - 同步
-(void)synchronization
{
    WS(weakSelf);
    NSLog(@"同步!!!!");
    //    [SVProgressHUD showProgress:0 status:NSLocalizedString(@"Synchronizationing", nil)];
    [SVProgressHUD showProgress:0 status:[NSString stringWithFormat:@"%@0%%", NSLocalizedString(@"Synchronizationing", nil)]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *lastSynchronizationDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"lastSynchronizationTime"]];
    NSString *lastSynchronizationTime  =  lastSynchronizationDict[[MSCoreManager sharedManager].userModel.deviceCode];
    self.synchronizationCount = 0;
    
    //判断某个时间距离现在已经过了多久
    int num = [UIFactory getUTCFormateDate:[UIFactory stringReturnDate:lastSynchronizationTime]];
    if(num < 6)
    {
        //如果是，就同步上一次同步日期（包含）到今天的所有数据
        self.totalCount = (num+1) *2;
    }
    else
    {
        //如果不在7天之内，就同步7天数据
        self.totalCount = 14;
    }
    
    //同步回调
    self.manager.synchronizationBlock = ^(int count) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.synchronizationCount++;
            if (weakSelf.synchronizationCount != weakSelf.totalCount)
            {
                [SVProgressHUD showProgress:(float)weakSelf.synchronizationCount/weakSelf.totalCount status:[NSString stringWithFormat:@"%@%.0f%%", NSLocalizedString(@"Synchronizationing", nil),(float)weakSelf.synchronizationCount/weakSelf.totalCount*100]];
                
            }else
            {
                [SVProgressHUD popActivity];
                lastSynchronizationDict[[MSCoreManager sharedManager].userModel.deviceCode] = [UIFactory dateForNumString:[NSDate date]];
                [defaults setObject:lastSynchronizationDict forKey:@"lastSynchronizationTime"];
                [defaults synchronize];
            }
        });
        
    };
    
    if(num < 6)
    {
        //如果是，就同步上一次同步日期（包含）到今天的所有数据
        [self.manager getTurnOverHistoricalData:num+1];
        
    }
    else
    {
        //如果不在7天之内，就同步7天数据
        [self.manager getTurnOverHistoricalData:7];
        
    }
}

//左栏回调
-(void)menuBtnTouch
{
    if (self.leftMenuV.hidden)
    {
        [self.leftMenuV showView];
        
    }else
    {
        [self.leftMenuV hiddenView];
    }
}

-(void)setUI
{
    WS(weakSelf);
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
    if (self.manager.isConnect)
    {
        self.blueToothBtn.selected = YES;
        
    }else
    {
        self.blueToothBtn.selected = NO;
    }
    [self.view addSubview:self.blueToothBtn];
    [self.blueToothBtn mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(0);
        make.height.equalTo(@44);
        make.width.equalTo(@54);
        
    }];
    [self.blueToothBtn addTarget:self action:@selector(blueTooth:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *fImageV = [[UIImageView alloc]init];
    fImageV.image = [UIImage imageNamed:@"sleep_animation_1"];
    [self.view addSubview:fImageV];
    fImageV.alpha = 0;
    [fImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+94);
        make.left.mas_equalTo(weakSelf.view.mas_centerX).offset(-27);
        make.width.equalTo(@43.5);
        make.height.equalTo(@81);
        
    }];
    
    UIImageView *sImageV = [[UIImageView alloc]init];
    sImageV.image = [UIImage imageNamed:@"sleep_animation_3"];
    [self.view addSubview:sImageV];
    sImageV.alpha = 0;
    [sImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+38);
        make.left.mas_equalTo(weakSelf.view.mas_centerX).offset(8);
        make.width.equalTo(@34.5);
        make.height.equalTo(@34.5);
        
    }];
    
    UIImageView *tImageV = [[UIImageView alloc]init];
    tImageV.image = [UIImage imageNamed:@"sleep_animation_2"];
    [self.view addSubview:tImageV];
    tImageV.alpha = 0;
    [tImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+90);
        make.left.mas_equalTo(weakSelf.view.mas_centerX).offset(20);
        make.width.equalTo(@24);
        make.height.equalTo(@29);
        
    }];
    
    [UIView animateWithDuration:0.5f animations:^{
        fImageV.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            tImageV.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                sImageV.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
    
    UIImageView *rrImageV = [[UIImageView alloc]init];
    rrImageV.image = [UIImage imageNamed:@"sleep_bg_heart"];
    [self.view addSubview:rrImageV];
    [rrImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(0);
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+124);
        make.centerY.mas_equalTo(weakSelf.view).offset(10);
        make.width.equalTo(@161.5);
        make.height.equalTo(@333.5);
    }];
    
    UIButton *rrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rrBtn setImage:[UIImage imageNamed:@"sleep_icon_breath"] forState:UIControlStateNormal];
    [self.view addSubview:rrBtn];
    [rrBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(93);
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+254);
        make.centerY.mas_equalTo(rrImageV).offset(-17);
        make.width.equalTo(@41);
        make.height.equalTo(@41);
    }];
    [rrBtn addTarget:self action:@selector(realTime) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *respiratoryRateUnitLabel = [[UILabel alloc]init];
    [self.view addSubview:respiratoryRateUnitLabel];
    respiratoryRateUnitLabel.text = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
    respiratoryRateUnitLabel.font = [UIFont systemFontOfSize:9];
    respiratoryRateUnitLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    CGSize rrTextSize = [respiratoryRateUnitLabel.text sizeWithAttributes:@{NSFontAttributeName:respiratoryRateUnitLabel.font}];
    [respiratoryRateUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(rrBtn.mas_left).offset(-9);
        make.width.equalTo(@(rrTextSize.width+1));
        make.height.equalTo(@9);
        make.centerY.equalTo(rrBtn);
        
    }];
    
    self.respiratoryRateLabel = [[UILabel alloc]init];
    [self.view addSubview:self.respiratoryRateLabel];
    self.respiratoryRateLabel.text = @"-";
    self.respiratoryRateLabel.font = [UIFont systemFontOfSize:16];
    self.respiratoryRateLabel.textAlignment = NSTextAlignmentRight;
    self.respiratoryRateLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    [self.respiratoryRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(respiratoryRateUnitLabel.mas_left).offset(-5);
        make.centerY.equalTo(rrBtn);
        make.width.equalTo(@30);
        make.height.equalTo(@16);
        
    }];
    
    UIImageView *hrImageV = [[UIImageView alloc]init];
    hrImageV.image = [UIImage imageNamed:@"sleep_bg_breath"];
    [self.view addSubview:hrImageV];
    [hrImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(0);
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+124);
        make.centerY.mas_equalTo(weakSelf.view).offset(10);
        make.width.equalTo(@161.5);
        make.height.equalTo(@333.5);
    }];
    
    UIButton *hrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hrBtn setImage:[UIImage imageNamed:@"sleep_icon_heartrate"] forState:UIControlStateNormal];
    [self.view addSubview:hrBtn];
    [hrBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-93);
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+254);
        make.centerY.mas_equalTo(hrImageV).offset(-17);
        make.width.equalTo(@41);
        make.height.equalTo(@41);
    }];
    [hrBtn addTarget:self action:@selector(realTime) forControlEvents:UIControlEventTouchUpInside];

    
    self.heartRateLabel = [[UILabel alloc]init];
    [self.view addSubview:self.heartRateLabel];
    self.heartRateLabel.text = @"-";
    self.heartRateLabel.font = [UIFont systemFontOfSize:16];
    self.heartRateLabel.textAlignment = NSTextAlignmentLeft;
    self.heartRateLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    CGSize hrTextSize = [self.heartRateLabel.text sizeWithAttributes:@{NSFontAttributeName:self.heartRateLabel.font}];
    [self.heartRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(hrBtn);
        make.width.equalTo(@(hrTextSize.width+1));
        make.height.equalTo(@16);
        make.left.mas_equalTo(hrBtn.mas_right).offset(9);
    }];
    
    UILabel *heartRateUnitLabel = [[UILabel alloc]init];
    [self.view addSubview:heartRateUnitLabel];
    heartRateUnitLabel.text = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
    heartRateUnitLabel.font = [UIFont systemFontOfSize:9];
    heartRateUnitLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    CGSize textSize = [heartRateUnitLabel.text sizeWithAttributes:@{NSFontAttributeName:heartRateUnitLabel.font}];
    [heartRateUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(hrBtn);
        make.left.mas_equalTo(weakSelf.heartRateLabel.mas_right).offset(5);
        make.width.equalTo(@(textSize.width+1));
        make.height.equalTo(@16);
    }];

    self.clockImageV = [[UIImageView alloc]init];
    self.clockImageV.image = [UIImage imageNamed:@"sleep_bg_alarm"];
    [self.view addSubview:self.clockImageV];
    self.clockImageV.userInteractionEnabled = YES;
    [self.clockImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight+61);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@199);
        make.height.equalTo(@148);
    }];
    
    self.alarmClockView = [[UIView alloc]init];
    self.alarmClockView.userInteractionEnabled = YES;
    [self.alarmClockView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alarmClock)]];
    [self.clockImageV addSubview:self.alarmClockView];
    
    self.alarmClockIV = [[UIImageView alloc]init];
    [self.alarmClockView addSubview:self.alarmClockIV];
    self.alarmClockIV.image = [UIImage imageNamed:@"sleep_icon_alarm"];
    [self.alarmClockIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.alarmClockView.mas_top).offset(0.5);
        make.left.equalTo(weakSelf.alarmClockView);
        make.width.height.equalTo(@18);
    }];
    
    self.alarmClockLabel = [[UILabel alloc]init];
//    self.alarmClockLabel.backgroundColor = [UIColor blackColor];
    [self.alarmClockView addSubview:self.alarmClockLabel];
    self.alarmClockLabel.text = NSLocalizedString(@"SMVC_NoClock", nil);
    self.alarmClockLabel.font = [UIFont systemFontOfSize:16];
    self.alarmClockLabel.textAlignment = NSTextAlignmentLeft;
    self.alarmClockLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    CGSize alarmSize = [self.alarmClockLabel.text sizeWithAttributes:@{NSFontAttributeName:self.alarmClockLabel.font}];
    [self.alarmClockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(18+9+alarmSize.width+1));
        make.height.equalTo(@18);
        make.centerX.equalTo(weakSelf.clockImageV);
        make.top.mas_equalTo(weakSelf.clockImageV.mas_top).offset(28);
    }];
    [self.alarmClockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(alarmSize.width+1));
        make.centerY.equalTo(weakSelf.alarmClockView);
        make.left.mas_equalTo(weakSelf.alarmClockIV.mas_right).offset(9);
    }];
    
    UIImageView *sleepImageV = [[UIImageView alloc]init];
    sleepImageV.image = [UIImage imageNamed:@"sleep_btn_sleep"];
    [self.view addSubview:sleepImageV];
    [sleepImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@275);
        make.height.equalTo(@91);
    }];
    
    self.sleepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sleepBtn setTitle:NSLocalizedString(@"SMVC_StartSleep", nil) forState:UIControlStateNormal];
    [self.sleepBtn setTitle:NSLocalizedString(@"SMVC_FinishSleep", nil) forState:UIControlStateSelected];
    [self.sleepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sleepBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    self.sleepBtn.selected = self.isOpenHrRrNotify;
    [self.view addSubview:self.sleepBtn];
    [self.sleepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sleepImageV);
        make.centerY.mas_equalTo(sleepImageV).offset(8);
//        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-18);
//        make.width.equalTo(@108);
//        make.height.equalTo(@40);
        make.width.mas_equalTo(sleepImageV).offset(-40);
        make.height.mas_equalTo(sleepImageV).offset(-30);
        
    }];
    [self.sleepBtn addTarget:self action:@selector(sleep:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *bottomV = [[UIView alloc]init];
    bottomV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomV];
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@(-kTabbarSafeHeight));
    }];
    
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

-(void)setUI2
{
    WS(weakSelf);
    
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.autoSleepMonitor = [[defaults objectForKey:@"AutoSleepMonitor"] intValue];
    
    self.alertLabel = [[UILabel alloc]init];
    [self.view addSubview:self.alertLabel];
    self.alertLabel.font = [UIFont systemFontOfSize:17];
    self.alertLabel.textAlignment = NSTextAlignmentCenter;
    self.alertLabel.textColor = [UIColor whiteColor];
    self.alertLabel.text = NSLocalizedString(@"BTM_FailToConnectPeripheral", nil);
    CGSize alertTextSize = [self.alertLabel.text sizeWithAttributes:@{NSFontAttributeName:self.alertLabel.font}];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@(alertTextSize.width+5));
    }];
    
    self.helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.helpBtn setImage:[UIImage imageNamed:@"sleep_icon_help"] forState:UIControlStateNormal];
    self.helpBtn.hidden = NO;
    [self.view addSubview:self.helpBtn];
    [self.helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+4);
        make.left.mas_equalTo(weakSelf.alertLabel.mas_right).offset(0);
        make.width.height.equalTo(@36);
    }];
    [self.helpBtn addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    
    if(!self.autoSleepMonitor){
        self.alertLabel.hidden = YES;
        self.helpBtn.hidden = YES;
    }
    
    self.blueToothBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.blueToothBtn setImage:[UIImage imageNamed:@"sleep_icon_bd"] forState:UIControlStateNormal];
    [self.blueToothBtn setImage:[UIImage imageNamed:@"sleep_icon_blue"] forState:UIControlStateSelected];
    self.blueToothBtn.selected = NO;
    [self.view addSubview:self.blueToothBtn];
    [self.blueToothBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(0);
        make.width.equalTo(@50);
        make.height.equalTo(@44);
    }];
    [self.blueToothBtn addTarget:self action:@selector(blueTooth:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setImage:[UIImage imageNamed:@"sleep_icon_setting"] forState:UIControlStateNormal];
    [self.view addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.right.mas_equalTo(weakSelf.blueToothBtn.mas_left).offset(0);
        make.width.equalTo(@45);
        make.height.equalTo(@44);
    }];
    [settingBtn addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *realTimeView = [[UIView alloc]init];
    [self.view addSubview:realTimeView];
    [realTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+95);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
        make.height.equalTo(@53);
    }];
    [realTimeView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(realTime)]];
    
    //    //心率
    //
    UILabel *heartRateUnitLabel = [[UILabel alloc]init];
    [realTimeView addSubview:heartRateUnitLabel];
    heartRateUnitLabel.text = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
    heartRateUnitLabel.font = [UIFont systemFontOfSize:14];
    heartRateUnitLabel.textColor = [UIColor whiteColor];
    CGSize textSize = [heartRateUnitLabel.text sizeWithAttributes:@{NSFontAttributeName:heartRateUnitLabel.font}];
    [heartRateUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(realTimeView.mas_top).offset(30);
        make.right.mas_equalTo(realTimeView.mas_centerX).offset(-kMargin);
        make.width.equalTo(@(textSize.width+5));
        make.height.equalTo(@23);
    }];
    
    UIImageView *heartRateIV = [[UIImageView alloc]init];
    [realTimeView addSubview:heartRateIV];
    heartRateIV.image = [UIImage imageNamed:@"sleep_icon_bpm"];
    [heartRateIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(realTimeView.mas_top).offset(4);
        make.left.equalTo(heartRateUnitLabel);
        make.width.height.equalTo(@21);
    }];
    
    self.heartRateLabel = [[UILabel alloc]init];
    [realTimeView addSubview:self.heartRateLabel];
    self.heartRateLabel.text = @"— —";
    self.heartRateLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightMedium];
    self.heartRateLabel.textAlignment = NSTextAlignmentRight;
    self.heartRateLabel.textColor = [UIColor whiteColor];
    [self.heartRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.equalTo(realTimeView);
        make.right.mas_equalTo(heartRateIV.mas_left).offset(-6);
    }];
    
    //呼吸率
    
    self.respiratoryRateLabel = [[UILabel alloc]init];
    [realTimeView addSubview:self.respiratoryRateLabel];
    self.respiratoryRateLabel.text = @"— —";
    self.respiratoryRateLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightMedium];
    self.respiratoryRateLabel.textAlignment = NSTextAlignmentRight;
    self.respiratoryRateLabel.textColor = [UIColor whiteColor];
    [self.respiratoryRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(realTimeView);
        make.left.mas_equalTo(realTimeView.mas_centerX).offset(kMargin);
        make.width.equalTo(@80);
    }];
    
    UILabel *respiratoryRateUnitLabel = [[UILabel alloc]init];
    [realTimeView addSubview:respiratoryRateUnitLabel];
    respiratoryRateUnitLabel.text = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
    respiratoryRateUnitLabel.font = [UIFont systemFontOfSize:14];
    respiratoryRateUnitLabel.textColor = [UIColor whiteColor];
    [respiratoryRateUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(realTimeView.mas_top).offset(30);
        make.width.equalTo(@(textSize.width+5));
        make.height.equalTo(heartRateUnitLabel);
        make.left.mas_equalTo(weakSelf.respiratoryRateLabel.mas_right).offset(6);
    }];
    
    UIImageView *respiratoryRateIV = [[UIImageView alloc]init];
    [realTimeView addSubview:respiratoryRateIV];
    respiratoryRateIV.image = [UIImage imageNamed:@"sleep_icon_bm"];
    [respiratoryRateIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.equalTo(heartRateIV);
        make.left.equalTo(respiratoryRateUnitLabel);
    }];
    
    
    
    self.alarmClockView = [[UIView alloc]init];
    self.alarmClockView.userInteractionEnabled = YES;
    [self.alarmClockView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alarmClock)]];
    [self.view addSubview:self.alarmClockView];
    
    
    self.alarmClockIV = [[UIImageView alloc]init];
    [self.alarmClockView addSubview:self.alarmClockIV];
    self.alarmClockIV.image = [UIImage imageNamed:@"sleep_icon_clock"];
    [self.alarmClockIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.alarmClockView.mas_top).offset(5.5);
        make.left.equalTo(weakSelf.alarmClockView);
        make.width.height.equalTo(@19);
    }];
    
    self.alarmClockLabel = [[UILabel alloc]init];
    [self.view addSubview:self.alarmClockLabel];
    self.alarmClockLabel.text = NSLocalizedString(@"SMVC_NoClock", nil);
    self.alarmClockLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.alarmClockLabel.textAlignment = NSTextAlignmentCenter;
    self.alarmClockLabel.textColor = [UIColor whiteColor];
    CGSize alarmSize = [self.alarmClockLabel.text sizeWithAttributes:@{NSFontAttributeName:self.alarmClockLabel.font}];
    [self.alarmClockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(realTimeView.mas_bottom).offset(14);
        make.width.equalTo(@(19+6+alarmSize.width+5));
        make.height.equalTo(@30);
        make.centerX.equalTo(weakSelf.view);
    }];
    [self.alarmClockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(weakSelf.alarmClockView);
        make.left.mas_equalTo(weakSelf.alarmClockIV.mas_right).offset(6);
        make.height.equalTo(@30);
    }];
    
    
    UIImageView *sleepBtnIV = [[UIImageView alloc]init];
    [self.view addSubview:sleepBtnIV];
    sleepBtnIV.image = [UIImage imageNamed:@"sleepbtn_bg"];
    [sleepBtnIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.alarmClockView.mas_bottom).offset(88);
        make.centerX.equalTo(weakSelf.view);
        make.width.height.equalTo(@200);
    }];
    
    self.sleepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sleepBtn setTitle:NSLocalizedString(@"SMVC_StartSleep", nil) forState:UIControlStateNormal];
    [self.sleepBtn setTitle:NSLocalizedString(@"SMVC_FinishSleep", nil) forState:UIControlStateSelected];
    [self.sleepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sleepBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.sleepBtn.backgroundColor = [UIColor colorWithHexString:@"#9d9fb3"];
    self.sleepBtn.layer.cornerRadius = 54;
    [self.view addSubview:self.sleepBtn];
    [self.sleepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(sleepBtnIV);
        make.width.height.equalTo(@108);
    }];
    [self.sleepBtn addTarget:self action:@selector(sleep:) forControlEvents:UIControlEventTouchUpInside];
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
