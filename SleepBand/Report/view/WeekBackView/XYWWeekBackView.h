//
//  XYWWeekBackView.h
//  SleepBand
//
//  Created by admin on 2019/6/4.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYWWeekBackView : UIView

@property (nonatomic, strong) NSArray * titleXArr;

- (instancetype)init;

//刷新-睡眠质量
- (void)xyw_refreshSleepQualityDataWithDataArr:(NSArray*)selectDataArr;
//刷新-心率数据
- (void)xyw_refreshHeartRateDataWithDataArr:(NSArray*)selectDataArr;
//刷新-呼吸数据
- (void)xyw_refreshBreathRateDataWithDataArr:(NSArray*)selectDataArr;
//刷新-翻身数据
- (void)xyw_refreshTurnOverDataWithDataArr:(NSArray*)selectDataArr;
//刷新-全部数据
- (void)xyw_refreshWeekBackViewWithDataArr:(NSArray*)selectDataArr;

@end

NS_ASSUME_NONNULL_END
