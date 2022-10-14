//
//  XYWWeekBackView.m
//  SleepBand
//
//  Created by admin on 2019/6/4.
//  Copyright © 2019 admin. All rights reserved.
//

#import "XYWWeekBackView.h"
#import "AAChartKit.h"
#import "XYWProgressCellView.h"
#import "XYWReportBaseChartView.h"

#define labelWidth 45

@interface XYWWeekBackView ()<AAChartViewEventDelegate>

@property (nonatomic, strong) AAChartModel * SQChartModel;
@property (nonatomic, strong) AAChartView * SQChartView;
@property (nonatomic, strong) UILabel * valueLabel;//睡眠的时长
@property (nonatomic, strong) NSArray<UILabel*> * yLabViews;
@property (nonatomic, strong) NSArray<UILabel*> * xLabViews;
@property (nonatomic, strong) NSArray<XYWProgressCellView *> * progressArr;

@property (nonatomic, strong) UILabel * monitorTitleLab;//睡眠监测标题lab
@property (nonatomic, strong) XYWReportBaseChartView * reportHeartRateView;//HeartRate
@property (nonatomic, strong) XYWReportBaseChartView * reportBreathRateView;//BreathRate
@property (nonatomic, strong) XYWReportBaseChartView * reportTurnOverView;//Turn

@end

@implementation XYWWeekBackView

#pragma mark --init
- (instancetype)init{
    
    if (self = [super init]) {
        // 设置属性值
        //...
        // 创建临时变量
        //...
        /*  睡眠质量  */
        [self setUIForSleepQuality];
        /*  心率数据表   */
        [self setUIForHeartRate];
        /*  呼吸数据表  */
        [self setUIForBreathRate];
        /*  翻身数据表  */
        [self setUIForTurnOver];
        
    }
    return self;
}

- (void)setTitleXArr:(NSArray *)titleXArr{
    if (_titleXArr != titleXArr) {
        _titleXArr = titleXArr;
        
        self.SQChartModel.categoriesSet(titleXArr);//设置 X 轴坐标文字内容
        [self.SQChartView aa_refreshChartWithChartModel:self.SQChartModel];
        
        for (UILabel * lab in _xLabViews) {
            lab.text = titleXArr[lab.tag-10];
        }
    }
}

#pragma mark --setUI 睡眠质量
- (void)setUIForSleepQuality{
    
    //画虚线 (清醒，浅睡，中睡，深睡)
//    [self drawLineForChart];
    
    //睡眠质量波形图 初始化
    [self drawChartForSQChartView];
    
    //睡眠的时长
    UILabel * valueLabel = [[UILabel alloc]init];
    [self addSubview:valueLabel];
    valueLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.font = [UIFont boldSystemFontOfSize:24.0];
    self.valueLabel = valueLabel;
    
    NSArray * titleYArr = @[@"12h",@"9h",@"6h",@"3h",];
    NSMutableArray * yLabViews = [NSMutableArray array];
    for (int i = 0; i<4; i++) {
        UILabel * lab = [[UILabel alloc]init];
        [self addSubview:lab];
        lab.tag = i;
        lab.backgroundColor = [UIColor whiteColor];
        lab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
        lab.textColor = [UIColor colorWithHexString:@"#b1aca8"];
        lab.textAlignment = NSTextAlignmentRight;
        lab.text = titleYArr[i];
        [yLabViews addObject:lab];
    }
    self.yLabViews = yLabViews;
    
    NSMutableArray * xLabViews = [NSMutableArray array];
    NSArray * xLabTitle = @[NSLocalizedString(@"RMVC_Sunday", nil),
                            NSLocalizedString(@"RMVC_Monday", nil),
                            NSLocalizedString(@"RMVC_Tuesday", nil),
                            NSLocalizedString(@"RMVC_Wednesday", nil),
                            NSLocalizedString(@"RMVC_Thursday", nil),
                            NSLocalizedString(@"RMVC_Friday", nil),
                            NSLocalizedString(@"RMVC_Saturday", nil),];
    for (int i = 0; i<7; i++) {
        UILabel * lab = [[UILabel alloc]init];
        [self addSubview:lab];
        lab.tag = i + 10;
        lab.backgroundColor = [UIColor whiteColor];
        lab.font = [UIFont systemFontOfSize:13];
        lab.textColor = [UIColor grayColor];
        lab.text = xLabTitle[i];
        lab.textAlignment = NSTextAlignmentCenter;
        [xLabViews addObject:lab];
    }
    self.xLabViews = xLabViews;
    
    //睡眠质量进度条
    [self drawViewForProgressCellView];
    
    //睡眠监测Lab
    UILabel * monitorTitleLab = [[UILabel alloc]init];
    [self addSubview:monitorTitleLab];
    monitorTitleLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    monitorTitleLab.textAlignment = NSTextAlignmentCenter;
    monitorTitleLab.textColor = [UIColor colorWithHexString:@"#575756"];
    monitorTitleLab.text = NSLocalizedString(@"RMVC_SleepMonitoring", nil);
    self.monitorTitleLab = monitorTitleLab;
}

#pragma mark --setUI 心率数据表
- (void)setUIForHeartRate{
    
    XYWReportBaseChartView * reportHeartRateView = [[XYWReportBaseChartView alloc]initWithIconStr:@"realtime_icon_heartrate" title:NSLocalizedString(@"RTVC_RespiratoryRateTitle", nil) bgImgStr:@"report_br_bg" valueStr:[NSString stringWithFormat:@"--%@",NSLocalizedString(@"SMVC_HeartRateUnit", nil)] themeColor:@"#1b86a4" gridYLineColor:@"#26B9DA" titleYArr:@[@"180",@"135",@"90",@"45",@"0"]];
    [self addSubview:reportHeartRateView];
    self.reportHeartRateView = reportHeartRateView;
    
}

#pragma mark --setUI 呼吸数据表
- (void)setUIForBreathRate{
    
    XYWReportBaseChartView * reportBreathRateView = [[XYWReportBaseChartView alloc]initWithIconStr:@"realtime_icon_breath" title:NSLocalizedString(@"RTVC_RespiratoryRateTitle", nil) bgImgStr:@"report_hr_bg" valueStr:[NSString stringWithFormat:@"--%@",NSLocalizedString(@"SMVC_HeartRateUnit", nil)] themeColor:@"#c3ad8c" gridYLineColor:@"#CEAC87" titleYArr:@[@"40",@"30",@"20",@"10",@"0"]];
    [self addSubview:reportBreathRateView];
    self.reportBreathRateView = reportBreathRateView;
    
}

#pragma mark --setUI 翻身数据表
- (void)setUIForTurnOver{
    
    XYWReportBaseChartView * reportTurnOverView = [[XYWReportBaseChartView alloc]initWithIconStr:@"report_icon_turn" title:NSLocalizedString(@"RMVC_TurnOver", nil) bgImgStr:@"report_br_bg" valueStr:[NSString stringWithFormat:@"--%@",NSLocalizedString(@"RMVC_TurnOverHourTime", nil)] themeColor:@"#1b86a4" gridYLineColor:@"#26B9DA" titleYArr:@[@"8",@"6",@"4",@"2",@"0"]];
    [self addSubview:reportTurnOverView];
    self.reportTurnOverView = reportTurnOverView;
    
}

#pragma mark --自定义
//画虚线 (清醒，浅睡，中睡，深睡)
-(void)drawLineForChart{
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor colorWithHexString:@"#e5e4df"].CGColor;
    border.fillColor = nil;
    
    CGFloat yPat = 65;
    CGFloat midPat = 34;
    
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(62, yPat)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-40), yPat)];
    yPat += midPat;
    [pat moveToPoint:CGPointMake(62, yPat)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-40), yPat)];
    yPat += midPat;
    [pat moveToPoint:CGPointMake(62, yPat)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-40), yPat)];
    yPat += midPat;
    [pat moveToPoint:CGPointMake(62, yPat)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-40), yPat)];
    border.path = pat.CGPath;
    [self.layer addSublayer:border];
    
    CAShapeLayer *borderDown = [CAShapeLayer layer];
    borderDown.strokeColor = [UIColor colorWithHexString:@"#1b86a4"].CGColor;
    borderDown.fillColor = nil;
    UIBezierPath *patDown = [UIBezierPath bezierPath];
    yPat += midPat;
    [patDown moveToPoint:CGPointMake(62, yPat)];
    [patDown addLineToPoint:CGPointMake((kSCREEN_WIDTH-40), yPat)];
    borderDown.path = patDown.CGPath;
    [self.layer addSublayer:borderDown];
    
}

//睡眠质量波形图 初始化
- (void)drawChartForSQChartView{
    
    NSArray * nomalArr = @[@0,@0,@0,@0,@0,@0,@0];
    
    self.SQChartView = [[AAChartView alloc]init];
    self.SQChartView.delegate = self;
    self.SQChartView.scrollEnabled = NO;//禁用 AAChartView 滚动效果
    //    设置aaChartVie 的内容高度(content height)
    //    self.aaChartView.contentHeight = chartViewHeight*2;
    //    设置aaChartVie 的内容宽度(content  width)
    //    self.aaChartView.contentWidth = chartViewWidth*2;
    [self addSubview:self.SQChartView];
    self.SQChartView.isClearBackgroundColor = YES;//背景色是否为透明
    
    self.SQChartModel= AAChartModel.new
    .chartTypeSet(AAChartTypeColumn)//图表类型
    .stackingSet(AAChartStackingTypeNormal)//堆积样式
    .titleSet(@"")//图表主标题
    .subtitleSet(@"")//图表副标题
    .yAxisLineWidthSet(@0)//Y轴轴线线宽为0即是隐藏Y轴轴线
//    .colorsThemeSet(@[@"#1b86a4"])//设置主体颜色数组(线条颜色)
    .colorsThemeSet(@[@"#96F2F8",@"#48d8ef",@"#23abcb",@"#1b86a3"])//
    .yAxisTitleSet(@"")//设置 Y 轴标题
    .tooltipValueSuffixSet(@"℃")//设置浮动提示框单位后缀
    .tooltipEnabledSet(NO)//是否显示浮动提示框
    .backgroundColorSet(@"#4b2b7f")
    .yAxisGridLineWidthSet(@1)//y轴横向分割线宽度为0(即是隐藏分割线)
    .yAxisTickPositionsSet(@[@0,@3,@6,@9,@12])//自定义 y 轴坐标
//    .yAxisTickPositionsSet(@[@0,@2,@4,@6,@8])//自定义 y 轴坐标
    .yAxisLabelsEnabledSet(NO)//y 轴是否显示文字
    .touchEventEnabledSet(NO)//支持用户点击事件
    .borderRadiusSet(@5)
    .seriesSet(@[
                 AASeriesElement.new
                 .nameSet(NSLocalizedString(@"RMVC_Sober", nil))
                 .dataSet(nomalArr),
                 AASeriesElement.new
                 .nameSet(NSLocalizedString(@"RMVC_LightSleep", nil))
                 .dataSet(nomalArr),
                 AASeriesElement.new
                 .nameSet(NSLocalizedString(@"RMVC_MiddleSleep", nil))
                 .dataSet(nomalArr),
                 AASeriesElement.new
                 .nameSet(NSLocalizedString(@"RMVC_DeepSleep", nil))
                 .dataSet(nomalArr),
                 ]
               )
    .markerSymbolStyleSet(AAChartSymbolStyleTypeBorderBlank)//设置折线连接点样式为:边缘白色
    .yAxisVisibleSet(YES)//y 轴是否可见
    .xAxisVisibleSet(YES)//x 轴是否可见
    .xAxisCrosshairWidthSet(@0)//Zero width to disable crosshair by default
//    .xAxisCrosshairColorSet(@"#ffffff")//浅石板灰准星线
    .xAxisCrosshairDashStyleTypeSet(AALineDashStyleTypeLongDashDotDot)
    .categoriesSet(@[NSLocalizedString(@"RMVC_Sunday", nil),
                     NSLocalizedString(@"RMVC_Monday", nil),
                     NSLocalizedString(@"RMVC_Tuesday", nil),
                     NSLocalizedString(@"RMVC_Wednesday", nil),
                     NSLocalizedString(@"RMVC_Thursday", nil),
                     NSLocalizedString(@"RMVC_Friday", nil),
                     NSLocalizedString(@"RMVC_Saturday", nil),])//设置 X 轴坐标文字内容
    .xAxisLabelsFontSizeSet(@13)//x 轴文字字体大小
    .xAxisLabelsFontColorSet(@"#b1aca8")//x 轴文字字体颜色
    .animationTypeSet(AAChartAnimationBounce)//图形的渲染动画为弹性动画
    .animationDurationSet(@(1200))//图形渲染动画时长为1200毫秒
    .legendEnabledSet(NO);//是否显示图例 lengend(图表底部可点按的圆点和文字)
    
    /*配置 Y 轴标注线,解开注释,即可查看添加标注线之后的图表效果(NOTE:必须设置 Y 轴可见)*/
    //    [self configureTheYAxisPlotLineForAAChartView];
    
    [self.SQChartView aa_drawChartWithChartModel:_SQChartModel];
    
}

//睡眠质量进度条
- (void)drawViewForProgressCellView{
    
    NSArray *titleArray = @[NSLocalizedString(@"RMVC_DeepSleepTime", nil),
                            NSLocalizedString(@"RMVC_MiddleSleepTime", nil),
                            NSLocalizedString(@"RMVC_LightSleepTime", nil),
                            NSLocalizedString(@"RMVC_SoberTime", nil),
                            NSLocalizedString(@"RTVC_HeartRateTitle", nil),
                            NSLocalizedString(@"RTVC_RespiratoryRateTitle", nil)];
    NSArray *iconArray  =  @[@"report_icon_deep",@"report_icon_middle",@"report_icon_light",@"report_icon_wakeup",
                             @"report_icon_heartrate",@"report_icon_breath"];
    NSMutableArray * progressCellViewsArr = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        XYWProgressCellView * progressCellView = [[XYWProgressCellView alloc]initWithIconStr:iconArray[i] title:titleArray[i] percentage:0.0 time:@"0" index:i];
        [self addSubview:progressCellView];
        [progressCellViewsArr addObject:progressCellView];
    }
    self.progressArr = [NSArray arrayWithArray:progressCellViewsArr];
    
}
#pragma mark --刷新UI
- (void)xyw_refreshWeekBackViewWithDataArr:(NSArray*)selectDataArr{
    [self xyw_refreshSleepQualityDataWithDataArr:selectDataArr];
    [self xyw_refreshHeartRateDataWithDataArr:selectDataArr];
    [self xyw_refreshBreathRateDataWithDataArr:selectDataArr];
    [self xyw_refreshTurnOverDataWithDataArr:selectDataArr];
}
//刷新-睡眠质量
- (void)xyw_refreshSleepQualityDataWithDataArr:(NSArray*)selectDataArr{
    
    NSMutableArray *dateSleepQualityArray = [SleepQualityModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    
    if (dateSleepQualityArray.count == 0) {
        NSLog(@"没有可刷新的睡眠质量数据");
        return;
    }
    NSMutableArray * deepSleepTimeArr = [NSMutableArray array];
    NSMutableArray * midSleepTimeArr = [NSMutableArray array];
    NSMutableArray * lightSleepTimeArr = [NSMutableArray array];
    NSMutableArray * awakeTimeArr = [NSMutableArray array];
    
    for (int j = 0; j < selectDataArr.count; j++) {
        
        NSTimeInterval a = [[UIFactory stringReturnDate:selectDataArr[j]] timeIntervalSince1970];
        NSInteger beginTime = (NSInteger)a + 5*60*60;
        NSInteger endTime = beginTime + 86400;
        
        CGFloat deepSleepTime = 0;//深睡时长
        CGFloat midSleepTime = 0;//中睡时长
        CGFloat lightSleepTime = 0;//浅睡时长
        CGFloat awakeTime = 0;//清醒时长
        
//        SleepQualityModel * model = nil;
        NSMutableArray * sleepQualityModelArr = [NSMutableArray array];
        for (int i = 0; i < dateSleepQualityArray.count; i++) {
            SleepQualityModel * testModel = dateSleepQualityArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
//                model = testModel;
                [sleepQualityModelArr addObject:testModel];
            }
        }
        
        if (sleepQualityModelArr.count > 0) {
            for (SleepQualityModel * model in sleepQualityModelArr) {
                for (NSDictionary * dict in model.dataArray) {
                    
                    //状态
                    NSString * stateStr = [dict objectForKey:@"state"];
                    NSInteger stateInteger = [stateStr integerValue];
                    //状态时长
                    NSString * stateTimeStr = [dict objectForKey:@"stateTime"];
                    NSInteger stateTimeInt = [stateTimeStr intValue];
                    
                    if (0<stateInteger && stateInteger<=90) {
                        //深睡
                        deepSleepTime = deepSleepTime + stateTimeInt;
                    }else if (90<stateInteger && stateInteger<=150) {
                        //中睡
                        midSleepTime = midSleepTime + stateTimeInt;
                    }else if (150<stateInteger && stateInteger<=234) {
                        //浅睡
                        lightSleepTime = lightSleepTime + stateTimeInt;
                    }else if (234<stateInteger && stateInteger<=256) {
                        //清醒
                        awakeTime = awakeTime + stateTimeInt;
                    }
                }
            }
            [deepSleepTimeArr addObject:[NSNumber numberWithFloat:deepSleepTime]];
            [midSleepTimeArr addObject:[NSNumber numberWithFloat:midSleepTime]];
            [lightSleepTimeArr addObject:[NSNumber numberWithFloat:lightSleepTime]];
            [awakeTimeArr addObject:[NSNumber numberWithFloat:awakeTime]];
        }else{
            [deepSleepTimeArr addObject:[NSNumber numberWithInt:0]];
            [midSleepTimeArr addObject:[NSNumber numberWithInt:0]];
            [lightSleepTimeArr addObject:[NSNumber numberWithInt:0]];
            [awakeTimeArr addObject:[NSNumber numberWithInt:0]];
        }
        
        
    }
    
    //刷新-波形图
//    NSArray * series = @[@{@"data":awakeTimeArr},@{@"data":lightSleepTimeArr},@{@"data":midSleepTimeArr},@{@"data":deepSleepTimeArr}];
//    [self.SQChartView aa_onlyRefreshTheChartDataWithChartModelSeries:series];
    
    if (selectDataArr.count>7) {
        NSMutableArray * midXArr = [NSMutableArray array];
        for (int i = 1; i<=selectDataArr.count; i++) {
            [midXArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
        self.titleXArr = midXArr;
    }else{
        self.titleXArr = @[NSLocalizedString(@"RMVC_Sunday", nil),
                           NSLocalizedString(@"RMVC_Monday", nil),
                           NSLocalizedString(@"RMVC_Tuesday", nil),
                           NSLocalizedString(@"RMVC_Wednesday", nil),
                           NSLocalizedString(@"RMVC_Thursday", nil),
                           NSLocalizedString(@"RMVC_Friday", nil),
                           NSLocalizedString(@"RMVC_Saturday", nil),];
    }
    
    self.SQChartModel.seriesSet(@[
                                  AASeriesElement.new
                                  .nameSet(NSLocalizedString(@"RMVC_Sober", nil))
                                  .dataSet([self reduce60tTimesWithArr:awakeTimeArr]),
                                  AASeriesElement.new
                                  .nameSet(NSLocalizedString(@"RMVC_LightSleep", nil))
                                  .dataSet([self reduce60tTimesWithArr:lightSleepTimeArr]),
                                  AASeriesElement.new
                                  .nameSet(NSLocalizedString(@"RMVC_MiddleSleep", nil))
                                  .dataSet([self reduce60tTimesWithArr:midSleepTimeArr]),
                                  AASeriesElement.new
                                  .nameSet(NSLocalizedString(@"RMVC_DeepSleep", nil))
                                  .dataSet([self reduce60tTimesWithArr:deepSleepTimeArr])
                                  ]
                                )
    .categoriesSet(self.titleXArr);//设置 X 轴坐标文字内容;
    
    /*刷新-波形图 更新 AAChartModel 内容之后,刷新图表*/
    [self.SQChartView aa_refreshChartWithChartModel:self.SQChartModel];
    
    //刷新-睡眠总时长
    CGFloat deepSleepSum = [[deepSleepTimeArr valueForKeyPath:@"@sum.floatValue"] floatValue];
    CGFloat midSleepSum = [[midSleepTimeArr valueForKeyPath:@"@sum.floatValue"] floatValue];
    CGFloat lightSleepSum = [[lightSleepTimeArr valueForKeyPath:@"@sum.floatValue"] floatValue];
    CGFloat awakeSum = [[awakeTimeArr valueForKeyPath:@"@sum.floatValue"] floatValue];
    CGFloat allStateTime = deepSleepSum + midSleepSum + lightSleepSum + awakeSum;//
    int hour = 0;
    int minute = 0;
    if (allStateTime != 0) {
        hour = floorf(allStateTime/60);//取整
        minute = floorf((int)allStateTime%60);//取整
    }
    
    NSString * hUnit= NSLocalizedString(@"RMVC_Hour", nil);//h
    NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);//min
    
    NSString * timeString = [NSString stringWithFormat:@"%02d%@%02d%@",hour,hUnit,minute,minUnit];
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:13.0]
                          range:NSMakeRange(timeString.length-minUnit.length, minUnit.length)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:13.0]
                          range:NSMakeRange(timeString.length-minUnit.length-2-hUnit.length, hUnit.length)];
    self.valueLabel.attributedText = AttributedStr;

    //刷新-进度条（深睡时长、中睡时长、浅睡时长、清醒时长）
    if (allStateTime == 0) {
        for (XYWProgressCellView * progressCellView in self.progressArr) {
            if (progressCellView.index < 4) {
                progressCellView.time = @"0";
                progressCellView.percentage = 0;
            }
        }
    }else{
        for (XYWProgressCellView * progressCellView in self.progressArr) {
            switch (progressCellView.index) {
                case 0:
                    progressCellView.time = [NSString stringWithFormat:@"%.f",deepSleepSum];
                    progressCellView.percentage = (CGFloat)(deepSleepSum / allStateTime);
                    break;
                case 1:
                    progressCellView.time = [NSString stringWithFormat:@"%.f",midSleepSum];
                    progressCellView.percentage = (CGFloat)(midSleepSum / allStateTime);
                    break;
                case 2:
                    progressCellView.time = [NSString stringWithFormat:@"%.f",lightSleepSum];
                    progressCellView.percentage = (CGFloat)(lightSleepSum / allStateTime);
                    break;
                case 3:
                    progressCellView.time = [NSString stringWithFormat:@"%.f",awakeSum];
                    progressCellView.percentage = (CGFloat)(awakeSum / allStateTime);
                    break;
                default:
                    break;
            }
        }
    }
}

- (NSMutableArray *)reduce60tTimesWithArr:(NSMutableArray*)arr{
    
    NSMutableArray * newArr = [NSMutableArray array];
    
    for (int i = 0 ; i < arr.count ; i++) {
        NSNumber * num = arr[i];
        if ([num intValue] == 0) {
            [newArr addObject:[NSNumber numberWithInteger:[num intValue]]];
        }else{
            CGFloat hourNum = [num floatValue] / 60;
            [newArr addObject:[NSNumber numberWithFloat:hourNum]];
        }
    }
    return newArr;
}

//刷新-心率数据
- (void)xyw_refreshHeartRateDataWithDataArr:(NSArray*)selectDataArr{

    NSMutableArray *dateHeartRateArray = [HeartRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    
    if (dateHeartRateArray.count == 0) {
        NSLog(@"没有可刷新的心率数据");
        return;
    }
    NSMutableArray * chartData = [NSMutableArray array];//存放波形图数据的数组
    for (int j = 0; j < selectDataArr.count; j++) {
        
        NSTimeInterval a = [[UIFactory stringReturnDate:selectDataArr[j]] timeIntervalSince1970];
        NSInteger beginTime = (NSInteger)a + 5*60*60;
        NSInteger endTime = beginTime + 86400;
        
        
        int allData = 0;//总和
        int allDataNum = 0;//总和个数
        HeartRateModel * model = nil;
        for (int i = 0; i < dateHeartRateArray.count; i++) {
            HeartRateModel * testModel = dateHeartRateArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
                model = testModel;
            }
        }
        if (model && model.dataArray.count > 0) {
            for (NSDictionary * dict in model.dataArray) {
                //心率
                NSInteger heartRateValue = [[dict objectForKey:@"value"] integerValue];
                if (heartRateValue != 0) {
                    allData += heartRateValue;
                    allDataNum++;
                }
            }
            [chartData addObject:[NSNumber numberWithFloat:allData/allDataNum]];
        }else{
            [chartData addObject:[NSNumber numberWithFloat:0]];
        }
    }
    
    //刷新-波形图
    [self.reportHeartRateView xyw_refreshChatrDataWithYtitleArr:@[@0, @45, @90, @135, @180] pointArr:chartData];
    if (selectDataArr.count>7) {
        self.reportHeartRateView.titleXArr = @[@"1",@"6", @"11", @"16", @"21", @"26", [NSString stringWithFormat:@"%d",(int)selectDataArr.count]];
    }else{
        self.reportHeartRateView.titleXArr = @[NSLocalizedString(@"RMVC_Sunday", nil),
                                               NSLocalizedString(@"RMVC_Monday", nil),
                                               NSLocalizedString(@"RMVC_Tuesday", nil),
                                               NSLocalizedString(@"RMVC_Wednesday", nil),
                                               NSLocalizedString(@"RMVC_Thursday", nil),
                                               NSLocalizedString(@"RMVC_Friday", nil),
                                               NSLocalizedString(@"RMVC_Saturday", nil),];
    }
    
    //1.需要去掉的元素数组
    NSMutableArray *zeroNum = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0], nil];
    //2/类似于SQL语句  NOT 不是   SELF 代表字符串本身   IN 范围运算符
    //那么NOT (SELF IN %@) 意思就是：不是这里所指定的字符串的值
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",zeroNum];
    //3.过滤数组  拿到非0数组
    NSArray * newChartData = [chartData filteredArrayUsingPredicate:filterPredicate];
    //刷新-波形图平均值
    int avgValue = 0;
    NSString * valueStr;
    if (newChartData.count != 0) {
        avgValue = [[newChartData valueForKeyPath:@"@avg.floatValue"] intValue];
        valueStr = [NSString stringWithFormat:@"%d%@",avgValue,NSLocalizedString(@"SMVC_HeartRateUnit", nil)];
    }else{
        valueStr = [NSString stringWithFormat:@"--%@",NSLocalizedString(@"SMVC_HeartRateUnit", nil)];
    }
    self.reportHeartRateView.valueStr = valueStr;
    
    //刷新-进度条（平均心率）
    for (XYWProgressCellView * progressCellView in self.progressArr) {
        if (progressCellView.index == 4) {
            progressCellView.time = [NSString stringWithFormat:@"%d",avgValue];
            progressCellView.percentage = (float)avgValue/180;
        }
    }
}
//刷新-呼吸数据
- (void)xyw_refreshBreathRateDataWithDataArr:(NSArray*)selectDataArr{
    
    NSMutableArray *datebreathRateArray = [RespiratoryRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    
    if (datebreathRateArray.count == 0) {
        NSLog(@"没有可刷新的呼吸数据");
        return;
    }
    NSMutableArray * chartData = [NSMutableArray array];//存放波形图数据的数组
    for (int j = 0; j < selectDataArr.count; j++) {
        
        //转时间戳
        NSTimeInterval a = [[UIFactory stringReturnDate:selectDataArr[j]] timeIntervalSince1970];
        NSInteger beginTime = (NSInteger)a + 5*60*60;
        NSInteger endTime = beginTime + 86400;
        
        int allData = 0;//总和
        int allDataNum = 0;//总和个数
        RespiratoryRateModel * model = nil;
        for (int i = 0; i < datebreathRateArray.count; i++) {
            RespiratoryRateModel * testModel = datebreathRateArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
                model = testModel;
            }
        }
        
        if (model && model.dataArray.count > 0) {
            for (NSDictionary * dict in model.dataArray) {
                //心率
                NSInteger respiratoryRateValue = [[dict objectForKey:@"value"] integerValue];
                if (respiratoryRateValue != 0) {
                    allData += respiratoryRateValue;
                    allDataNum++;
                }
            }
            [chartData addObject:[NSNumber numberWithFloat:allData/allDataNum]];
        }else{
            [chartData addObject:[NSNumber numberWithFloat:0]];
        }
        
    }

    //刷新-波形图
    [self.reportBreathRateView xyw_refreshChatrDataWithYtitleArr:@[@0, @10, @20, @30, @40] pointArr:chartData];
    if (selectDataArr.count>7) {
        self.reportBreathRateView.titleXArr = @[@"1",@"6", @"11", @"16", @"21", @"26", [NSString stringWithFormat:@"%d",(int)selectDataArr.count]];
    }else{
        self.reportBreathRateView.titleXArr = @[NSLocalizedString(@"RMVC_Sunday", nil),
                                                NSLocalizedString(@"RMVC_Monday", nil),
                                                NSLocalizedString(@"RMVC_Tuesday", nil),
                                                NSLocalizedString(@"RMVC_Wednesday", nil),
                                                NSLocalizedString(@"RMVC_Thursday", nil),
                                                NSLocalizedString(@"RMVC_Friday", nil),
                                                NSLocalizedString(@"RMVC_Saturday", nil),];
    }
    //1.需要去掉的元素数组
    NSMutableArray *zeroNum = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0], nil];
    //2/类似于SQL语句  NOT 不是   SELF 代表字符串本身   IN 范围运算符
    //那么NOT (SELF IN %@) 意思就是：不是这里所指定的字符串的值
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",zeroNum];
    //3.过滤数组  拿到非0数组
    NSArray * newChartData = [chartData filteredArrayUsingPredicate:filterPredicate];
    
    //刷新-波形图平均值
    int avgValue = 0;
    NSString * valueStr;
    if (newChartData.count != 0) {
        avgValue = [[newChartData valueForKeyPath:@"@avg.floatValue"] intValue];
        valueStr = [NSString stringWithFormat:@"%d%@",avgValue,NSLocalizedString(@"SMVC_HeartRateUnit", nil)];
    }else{
        valueStr = [NSString stringWithFormat:@"--%@",NSLocalizedString(@"SMVC_HeartRateUnit", nil)];
    }
    self.reportBreathRateView.valueStr = valueStr;
    
    //刷新-进度条（平均呼吸率）
    for (XYWProgressCellView * progressCellView in self.progressArr) {
        if (progressCellView.index == 5) {
            progressCellView.time = [NSString stringWithFormat:@"%d",avgValue];
            progressCellView.percentage = (float)avgValue/40;
        }
    }
}
//刷新-翻身数据
- (void)xyw_refreshTurnOverDataWithDataArr:(NSArray*)selectDataArr{

    NSMutableArray *dateTurnOverArray = [TurnOverModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    
    if (dateTurnOverArray.count == 0) {
        NSLog(@"没有可刷新的心率数据");
        return;
    }
    NSMutableArray * chartData = [NSMutableArray array];//存放波形图数据的数组
    for (int j = 0; j < selectDataArr.count; j++) {
        
        NSTimeInterval a = [[UIFactory stringReturnDate:selectDataArr[j]] timeIntervalSince1970];
        NSInteger beginTime = (NSInteger)a + 5*60*60;
        NSInteger endTime = beginTime + 86400;
        int allData = 0;//总和
        int allDataNum = 0;//总和个数
        TurnOverModel * model = nil;
        for (int i = 0; i < dateTurnOverArray.count; i++) {
            TurnOverModel * testModel = dateTurnOverArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
                model = testModel;
            }
        }
        if (model && model.dataArray.count > 0) {
            for (NSDictionary * dict in model.dataArray) {
                //三分钟的翻身次数
                NSInteger turnOverValue = [[dict objectForKey:@"value"] integerValue];
                turnOverValue = turnOverValue & 0x0f;//取低四位
                allData += turnOverValue;//三分钟的翻身次数
                allDataNum++;
            }
            [chartData addObject:[NSNumber numberWithFloat:allData*20/allDataNum > 12 ? 12 : allData*20/allDataNum]];
        }else{
            [chartData addObject:[NSNumber numberWithFloat:0]];
        }
    }
    
    //刷新-波形图
    [self.reportTurnOverView xyw_refreshChatrDataWithYtitleArr:@[@0, @3, @6, @9, @12] pointArr:chartData];
    if (selectDataArr.count>7) {
        
        self.reportTurnOverView.titleXArr = @[@"1",@"6", @"11", @"16", @"21", @"26", [NSString stringWithFormat:@"%d",(int)selectDataArr.count]];
    }else{
        self.reportTurnOverView.titleXArr = @[NSLocalizedString(@"RMVC_Sunday", nil),
                                              NSLocalizedString(@"RMVC_Monday", nil),
                                              NSLocalizedString(@"RMVC_Tuesday", nil),
                                              NSLocalizedString(@"RMVC_Wednesday", nil),
                                              NSLocalizedString(@"RMVC_Thursday", nil),
                                              NSLocalizedString(@"RMVC_Friday", nil),
                                              NSLocalizedString(@"RMVC_Saturday", nil),];
    }
    //1.需要去掉的元素数组
    NSMutableArray *zeroNum = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0], nil];
    //2/类似于SQL语句  NOT 不是   SELF 代表字符串本身   IN 范围运算符
    //那么NOT (SELF IN %@) 意思就是：不是这里所指定的字符串的值
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",zeroNum];
    //3.过滤数组  拿到非0数组
    NSArray * newChartData = [chartData filteredArrayUsingPredicate:filterPredicate];
    //刷新-波形图平均值
    int avgValue = 0;
    NSString * valueStr;
    if (newChartData.count != 0) {
        avgValue = [[newChartData valueForKeyPath:@"@avg.floatValue"] intValue];
        valueStr = [NSString stringWithFormat:@"%d%@",avgValue,NSLocalizedString(@"RMVC_TurnOverHourTime", nil)];
    }else{
        valueStr = [NSString stringWithFormat:@"--%@",NSLocalizedString(@"RMVC_TurnOverHourTime", nil)];
    }
    self.reportTurnOverView.valueStr = valueStr;
    
}

#pragma mark --------------------------------------------------------------------
#pragma mark --layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    
    [self.SQChartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset(55);
        make.left.mas_equalTo(weakSelf.mas_left).offset(55);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-30);
//        make.width.equalTo(@(kSCREEN_WIDTH-70));
        make.height.equalTo(@180);
    }];
//    self.valueLabel.backgroundColor = [UIColor blueColor];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset(6);
//        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
//        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
        make.centerX.mas_equalTo(weakSelf.mas_centerX);
        make.width.equalTo(@140);
        make.height.equalTo(@40);
    }];
    
    //图表-图例色块示意图
    [self setColorView];
    
    __block CGFloat yLabSpaceHeight = 13;//上下间离
    __block CGFloat yLabWidth = labelWidth;
    __block CGFloat yLabHeight = 20;
    __block NSInteger k = 0;
    for (UILabel * lab in self.yLabViews) {
        k = lab.tag;
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.valueLabel.mas_bottom).offset(3+(yLabSpaceHeight+yLabHeight)*k);
            make.left.mas_equalTo(weakSelf.mas_left).offset(10);
            make.width.equalTo(@(yLabWidth));
            make.height.equalTo(@(yLabHeight));
        }];
    }
    
    __block CGFloat xLabWidth = 28;
    __block CGFloat xLabHeight = 15;
    __block CGFloat xLabSpaceWidth = (kSCREEN_WIDTH - 118 - xLabWidth*7)/6;//左右间离
//    __block CGFloat xLabSpaceWidth = 30;
    __block NSInteger m = 0;
    for (UILabel * lab in self.xLabViews) {
        m = lab.tag - 10;
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.SQChartView.mas_bottom).offset(20);
            make.left.equalTo(@(70+(xLabSpaceWidth+xLabWidth)*m));
//            make.width.equalTo(@(xLabWidth));
//            make.height.equalTo(@(xLabHeight));
            make.width.equalTo(@0);
            make.height.equalTo(@0);
        }];
    }
    
    __block CGFloat spaceWidth = 15;//左右间离
    __block CGFloat spaceheight = 20;//上下间离
    __block CGFloat width = (kSCREEN_WIDTH - 60)/3;
    __block CGFloat height = 85;
    __block NSInteger i = 0;
    __block NSInteger j = 0;
    __block CGFloat cellViewY = 0;
    for (XYWProgressCellView * progressCellView in self.progressArr) {
        i = progressCellView.index;
        j = i < 3 ? 0 : 1;
        i = i < 3 ? i : (i-3);
        [progressCellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.SQChartView.mas_bottom).offset(10 + (spaceheight + height)*j);
            make.left.mas_equalTo(weakSelf.mas_left).offset(15+i*(width+spaceWidth));
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        cellViewY = 60 + spaceheight + height + height;
    }
    
    [self.monitorTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.SQChartView.mas_bottom).offset(cellViewY-20);
        make.height.equalTo(@14);
        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
    }];
    
    [self.reportHeartRateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.monitorTitleLab.mas_bottom).offset(15);
        make.left.right.equalTo(weakSelf);
        make.height.equalTo(@(232));
    }];
    
    [self.reportBreathRateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.reportHeartRateView.mas_bottom).offset(5);
        make.left.right.equalTo(weakSelf);
        make.height.equalTo(@(232));
    }];
    [self.reportTurnOverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.reportBreathRateView.mas_bottom).offset(5);
        make.left.right.equalTo(weakSelf);
        make.height.equalTo(@(232));
    }];
    
}

#pragma mark - 图表-图例色块示意图
- (void)setColorView{
    
    WS(weakSelf);
    NSArray * titleArr = @[NSLocalizedString(@"RMVC_Sober", nil),
                           NSLocalizedString(@"RMVC_LightSleep", nil),
                           NSLocalizedString(@"RMVC_MiddleSleep", nil),
                           NSLocalizedString(@"RMVC_DeepSleep", nil)];
    NSArray * colorArr = @[@"#96F2F8",@"#48d8ef",@"#23abcb",@"#1b86a3"];
    CGFloat colorViewHeight = 50.0;
    CGFloat buttonHeight = colorViewHeight/2;
    CGFloat buttonFontSize = 12;
    
    UIView * colorView = [[UIView alloc]init];
    colorView.backgroundColor = [UIColor clearColor];
    [self addSubview:colorView];
    [colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.valueLabel.mas_top).offset(0);
        make.right.mas_equalTo(weakSelf.SQChartView.mas_right).offset(10);
        make.left.mas_equalTo(weakSelf.valueLabel.mas_right).offset(0);
        make.height.equalTo(@(colorViewHeight));
    }];
    
    //右上 -中睡
    UIButton * colorButton0 = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton0 setImage:[self buttonImageFromColor:[UIColor colorWithHexString:colorArr[2]]] forState:UIControlStateNormal];
    [colorButton0 setTitle:titleArr[2] forState:UIControlStateNormal];
    [colorButton0.titleLabel setFont:[UIFont systemFontOfSize:buttonFontSize]];
    [colorButton0 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    colorButton0.backgroundColor = [UIColor clearColor];
    [colorView addSubview:colorButton0];
    [colorButton0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.right.mas_equalTo(colorView.mas_right).offset(0);
        make.height.equalTo(@(buttonHeight));
    }];
    //左上 -清醒
    UIButton * colorButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton1 setImage:[self buttonImageFromColor:[UIColor colorWithHexString:colorArr[0]]] forState:UIControlStateNormal];
    [colorButton1 setTitle:titleArr[0] forState:UIControlStateNormal];
    [colorButton1.titleLabel setFont:[UIFont systemFontOfSize:buttonFontSize]];
    [colorButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    colorButton1.backgroundColor = [UIColor clearColor];
    [colorView addSubview:colorButton1];
    [colorButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.mas_equalTo(colorView.mas_left).offset(-5);
        make.right.mas_equalTo(colorButton0.mas_left).offset(0);
        make.width.mas_equalTo(colorButton0.mas_width).offset(0);
        make.height.equalTo(@(buttonHeight));
    }];
    //左下 -浅睡
    UIButton * colorButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton2 setImage:[self buttonImageFromColor:[UIColor colorWithHexString:colorArr[1]]] forState:UIControlStateNormal];
    [colorButton2 setTitle:titleArr[1] forState:UIControlStateNormal];
    [colorButton2.titleLabel setFont:[UIFont systemFontOfSize:buttonFontSize]];
    [colorButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    colorButton2.backgroundColor = [UIColor clearColor];
    [colorView addSubview:colorButton2];
    [colorButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(colorButton1.mas_bottom);
        make.left.mas_equalTo(colorButton1.mas_left);
        make.width.mas_equalTo(colorButton1.mas_width);
        make.height.mas_equalTo(colorButton1.mas_height);
    }];
    //右下 -深睡
    UIButton * colorButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton3 setImage:[self buttonImageFromColor:[UIColor colorWithHexString:colorArr[3]]] forState:UIControlStateNormal];
    [colorButton3 setTitle:titleArr[3] forState:UIControlStateNormal];
    [colorButton3.titleLabel setFont:[UIFont systemFontOfSize:buttonFontSize]];
    [colorButton3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    colorButton3.backgroundColor = [UIColor clearColor];
    [colorView addSubview:colorButton3];
    [colorButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(colorButton0.mas_bottom);
        make.left.mas_equalTo(colorButton0.mas_left);
        make.width.mas_equalTo(colorButton0.mas_width);
        make.height.mas_equalTo(colorButton0.mas_height);
    }];
    
    
}

#pragma mark - 通过颜色来生成一个纯色图片
- (UIImage *)buttonImageFromColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0, 0, 8, 6);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//- (instancetype)init{
//
//    if (self = [super init]) {
//        // 设置属性值
//
//        // 创建临时变量
//        //...
//    }
//    return self;
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    __weak typeof(self) weakSelf = self;
//
//}

@end
