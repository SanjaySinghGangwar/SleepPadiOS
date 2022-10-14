//
//  XYWDayBackView.h
//  SleepBand
//
//  Created by admin on 2019/6/4.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYWDayBackView : UIView

@property (nonatomic, strong) NSArray * titleXArr;
@property (nonatomic, strong) NSMutableArray * sleepTimeArr;

- (instancetype)init;

//刷新-睡眠质量
- (void)xyw_refreshSleepQualityDataWithData:(NSInteger)selectData;
//刷新-心率数据
- (void)xyw_refreshHeartRateDataWithData:(NSInteger)selectData;
//刷新-呼吸数据
- (void)xyw_refreshBreathRateDataWithData:(NSInteger)selectData;
//刷新-翻身数据
- (void)xyw_refreshTurnOverDataWithData:(NSInteger)selectData;
//刷新-全部数据（睡眠质量、心率、呼吸、翻身）
//sizeTime （单位：秒）
- (void)xyw_refreshDayBackViewWithData:(NSInteger)selectData sizeTime:(NSInteger)sizeTime;

@end

NS_ASSUME_NONNULL_END
