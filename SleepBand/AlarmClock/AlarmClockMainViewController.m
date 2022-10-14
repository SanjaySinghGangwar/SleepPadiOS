//
//  AlarmClockMainViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AlarmClockMainViewController.h"
#import "AlarmClockTableViewCell.h"
#import "AlarmClockModel.h"
#import "AlarmClockEditViewController.h"
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface AlarmClockMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)UITableView *alarmClockTableView;
@property (strong,nonatomic)NSMutableArray *myClockArray;
@property (strong,nonatomic)NSMutableArray *deviceClockArray;
@property (strong,nonatomic)NSMutableArray *allClockArray;
@property (strong, nonatomic)NSIndexPath* editingIndexPath;  //当前左滑cell的index，在代理方法中设置
@property (strong, nonatomic)BlueToothManager *blueToothManager;
@property (strong, nonatomic)MSCoreManager *coreManager;
@property (assign, nonatomic)int deviceClockCount;  //设备已存闹钟个数
@property (assign, nonatomic)int intelligentClockCount;//智能闹钟个数
@property (assign, nonatomic)int selectIndex;  //所选设备下标
@property (assign, nonatomic)BOOL isAlreadyShow;
@property (strong,nonatomic)UIButton *blueToothBtn;
@property (strong,nonatomic)LeftView *leftMenuV;
@property (strong,nonatomic)AlertView *alertView;
@end

@implementation AlarmClockMainViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    delegate.mainTabBar.tabBarView.hidden = NO;
    
    [self setBlueTooth];
    
    if (self.isAlreadyShow)
    {
        [self restatementBlock];
        
    }else
    {
        self.isAlreadyShow = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.blueToothManager = [BlueToothManager shareIsnstance];
    self.coreManager = [MSCoreManager sharedManager];
    
    [self setUI];
    
    [self getClockSetting];
    
    self.leftMenuV.selectControllerBlock = ^(LeftMenuType type) {
        
        if (type != LeftMenuType_Clock)
        {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (type == LeftMenuType_Report) {
                
                [delegate setRootViewControllerForReport];
                
            }else if (type == LeftMenuType_Sleep){
                
                
                [delegate setRootViewControllerForSleep];
                
                
            }else
            {
                [delegate setRootViewControllerForMe];
            }
            
        }
    };
    NSLog(@"进入闹钟页面，查看推送->打印当前存在的推送");
    [ClockTool logNotification];
    
//    NSString *str = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:[UIFactory dateForBeforeDate:[NSDate date] withDay:@"-7" withMonth:@"0"]]];
//    NSLog(@"%@",str);
}

#pragma mark - 获取设置
-(void)getClockSetting
{
    self.myClockArray = [[NSMutableArray alloc]init];
    self.deviceClockArray = [[NSMutableArray alloc]init];
    self.allClockArray = [[NSMutableArray alloc]init];
    
    //获取服务器闹钟
    [self getUserClock];
    
}

//计算智能闹钟个数
-(void)getDeviceIntelligentClockCount
{
    self.intelligentClockCount = 0;
    for (AlarmClockModel *model in self.allClockArray)
    {
        if (model.isIntelligentWake)
        {
            self.intelligentClockCount++;
        }
    }
    NSLog(@"统计智能闹钟，个数为%d",self.intelligentClockCount);
}

//计算设备闹钟个数
-(void)getDeviceClockCount
{
    self.deviceClockCount = 0 ;
    for (AlarmClockModel *model in self.allClockArray)
    {
        if (!model.isPhone) {
            self.deviceClockCount++;
            continue;
        }
        if (model.isPhone && model.isIntelligentWake)
        {
            self.deviceClockCount++;
            continue;
        }
    }
    
    [self getDeviceIntelligentClockCount];
    NSLog(@"统计设备闹钟，个数为%d",self.deviceClockCount);
}

//获取服务器闹钟
-(void)getUserClock
{
    if (self.alarmClockTableView.mj_header.isRefreshing)
    {
        [self.alarmClockTableView.mj_header endRefreshing];
    }
//    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    WS(weakSelf);
    [self.coreManager.clockArray removeAllObjects];
    [self.allClockArray removeAllObjects];
    NSLog(@"获取服务器闹钟数据");
    
    [self.coreManager getGetAlarmClockForData:nil WithResponse:^(ResponseInfo *info) {
        
        if ([info.code isEqualToString:@"200"])
        {
            NSArray * list = [info.data objectForKey:@"list"];
            NSLog(@"获取服务器闹钟数据成功,个数为%lu",(unsigned long)list.count);
            
            if (list.count > 0)
            {
                [weakSelf.coreManager.clockArray removeAllObjects];
                [weakSelf.allClockArray removeAllObjects];
                
                for (NSDictionary *dict in list)
                {
                    NSMutableDictionary * modelDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [modelDict setObject:[dict objectForKey:@"repeat"] forKey:@"repeatStr"];
                    NSMutableArray * repeat = [NSMutableArray array];
                    AlarmClockModel *model = [AlarmClockModel mj_objectWithKeyValues:modelDict];
                    model.clockId = [[modelDict objectForKey:@"id"] intValue];//12
                    if (model.repeatStr && model.repeatStr.length>0) {
                        for (int i = 0; i<7; i++) {
                            NSString * iStr = [NSString stringWithFormat:@"%d",i];
                            if([model.repeatStr containsString:iStr]) {
                                [repeat addObject:iStr];
                            }
                        }
                    }
                    model.repeat = repeat;
                    [weakSelf.coreManager.clockArray addObject:model];
                }
                [weakSelf.allClockArray addObjectsFromArray:weakSelf.coreManager.clockArray];
                //获取设备闹钟
                if (weakSelf.blueToothManager.isConnect)
                {
                    [weakSelf getDeviceClock];
                    //                    [weakSelf clockDataSort];
                    //                    [SVProgressHUD dismiss];
                }else
                {
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                    [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    [weakSelf clockDataSort];
                }
            }else
            {
                if (weakSelf.blueToothManager.isConnect)
                {
                    [weakSelf getDeviceClock];
                    
                }else
                {
                    [weakSelf.allClockArray removeAllObjects];
                    [weakSelf.coreManager.clockArray removeAllObjects];
                }
                [SVProgressHUD dismiss];
            }
        }else
        {
            [SVProgressHUD dismiss];
            NSLog(@"获取服务器闹钟数据失败");
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
}

-(void)clockDataSort
{
    NSLog(@"闹钟数组排序");
    //    [self.allClockArray removeAllObjects];
    //    [self.allClockArray addObjectsFromArray:self.coreManager.clockArray];
    if (self.allClockArray.count > 0)
    {
        NSArray *result = [self.allClockArray sortedArrayUsingComparator:^NSComparisonResult(AlarmClockModel *firstModel ,AlarmClockModel *secondModel) {
            NSString *firstTime = [NSString stringWithFormat:@"%02d:%02d",firstModel.hour,firstModel.minute];
            NSString *secondTime = [NSString stringWithFormat:@"%02d:%02d",secondModel.hour,secondModel.minute];
            return [firstTime compare:secondTime]; //升序
        }];
        [self.allClockArray removeAllObjects];
        [self.allClockArray addObjectsFromArray:result];
//        [self.coreManager.clockArray removeAllObjects];
//        [self.coreManager.clockArray addObjectsFromArray:self.allClockArray];
        NSLog(@"刷新闹钟列表 - 241");
        [self refreshLocalAlarmClockAndReloadTableData];//刷新本地闹钟（APP内响铃闹钟） 和  列表数据
        
        
        [self getDeviceClockCount];
    }
}

//对比服务器上面的闹钟跟推送
-(void)serverClockCompareNotification
{
    NSLog(@"对比服务器闹钟与推送");
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for(int i = 0 ; i < self.allClockArray.count; i++){
                AlarmClockModel *model = self.allClockArray[i];
                if (model.isOn) {
                    for(int j = 0 ; j < requests.count; j++){
                        UNNotificationRequest *request = requests[j];
                        if([[NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute] isEqualToString:request.identifier]){
                            break;
                        }
                        if (j == requests.count -1 && ![[NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute] isEqualToString:request.identifier]) {
                            [self deleteNotification:model];
                            [self addNotification:model];
                        }
                    }
                }
            }
            //循环推送数组，对比闹钟数组，删除没有的推送
            for (UNNotificationRequest *request in requests) {
                for(int i = 0 ; i < self.allClockArray.count; i++){
                    AlarmClockModel *model = self.allClockArray[i];
                    if([[NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute] isEqualToString:request.identifier] && model.isOn){
                        break;
                    }
                    if (i == self.allClockArray.count-1) {
                        [center removePendingNotificationRequestsWithIdentifiers:@[request.identifier]];
                    }
                }
            }
        }];
    } else {
        NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
        //循环闹钟数组，对比推送数组，增加没有的推送
        for(int i = 0 ; i < self.allClockArray.count; i++){
            AlarmClockModel *model = self.allClockArray[i];
            if (model.isOn) {
                for(int j = 0 ; j < localNotifications.count; j++){
                    UILocalNotification *notification = localNotifications[j];
                    NSDictionary *userInfo = notification.userInfo;
                    if (userInfo) {
                        NSDictionary *info = userInfo[projectName];
                        if (info != nil) {
                            if([[NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute] isEqualToString:info[@"time"]]){
                                break;
                            }
                            if (j == localNotifications.count -1) {
                                [self addNotification:model];
                            }
                        }
                    }
                }
            }
        }
        //循环推送数组，对比闹钟数组，删除没有的推送
        for (UILocalNotification *notification in localNotifications) {
            NSDictionary *userInfo = notification.userInfo;
            if (userInfo) {
                NSDictionary *info = userInfo[projectName];
                if (info != nil) {
                    for(int i = 0 ; i < self.allClockArray.count; i++){
                        AlarmClockModel *model = self.allClockArray[i];
                        if([[NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute] isEqualToString:info[@"time"]] && model.isOn){
                            break;
                        }
                        if (i == self.allClockArray.count-1) {
                            [[UIApplication sharedApplication] cancelLocalNotification:notification];
                        }
                    }
                }
            }
        }
    }
}

//对比设备闹钟数据跟服务器上面的数据
-(void)deviceClockCompareServerClock
{
    NSLog(@"对比服务器与设备闹钟");
    if (self.deviceClockArray.count > 0 ) {
        NSLog(@"设备没有闹钟");
        //判断服务器数据有没有多余的设备闹钟
        for(int i = 0 ; i < self.allClockArray.count ; i++)
        {
            
            AlarmClockModel *serverClock = self.allClockArray[i];
            if(serverClock.isPhone == NO || (serverClock.isPhone == YES && serverClock.isIntelligentWake == YES))
            {
                for(int j = 0 ; j < self.deviceClockArray.count ; j++){
                    AlarmClockModel *deviceClock = self.deviceClockArray[j];
                    if (serverClock.hour == deviceClock.hour && serverClock.minute == deviceClock.minute) {
                        serverClock = deviceClock;
                        break;
                    }
                    
                    if (j == self.deviceClockArray.count-1 && serverClock.hour != deviceClock.hour && serverClock.minute != deviceClock.minute)
                    {
                        NSLog(@"服务器有闹钟,设备没有闹钟，删除设备闹钟");
                        [self.coreManager getDeleteAlarmClockForData:@{@"id":[NSNumber numberWithInt:serverClock.clockId]} WithResponse:^(ResponseInfo *info) {
                        }];
                        [self.allClockArray removeObject:serverClock];
                        i--;
                    }
                }
            }
        }
        
        //判断服务器有没有缺少的设备闹钟
        if (self.allClockArray.count == 0) {
            
            for(int i = 0 ; i < self.deviceClockArray.count ; i++)
            {
                AlarmClockModel *deviceClock = self.deviceClockArray[i];
                [self addToServer:deviceClock];
                [self.allClockArray addObject:deviceClock];
                
            }
        }else
        {
            for(int i = 0 ; i < self.deviceClockArray.count ; i++){
                AlarmClockModel *deviceClock = self.deviceClockArray[i];
                for(int j = 0 ; j < self.allClockArray.count ; j++){
                    AlarmClockModel *serverClock = self.allClockArray[j];
                    if(serverClock.isPhone == NO || (serverClock.isPhone == YES && serverClock.isIntelligentWake == YES)){
                        if (serverClock.hour == deviceClock.hour && serverClock.minute == deviceClock.minute) {
                            break;
                        }
                        if (j == self.allClockArray.count-1 && serverClock.hour != deviceClock.hour && serverClock.minute != deviceClock.minute) {
                            NSLog(@"服务器没有闹钟,设备有闹钟，上传设备闹钟");
                            //上传到服务器
                            [self addToServer:deviceClock];
                            [self.allClockArray addObject:deviceClock];
                            break;
                        }
                    }
                }
            }
        }
        [SVProgressHUD dismiss];
    }
    [self serverClockCompareNotification];
    [SVProgressHUD dismiss];
    
    //测试
    //    [self.coreManager.clockArray removeAllObjects];
    //    [self.coreManager.clockArray addObjectsFromArray:self.allClockArray];
    
    [self clockDataSort];
}

//重新声明Block人，反正block引用没在本页面回调
-(void)restatementBlock
{
    WS(weakSelf);
    self.blueToothManager.clockOperationBlock = ^(int operation, int index, int isSuccess) {
        if (!isSuccess) {
            [SVProgressHUD dismiss];
            if (operation == 4)
            {
                //查询失败
                NSLog(@"获取设备闹钟失败");
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ACMVC_GetDeviceClockError", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                [weakSelf clockDataSort];
                return ;
            }
            if (operation == 2)
            {
                //删除失败
                NSLog(@"删除设备闹钟失败");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"DeleteError", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                return;
            }
            if (operation == 3)
            {
                //编辑失败
                NSLog(@"编辑设备闹钟失败");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"OperationError", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                AlarmClockModel *model = weakSelf.allClockArray[weakSelf.selectIndex];
                model.isOn = !model.isOn;
                return;
            }
        }else
        {
            if (operation == 2)
            {
                //删除成功
                NSLog(@"删除设备闹钟成功");
                [weakSelf deleteServerClock];
            }
            if (operation == 3)
            {
                //编辑成功
                NSLog(@"编辑设备闹钟成功");
                AlarmClockModel *model = weakSelf.allClockArray[weakSelf.selectIndex];
                [weakSelf editServerClock:model];
            }
        }
    };
}

//获取设备闹钟
-(void)getDeviceClock
{
    NSLog(@"获取设备闹钟");
    [SVProgressHUD show];
    WS(weakSelf);
    self.blueToothManager.clockBlock = ^(NSArray *clockArray)
    {
        NSLog(@"获取设备闹钟成功,个数为%lu",(unsigned long)clockArray.count);
        [SVProgressHUD dismiss];
        [weakSelf.deviceClockArray removeAllObjects];
        [weakSelf.deviceClockArray addObjectsFromArray:clockArray];
        for (AlarmClockModel *model in clockArray) {
            NSLog(@"model.index = %d , hour = %d,minute = %d,clockId = %d",model.index,model.hour,model.minute,model.clockId);
        }
        [weakSelf deviceClockCompareServerClock];
    };
    self.blueToothManager.clockOperationBlock = ^(int operation, int index, int isSuccess) {
        if (!isSuccess) {
            [SVProgressHUD dismiss];
            if (operation == 4) {
                //查询失败
                NSLog(@"获取设备闹钟失败");
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ACMVC_GetDeviceClockError", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                [weakSelf clockDataSort];
                return ;
            }
            if (operation == 2) {
                //删除失败
                NSLog(@"删除设备闹钟失败");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"DeleteError", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                return;
            }
            if (operation == 3) {
                //编辑失败
                NSLog(@"编辑设备闹钟失败");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"OperationError", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                AlarmClockModel *model = weakSelf.allClockArray[weakSelf.selectIndex];
                model.isOn = !model.isOn;
                return;
            }
        }else
        {
            if (operation == 2)
            {
                //删除成功
                NSLog(@"删除设备闹钟成功");
                [weakSelf deleteServerClock];
            }
            if (operation == 3)
            {
                //编辑成功
                NSLog(@"编辑设备闹钟成功");
                AlarmClockModel *model = weakSelf.allClockArray[weakSelf.selectIndex];
                [weakSelf editServerClock:model];
            }
        }
    };
    [self.blueToothManager getDeviceClock];
}

#pragma mark - 新增
-(void)addAlarmClock
{
    NSLog(@"进入添加闹钟页面");
    WS(weakSelf);
    AlarmClockEditViewController *edit = [[AlarmClockEditViewController alloc]init];
    edit.isAdd = YES;
    edit.intelligentWakeCount = self.intelligentClockCount;
    edit.deviceClockCount = self.deviceClockCount;
    
    edit.saveBlock = ^(AlarmClockModel *model) {
        
        NSLog(@"闹钟新增成功回调");
        [weakSelf.allClockArray removeAllObjects];
        [weakSelf.allClockArray addObjectsFromArray:weakSelf.coreManager.clockArray];
        
//        if (weakSelf.allClockArray.count > 0){
//            //替换最后一个模型
//            [weakSelf.allClockArray replaceObjectAtIndex:weakSelf.allClockArray.count-1 withObject:model];
//        }
        
        for (AlarmClockModel *model in weakSelf.allClockArray) {
            
            NSLog(@"%d:%d ,index = %d",model.hour,model.minute,model.index);
        }
        
        [weakSelf clockDataSort];
    };
    //    edit.backBlock = ^{
    //        NSMutableArray *vcArray = [NSMutableArray arrayWithArray:weakSelf.navigationController.viewControllers];
    //        // 获取当前控制器在数组的位置
    //        int index = (int)[vcArray indexOfObject:weakSelf];
    //        if(index != vcArray.count){
    //            AlarmClockEditViewController *edit = vcArray[1];
    //            edit = nil;
    //            [vcArray removeObjectAtIndex:1];
    //            [weakSelf.navigationController setViewControllers:vcArray animated:YES];
    //        }
    //    };
    [self tabBarViewHidden];
    [self.navigationController pushViewController:edit animated:YES];
}

//开启闹钟
-(void)openClock
{
    __weak AlarmClockModel *model = self.allClockArray[self.selectIndex];
    model.isOn = YES;
    if(model.isPhone){
        if(model.isIntelligentWake){
            if (self.blueToothManager.isConnect) {
                
                //开启设备闹钟
                [self.blueToothManager editClock:model];
                
            }else{
                
                model.isOn = NO;
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                
            }
        }else
        {
            //上传修改闹钟
            [self editServerClock:model];
        }
    }else{
        
        if (self.blueToothManager.isConnect) {
            //开启设备闹钟
            [self.blueToothManager editClock:model];
            
        }else{
            
            model.isOn = NO;
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }
}

-(void)editServerClock:(AlarmClockModel*)model
{
    WS(weakSelf);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:model.mj_keyValues];
    [dict setObject:[NSNumber numberWithInt:(int)model.isIntelligentWake] forKey:@"isIntelligentWake"];
    [dict setObject:[NSNumber numberWithInt:(int)model.isOn] forKey:@"isOn"];
    [dict setObject:[NSNumber numberWithInt:(int)model.isPhone] forKey:@"isPhone"];
    [dict setObject:[NSString stringWithFormat:@"%@",model.repeat] forKey:@"repeat"];
    [dict setObject:[NSNumber numberWithInt:model.clockId] forKey:@"id"];
    [self.coreManager postUpdateAlarmClockForData:dict WithResponse:^(ResponseInfo *info) {
        
        if ([info.code isEqualToString:@"200"]) {
            //开启推送
            if (model.isPhone) {
                if (model.isOn) {
                    [weakSelf addNotification:model];
                }else{
                    [weakSelf deleteNotification:model];
                }
            }
            NSLog(@"刷新闹钟列表 - 624");
            [weakSelf refreshLocalAlarmClockAndReloadTableData];//刷新本地闹钟（APP内响铃闹钟） 和  列表数据
        }else{
            model.isOn = NO;
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"OperationError", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
}

//关闭闹钟
-(void)closeClock
{
    __weak AlarmClockModel *model = self.allClockArray[self.selectIndex];
    model.isOn = NO;
    if(model.isPhone){
        if(model.isIntelligentWake){
            if (self.blueToothManager.isConnect) {
                //开启设备闹钟
                [self.blueToothManager editClock:model];
            }else
            {
                model.isOn = YES;
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }else
        {
            //上传修改闹钟
            [self editServerClock:model];
        }
    }else
    {
        if (self.blueToothManager.isConnect)
        {
            //开启设备闹钟
            [self.blueToothManager editClock:model];
            
        }else
        {
            model.isOn = YES;
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }
}

//添加推送
-(void)addNotification:(AlarmClockModel*)model
{
//    [ClockTool addNotification:model];
}

//删除推送
-(void)deleteNotification:(AlarmClockModel*)model
{
//    [ClockTool deleteNotification:model];
}

//删除服务器闹钟
-(void)deleteServerClock
{
    NSLog(@"删除服务器闹钟");
    WS(weakSelf);
    AlarmClockModel *model = self.allClockArray[self.selectIndex];
    [self.coreManager getDeleteAlarmClockForData:@{@"id":[NSNumber numberWithInt:model.clockId]} WithResponse:^(ResponseInfo *info) {
        [SVProgressHUD dismiss];
        if ([info.code isEqualToString:@"200"])
        {
            NSLog(@"删除服务器闹钟成功");
            if (model.isOn)
            {
                [weakSelf deleteNotification:model];
            }
            
            [weakSelf.coreManager.clockArray removeObject:model];
            [weakSelf.allClockArray removeObject:model];
            if (model.isIntelligentWake) {
                weakSelf.intelligentClockCount--;
            }
            NSLog(@"刷新闹钟列表 - 703");
            [weakSelf refreshLocalAlarmClockAndReloadTableData];//刷新本地闹钟（APP内响铃闹钟） 和  列表数据
            
            if(weakSelf.allClockArray.count == 0)
            {
                NSLog(@"闹钟数组没有数据,清除所有推送");
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            }
            [SVProgressHUD dismiss];
            
        }else
        {
            NSLog(@"删除服务器闹钟失败");
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
    
}

//添加服务器闹钟
-(void)addToServer:(AlarmClockModel *)model
{
    WS(weakSelf);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:model.mj_keyValues];
    [dict setObject:[NSNumber numberWithInt:(int)model.isIntelligentWake] forKey:@"isIntelligentWake"];
    [dict setObject:[NSNumber numberWithInt:(int)model.isOn] forKey:@"isOn"];
    [dict setObject:[NSNumber numberWithInt:(int)model.isPhone] forKey:@"isPhone"];
    [dict setObject:[NSString stringWithFormat:@"%@",model.repeat] forKey:@"repeat"];
    [self.coreManager postAddAlarmClockForData:dict WithResponse:^(ResponseInfo *info) {
        
    }];
    
}

//删除设备闹钟
-(void)deleteDeviceClock
{
    AlarmClockModel *model = self.allClockArray[self.selectIndex];
    [self.blueToothManager deleteClock:model];
}

-(void)tabBarViewHidden
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.mainTabBar.tabBarView.hidden == NO)
    {
        delegate.mainTabBar.tabBarView.hidden = YES;
    }
}

-(void)setBlueTooth
{
    WS(weakSelf);
    if (self.blueToothManager.isConnect)
    {
        if (self.blueToothBtn.selected == NO)
        {
            self.blueToothBtn.selected = YES;
        }
        
    }else
    {
        self.blueToothBtn.selected = NO;
    }
    
    self.blueToothManager.connectPeripheralBlock = ^(BOOL isSuccess)
    {
        if (weakSelf)
        {
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

-(void)blueTooth:(UIButton *)sender
{
    if (!sender.selected)
    {
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

-(void)connectPeripheral
{
    if(self.blueToothManager.centralManagerState == 5){
//        [SVProgressHUD showWithStatus:NSLocalizedString(@"BTM_DeviceMonitoring", nil)];
//        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        if (self.blueToothManager.currentPeripheral) {
            
            [self.blueToothManager connectCurrentPeripheral];
            
        }else
        {
            [self.blueToothManager scanAllPeripheral];
        }
    }else
    {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothClose", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
    
}

#pragma mark - 设置界面UI
-(void)setUI
{
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
    if (self.blueToothManager.isConnect) {
        
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
    
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"ACMVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.alarmClockTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.alarmClockTableView];
    self.alarmClockTableView.backgroundColor = [UIColor clearColor];
    self.alarmClockTableView.showsVerticalScrollIndicator = NO;
    self.alarmClockTableView.delegate = self;
    self.alarmClockTableView.dataSource = self;
    //    self.alarmClockTableView.bounces = NO;
    [self.alarmClockTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-110-36-5);
    }];
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    self.alarmClockTableView.tableFooterView = footerView;
    self.alarmClockTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.alarmClockTableView registerClass:[AlarmClockTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addBtn];
    [addBtn setImage:[UIImage imageNamed:@"alarm_btn_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addAlarmClock) forControlEvents:UIControlEventTouchUpInside];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.alarmClockTableView.mas_bottom).offset(5);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@45);
        make.height.equalTo(@36);
    }];
    
    UILabel *btnTitleL = [[UILabel alloc]init];
    btnTitleL.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    btnTitleL.textColor = [UIColor colorWithHexString:@"#575756"];
    btnTitleL.textAlignment = NSTextAlignmentCenter;
    btnTitleL.text = NSLocalizedString(@"ACMVC_Add", nil);
    [self.view addSubview:btnTitleL];
    [btnTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addBtn.mas_bottom).offset(10);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@100);
        make.height.equalTo(@12);
    }];
    
    
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getUserClock)];
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:NSLocalizedString(@"PullDownToRefresh", nil) forState:MJRefreshStateIdle];
    [header setTitle:NSLocalizedString(@"ReleaseToRefresh", nil) forState:MJRefreshStatePulling];
    [header setTitle:NSLocalizedString(@"Loading", nil) forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    self.alarmClockTableView.mj_header = header;
    
    UIImageView *bottomImageV = [[UIImageView alloc]init];
    bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
    [self.view addSubview:bottomImageV];
    [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
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
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"ACMVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.alarmClockTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.alarmClockTableView];
    self.alarmClockTableView.backgroundColor = [UIColor clearColor];
    self.alarmClockTableView.showsVerticalScrollIndicator = NO;
    self.alarmClockTableView.delegate = self;
    self.alarmClockTableView.dataSource = self;
    //    self.alarmClockTableView.bounces = NO;
    [self.alarmClockTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarHeight-30);
    }];
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(kMargin*2, 55, kSCREEN_WIDTH-kMargin*4, 45);
    addButton.backgroundColor = [UIColor whiteColor];
    addButton.titleLabel.font = [UIFont systemFontOfSize:16];
    addButton.layer.cornerRadius = textFieldCornerRadius;
    [addButton setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [addButton setTitle:NSLocalizedString(@"ACMVC_Add", nil) forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addAlarmClock) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:addButton];
    self.alarmClockTableView.tableFooterView = footerView;
    self.alarmClockTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.alarmClockTableView registerClass:[AlarmClockTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getUserClock)];
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:NSLocalizedString(@"PullDownToRefresh", nil) forState:MJRefreshStateIdle];
    [header setTitle:NSLocalizedString(@"ReleaseToRefresh", nil) forState:MJRefreshStatePulling];
    [header setTitle:NSLocalizedString(@"Loading", nil) forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor = [UIColor whiteColor];
    self.alarmClockTableView.mj_header = header;
    
    
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allClockArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WS(weakSelf);
    AlarmClockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.allClockArray.count > 0) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        AlarmClockModel *model = self.allClockArray[indexPath.row];
        [cell setClockValue:model];
        cell.switchBlock = ^(BOOL isOn) {
            //开关
            weakSelf.selectIndex = (int)indexPath.row;
            
            if (isOn) {
                
                [weakSelf openClock];
                
            }else{
                
                [weakSelf closeClock];
            }
        };
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf);
    AlarmClockModel *model = self.allClockArray[indexPath.row];
    if (!model.isPhone || model.isIntelligentWake)
    {
        if (!self.blueToothManager.isConnect)
        {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            
            return;
        }
    }
    
    NSLog(@"进入编辑界面");
    AlarmClockEditViewController *edit = [[AlarmClockEditViewController alloc]init];
    edit.intelligentWakeCount = self.intelligentClockCount;
//    edit.deviceClockCount = self.deviceClockCount;
    edit.oldModel = model;
    edit.changeModel = [model copy];
    edit.editBlock = ^(BOOL isSuccess) {
        
        NSLog(@"编辑成功回调");
        [weakSelf.allClockArray removeAllObjects];
        [weakSelf.allClockArray addObjectsFromArray:weakSelf.coreManager.clockArray];
        [weakSelf clockDataSort];
        
    };
    [self tabBarViewHidden];
    [self.navigationController pushViewController:edit animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    return 60;
    return 82;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editingIndexPath = indexPath;
    [self.view setNeedsLayout];   // 触发-(void)viewDidLayoutSubviews
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editingIndexPath = nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.selectIndex = (int)indexPath.row;
        AlarmClockModel *model = self.allClockArray[indexPath.row];
        NSLog(@"model.clockId = %d,model.index = %d,model.hour = %d,model.minute = %d",model.clockId,model.index,model.hour,model.minute);
        if (!model.isPhone || model.isIntelligentWake){
            if(self.blueToothManager.isConnect){
                [SVProgressHUD show];
                //删除设备数据，再删除服务器数据
                [self deleteDeviceClock];
                
            }else{
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
            
        }else{
            //删除服务器数据
            [SVProgressHUD show];
            [self deleteServerClock];
        }
    }
}

//刷新本地闹钟（APP内响铃闹钟） 和  列表数据
- (void)refreshLocalAlarmClockAndReloadTableData{
    
    [self.alarmClockTableView reloadData];
    
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
    if (self.allClockArray.count == 0) {
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
    
    for (AlarmClockModel * model in self.allClockArray) {
        
        NSString * selectClockTimer = [NSString stringWithFormat:@"%02d:%02d:00",model.hour,model.minute];
        //查重、响应端、循环周的判断
        if (![clockTimerArr containsObject:selectClockTimer] && model.isPhone && model.isOn && [model.repeat containsObject:weekString]) {
            [clockTimerArr addObject:selectClockTimer];
            model.clockTitle = NSLocalizedString(@"ACMVC_Title", nil);
            model.clockDescribe = model.remark;
            model.clockMusic = @"bell_ring.m4a";
            NSString *clockTimer = [timeString stringByReplacingOccurrencesOfString:[[formatter stringFromDate:[NSDate date]] substringFromIndex:timeString.length-8] withString:selectClockTimer];
            NSLog(@"APP内响铃闹钟 响铃时间 : %@",clockTimer);
            model.clockTimer = clockTimer;
            [AlarmClockModel SaveAlarmClockWithModel:model];
        }
    }
    
    
    
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.editingIndexPath)
    {
        [self configSwipeButtons];
    }
}

- (void)configSwipeButtons
{
    // 获取选项按钮的reference
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
    {
        // iOS 11层级 (Xcode 9编译): UITableView -> UISwipeActionPullView
        for (UIView *subview in self.alarmClockTableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subview.subviews count] >= 1)
            {
                // 和iOS 10的按钮顺序相反
                UIButton *deleteButton = subview.subviews[0];
                
                [self configDeleteButton:deleteButton];
                
            }
        }
    }
    else
    {
        // iOS 8-10层级: UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        AlarmClockTableViewCell *tableCell = [self.alarmClockTableView cellForRowAtIndexPath:self.editingIndexPath];
        for (UIView *subview in tableCell.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subview.subviews count] >= 2)
            {
                UIButton *deleteButton = subview.subviews[0];
                [self configDeleteButton:deleteButton];
            }
        }
    }
}

- (void)configDeleteButton:(UIButton*)deleteButton
{
    if (deleteButton)
    {
        [deleteButton setImage:[UIImage imageNamed:@"clock_icon_list_del"] forState:UIControlStateNormal];
    }
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
