//
//  WelcomePageViewController.m
//  SleepBand
//
//  Created by admin on 2018/8/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "WelcomePageViewController.h"
#import "AppDelegate.h"

@interface WelcomePageViewController ()

@property (strong,nonatomic)NSTimer *sendTimer;
@property (assign,nonatomic)int sendTime;

@end

@implementation WelcomePageViewController
-(void)dealloc
{
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    
}
//-(BOOL)prefersStatusBarHidden
//{
//    return YES;//隐藏为YES，显示为NO
//}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏=YES,显示=NO; Animation:动画效果
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //隐藏=YES,显示=NO; Animation:动画效果
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
}

-(void)countDown
{
    if (self.sendTime == 1)
    {
        [self.sendTimer setFireDate:[NSDate distantFuture]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"0" forKey:@"isLogin"];
        [defaults synchronize];
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate setRootViewControllerForLogin];
        
    }else
    {
        self.sendTime --;
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    WS(weakSelf);
//    [self prefersStatusBarHidden];
//    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
       
    
//    UIColor *bgColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"launch"]];
//    self.view.backgroundColor = bgColor;
//    self.view.backgroundColor = [UIColor whiteColor];
//    UIImageView *launchIV = [[UIImageView alloc]init];
//    launchIV.contentMode = UIViewContentModeScaleAspectFill;
//    launchIV.image  = [UIImage imageNamed:@"startPhoto"];
//    [self.view addSubview:launchIV];
//    [launchIV mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.top.left.right.bottom.equalTo(weakSelf.view);
//
//    }];
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        LKDBHelper *dbHelper  = [[LKDBHelper alloc] initWithDBName:@"LKDB"];
        
        if ([defaults stringForKey:@"sleepTime"].length == 0)
        {
            
            [defaults setObject:@"22:00" forKey:@"sleepTime"];
            [defaults synchronize];
            
        }
        if([defaults arrayForKey:@"weekMonthCustom"].count == 0)
        {
            
            [defaults setObject:@[@"0",@"1",@"6"] forKey:@"weekMonthCustom"];
            [defaults synchronize];
            
        }
        
        //    没登录就跳到登录界面
        if ([defaults stringForKey:@"isLogin"].length == 0 || [[defaults stringForKey:@"isLogin"] isEqualToString:@"0"])
        {
            [delegate setRootViewControllerForLogin];
            
        }
        else
        {
            self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
            self.sendTime = 10;
            [self.sendTimer setFireDate:[NSDate date]];
            
            //自动登录 13828828394 1325
            NSDictionary *loginMessage = [defaults objectForKey:@"LoginMessage"];
            NSString *password = [SAMKeychain passwordForService:@"com.keychainSleepBandLoginAccount.data" account:loginMessage[@"account"]];
            if (password.length == 0) {
                [defaults setObject:@"0" forKey:@"isLogin"];
                [defaults synchronize];
                [delegate setRootViewControllerForLogin];
            }else{
                
                NSString * phoneNumber;
                NSString * email;
                NSString * account = [loginMessage objectForKey:@"account"];
                if ([account rangeOfString:@"."].length > 0) {
                    email = account;
                    phoneNumber = @"";
                }else{
                    email = @"";
                    phoneNumber = account;
                }
                NSDictionary *loginForData = @{
                                       @"areaCode":[loginMessage objectForKey:@"countryCode"],
                                       @"phoneNumber":phoneNumber,
                                       @"password":password,
                                       @"project":@"sleep",
                                       @"type":phoneNumber.length>0 ? @"1" : @"2",
                                       @"email":email};
                
                [[MSCoreManager sharedManager] postLoginForData:loginForData WithResponse:^(ResponseInfo *info) {
                    [weakSelf.sendTimer setFireDate:[NSDate distantFuture]];
                    if ([info.code isEqualToString:@"200"]) {
                        [[MSCoreManager sharedManager].httpManager setRequestHeader:@{@"token":info.data[@"token"]}];

                        //创建用户
                        [MSCoreManager sharedManager].userModel = [UserModel mj_objectWithKeyValues:info.data[@"userInfo"]];
                        [MSCoreManager sharedManager].userModel.token = info.data[@"token"];
                        
                        [defaults setObject:[MSCoreManager sharedManager].userModel.deviceCode forKey:@"lastConnectDevice"];
                        [defaults synchronize];
                        //已登录有连接过设备就跳到主界面，并在主界面连接设备
                        if ([defaults stringForKey:@"lastConnectDevice"].length > 1) {
                             //xu测试 - 1 - 当前UI调试界面,调试完毕后后删除 并打开下一行注释代码
//                            [delegate setRootViewControllerForReport];
                            [delegate setRootViewControllerForSleep];
                        }else{
                            //已登录没有连接过设备就跳到选择设备界面
                            [delegate setRootViewControllerForSearch];
                        }
                    }else{
                        [defaults setObject:@"0" forKey:@"isLogin"];
                        [defaults synchronize];
                        [delegate setRootViewControllerForLogin];
                    }
                }];
            }
        }
        
    });
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
