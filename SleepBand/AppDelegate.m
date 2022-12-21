//
//  AppDelegate.m
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomePageViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    //    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
    //        NSLog(@"%@",requests);
    //    }];
    
    
    //    NSString * startStr =@"2018-09-28 22:00:00";
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSDate *startStrD = [dateFormatter dateFromString:startStr];
    //    //测试 - 加大结束时间
    //    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    //    [adcomps setDay:100];
    //    //        [adcomps setHour:7];
    //    NSLog(@"%@",[calendar dateByAddingComponents:adcomps toDate:startStrD options:0]);
    
    
    //    NSDictionary* defaults = [NSDictionary dictionaryWithObjects:@[@"2.3", [NSNumber numberWithInt:12], @NO] forKeys:@[@"key_diameter", @"dfu_number_of_packets", @"dfu_force_dfu"]];
    //    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [self registerUserNotification];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    //关闭深夜模式
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    self.window.rootViewController = [[WelcomePageViewController alloc]initWithNibName:@"WelcomePageViewController" bundle:[NSBundle mainBundle]];
    [self.window makeKeyAndVisible];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    //设置默认服务器域名为：正式服务器
    if (!GET_NetWork_URL_Head) {
        [[NSUserDefaults standardUserDefaults] setObject:NetWork_URL_Head_cloud forKey:@"the_sleepee_http_url_head"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[IQKeyboardManager sharedManager] setEnable: YES];
    return YES;
}

//监听音量键
- (void)onVolumeChanged:(NSNotification *)notification {
    if ([[notification.userInfo objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"] isEqualToString:@"Audio/Video"]) {
        if ([[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqualToString:@"ExplicitVolumeChange"]) {
            CGFloat volume = [[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
            NSLog(@"音量大小为：%f",volume);
            self.alarmClockTool.closePlay = YES;
        }
    }
}

-(void)testAddDBData
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [path stringByAppendingPathComponent:@"db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
        //removing file
        if (![[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil])
        {
            NSLog(@"Could not remove old files. Error:");
        }
    }
    NSString *dbdataPath = [path stringByAppendingPathComponent:@"dbdata"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbdataPath])
    {
        //removing file
        if (![[NSFileManager defaultManager] removeItemAtPath:dbdataPath error:nil])
        {
            NSLog(@"Could not remove old files. Error:");
        }
    }
    
    //     NSString *dbBundlePath=[NSString stringWithFormat:@"%@/db",[[NSBundle mainBundle]resourcePath]];
    //    NSString *dbdataBundlePath=[NSString stringWithFormat:@"%@/dbdata",[[NSBundle mainBundle]resourcePath]];
    [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:dbdataPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *TurnOverModelPath = [dbdataPath stringByAppendingPathComponent:@"TurnOverModel"];
    [[NSFileManager defaultManager] createDirectoryAtPath:TurnOverModelPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *BundlePath1 = [[NSBundle mainBundle] pathForResource:@"LKDB" ofType:@"db"];
    NSString *BundlePath2 = [[NSBundle mainBundle] pathForResource:@"data9791273855" ofType:@""];
    NSString *BundlePath3 = [[NSBundle mainBundle] pathForResource:@"data953639629" ofType:@""];
    NSString *BundlePath4 = [[NSBundle mainBundle] pathForResource:@"data9536383096" ofType:@""];
    NSString *BundlePath5 = [[NSBundle mainBundle] pathForResource:@"data9536382998" ofType:@""];
    NSString *BundlePath6 = [[NSBundle mainBundle] pathForResource:@"data9536381546" ofType:@""];
    NSString *BundlePath7 = [[NSBundle mainBundle] pathForResource:@"data171571161" ofType:@""];
    NSString *BundlePath8 = [[NSBundle mainBundle] pathForResource:@"data9791563482" ofType:@""];
    NSString *BundlePath9 = [[NSBundle mainBundle] pathForResource:@"data9790373886" ofType:@""];
    NSString *BundlePath10 = [[NSBundle mainBundle] pathForResource:@"data9536383717" ofType:@""];
    NSString *BundlePath11 = [[NSBundle mainBundle] pathForResource:@"data9536393332" ofType:@""];
    NSString *BundlePath12 = [[NSBundle mainBundle] pathForResource:@"data9536393849" ofType:@""];
    
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath1 toPath:[dbPath stringByAppendingPathComponent:@"LKDB.db"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath2 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9791273855"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath3 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data953639629"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath4 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9536383096"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath5 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9536382998"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath6 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9536381546"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath7 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data171571161"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath8 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9791563482"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath9 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9790373886"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath10 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9536383717"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath11 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9536393332"] error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:BundlePath12 toPath:[TurnOverModelPath stringByAppendingPathComponent:@"data9536393849"] error:nil];
}

-(void)registerUserNotification
{
    if (@available(iOS 10.0, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //监听回调事件
        center.delegate = self;
        //iOS 10 使用以下方法注册，才能得到授权
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound +UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  
                              }];
    }else
    {
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        
    }
}

//登录注册
-(void)setRootViewControllerForLogin
{
    if (self.mainNavigation == nil)
    {
        self.mainNavigation = [[UINavigationController alloc]initWithRootViewController:[[LoginViewController alloc] initWithNibName: @"LoginViewController" bundle: [NSBundle mainBundle]]];
        
    }else
    {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.mainNavigation.viewControllers];
        [controllers removeAllObjects];
        controllers[0] = [[LoginViewController alloc] initWithNibName: @"LoginViewController" bundle: [NSBundle mainBundle]];
//        self.mainNavigation.viewControllers = controllers;
        [self.mainNavigation setViewControllers:controllers];
        
    }
    self.window.rootViewController = self.mainNavigation;
//    self.mainTabBar = nil;
    
}

//搜索
-(void)setRootViewControllerForSearch
{
    if (self.mainNavigation == nil)
    {
       self.mainNavigation = [[UINavigationController alloc]initWithRootViewController:[[SearchDeviceViewController alloc]initWithNibName:@"SearchDeviceViewController" bundle: [NSBundle mainBundle]]];
        
    }else
    {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.mainNavigation.viewControllers];
        [controllers removeAllObjects];
        
        controllers[0] = [[SearchDeviceViewController alloc]initWithNibName:@"SearchDeviceViewController" bundle: [NSBundle mainBundle]];
//        self.mainNavigation.viewControllers = controllers;
        [self.mainNavigation setViewControllers:controllers];
        
    }
    self.window.rootViewController = self.mainNavigation;
//    self.mainTabBar = nil;
    
}

//睡眠界面
-(void)setRootViewControllerForSleep
{
    if (self.mainNavigation == nil)
    {
        self.mainNavigation = [[UINavigationController alloc]initWithRootViewController:[[SleepMainViewController alloc]init]];
        
    }else
    {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.mainNavigation.viewControllers];
        [controllers removeAllObjects];
        controllers[0] = [[SleepMainViewController alloc] init];
//        self.mainNavigation.viewControllers = controllers;
        [self.mainNavigation setViewControllers:controllers];
        
    }
    self.window.rootViewController = self.mainNavigation;
//    self.mainTabBar = nil;
}

//报告界面
-(void)setRootViewControllerForReport
{
    if (self.mainNavigation == nil)
    {
        
        self.mainNavigation = [[UINavigationController alloc]initWithRootViewController:[[ReportMainViewController alloc]init]];
        
    }else
    {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.mainNavigation.viewControllers];
        [controllers removeAllObjects];
        
        controllers[0] = [[ReportMainViewController alloc] init];
        self.mainNavigation.viewControllers = controllers;
        [self.mainNavigation setViewControllers:controllers];
        
    }
    self.window.rootViewController = self.mainNavigation;
    //    self.mainTabBar = nil;
}

//报告-new
//- (void)setRootViewControllerForReportMain
//{
//    if (self.mainNavigation == nil)
//    {
//        self.mainNavigation = [[UINavigationController alloc]initWithRootViewController:[[ReportMainVC alloc]init]];
//
//    }else
//    {
//        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.mainNavigation.viewControllers];
//        [controllers removeAllObjects];
//
//        controllers[0] = [[ReportMainVC alloc] init];
//        self.mainNavigation.viewControllers = controllers;
//        [self.mainNavigation setViewControllers:controllers];
//
//    }
//    self.window.rootViewController = self.mainNavigation;
//
//}


//闹钟界面
-(void)setRootViewControllerForClock
{
    if (self.mainNavigation == nil)
    {
        self.mainNavigation = [[UINavigationController alloc]initWithRootViewController:[[AlarmClockMainViewController alloc]init]];
        
    }else
    {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.mainNavigation.viewControllers];
        [controllers removeAllObjects];
        controllers[0] = [[AlarmClockMainViewController alloc] init];
//        self.mainNavigation.viewControllers = controllers;
        [self.mainNavigation setViewControllers:controllers];
        
    }
    self.window.rootViewController = self.mainNavigation;
    //    self.mainTabBar = nil;
}

//个人界面
-(void)setRootViewControllerForMe
{
    if (self.mainNavigation == nil)
    {
        self.mainNavigation = [[UINavigationController alloc]initWithRootViewController:[[PersonalMainViewController alloc]init]];
        
    }else
    {
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.mainNavigation.viewControllers];
        [controllers removeAllObjects];
        controllers[0] = [[PersonalMainViewController alloc] init];
//        self.mainNavigation.viewControllers = controllers;
        [self.mainNavigation setViewControllers:controllers];
        
    }
    self.window.rootViewController = self.mainNavigation;
    //    self.mainTabBar = nil;
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    //关闭闹钟
    self.alarmClockTool.closePlay = YES;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if(self.window.rootViewController == self.mainTabBar)
    {
        [self.mainTabBar judgementWhetherSynchronization];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.mainTabBar)
    {
        if (self.mainTabBar.selectedIndex == 0 && self.mainTabBar.sleepView.sleepBtn.selected)
        {
            [self.mainTabBar.sleepView removeSleepAnimation];
            [self.mainTabBar.sleepView addSleepAnimation];
        }
    }
    
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0))
{
    //    NSDictionary * userInfo = notification.request.content.userInfo;
    if (@available(iOS 10.0, *))
    {
        
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {//应用处于前台时的远程推送接受
            
        } else
        {
            //应用处于前台时的本地推送接受
            completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);//
        }
    } else
    {
        // Fallback on earlier versions
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"收到本地通知");
    if (application.applicationState == UIApplicationStateActive)
    {
        //        UILocalNotification *notification = [[UILocalNotification alloc] init];
        //        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
        //        notification.repeatInterval = NSCalendarUnitDay;
        //        notification.alertBody = userInfo[@"body"];
        //        notification.timeZone = [NSTimeZone defaultTimeZone];
        //        notification.soundName = UILocalNotificationDefaultSoundName;
        //        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        [SVProgressHUD showInfoWithStatus:userInfo[@"body"]];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
