//
//  ManualSleepReportViewController.m
//  SleepBand
//
//  Created by admin on 2018/9/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ManualSleepReportViewController.h"
#import "DrawView.h"
#import "SleepCurveTool.h"
#import "SleepQualityModel.h"

@interface ManualSleepReportViewController ()
@property (strong,nonatomic)UIScrollView *dayScrollView;
@property (strong,nonatomic)UIView *dayProfileView;
@property (strong,nonatomic)UIView *dayView;  //日视图
@property (strong,nonatomic)DrawView *sleepTimeDayView;  //天，睡眠质量
@property (strong,nonatomic)DrawView *averageHeartRateDayView;  //天，心率
@property (strong,nonatomic)DrawView *averageRespiratoryRateDayView;  //天，呼吸率
@property (strong,nonatomic)DrawView *turnOverDayView;  //天，翻身次数
@property (strong,nonatomic)BlueToothManager *blueToothManager;
@property (copy,nonatomic)NSString *sleepTime; //用户设置的报告起始时间
@property (assign,nonatomic)int totalCount; //总共需要同步的次数
@property (assign,nonatomic)int synchronizationCount; //已同步的次数
@property (strong,nonatomic)NSMutableArray *sleepQualityDataArray; //睡眠质量历史数据数组
@property (strong,nonatomic)NSMutableArray *HRDataArray;//心率历史数据数组
@property (strong,nonatomic)NSMutableArray *RRDataArray;//呼吸率历史数据数组
@property (strong,nonatomic)NSMutableArray *turnOverDataArray;//翻身次数历史数据数组
@property (strong,nonatomic)NSMutableArray *tagDataArray;//上下床标记历史数据数组
@property (strong,nonatomic)NSMutableArray *stateArray; //高四位状态
@end

@implementation ManualSleepReportViewController

-(NSMutableArray *)stateArray
{
    if (_stateArray == nil) {
        
        _stateArray = [[NSMutableArray alloc]init];
        
    }
    return _stateArray;
}

-(NSMutableArray *)HRDataArray
{
    if (_HRDataArray == nil) {
        _HRDataArray = [[NSMutableArray alloc]init];
    }
    return _HRDataArray;
}

-(NSMutableArray *)RRDataArray
{
    if (_RRDataArray == nil) {
        _RRDataArray = [[NSMutableArray alloc]init];
    }
    return _RRDataArray;
}

-(NSMutableArray *)turnOverDataArray
{
    if (_turnOverDataArray == nil) {
        _turnOverDataArray = [[NSMutableArray alloc]init];
    }
    return _turnOverDataArray;
}

-(NSMutableArray *)tagDataArray
{
    if (_tagDataArray == nil) {
        _tagDataArray = [[NSMutableArray alloc]init];
    }
    return _tagDataArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.blueToothManager = [BlueToothManager shareIsnstance];
    
    [self setUI];
    
    //同步数据
    [self synchronousData];
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)synchronousData
{
    NSString *startDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:self.manualStartDate]];
    NSString *endDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:self.manualEndDate]];
    if ([[startDate substringToIndex:10] isEqualToString:[endDate substringToIndex:10]])
    {
        //同一天
        [self refreshTodayData];
        
    }else
    {
        //两天
    }
    
}

#pragma mark - 刷新今天数据
-(void)refreshTodayData
{
    WS(weakSelf);
    if(self.blueToothManager.isConnect)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *lastSynchronizationDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"lastSynchronizationTime"]];
        NSString *lastSynchronizationTime  =  lastSynchronizationDict[[MSCoreManager sharedManager].userModel.deviceCode];
        
        self.totalCount = 4;
        self.synchronizationCount = 0;
        [SVProgressHUD showProgress:0 status:NSLocalizedString(@"Synchronizationing", nil)];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        //同步回调
        self.blueToothManager.synchronizationBlock = ^(int count)
        {
            NSLog(@"%d,%d",weakSelf.synchronizationCount,weakSelf.totalCount);
            
            weakSelf.synchronizationCount++;
            //            dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"同步数据");
            
            if (weakSelf.synchronizationCount != weakSelf.totalCount)
            {
                [SVProgressHUD showProgress:(float)weakSelf.synchronizationCount/weakSelf.totalCount status:[NSString stringWithFormat:@"%@%.0f%%", NSLocalizedString(@"Synchronizationing", nil),(float)weakSelf.synchronizationCount/weakSelf.totalCount*100]];
            }else
            {
                [SVProgressHUD dismiss];
                
                lastSynchronizationDict[[MSCoreManager sharedManager].userModel.deviceCode] = [UIFactory dateForNumString:[NSDate date]];
                [defaults setObject:lastSynchronizationDict forKey:@"lastSynchronizationTime"];
                [defaults synchronize];
                
                //同步数据结束，刷新页面数据
                NSLog(@"同步数据结束，刷新页面数据");
                
                [weakSelf loadManualData];
                
            }
            //            });
        };
        
        [self.blueToothManager getTurnOverHistoricalData:2];
        
    }else
    {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"UnconnectedDevice", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
    
}

-(void)loadManualData
{
    
    //测试 - 自定义开始结束时间
//    NSString * startStr =@"2018-09-28 00:00:00";
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *startStrD = [dateFormatter dateFromString:startStr];
//
//    NSString * endStr =@"2018-09-28 23:59:00";
//    NSDate *endStrD =[dateFormatter dateFromString:endStr];
//
//    self.manualStartDate = startStrD;
//    self.manualEndDate = endStrD;
    
//    NSString * startStr =@"2018-09-28 22:00:00";
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *startStrD = [dateFormatter dateFromString:startStr];
//    //测试 - 加大结束时间
//        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
//            [adcomps setDay:100];
////        [adcomps setHour:7];
//        self.manualEndDate =  [calendar dateByAddingComponents:adcomps toDate:self.manualStartDate options:0];
    
    
    WS(weakSelf);
    NSString *startDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:self.manualStartDate]];
    NSString *endDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:self.manualEndDate]];
    
    
    
//    NSLog(@"%@,%@,%@,%@",self.manualStartDate,self.manualEndDate,startDate,endDate);
    
    
    //没有-的日期
    NSString *startDateNum = [NSString stringWithFormat:@"%@",[UIFactory dateForNumString:[UIFactory NSDateForNoUTC:self.manualStartDate]]];
    NSString *endDateNum = [NSString stringWithFormat:@"%@",[UIFactory dateForNumString:[UIFactory NSDateForNoUTC:self.manualEndDate]]];
    
    NSString *startHour = [startDate substringWithRange:NSMakeRange(11, 2)];
    NSString *startMinute = [startDate substringWithRange:NSMakeRange(14, 2)];
    
    NSString *endHour = [endDate substringWithRange:NSMakeRange(11, 2)];
    NSString *endMinute = [endDate substringWithRange:NSMakeRange(14, 2)];
    
    int startTotalMinute = [startHour intValue]*60 + [startMinute intValue];
    int endTotalMinute = [endHour intValue]*60 + [endMinute intValue];
    
    //睡眠三分钟一个点,计算出实际取点的时间
    int startPointHour = startTotalMinute/60;
    int startPointMinute = startTotalMinute%60/3*3;
    int endPointHour = endTotalMinute/60;
    int endPointMinute = endTotalMinute%60/3*3;
    
    int startPointTotalMinute = startPointHour*60 + startPointMinute;
    int endPointTotalMinute = endPointHour*60 + endPointMinute;
    
    //心率呼吸率五分钟一个点
    int startHRRRPointHour = startTotalMinute/60;
    int startHRRRPointMinute = startTotalMinute%60/5*5;
    int endHRRRPointHour = endTotalMinute/60;
    int endHRRRPointMinute = endTotalMinute%60/5*5;
    
    int startHRRRPointTotalMinute = startHRRRPointHour*60 + startHRRRPointMinute;
    int endHRRRPointTotalMinute = endHRRRPointHour*60 + endHRRRPointMinute;
    
    Byte *dateByteArray;
    int dateByteArrayCount = 0;
//    NSMutableArray *arrayTag = [[NSMutableArray alloc]init];
    
    if ([[startDate substringToIndex:10] isEqualToString:[endDate substringToIndex:10]])
    {
        //同一天
        dateByteArray  =  (Byte*)malloc(endPointTotalMinute/3 - startPointTotalMinute/3 +1);
        NSMutableArray *dateTurnOverArray = [TurnOverModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":startDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        
        if (dateTurnOverArray.count > 0)
        {
            TurnOverModel *turnOverModel = dateTurnOverArray[0];
            Byte * totalByte = (Byte *)[turnOverModel.data bytes];

            for(int i = 0 ; i < endPointTotalMinute/3+1 - startPointTotalMinute/3 ; i ++)
            {
                    dateByteArray[i] = totalByte[i+ startPointTotalMinute/3];
                    dateByteArrayCount++;
            }
            
        }else
        {
            for(int i = 0 ; i < endPointTotalMinute/3+1 - startPointTotalMinute/3 ; i ++)
            {
                //                if (i == 0) {
                //                    dateByteArray[i] = 0x10;
                //                }else if(i == endPointTotalMinute/3 - startPointTotalMinute/3){
                //                    dateByteArray[i] = 0x30;
                //                }else{
                //                    dateByteArray[i] = 0x20;
                //                }
                dateByteArray[i] = 0x00;
                dateByteArrayCount++;
            }
        }
        
        //心率
        NSMutableArray *heartRateArray = [HeartRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":startDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        if (heartRateArray.count == 0)
        {
            for(int i = 0 ; i < endHRRRPointTotalMinute/5+1 - startHRRRPointTotalMinute/5 ; i ++)
            {
                [self.HRDataArray addObject:@"0"];
            }
            
        }else
        {
            HeartRateModel *heartRateModel = heartRateArray[0];
            for(int i = 0 ; i < endHRRRPointTotalMinute/5+1 - startHRRRPointTotalMinute/5 ; i ++)
            {
                [self.HRDataArray addObject: heartRateModel.dataArray[i+startHRRRPointTotalMinute/5]];
            }
        }
        
        //呼吸率数据
        NSMutableArray *respiratoryRateArray = [RespiratoryRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":startDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        if (respiratoryRateArray.count == 0)
        {
            for(int i = 0 ; i < endHRRRPointTotalMinute/5+1 - startHRRRPointTotalMinute/5 ; i ++)
            {
                [self.RRDataArray addObject:@"0"];
            }
            
        }else
        {
            RespiratoryRateModel *respiratoryRateModel = respiratoryRateArray[0];
            for(int i = 0 ; i < endHRRRPointTotalMinute/5+1 - startHRRRPointTotalMinute/5 ; i ++)
            {
                [self.RRDataArray addObject: respiratoryRateModel.dataArray[i+startHRRRPointTotalMinute/5]];
            }
        }
        
    }else
    {
        //两天
        int firstDayMinute = 24*60-startPointTotalMinute;
        int firstDayMinuteCount = firstDayMinute/3;
        
        int secondDayMinuteCount = endPointTotalMinute/3;
        
        //        dateByteArray =  (Byte*)malloc(160);
        dateByteArray  =  (Byte*)malloc(firstDayMinuteCount + secondDayMinuteCount +1 );
        dateByteArrayCount = firstDayMinuteCount + secondDayMinuteCount +1 ;
        
        //        Byte *dateByteArray2;
        //        dateByteArray2 =  (Byte*)malloc(480);
        //
        //        if (dateByteArray == NULL) {
        //            NSLog(@"malloc无效");
        //        }else{
        //            NSLog(@"malloc有效");
        //        }
        //
        //        dateByteArray[0] = 0x01;
        //        dateByteArray2[0] = 0x01;
        
    
        NSMutableArray *firstDateTurnOverArray = [TurnOverModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":startDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        if (firstDateTurnOverArray.count > 0)
        {
            TurnOverModel *turnOverModel = firstDateTurnOverArray[0];
            Byte * totalByte = (Byte *)[turnOverModel.data bytes];
            for(int i = 0 ; i < firstDayMinuteCount ; i ++)
            {
//                if (i == 0) {
//                    dateByteArray[0] = (totalByte[i] & 0x0f) | (0x00 <<4);
//                }else{
//                    dateByteArray[i] = (totalByte[i] & 0x0f) | (0x02 <<4);
//                }
                dateByteArray[i] = totalByte[i];
            }
            
        }else
        {
            for(int i = 0 ; i < firstDayMinuteCount ; i ++)
            {
                dateByteArray[i] = 0x00;
            }
        }
        
        NSMutableArray *secondDateTurnOverArray = [TurnOverModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":endDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        if (secondDateTurnOverArray.count > 0)
        {
            TurnOverModel *turnOverModel = secondDateTurnOverArray[0];
            Byte * totalByte = (Byte *)[turnOverModel.data bytes];
            for(int i = 0 ; i < secondDayMinuteCount+1 ; i ++)
            {
//                if (i == secondDayMinuteCount) {
//                    dateByteArray[i+firstDayMinuteCount] = (totalByte[i] & 0x0f) | (0x00 <<4);
//                }else{
//                    dateByteArray[i+firstDayMinuteCount] = (totalByte[i] & 0x0f) | (0x02 <<4);
//                }
                dateByteArray[i+firstDayMinuteCount] = totalByte[i];
            }
    
        }else
        {
            for(int i = 0 ; i < secondDayMinuteCount+1 ; i ++)
            {
                dateByteArray[i+firstDayMinuteCount] = 0x00;
            }
        }
        
        int firstHRRRDayMinute = 24*60-startHRRRPointTotalMinute;
        int firstHRRRDayMinuteCount = firstHRRRDayMinute/5;
        
        int secondHRRRDayMinuteCount = endHRRRPointTotalMinute/5;
        //心率
        NSMutableArray *heartRateFirstArray = [HeartRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":startDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        
        if (heartRateFirstArray.count == 0)
        {
            for(int i = 0 ; i < firstHRRRDayMinuteCount ; i ++)
            {
                [self.HRDataArray addObject:@"0"];
            }
            
        }else
        {
            HeartRateModel *heartRateFirstModel = heartRateFirstArray[0];
            for(int i = 0 ; i < firstHRRRDayMinuteCount ; i ++){
                
                [self.HRDataArray addObject: heartRateFirstModel.dataArray[i+startHRRRPointTotalMinute/5]];
                
            }
        }
        NSMutableArray *heartRateSecondArray = [HeartRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":endDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        
        if (heartRateSecondArray.count == 0) {
            
            for(int i = 0 ; i < secondHRRRDayMinuteCount +1 ; i ++)
            {
                [self.HRDataArray addObject:@"0"];
            }
            
        }else
        {
            HeartRateModel *heartRateSecondModel = heartRateSecondArray[0];
            for(int i = 0 ; i < secondHRRRDayMinuteCount+1 ; i ++)
            {
                [self.HRDataArray addObject: heartRateSecondModel.dataArray[i]];
            }
        }
        
        //呼吸率
        NSMutableArray *respiratoryRateFirstArray = [RespiratoryRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":startDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        if (respiratoryRateFirstArray.count == 0)
        {
            for(int i = 0 ; i < firstHRRRDayMinuteCount ; i ++)
            {
                [self.RRDataArray addObject:@"0"];
            }
            
        }else
        {
            RespiratoryRateModel *respiratoryRateFirstModel = respiratoryRateFirstArray[0];
            for(int i = 0 ; i < firstHRRRDayMinuteCount ; i ++)
            {
                [self.RRDataArray addObject: respiratoryRateFirstModel.dataArray[i+startHRRRPointTotalMinute/5]];
            }
        }
        NSMutableArray *respiratoryRateSecondArray = [RespiratoryRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":endDateNum,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
        if (respiratoryRateSecondArray.count == 0)
        {
            for(int i = 0 ; i < secondHRRRDayMinuteCount +1 ; i ++)
            {
                [self.RRDataArray addObject:@"0"];
            }
            
        }else
        {
            RespiratoryRateModel *respiratoryRateSecondModel = respiratoryRateSecondArray[0];
            for(int i = 0 ; i < secondHRRRDayMinuteCount+1 ; i ++)
            {
                [self.RRDataArray addObject: respiratoryRateSecondModel.dataArray[i]];
            }
        }
    }
    
    //翻身数组
    for(int i = 0 ; i < dateByteArrayCount ; i ++)
    {
        int turnOver = (int)(dateByteArray[i] & 0x0f);
        if(turnOver == 15)
        {
            turnOver = 0;
        }
        if (turnOver > 9)
        {
            turnOver = 9;
        }
        [self.turnOverDataArray addObject:[NSString stringWithFormat:@"%d",turnOver]];
        [self.stateArray addObject:[NSString stringWithFormat:@"%d",(int)((dateByteArray[i] & 0xf0) >> 4)]];
        
    }
    
    //    for(int i = 0 ; i < dateByteArrayCount;i++){
    //        NSLog(@"%@",[NSString stringWithFormat:@"%hhu",dateByteArray[i]]);
    //    }
    
    
    //    NSLog(@"%@,%@,%@,%@",self.HRDataArray,self.RRDataArray,self.turnOverDataArray,self.stateArray);
    
    //    NSLog(@"%d,%d,%d",startPointTotalMinute,endPointTotalMinute,dateByteArrayCount);
    
    //保存数据到文件
//    NSData *adata = [[NSData alloc] initWithBytes:dateByteArray length:dateByteArrayCount];
//    NSString *path_1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    path_1 = [path_1 stringByAppendingPathComponent:[NSString stringWithFormat:@"1.txt"]];
//    [adata writeToFile:path_1 atomically:YES];
//    NSLog(@"%d",dateByteArrayCount);
    
    
    NSDictionary *dict = [SleepCurveTool sleepCurve:dateByteArray WithDataByteLength:dateByteArrayCount WithIndex:0];
    SleepQualityModel *model = [[SleepQualityModel alloc]init];
    model.sleepCurveArray = dict[@"SleepCurve"];
    model.awakeTime = dict[@"AwakeTime"];
    model.lightSleepTime = dict[@"LightSleepTime"];
    model.midSleepTime = dict[@"MidSleepTime"];
    model.deepSleepTime = dict[@"DeepSleepTime"];
    model.tagArray = dict[@"tagArray"];
    [self setSleepQualityLabelValue:dict];
    
    
    [weakSelf.sleepTimeDayView drawManualSleepViewForSleepData:model.sleepCurveArray WithStartTime:weakSelf.manualStartDate WithEndTime:weakSelf.manualEndDate WithGetUpIndex:model.tagArray WithData:YES];
    
    [self refreshUI];
    
}

//刷新UI
-(void)refreshUI
{
    NSString *averageHeartRate = [self.averageHeartRateDayView drawUniversalManualViewDrawType:SleepDrawDayViewType_AverageHeartRate WithData:self.HRDataArray WithStartTime:self.manualStartDate WithEndTime:self.manualEndDate];
    NSString *averageRespiratoryRate = [self.averageRespiratoryRateDayView drawUniversalManualViewDrawType:SleepDrawDayViewType_AverageRespiratoryRate WithData:self.RRDataArray WithStartTime:self.manualStartDate WithEndTime:self.manualEndDate];
    [self.turnOverDayView drawUniversalManualViewDrawType:SleepDrawDayViewType_TurnOver WithData:self.turnOverDataArray WithStartTime:self.manualStartDate WithEndTime:self.manualEndDate];
    
    //修改睡眠质量视图文本数据，平均心率、平均呼吸率
    UILabel *averageHeartRateLabel = (UILabel *)[self.sleepTimeDayView viewWithTag:104];
    NSMutableAttributedString *heartRateAttributedStr;
    NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);
    heartRateAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",averageHeartRate,unit]];
    [heartRateAttributedStr addAttribute:NSFontAttributeName
                                   value:[UIFont boldSystemFontOfSize:18.0]
                                   range:NSMakeRange(0, averageHeartRate.length)];
    [heartRateAttributedStr addAttribute:NSFontAttributeName
                                   value:[UIFont systemFontOfSize:10.0]
                                   range:NSMakeRange(averageHeartRate.length, unit.length)];
    averageHeartRateLabel.attributedText = heartRateAttributedStr;
    
    UILabel *averageRespiratoryRateLabel = (UILabel *)[self.sleepTimeDayView viewWithTag:105];
    NSMutableAttributedString *respiratoryRateAttributedStr;
    respiratoryRateAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",averageRespiratoryRate,unit]];
    [respiratoryRateAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:18.0]
                                         range:NSMakeRange(0, averageRespiratoryRate.length)];
    [respiratoryRateAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont systemFontOfSize:10.0]
                                         range:NSMakeRange(averageRespiratoryRate.length, unit.length)];
    averageRespiratoryRateLabel.attributedText = respiratoryRateAttributedStr;
    
}

//修改日睡眠质量视图文本数据，深睡、浅睡、清醒、中睡时长
-(void)setSleepQualityLabelValue:(NSDictionary *)sleepQuality
{
    
    NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);
    NSString * hourUnit= NSLocalizedString(@"RMVC_Hour", nil);
    
    int awakeTime = [sleepQuality[@"AwakeTime"] intValue];
    int lightSleepTime = [sleepQuality[@"LightSleepTime"] intValue];
    int midSleepTime = [sleepQuality[@"MidSleepTime"] intValue];
    int deepSleepTime = [sleepQuality[@"DeepSleepTime"] intValue];
    if (deepSleepTime == 86400)
    {
        deepSleepTime = 0;
    }
    
    //更新实际睡眠时间Label
    int sumTime = lightSleepTime + midSleepTime + deepSleepTime;
    NSString *sumTimeHour = [NSString stringWithFormat:@"%d",sumTime/3600];
    NSString *sumTimeMinute = [NSString stringWithFormat:@"%d",(sumTime%3600)/60];
    NSMutableAttributedString *sumTimeAttributedStr;
    if (sumTime == 0)
    {
        sumTimeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0min"]];
        [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                     value:[UIFont boldSystemFontOfSize:36.0]
                                     range:NSMakeRange(0, 1)];
        [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:21.0]
                                     range:NSMakeRange(1, 3)];
    }else
    {
        
        if ([sumTimeHour intValue] == 0)
        {
            
            sumTimeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",sumTimeMinute,minUnit]];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:36.0]
                                         range:NSMakeRange(0, sumTimeMinute.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont systemFontOfSize:21.0]
                                         range:NSMakeRange(sumTimeMinute.length, minUnit.length)];
        }else
        {
            
            sumTimeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@%@%@",sumTimeHour,hourUnit,sumTimeMinute,minUnit]];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:36.0]
                                         range:NSMakeRange(0, sumTimeHour.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont systemFontOfSize:21.0]
                                         range:NSMakeRange(sumTimeHour.length, hourUnit.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:36.0]
                                         range:NSMakeRange(sumTimeHour.length+1, sumTimeMinute.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont systemFontOfSize:21.0]
                                         range:NSMakeRange(sumTimeHour.length+1+sumTimeMinute.length, minUnit.length)];
        }
        
    }
    self.sleepTimeDayView.valueLabel.attributedText = sumTimeAttributedStr;
    
    for(int i = 0 ; i < 4 ; i++)
    {
        int time;
        if (i == 0) {
            time = deepSleepTime;
        }else if (i == 1){
            time = midSleepTime;
        }else if (i == 2){
            time = lightSleepTime;
        }else{
            time = awakeTime;
        }
        UILabel *timeLabel = (UILabel *)[self.sleepTimeDayView viewWithTag:100+i];
        NSMutableAttributedString *timeAttributedStr;
        NSString *timeHour = [NSString stringWithFormat:@"%d",time/3600];
        NSString *timeMinute = [NSString stringWithFormat:@"%d",(time%3600)/60];
        //        NSString *timeSecond = [NSString stringWithFormat:@"%d",time%60];
        
        if ([timeHour intValue] == 0 && [timeMinute intValue]== 0) {
            NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);
            timeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",minUnit]];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont boldSystemFontOfSize:18.0]
                                      range:NSMakeRange(0, 1)];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:10.0]
                                      range:NSMakeRange(1, minUnit.length)];
        }else{
            if ([timeHour intValue] == 0) {
                timeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",timeMinute,minUnit]];
                [timeAttributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont boldSystemFontOfSize:18.0]
                                          range:NSMakeRange(0, timeMinute.length)];
                [timeAttributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont systemFontOfSize:10.0]
                                          range:NSMakeRange(timeMinute.length, minUnit.length)];
            }else{
                timeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@%@%@",timeHour,hourUnit,timeMinute,minUnit]];
                [timeAttributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont boldSystemFontOfSize:18.0]
                                          range:NSMakeRange(0, timeHour.length)];
                [timeAttributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont systemFontOfSize:10.0]
                                          range:NSMakeRange(timeHour.length, hourUnit.length)];
                [timeAttributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont boldSystemFontOfSize:18.0]
                                          range:NSMakeRange(timeHour.length+1, timeMinute.length)];
                [timeAttributedStr addAttribute:NSFontAttributeName
                                          value:[UIFont systemFontOfSize:10.0]
                                          range:NSMakeRange(timeHour.length+1+timeMinute.length, minUnit.length)];
            }
        }
        timeLabel.attributedText = timeAttributedStr;
    }
}

-(void)setDayViewScrollViewContentOffset:(UIScrollView*)scrollView
{
    for(int i = 1000 ; i < 1004 ; i++)
    {
        DrawView *drawView = (DrawView *)[self.dayView viewWithTag:i];
        if(scrollView != drawView.scrollDayView)
        {
            drawView.scrollDayView.contentOffset = scrollView.contentOffset;
        }
    }
}

-(void)setManualViewUI
{
    WS(weakSelf);
    self.dayScrollView = [[UIScrollView alloc]init];
    self.dayScrollView.bounces = NO;
    self.dayScrollView.showsVerticalScrollIndicator = FALSE;
    // 添加scrollView添加到父视图，并设置其约束
    [self.view addSubview:self.dayScrollView];
    [self.dayScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        
    }];
    
    // 设置scrollView的子视图，即过渡视图contentSize，并设置其约束
    self.dayProfileView = [[UIView alloc]init];
    [self.dayScrollView addSubview:self.dayProfileView];
    [self.dayProfileView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.bottom.and.right.equalTo(weakSelf.dayScrollView).with.insets(UIEdgeInsetsZero);
        make.width.equalTo(weakSelf.dayScrollView);
        
    }];
    
    self.dayView = [[UIView alloc]init];
    [self.dayProfileView addSubview:self.dayView];
    
    self.sleepTimeDayView = [[DrawView alloc]init];
    self.sleepTimeDayView.tag = 1000;
    self.sleepTimeDayView.contentOffsetBlock = ^(UIScrollView *scrollView) {
        
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
        
    };
    [self.dayView addSubview:self.sleepTimeDayView];
    [self.sleepTimeDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@446);
    }];
    
    //手动测试
    [self.sleepTimeDayView setManualSleepViewUI];
    
    UILabel * monitorTitleLabel = [[UILabel alloc]init];
    [self.dayView addSubview:monitorTitleLabel];
    monitorTitleLabel.font = [UIFont systemFontOfSize:15];
    monitorTitleLabel.textAlignment = NSTextAlignmentLeft;
    monitorTitleLabel.textColor = [UIColor whiteColor];
    monitorTitleLabel.text = NSLocalizedString(@"RMVC_SleepMonitoring", nil);
    [monitorTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.sleepTimeDayView.mas_bottom).offset(0);
        make.height.equalTo(@37);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
        
    }];
    
    self.averageHeartRateDayView = [[DrawView alloc]init];
    [self.dayView addSubview:self.averageHeartRateDayView];
    self.averageHeartRateDayView.tag = 1001;
    self.averageHeartRateDayView.contentOffsetBlock = ^(UIScrollView *scrollView) {
        
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
        
    };
    
    [self.averageHeartRateDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(monitorTitleLabel.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@220);
        
    }];
    
    [self.averageHeartRateDayView setUniversalManualViewUIForDrawType:SleepDrawDayViewType_AverageHeartRate];
    
    self.averageRespiratoryRateDayView = [[DrawView alloc]init];
    self.averageRespiratoryRateDayView.tag = 1002;
    self.averageRespiratoryRateDayView.contentOffsetBlock = ^(UIScrollView *scrollView) {
        
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
    };
    
    [self.dayView addSubview:self.averageRespiratoryRateDayView];
    [self.averageRespiratoryRateDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.averageHeartRateDayView.mas_bottom).offset(10);
        make.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@220);
        
    }];
    
    [self.averageRespiratoryRateDayView setUniversalManualViewUIForDrawType:SleepDrawDayViewType_AverageRespiratoryRate];
    
    self.turnOverDayView = [[DrawView alloc]init];
    [self.dayView addSubview:self.turnOverDayView];
    self.turnOverDayView.tag = 1003;
    self.turnOverDayView.contentOffsetBlock = ^(UIScrollView *scrollView) {
        [weakSelf setDayViewScrollViewContentOffset:scrollView];
    };
    [self.turnOverDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.averageRespiratoryRateDayView.mas_bottom).offset(10);
        make.left.right.equalTo(weakSelf.dayView);
        make.height.equalTo(@220);
        
    }];
    [self.turnOverDayView setUniversalManualViewUIForDrawType:SleepDrawDayViewType_TurnOver];
    
    [self.dayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.equalTo(weakSelf.dayProfileView);
        make.bottom.mas_equalTo(weakSelf.turnOverDayView.mas_bottom).offset(0);
        
    }];
    
    // 设置过渡视图的底边距为最后一个子视图的底部（此设置将影响到scrollView的contentSize）
    [self.dayProfileView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(weakSelf.dayView.mas_bottom).offset(0);
        
    }];
    
}

-(void)setUI
{
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
    titleLabel.text = NSLocalizedString(@"RMVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    [self setManualViewUI];
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
