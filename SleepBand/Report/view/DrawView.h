//
//  DrawView.h
//  SleepBand
//
//  Created by admin on 2018/7/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

//睡眠质量
typedef NS_ENUM(NSInteger,SleepQualityValueType){
    
    SleepQualityValueType_DeepSleepTime, //深睡时长
    SleepQualityValueType_MidSleepTime,  //入睡时长
    SleepQualityValueType_LightSleepTime, //浅睡时长
    SleepQualityValueType_SoberTime, //梦醒时长
    SleepQualityValueType_AverageHeartRate, //平均心率
    SleepQualityValueType_AverageRespiratoryRate,  //平均呼吸率
};

//日
typedef NS_ENUM(NSInteger,SleepDrawDayViewType)
{
    SleepDrawDayViewType_AverageHeartRate = 1, //平均心率
    SleepDrawDayViewType_AverageRespiratoryRate, //平均呼吸率
    SleepDrawDayViewType_TurnOver //翻身次数
    
};

//月周
typedef NS_ENUM(NSInteger,SleepDrawWeekMonthViewType)
{
    SleepDrawWeekMonthViewType_AverageHeartRate, //平均心率
    SleepDrawWeekMonthViewType_AverageRespiratoryRate, //平均呼吸率
    SleepDrawWeekMonthViewType_AverageLengthOfSleepStages, //平均入睡时长
    SleepDrawWeekMonthViewType_SleepLatency, //入睡时间
    SleepDrawWeekMonthViewType_GetUpTime, //起床时间
    SleepDrawWeekMonthViewType_FrequencyOfWakeUp, //清醒次数
    SleepDrawWeekMonthViewType_FrequencyOfBedAway //离床次数
    
};

typedef void(^ContentOffsetBlock)(UIScrollView *scrollView);

@interface DrawView : UIView

@property (strong,nonatomic)NSMutableArray *drawViewDataArray;
@property (strong,nonatomic)UIBezierPath *bezierPath;
@property (strong,nonatomic)CAShapeLayer *shapeLayer;
@property (assign,nonatomic)CGPoint lastPoint;
@property (assign,nonatomic)BOOL isRR;

//report
@property (strong,nonatomic)NSMutableArray *reortDataArray;
@property (strong,nonatomic)UIBezierPath *reportBezierPath;
@property (strong,nonatomic)CAShapeLayer *reportShapeLayer;
@property (assign,nonatomic)CGPoint reportPoint;

@property (strong,nonatomic)UILabel *valueLabel; //数据

@property (strong,nonatomic)UIView *sleepQualityDayView; //日睡眠质量线视图
@property (strong,nonatomic)UIView *sleepQualityDayCoverView;//日睡眠质量遮挡视图
@property (strong,nonatomic)UIView *averageHeartRateDayView; //日平均心率视图
@property (strong,nonatomic)UIView *averageRespiratoryRateDayView; //日平均呼吸视图
@property (strong,nonatomic)UIView *turnOverDayView; //日翻身次数视图
@property (strong,nonatomic)UIScrollView *scrollDayView;
@property (strong,nonatomic)UIView *universalDayView; //日通用视图
@property (strong,nonatomic)NSArray *yScaleArray;
@property (strong,nonatomic)UILabel *maxSleepTimeLabel; //最大睡眠时间
@property (strong,nonatomic)UIView *sleepQualityView; //周月睡眠质量视图
@property (strong,nonatomic)UIView *universalWeekMonthView; //周月通用视图
@property (copy,nonatomic)ContentOffsetBlock contentOffsetBlock;




#pragma mark - 实时
//采样值实时图
-(void)drawSampleView;
//采样值增加
-(void)addData:(NSArray *)array;

//report
- (void)reportAddData:(NSArray *) array;
- (void)reportBrHrData:(NSArray*) array;


#pragma mark - 手动测试报告
//手动测试，睡眠质量UI
-(void)setManualSleepViewUI;
//手动测试，睡眠质量画图
//-(void)drawManualSleepViewForSleepData:(NSArray *)arrayData WithStartTime:(NSDate *)startTime WithEndTime:(NSDate *)endTime WithData:(BOOL)hasData;
-(void)drawManualSleepViewForSleepData:(NSArray *)arrayData WithStartTime:(NSDate *)startTime WithEndTime:(NSDate *)endTime  WithGetUpIndex:(NSArray *)indexArray WithData:(BOOL)hasData;
//手动测试，通用UI
-(void)setUniversalManualViewUIForDrawType:(SleepDrawDayViewType)type;
//手动测试，通用画图
-(NSString *)drawUniversalManualViewDrawType:(SleepDrawDayViewType)type WithData:(NSArray *)dataArray WithStartTime:(NSDate *)startTime WithEndTime:(NSDate *)endTime;

#pragma mark - 日
//天，睡眠质量UI
-(void)setSleepDayViewUI;
//天，睡眠质量画图
-(void)drawSleepDayViewForSleepData:(NSArray *)arrayData WithHour:(int)hour WithGetUpIndex:(NSArray *)indexArray WithData:(BOOL)hasData;
//天，通用UI
-(void)setUniversalDayViewUIForDrawType:(SleepDrawDayViewType)type;
//天，通用画图
-(NSString *)drawUniversalDayViewDrawType:(SleepDrawDayViewType)type WithData:(NSArray *)dataArray WithHour:(int)hour;

//egeg
- (NSString *)drawUniversalDayViewDrawTe:(SleepDrawDayViewType)type WithData:(NSArray *)dataArry WithHour:(int)hour;

#pragma mark - 周月
//周月，睡眠质量UI
-(void)setSleepViewUI;
//周月，睡眠质量画图
-(void)drawSleepViewForData:(NSArray *)dataArray withSleepDateArray:(NSArray *)dateArray withHeartRateDateArray:(NSArray *)heartRateArray withRespiratoryRateDateArray:(NSArray *)respiratoryRateArray;
//周月，通用UI
-(void)setUniversalWeekMonthViewUIForDrawType:(SleepDrawWeekMonthViewType)type;
//周月，通用画图
-(void)drawUniversalWeekMonthViewDrawType:(SleepDrawWeekMonthViewType)type WithData:(NSArray *)dataArray WithDateArray:(NSArray *)dateArray;

@end
