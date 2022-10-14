//
//  XYWReportBaseChartView.h
//  SleepBand
//
//  Created by admin on 2019/6/5.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYWReportBaseChartView : UIView

@property (nonatomic, strong) NSString * iconStr;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * backgroundImageStr;
@property (nonatomic, strong) NSString * valueStr;
@property (nonatomic, strong) NSString * themeColor;
@property (nonatomic, strong) NSString * gridYLineColor;
@property (nonatomic, strong) NSArray * titleXArr;
@property (nonatomic, strong) NSArray * titleYArr;

//init
- (instancetype)initWithIconStr:(NSString*)iconStr
                          title:(NSString*)title
                       bgImgStr:(NSString*)backgroundImageStr
                       valueStr:(NSString*)valueStr
                     themeColor:(NSString*)themeColor
                 gridYLineColor:(NSString*)gridYLineColor
                      titleYArr:(NSArray*)titleYArr;

//刷新表格数据
- (void)xyw_refreshChatrDataWithYtitleArr:(NSArray*)titleArr pointArr:(NSArray*)pointArr;

@end



NS_ASSUME_NONNULL_END
