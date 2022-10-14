//
//  DeviceUpdateViewController.m
//  SleepBand
//
//  Created by admin on 2018/8/23.
//  Copyright © 2018年 admin. All rights reserved.
//


//#import "DeviceUpdateViewController.h"
//#import "AppDelegate.h"
//
//@interface DeviceUpdateViewController ()
//
//@end
//
//@implementation DeviceUpdateViewController
//@end


#import "DeviceUpdateViewController.h"
//#import <iOSDFULibrary/iOSDFULibrary-Swift.h>
//#import "SleepBand-Swift.h"
#import "AppDelegate.h"

@import iOSDFULibrary;

@interface DeviceUpdateViewController ()<LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate>
@property (strong,nonatomic) UILabel *currentVersionLabel;
@property (strong,nonatomic) UILabel *updateVersionLabel;
@property (strong,nonatomic) UIImageView *iView;
@property (strong,nonatomic) UIButton *updateBtn;
@property (strong,nonatomic) MSCoreManager *coreManager;
@property (strong,nonatomic) BlueToothManager *blueToothManager;
@property (copy,nonatomic) NSString *updateUrl;
@property (copy,nonatomic) NSString *updateVersion;
@property (copy,nonatomic) NSURL *filePath;
@property (strong, nonatomic) DFUServiceController *controller;
@property (strong, nonatomic) DFUFirmware *selectedFirmware;
@end

static int Qcount = 0;

@implementation DeviceUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coreManager = [MSCoreManager sharedManager];
    self.blueToothManager = [BlueToothManager shareIsnstance];
    [self setUI];
    [self getUpdateInformation];
    
}
-(void)getUpdateInformation{
    WS(weaksSelf);
    [SVProgressHUD show];
    //设备升级
    [self.coreManager getDeviceUpdateForData:@{@"versionNumber":[NSString stringWithFormat:@"v%@_%@",self.hardwareVersion,self.softwareVersion]} WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            [SVProgressHUD dismiss];
            NSLog(@"info.data = %@",info.data);

            NSNumber * boolNum = info.data[@"hasNewVersion"];
            BOOL hasNewVersion = [boolNum boolValue];
            if (!hasNewVersion) return ;

            NSRange range = [info.data[@"versionNumber"] rangeOfString:@"_"];
            weaksSelf.updateVersion = [info.data[@"versionNumber"] substringFromIndex:range.location+1];
            weaksSelf.updateVersionLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"MDVC_NewestVersion", nil),[info.data objectForKey:@"versionNumber"]];

            weaksSelf.updateUrl = info.data[@"url"];
            weaksSelf.updateBtn.hidden = [weaksSelf.updateVersion isEqualToString:weaksSelf.softwareVersion];

        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MDVC_NewestVersionError", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)update{
    WS(weakSelf);
//    [SVProgressHUD showProgress:0 status:[NSString stringWithFormat:@"%@0%%", NSLocalizedString(@"Updateing", nil)]];
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    self.coreManager.downloadBlock = ^(NSURL *filePath, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UpdateError", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }else{
//            [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"dfu15.2_SP18" ofType:@"zip"]];
            NSLog(@"filePath = %@",filePath);
            weakSelf.filePath = filePath;
            [weakSelf updateDevice];
        }
        
    };
    self.coreManager.downloadProgressBlock = ^(long totalCount, long completedCount) {
        if (totalCount != completedCount) {
            [SVProgressHUD showProgress:(float)completedCount/totalCount status:[NSString stringWithFormat:@"%@%.0f%%", NSLocalizedString(@"Updateing", nil),(float)completedCount/totalCount*100]];
        }else{
            [SVProgressHUD popActivity];
        }
    };
    [self.coreManager updateDeviceForUrl:self.updateUrl];
}

-(void)updateDevice{
    WS(weakSelf);
    self.blueToothManager.connectPeripheralBlock = ^(BOOL isSuccess) {
        [SVProgressHUD popActivity];
        weakSelf.updateBtn.hidden = YES;
        if (isSuccess) {
            if (weakSelf.updateBlock) {
                weakSelf.updateBlock(weakSelf.updateVersion);
            }

        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BTM_FailToConnectPeripheral", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            [delegate.mainTabBar.sleepView deviceDisconnectState];
        }
    };
    self.blueToothManager.isUpdateManualCancelConnect = YES;
    self.blueToothManager.manualCancelConnectBlock = ^{


        Qcount++;
        NSString * Qname = [NSString stringWithFormat:@"com.nRF.customQueue%d",Qcount];
        NSLog(@"Qname = %@ , Qcount = %d",Qname,Qcount);
        const char *charString = NULL;
        charString = [Qname cStringUsingEncoding:NSUTF8StringEncoding];
        //DISPATCH_QUEUE_CONCURRENT
        dispatch_queue_t queue = dispatch_queue_create(charString, NULL);
//        dispatch_queue_t eventQueue = dispatch_queue_create("com.ota.updater", DISPATCH_QUEUE_CONCURRENT);
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc]initWithQueue:queue delegateQueue:queue progressQueue:queue loggerQueue:queue centralManagerOptions:nil];
//        DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithQueue:queue]; //recommend
         
        weakSelf.selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:weakSelf.filePath type:DFUFirmwareTypeApplication error:nil];

        initiator = [initiator withFirmware:weakSelf.selectedFirmware];
        initiator.forceDfu = [[[NSUserDefaults standardUserDefaults] valueForKey:@"dfu_force_dfu"] boolValue];
        initiator.packetReceiptNotificationParameter = [[[NSUserDefaults standardUserDefaults] valueForKey:@"dfu_number_of_packets"] intValue];
        initiator.logger = weakSelf;
        initiator.delegate = weakSelf;
        initiator.progressDelegate = weakSelf;
        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = YES;
        weakSelf.controller = [initiator startWithTarget:weakSelf.blueToothManager.currentPeripheral];
        weakSelf.blueToothManager.isUpdateManualCancelConnect = NO;
        if (weakSelf.selectedFirmware && weakSelf.selectedFirmware.fileName ) {
            NSLog(@"支持该文件");
        }else{
            NSLog(@"不支持该文件");
        }
    };
    //唤醒升级模式
    [self.blueToothManager upDataDeviceVersions];



}
#pragma mark - DFU Service delegate
//日志打印
-(void)logWith:(enum LogLevel)level message:(NSString *)message
{
    NSLog(@"日志打印 - %ld: %@", (long) level, message);
}
//更新进度状态  升级开始。。升级中断。。升级完成
-(void)dfuStateDidChangeTo:(enum DFUState)state
{
    switch (state) {
        case DFUStateConnecting:
            NSLog(@"Connecting...（连接：服务正在连接到DFU目标）");
            break;
        case DFUStateStarting:
            NSLog(@"Starting DFU...(启动：DFU服务正在初始化DFU操作)");
            break;
        case DFUStateEnablingDfuMode:
            NSLog(@"Enabling DFU Bootloader...(服务正在将设备切换到DFU模式)");
            break;
        case DFUStateUploading:
            NSLog(@"Uploading...(上传：服务正在上传固件)");
            break;
        case DFUStateValidating:
            NSLog(@"Validating...(验证：DFU目标正在验证固件)");
            break;
        case DFUStateDisconnecting:
            NSLog(@"Disconnecting...(iDevice正在断开连接或等待断开连接)");
            break;
        case DFUStateCompleted:{
            NSLog(@"Upload complete(完成：DFU操作完成并成功)");
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"UpdateSuccess", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            self.currentVersionLabel.text = [NSString stringWithFormat:@"%@v%@_%@",NSLocalizedString(@"MDVC_NewestVersion", nil),self.hardwareVersion,self.updateVersion];
            [self.blueToothManager createCentralManager];
        }
            break;
        case DFUStateAborted:
            NSLog(@"Upload aborted(DFU操作已中止)");
            break;
        default:
            break;
    }
}
//更新进度
- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond{

//    NSLog(@"更新进度 - part:%ld, totalParts:%ld, progress:%ld, currentSpeedBytesPerSecond:%f, avgSpeedBytesPerSecond:%f", part, totalParts, progress, currentSpeedBytesPerSecond, avgSpeedBytesPerSecond);
    //打印更新进度
//    self.progress.progress = progress / 100.0;
//    NSLog(@"%@",[NSString stringWithFormat:@"%ld%% (%ld/%ld)",progress,part,totalParts]);
    [SVProgressHUD showProgress:progress/100.0 status:[NSString stringWithFormat:@"%@%.0ld%%", NSLocalizedString(@"Updateing", nil),(long)progress]];
}
//升级error信息
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message{

    NSLog(@"Error %ld: %@", (long) error, message);
    [SVProgressHUD popActivity];
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UpdateError", nil)];
    [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];

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
    titleLabel.text = NSLocalizedString(@"MDVC_FirmwareTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];

    self.iView = [[UIImageView alloc]init];
    self.iView.image = [UIImage imageNamed:@"me_version_icon"];
    [self.view addSubview: self.iView];
    [self.iView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+12);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.width.height.equalTo(@48);
    }];

    self.currentVersionLabel = [[UILabel alloc]init];
    [self.view addSubview:self.currentVersionLabel];
    self.currentVersionLabel.text = [NSString stringWithFormat:@"%@v%@_%@",NSLocalizedString(@"MDVC_CurrentVersion", nil),self.hardwareVersion,self.softwareVersion];
    self.currentVersionLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    self.currentVersionLabel.textAlignment = NSTextAlignmentLeft;
    self.currentVersionLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    [self.currentVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.iView);
        make.left.mas_equalTo(weakSelf.iView.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.width.equalTo(@150);
        make.height.equalTo(@14);
    }];

    self.updateVersionLabel = [[UILabel alloc]init];
    [self.view addSubview:self.updateVersionLabel];
    self.updateVersionLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"MDVC_NewestVersion", nil)];
    self.updateVersionLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    self.updateVersionLabel.textAlignment = NSTextAlignmentLeft;
    self.updateVersionLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    [self.updateVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.iView);
        make.left.mas_equalTo(weakSelf.iView.mas_right).offset(10);
        make.width.equalTo(@150);
        make.height.equalTo(@14);
    }];

    self.updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.updateBtn];
    self.updateBtn.hidden = YES;
    [self.updateBtn setImage:[UIImage imageNamed:@"me_version_btn_update"] forState:UIControlStateNormal];
    [self.updateBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@31);
        make.height.equalTo(@25);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+23.5);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
    }];

    UIView *lineView = [[UIView alloc]init];
    [self.view addSubview:lineView];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+72);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
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
    titleLabel.text = NSLocalizedString(@"MDVC_FirmwareTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];

    UIView *bgView = [[UIView alloc]init];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = kAlpha;
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.height.equalTo(@78);
    }];

    self.iView = [[UIImageView alloc]init];
    self.iView.image = [UIImage imageNamed:@"my_icon_versions"];
    [self.view addSubview: self.iView];
    [self.iView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bgView);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
        make.width.height.equalTo(@48);
    }];

    self.currentVersionLabel = [[UILabel alloc]init];
    [self.view addSubview:self.currentVersionLabel];
    self.currentVersionLabel.text = [NSString stringWithFormat:@"%@V%@",NSLocalizedString(@"MDVC_CurrentVersion", nil),self.softwareVersion];
    self.currentVersionLabel.textColor = [UIColor whiteColor];
    self.currentVersionLabel.textAlignment = NSTextAlignmentLeft;
    self.currentVersionLabel.font = [UIFont systemFontOfSize:16];
    [self.currentVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.iView);
        make.left.mas_equalTo(weakSelf.iView.mas_right).offset(10);
        make.width.equalTo(@150);
        make.height.equalTo(@20);
    }];

    self.updateVersionLabel = [[UILabel alloc]init];
    [self.view addSubview:self.updateVersionLabel];
    self.updateVersionLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"MDVC_NewestVersion", nil)];
    self.updateVersionLabel.textColor = [UIColor whiteColor];
    self.updateVersionLabel.textAlignment = NSTextAlignmentLeft;
    self.updateVersionLabel.font = [UIFont systemFontOfSize:16];
    [self.updateVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.iView);
        make.left.mas_equalTo(weakSelf.iView.mas_right).offset(10);
        make.width.equalTo(@150);
        make.height.equalTo(@20);
    }];

    self.updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.updateBtn];
    self.updateBtn.hidden = YES;
    [self.updateBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [self.updateBtn setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
    self.updateBtn.backgroundColor = [UIColor whiteColor];
    self.updateBtn.layer.cornerRadius = 10;
    self.updateBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.updateBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@35);
        make.centerY.equalTo(bgView);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
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
