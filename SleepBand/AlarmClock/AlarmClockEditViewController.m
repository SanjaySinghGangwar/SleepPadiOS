//
//  AlarmClockEditViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/11.
//  Copyright © 2018年 admin. All rights reserved.
//



#import "AlarmClockEditViewController.h"
#import "CycleTableViewCell.h"
#import "UniversalTableViewCell.h"
#import "AlarmClockMusicViewController.h"
#import "AlarmClockTypeSelectViewController.h"

@interface AlarmClockEditViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)UITableView *clockTable;
@property (strong,nonatomic)NSArray *menuNameArray;
@property (strong,nonatomic)UIView *datePickerView;
@property (strong,nonatomic)UIDatePicker *datePicker;
@property (strong, nonatomic)BlueToothManager *blueToothManager;
@property (strong, nonatomic)MSCoreManager *coreManager;
@property (assign, nonatomic)BOOL isAgain; //重试上次服务器
@property (assign, nonatomic)EditAlarmClockType editType; //编辑类型
@property (assign, nonatomic)BOOL isDeleteDeviceClockFail; //是否删除设备闹钟失败
@property (assign, nonatomic)BOOL isAddDeviceClockFail; //是否新增设备闹钟失败
@property (assign, nonatomic)BOOL isEditDeviceClockFail; //是否编辑设备闹钟失败
@property (strong,nonatomic)AlertView *alertView;
@end

@implementation AlarmClockEditViewController
- (void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}


- (void)viewDidLoad
{
    WS(weakSelf);
    [super viewDidLoad];
    self.blueToothManager = [BlueToothManager shareIsnstance];
    self.coreManager = [MSCoreManager sharedManager];
    
    if (self.isAdd)
    {
        self.changeModel = [[AlarmClockModel alloc]init];
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *dateStr = [formatter stringFromDate:date];
        self.changeModel.hour = [[dateStr substringToIndex:2] intValue];
        self.changeModel.minute = [[dateStr substringFromIndex:3] intValue];
        self.changeModel.isPhone = YES;
        self.changeModel.isOn = YES;
        self.changeModel.repeat = @[];
        self.changeModel.isIntelligentWake = YES;
        self.changeModel.type = ClockType_GetUp;
    }
    
    [self setUI];
    
    self.blueToothManager.clockOperationBlock = ^(int operation, int index, int isSuccess) {
        NSLog(@"闹钟操作回调 -> 本次操作方式:<%d>(增1-删2-改3-查4),闹钟index:<%d>,操作结果:<%@>",operation,index,isSuccess == 1 ? @"成功":@"失败");
        if (!isSuccess) {//失败
            [weakSelf toClockOperationBlockErrorWithIndex:index operation:operation];
        }else{//成功
            [weakSelf toClockOperationBlockSuccessWithIndex:index operation:operation];
        }
    };
    
}

//设备操作回调失败后的闹钟处理
-(void)toClockOperationBlockErrorWithIndex:(int)index operation:(int)operation{
    NSString *error;
    if (operation == 1){
        NSLog(@"新增设备闹钟失败");
        error = NSLocalizedString(@"SaveError", nil);
    }else if (operation == 2){
        NSLog(@"删除设备闹钟失败");
        error = NSLocalizedString(@"DeleteError", nil);
    }else if (operation == 3){
        NSLog(@"编辑设备闹钟失败");
        error = NSLocalizedString(@"EditError", nil);
    }else if (operation == 4){
        //
    }
    [SVProgressHUD showErrorWithStatus:error];
    [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
}

//设备操作回调成功后的闹钟处理
-(void)toClockOperationBlockSuccessWithIndex:(int)index operation:(int)operation{
    if (operation == 1){
        NSLog(@"新增设备闹钟成功");
        self.changeModel.index = index;
        if (self.isAdd) {
            [self.coreManager.clockArray addObject:self.changeModel];
            [self addServerClock];
        }else{
            /*在修改闹钟save的情况下，能触发新增闹钟的情况：
                1、唤醒设备切换 （手机端->睡眠带）
                2、智能唤醒 （手机端->睡眠带）
             */
            if(self.editType == EditAlarmClockType_PhoneToDevice){
                [self editServerClock:self.changeModel];
            }
        }
        
    }else if (operation == 2){
        NSLog(@"删除设备闹钟成功");
        /*在修改闹钟save的情况下，能触发删除闹钟的情况：
         1、唤醒设备切换 （睡眠带->手机端）
         2、智能唤醒     唤醒设备为手机端，关闭智能唤醒（睡眠带->手机端）
         */
        if(self.editType == EditAlarmClockType_DeviceToPhone){
            self.changeModel.index = -1;
            [self editServerClock:self.changeModel];
        }else{
            [self deleteServerClock];
        }
    }else if (operation == 3){
        NSLog(@"编辑设备闹钟成功");
        if(self.editType == EditAlarmClockType_DeviceToDevice){
            [self editServerClock:self.changeModel];
        }
    }else if (operation == 4){
       //
    }
}

#pragma mark --删除服务器闹钟
-(void)deleteServerClock
{
    NSLog(@"删除服务器闹钟");
    [self.coreManager getDeleteAlarmClockForData:@{@"id":[NSNumber numberWithInt:self.changeModel.clockId]} WithResponse:^(ResponseInfo *info) {
        [SVProgressHUD dismiss];
        if ([info.code isEqualToString:@"200"]) {
            NSLog(@"删除服务器闹钟成功");
        }else{
            NSLog(@"删除服务器闹钟失败");
        }
    }];
}

#pragma mark --编辑闹钟
//编辑闹钟
-(void)editServerClock:(AlarmClockModel *)model
{
    NSLog(@"修改服务器闹钟");
    WS(weakSelf);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:model.mj_keyValues];
    [dict setObject:[NSNumber numberWithInt:(int)model.isIntelligentWake] forKey:@"isIntelligentWake"];
    [dict setObject:[NSNumber numberWithInt:(int)model.isOn] forKey:@"isOn"];
    [dict setObject:[NSNumber numberWithInt:(int)model.isPhone] forKey:@"isPhone"];
    [dict setObject:[NSString stringWithFormat:@"%@",model.repeat] forKey:@"repeat"];
    [dict setObject:[NSNumber numberWithInt:model.clockId] forKey:@"id"];
    [self.coreManager postUpdateAlarmClockForData:dict WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            NSLog(@"修改服务器闹钟成功");
            [weakSelf deleteNotification:weakSelf.oldModel];
            if (model.isPhone || model.isIntelligentWake) {
                [weakSelf addNotification:weakSelf.changeModel];
            }
            [weakSelf refreshAllClockArray];
            
            if (weakSelf.editType == EditAlarmClockType_PhoneToPhone) {
                
            }else if(weakSelf.editType == EditAlarmClockType_DeviceToPhone){
                
            }else if(weakSelf.editType == EditAlarmClockType_PhoneToDevice){
                
            }else if(weakSelf.editType == EditAlarmClockType_DeviceToDevice){
                
            }
        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"EditError", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
}

#pragma mark --增加服务器闹钟
-(void)addServerClock
{
     NSLog(@"新增服务器闹钟");
    WS(weakSelf);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.changeModel.mj_keyValues];
    [dict setObject:[NSNumber numberWithInt:(int)self.changeModel.isIntelligentWake] forKey:@"isIntelligentWake"];
    [dict setObject:[NSNumber numberWithInt:(int)self.changeModel.isOn] forKey:@"isOn"];
    [dict setObject:[NSNumber numberWithInt:(int)self.changeModel.isPhone] forKey:@"isPhone"];
    NSLog(@"self.changeModel.repeat = %@",self.changeModel.repeat);
    [dict setObject:[NSString stringWithFormat:@"%@",self.changeModel.repeat] forKey:@"repeat"];
    [self.coreManager postAddAlarmClockForData:dict WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            NSLog(@"上传服务器成功");
            int clockId = [[NSString stringWithFormat:@"%@",info.data[@"alarmClock"][@"id"]] intValue];
            weakSelf.changeModel.clockId = clockId;
            if (weakSelf.changeModel.isPhone == YES && weakSelf.changeModel.isIntelligentWake == NO){
                NSLog(@"手机闹钟，新增完成，返回上一页面");
                [weakSelf.coreManager.clockArray addObject:weakSelf.changeModel];
                weakSelf.saveBlock(weakSelf.changeModel);
                if (weakSelf.oldModel == nil) {
                    [weakSelf addNotification:weakSelf.changeModel];
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                if (weakSelf.changeModel.isPhone == YES && weakSelf.oldModel == nil) {
                    [weakSelf addNotification:weakSelf.changeModel];
                }
//                [weakSelf.coreManager.clockArray addObject:weakSelf.changeModel];
                NSLog(@"设备闹钟，上传完成");
                weakSelf.saveBlock(weakSelf.changeModel);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }else{
            if (weakSelf.isAgain) {
                NSLog(@"再次上传服务器失败");
                weakSelf.isAgain = NO;
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SaveError", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }else{
                NSLog(@"上传服务器失败，再次上传");
                weakSelf.isAgain = YES;
                [weakSelf addServerClock];
            }
        }
    }];
}

#pragma mark --新增闹钟
-(void)addClock
{
    //    NSArray *result = [self.changeModel.repeat  sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2){
    //        return [obj1 compare:obj2]; //升序
    //    }];
    //    self.changeModel.repeat = result;
    NSLog(@"新增闹钟");
    if(self.changeModel.type == ClockType_General){
        self.changeModel.remark = @"";
    }else if (self.changeModel.type == ClockType_Nurse){
        self.changeModel.remark = NSLocalizedString(@"ACMVC_NurseClock", nil);
    }else if (self.changeModel.type == ClockType_GoToBedEarly){
        self.changeModel.remark = NSLocalizedString(@"ACMVC_GoToBedEarlyClock", nil);
    }else{
        if (self.changeModel.isIntelligentWake == NO) {
            self.changeModel.remark = NSLocalizedString(@"ACMVC_GetUpClock", nil);
        }else{
            self.changeModel.remark = NSLocalizedString(@"ACMVC_IntelligentClock", nil);
        }
    }
    if (self.changeModel.isPhone == YES && self.changeModel.isIntelligentWake == NO)
    {
        //手机保存
        NSLog(@"手机保存,上传服务器");
        [self addServerClock];
        
    }else
    {
        NSLog(@"设备保存");
        //设备保存，智能保存10个闹钟
        if(self.isAdd)
        {
            if (self.deviceClockCount == 10) {
                NSLog(@"设备闹钟已经有10个,保存失败");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ACEVC_ClockIsFull", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                return;
            }
            if (self.changeModel.isIntelligentWake == YES && self.intelligentWakeCount > 0) {
                NSLog(@"智能闹钟已经有1个,保存失败");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ACEVC_IntelligentClockIsFull", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                return;
            }
        }
        NSLog(@"先写入设备,再上传服务器");
        [self.blueToothManager addClock:self.changeModel];
    }
}

#pragma mark --更新闹钟数组
//更新闹钟数组
-(void)refreshAllClockArray
{
    for(int i = 0 ; i < self.coreManager.clockArray.count; i++){
        AlarmClockModel *model = self.coreManager.clockArray[i];
        if (model == self.oldModel) {
            NSLog(@"删除闹钟数组旧闹钟数据");
            [self.coreManager.clockArray removeObject:model];
            NSLog(@"新增闹钟数组新闹钟数据");
            [self.coreManager.clockArray addObject:self.changeModel];
            break;
        }
    }
    //    AlarmClockModel *model = self.coreManager.clockArray[0];
    NSLog(@"编辑完成,返回上一页");
    self.editBlock(YES);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --编辑闹钟
//编辑闹钟
-(void)editClock
{
    //先判断新闹钟保存位置
    if(!self.changeModel.isPhone ||  (self.changeModel.isPhone && self.changeModel.isIntelligentWake)){
        NSLog(@"新闹钟保存在设备");
        //判断旧闹钟保存位置
        if(!self.oldModel.isPhone ||  (self.oldModel.isPhone && self.oldModel.isIntelligentWake)){
            NSLog(@"旧闹钟保存在设备");
            self.editType = EditAlarmClockType_DeviceToDevice;
            if(self.changeModel.isIntelligentWake){
                if(!self.oldModel.isIntelligentWake){
                    if (self.intelligentWakeCount > 0) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ACEVC_IntelligentClockIsFull", nil)];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        return;
                    }
                }
            }
            [self.blueToothManager editClock:self.changeModel];
        }else{
            NSLog(@"旧闹钟保存在手机");
            self.editType = EditAlarmClockType_PhoneToDevice;
            if(self.deviceClockCount == 10){
                NSLog(@"设备闹钟已经有10个,保存失败");
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ACEVC_ClockIsFull", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }else{
                NSLog(@"智能闹钟个数：%d",self.intelligentWakeCount);
                if (self.intelligentWakeCount > 0) {
                    if (self.changeModel.isIntelligentWake) {
                        NSLog(@"旧闹钟不是智能闹钟，智能闹钟个数已满");
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ACEVC_IntelligentClockIsFull", nil)];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    }else{
//                        [self editServerClock:self.changeModel];
                        [self.blueToothManager addClock:self.changeModel];
                    }
                }else{
//                    [self editServerClock:self.changeModel];
                    [self.blueToothManager addClock:self.changeModel];
                }
            }
        }
    }else
    {
        NSLog(@"新闹钟保存在手机");
        //判断旧闹钟保存位置
        if(!self.oldModel.isPhone ||  (self.oldModel.isPhone && self.oldModel.isIntelligentWake)){
            NSLog(@"旧闹钟保存在设备");
            self.editType = EditAlarmClockType_DeviceToPhone;
            if (self.blueToothManager.isConnect) {
//                [self editServerClock:self.changeModel];
                [self.blueToothManager deleteClock:self.oldModel];
            }else{
                
                NSLog(@"未连接设备,保存失败");
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }else{
            
            NSLog(@"旧闹钟保存在手机");
            self.editType = EditAlarmClockType_PhoneToPhone;
            [self editServerClock:self.changeModel];
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

-(void)back
{
    //    self.backBlock();
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存
-(void)save
{
    if (!self.changeModel.repeat || self.changeModel.repeat.count == 0) {
        NSLog(@"周期未选择,保存失败");
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"ACEVC_CycleNull", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        return;
    }
    if (self.isAdd)
    {
        if (!self.changeModel.isPhone || (self.changeModel.isPhone && self.changeModel.isIntelligentWake))
        {
            NSLog(@"新闹钟保存在设备");
            
            if(!self.blueToothManager.isConnect)
            {
                NSLog(@"未连接设备,保存失败");
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                return;
            }
        }
        [self addClock];
        
    }else
    {
        if (self.oldModel.hour != self.changeModel.hour ||
            self.oldModel.minute != self.changeModel.minute ||
            self.oldModel.isPhone != self.changeModel.isPhone ||
            self.oldModel.repeat != self.changeModel.repeat ||
            self.oldModel.isIntelligentWake != self.changeModel.isIntelligentWake)
        {
            NSLog(@"数据有更改，进入更改保存流程");
            if (!self.changeModel.isPhone || (self.changeModel.isPhone && self.changeModel.isIntelligentWake))
            {
                NSLog(@"新闹钟保存在设备");
                if(!self.blueToothManager.isConnect)
                {
                    NSLog(@"未连接设备,编辑失败");
                    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                    [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    return;
                }
            }
            if (!self.oldModel.isPhone || (self.oldModel.isPhone && self.oldModel.isIntelligentWake))
            {
                NSLog(@"旧闹钟保存在设备");
                if(!self.blueToothManager.isConnect)
                {
                    NSLog(@"未连接设备,编辑失败");
                    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceNoConnect", nil)];
                    [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    return;
                }
            }
            [self editClock];
            
        }else{
            NSLog(@"没有新数据改变，直接返回上一页");
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 设置界面UI
-(void)setUI
{
    WS(weakSelf);
    self.view.backgroundColor = [UIColor whiteColor];
    self.menuNameArray = @[NSLocalizedString(@"ACEVC_TimeTitle", nil),
                           NSLocalizedString(@"ACEVC_TypeTitle", nil),
                           NSLocalizedString(@"ACEVC_DeviceTitle", nil),
                           NSLocalizedString(@"ACEVC_CycleTitle", nil),
                           NSLocalizedString(@"ACEVC_IntelligentWakeTitle", nil)];
    //    self.menuNameArray = @[NSLocalizedString(@"ACEVC_TimeTitle", nil),
    //                           NSLocalizedString(@"ACEVC_TypeTitle", nil),
    //                           NSLocalizedString(@"ACEVC_DeviceTitle", nil),
    //                           NSLocalizedString(@"ACEVC_IntelligentWakeTitle", nil)];
    [self setNavigationUI];
    [self setDatePickerViewUI];
    self.clockTable = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.clockTable];
    self.clockTable.showsVerticalScrollIndicator = NO;
    self.clockTable.backgroundColor = [UIColor clearColor];
    self.clockTable.delegate = self;
    self.clockTable.dataSource = self;
    self.clockTable.bounces = NO;
    [self.clockTable mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.left.right.equalTo(weakSelf.view);
        //        make.top.mas_equalTo(weakSelf.datePicker.mas_bottom).offset(2);
        //        make.height.equalTo(@((weakSelf.menuNameArray.count-1)*64+114));
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.datePicker.mas_bottom).offset(0);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-110);
    }];
    
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake((kSCREEN_WIDTH-68)/2-22.5, 42, 45, 36);
    [saveBtn setImage:[UIImage imageNamed:@"me_btn_save"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:saveBtn];
    
    UILabel *saveBtnTitleL = [[UILabel alloc]initWithFrame:CGRectMake((kSCREEN_WIDTH-68)/2-50, 88, 100, 12)];
    saveBtnTitleL.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    saveBtnTitleL.textColor = [UIColor colorWithHexString:@"#575756"];
    saveBtnTitleL.textAlignment = NSTextAlignmentCenter;
    saveBtnTitleL.text = NSLocalizedString(@"Save", nil);
    [footerView addSubview:saveBtnTitleL];
    
    self.clockTable.tableFooterView = footerView;
    
    self.clockTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.clockTable registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.clockTable registerClass:[CycleTableViewCell class] forCellReuseIdentifier:@"cycleCell"];
    
    
    
    
    UIImageView *bottomImageV = [[UIImageView alloc]init];
    bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
    [self.view addSubview:bottomImageV];
    [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
    }];
    
    self.alertView = [[AlertView alloc]init];
//    [self.view addSubview:self.alertView];
//    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.bottom.equalTo(weakSelf.view);
//    }];
    
}

-(void)setDatePickerViewUI
{
    WS(weakSelf);
    
    //    UIView *pickerBgView = [[UIView alloc]init];
    //    pickerBgView.backgroundColor = [UIColor whiteColor];
    //    pickerBgView.alpha = kAlpha;
    //    [self.view addSubview:pickerBgView];
    //    [pickerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.right.equalTo(weakSelf.view);
    //        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+83);
    //        make.height.equalTo(@34);
    //    }];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.backgroundColor = [UIColor clearColor];
    //    //设置地区: zh-中国
    //    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    if (@available(iOS 13.4, *)) {
        /*
         苹果在 14 系统中修改了 datePicker 的preferredDatePickerStyle属性增加了UIDatePickerStyleInline,
         并且将默认样式调整到新增的 style 上,
         如果项目中没有设置 style 类型并且需要轮播那么就会出现问题
         */
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    [self.datePicker setDate:[NSDate date] animated:NO];
    [self.datePicker setValue:[UIColor colorWithHexString:@"#575756"] forKey:@"textColor"];
    [self.datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.height.equalTo(@(130));
    }];
    //清楚分割线
    //    [self clearSeparatorWithView:self.datePicker];
    if (!self.isAdd) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"HH:mm"];
        NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%02d:%02d",self.changeModel.hour,self.changeModel.minute]];
        [self.datePicker setDate:date animated:NO];
    }
}

//清楚分割线
-(void)clearSeparatorWithView:(UIView * )view
{
    for (UIView *subView in self.datePicker.subviews) {
        if ([subView isKindOfClass:[UIPickerView class]]) {
            for (UIView *subView2 in subView.subviews) {
                if (subView2.frame.size.height < 1) {//获取分割线view
                    subView2.backgroundColor = [UIColor redColor];//设置分割线颜色
                }
            }
        }
    }
    
    [self.view layoutIfNeeded];
}

-(void)dateChange:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSString *dateStr = [formatter  stringFromDate:sender.date];
    self.changeModel.hour = [[dateStr substringToIndex:2] intValue];
    self.changeModel.minute = [[dateStr substringFromIndex:3] intValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.clockTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.changeModel.type == ClockType_GetUp){
        return self.menuNameArray.count;
    }else{
        return self.menuNameArray.count-1;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WS(weakSelf);
    if (indexPath.row == 3) {
        CycleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cycleCell" forIndexPath:indexPath];
        cell.titleLabel.text = self.menuNameArray[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setRepeat:self.changeModel.repeat];
        cell.repeatBlock = ^(NSString *value) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.changeModel.repeat];
            if (array.count == 0) {
                [array addObject:value];
                weakSelf.changeModel.repeat = array;
            }else{
                for (int i = 0; i < array.count; i++) {
                    NSString *repeatValue = array[i];
                    if ([repeatValue isEqualToString:value]) {
                        [array removeObjectAtIndex:i];
                        weakSelf.changeModel.repeat = array;
                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:0];
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                        return ;
                    }
                    if (i == array.count - 1 && ![repeatValue isEqualToString:value]) {
                        [array addObject:value];
                        weakSelf.changeModel.repeat = array;
                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:0];
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                        return;
                    }
                }
            }
        };
        return cell;
    }else{
        
        __weak UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = self.menuNameArray[indexPath.row];
        if (indexPath.row == 4 ) {
            [cell setType:CellType_Switch];
            cell.switchBtn.selected = self.changeModel.isIntelligentWake;
            cell.switchBlock = ^(BOOL isOn) {
                if (weakSelf.changeModel.type == ClockType_GetUp) {
                    weakSelf.changeModel.isIntelligentWake = isOn;
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:4 inSection:0];
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                }else{
                    cell.switchBtn.selected = NO;
                }
            };
        }
        else{
            if (indexPath.row == 0) {
                [cell setType:CellType_Vaule];
                cell.valueLabel.text = [NSString stringWithFormat:@"%02d:%02d",self.changeModel.hour,self.changeModel.minute];
            }else if (indexPath.row == 2){
                if (self.changeModel.type == ClockType_GoToBedEarly || self.changeModel.type == ClockType_Nurse) {
                    [cell setType:CellType_Vaule];
                }else{
                    [cell setType:CellType_VauleArrows];
                }
                if (self.changeModel.isPhone) {
                    cell.valueLabel.text = NSLocalizedString(@"ACEVC_DevicePhone", nil);
                }else{
                    cell.valueLabel.text = NSLocalizedString(@"ACEVC_DeviceSleep", nil);
                }
            }else{
                if (self.isAdd) {
                    [cell setType:CellType_VauleArrows];
                }else{
                    [cell setType:CellType_Vaule];
                }
                if (self.changeModel.type == ClockType_General) {
                    cell.valueLabel.text = NSLocalizedString(@"ACMVC_General", nil);
                }else if (self.changeModel.type == ClockType_GetUp){
                    cell.valueLabel.text = NSLocalizedString(@"ACMVC_GetUp", nil);
                }else if (self.changeModel.type == ClockType_Nurse){
                    cell.valueLabel.text = NSLocalizedString(@"ACMVC_Nurse", nil);
                }else{
                    cell.valueLabel.text = NSLocalizedString(@"ACMVC_GoToBedEarly", nil);
                }
            }
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf);
    if(indexPath.row == 1){
        if(self.isAdd){
            AlarmClockTypeSelectViewController *select = [[AlarmClockTypeSelectViewController alloc]init];
            select.type = self.changeModel.type;
            select.selectBlock = ^(int type) {
                weakSelf.changeModel.type = type;
                if(type != ClockType_GetUp){
                    if(type == ClockType_GoToBedEarly){
                        weakSelf.changeModel.isPhone = YES;
                    }
                    weakSelf.changeModel.isIntelligentWake = NO;
                }
                [tableView reloadData];
            };
            [self.navigationController pushViewController:select animated:YES];
            return;
        }
    }
    if(indexPath.row == 2){
        if (self.changeModel.type != ClockType_GoToBedEarly  || self.changeModel.type != ClockType_Nurse) {
            
            [self.alertView showAlertWithType:AlertType_ActionSheet title:nil menuArray:@[NSLocalizedString(@"ACEVC_DevicePhone", nil),NSLocalizedString(@"ACEVC_DeviceSleep", nil)]];
            self.alertView.alertActionSheetBlock = ^(AlertType type, int index) {
                if (type == AlertType_ActionSheet) {
                    if (index == 0) {
                        if (weakSelf.changeModel.isPhone != 1) {
                            weakSelf.changeModel.isPhone = YES;
                            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }else{
                        if (weakSelf.changeModel.isPhone != 0) {
                            weakSelf.changeModel.isPhone = NO;
                            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
                            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                }
            };
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            }]];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ACEVC_DevicePhone", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                if (weakSelf.changeModel.isPhone != 1) {
//                    weakSelf.changeModel.isPhone = YES;
//                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
//                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//                }
//            }]];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ACEVC_DeviceSleep", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                if (weakSelf.changeModel.isPhone != 0) {
//                    weakSelf.changeModel.isPhone = NO;
//                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
//                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//                }
//            }]];
//            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        return 72;
    }
    return kCellHeight;
}

-(void)setAlertDevice
{
    WS(weakSelf);
    
    [self.alertView showAlertWithType:AlertType_ActionSheet title:nil menuArray:@[NSLocalizedString(@"ACEVC_DevicePhone", nil),NSLocalizedString(@"ACEVC_DeviceSleep", nil)]];
    self.alertView.alertActionSheetBlock = ^(AlertType type, int index) {
         if (type == AlertType_ActionSheet) {
             if (index == 0) {
                 if (!weakSelf.changeModel.isPhone) {
                     weakSelf.changeModel.isPhone = YES;
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                     [weakSelf.clockTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                 }
             }else{
                 if (weakSelf.changeModel.isPhone) {
                     weakSelf.changeModel.isPhone = NO;
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                     [weakSelf.clockTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                 }
             }
         }
    };
    
    
    
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ACEVC_DeviceTitle", nil)
//                                                                   message:nil
//                                                            preferredStyle:UIAlertControllerStyleActionSheet];
//
//    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction * action) {
//                                                         }];
//    UIAlertAction* phoneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACEVC_DevicePhone", nil) style:UIAlertActionStyleDefault
//                                                        handler:^(UIAlertAction * action) {
//                                                            if (!weakSelf.changeModel.isPhone) {
//                                                                weakSelf.changeModel.isPhone = YES;
//                                                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
//                                                                [weakSelf.clockTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//                                                            }
//                                                        }];
//    UIAlertAction* deviceAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACEVC_DeviceSleep", nil) style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {
//                                                             if (weakSelf.changeModel.isPhone) {
//                                                                 weakSelf.changeModel.isPhone = NO;
//                                                                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
//                                                                 [weakSelf.clockTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
//                                                             }
//                                                         }];
//    [alert addAction:phoneAction];
//    [alert addAction:deviceAction];
//    [alert addAction:cancelAction];
//    [self presentViewController:alert animated:YES completion:nil];
}

-(void)setNavigationUI
{
    WS(weakSelf);
    
    //    UIImageView *bgImageView = [[UIImageView alloc]init];
    //    bgImageView.image = [UIImage imageNamed:@"bg"];
    //    [self.view addSubview:bgImageView];
    //    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.left.bottom.right.equalTo(weakSelf.view);
    //    }];
    
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
    titleLabel.text = NSLocalizedString(@"ACEVC_EditClockTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    //    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    //    saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    //    [self.view addSubview:saveButton];
    //    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    //    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
    //        make.right.mas_equalTo(weakSelf.view.mas_right).offset(0);
    //        make.width.equalTo(@50);
    //        make.height.equalTo(@44);
    //    }];
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
