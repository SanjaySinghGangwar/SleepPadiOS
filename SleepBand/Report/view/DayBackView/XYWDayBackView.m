//
//  XYWDayBackView.m
//  SleepBand
//
//  Created by admin on 2019/6/4.
//  Copyright © 2019 admin. All rights reserved.
//

#import "XYWDayBackView.h"
#import "AAChartKit.h"
#import "XYWProgressCellView.h"
#import "XYWReportBaseChartView.h"
#import "SleepBand-Bridging-Header.h"
//#import "Charts-Swift.h"

#define labelWidth 79

@interface CubicLineSampleFillFormatter : NSObject <IChartFillFormatter>
{
}
@end

@implementation CubicLineSampleFillFormatter

- (CGFloat)getFillLinePositionWithDataSet:(LineChartDataSet *)dataSet dataProvider:(id<LineChartDataProvider>)dataProvider
{
    return -10.f;
}

@end

@interface XYWDayBackView ()<AAChartViewEventDelegate,ChartViewDelegate,IChartAxisValueFormatter>

@property (nonatomic, strong) LineChartView *chartView;
@property (nonatomic, strong) SleepQualityModel * myModel;
@property (nonatomic, strong) AAChartModel * SQChartModel;
@property (nonatomic, strong) AAChartView * SQChartView;
@property (nonatomic, strong) UIView * coverView;//图表遮罩布
@property (nonatomic, strong) UILabel * valueLabel;//睡眠的时长
@property (nonatomic, strong) NSArray<UILabel*> * yLabViews;
@property (nonatomic, strong) NSArray<UILabel*> * xLabViews;
@property (nonatomic, strong) NSArray<XYWProgressCellView *> * progressArr;

@property (nonatomic, strong) UILabel * monitorTitleLab;//睡眠监测标题lab
@property (nonatomic, strong) XYWReportBaseChartView * reportHeartRateView;//HeartRate
@property (nonatomic, strong) XYWReportBaseChartView * reportBreathRateView;//BreathRate
@property (nonatomic, strong) XYWReportBaseChartView * reportTurnOverView;//Turn

@property (nonatomic, assign) NSInteger spaceTime;

@end

@implementation XYWDayBackView

#pragma mark --init
- (instancetype)init{
    
    if (self = [super init]) {
        // 设置属性值
        //...
        // 创建临时变量
        //...
        /*  睡眠质量  */
        [self setUIForSleepQuality];
//        /*  心率数据表   */
        [self setUIForHeartRate];
//        /*  呼吸数据表  */
        [self setUIForBreathRate];
//        /*  翻身数据表  */
        [self setUIForTurnOver];
        
    }
    return self;
}

- (void)setTitleXArr:(NSArray *)titleXArr{
    if (_titleXArr != titleXArr) {
        _titleXArr = titleXArr;
        for (UILabel * lab in _xLabViews) {
            lab.text = titleXArr[lab.tag-10];
        }
    }
}

-(NSMutableArray *)sleepTimeArr{
    if (!_sleepTimeArr || _sleepTimeArr == nil) {
        _sleepTimeArr = [NSMutableArray array];
    }
    return _sleepTimeArr;
}

#pragma mark --setUI 睡眠质量
- (void)setUIForSleepQuality{
    
    //画虚线 (清醒，浅睡，中睡，深睡)
//    [self drawLineForChart];
    
    //睡眠质量波形图 初始化
    [self drawChartForSQChartView2];
    
    //coverView 遮罩布
//    UIView * coverView = [[UIView alloc] init];
//    coverView.backgroundColor = [UIColor clearColor];
//    self.coverView = coverView;
//    [self addSubview:self.coverView];
    
    //睡眠的时长
    UILabel * valueLabel = [[UILabel alloc]init];
    [self addSubview:valueLabel];
    valueLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.font = [UIFont boldSystemFontOfSize:24.0];
    self.valueLabel = valueLabel;
    
    NSArray * titleYArr = @[NSLocalizedString(@"RMVC_Sober", nil),
                                   NSLocalizedString(@"RMVC_LightSleep", nil),
                                   NSLocalizedString(@"RMVC_MiddleSleep", nil),
                                   NSLocalizedString(@"RMVC_DeepSleep", nil)];
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
    for (int i = 0; i<5; i++) {
        UILabel * lab = [[UILabel alloc]init];
        [self addSubview:lab];
        lab.tag = i + 10;
        lab.font = [UIFont systemFontOfSize:12];
        lab.textColor = [UIColor grayColor];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = @"00:00";
        [xLabViews addObject:lab];
        
        lab.textColor = [UIColor clearColor];
        lab.backgroundColor = [UIColor clearColor];
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
    
    XYWReportBaseChartView * reportHeartRateView = [[XYWReportBaseChartView alloc]initWithIconStr:@"realtime_icon_heartrate" title:NSLocalizedString(@"RTVC_HeartRateTitle", nil) bgImgStr:@"report_br_bg" valueStr:[NSString stringWithFormat:@"--%@",NSLocalizedString(@"SMVC_HeartRateUnit", nil)] themeColor:@"#1b86a4" gridYLineColor:@"#26B9DA" titleYArr:@[@"180",@"135",@"90",@"45",@"0"]];
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
    CGFloat midPat = 33;
    
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
    
//    CAShapeLayer *borderDown = [CAShapeLayer layer];
//    borderDown.strokeColor = [UIColor colorWithHexString:@"#1b86a4"].CGColor;
//    borderDown.fillColor = nil;
//    UIBezierPath *patDown = [UIBezierPath bezierPath];
//    yPat += midPat;
//    [patDown moveToPoint:CGPointMake(62, yPat)];
//    [patDown addLineToPoint:CGPointMake((kSCREEN_WIDTH-40), yPat)];
//    borderDown.path = patDown.CGPath;
//    [self.layer addSublayer:borderDown];
    
}

- (void)drawChartForSQChartView2{
    
    _chartView = [[LineChartView alloc]init];
    [self addSubview:_chartView];
    
    _chartView.backgroundColor =UIColor.clearColor;
    _chartView.delegate = self;
    [_chartView setViewPortOffsetsWithLeft:20.f top:0.f right:20.f bottom:20.f];
    _chartView.chartDescription.enabled = NO;
    
    _chartView.dragEnabled = YES;   // 开启拖拽图标
    _chartView.legend.enabled = NO;      // 关闭图例显示
    _chartView.scaleXEnabled = YES;     // 开启X轴缩放
    _chartView.scaleYEnabled = NO;      // 关闭Y轴缩放
    _chartView.doubleTapToZoomEnabled = NO;//是否支持双击缩放
    

    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.maxHighlightDistance = 300.0;


    _chartView.noDataText = @"";//没有数据时显示
    _chartView.highlightPerTapEnabled = NO;//高亮点击
    _chartView.highlightPerDragEnabled = NO;//高亮拖拽
    
    // Y轴设置
    ChartYAxis *yAxis = _chartView.leftAxis;
    yAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    yAxis.axisMaximum = 270;
    yAxis.axisMinimum = 0;
    [yAxis setLabelCount:4 force:NO];
    yAxis.labelTextColor = UIColor.clearColor;
//    yAxis.gridColor = [UIColor grayColor]; //网线颜色
    yAxis.drawGridLinesEnabled = NO; //是否要画网格线
    yAxis.labelPosition = YAxisLabelPositionInsideChart;
    yAxis.axisLineColor = UIColor.whiteColor; // Y轴颜色
//    yAxis.valueFormatter = self;
//    yAxis.granularity = 10;
    yAxis.drawLimitLinesBehindDataEnabled = YES;//设置限制线绘制在折线图的后面
    [yAxis removeAllLimitLines];
    
    NSArray * ySleepType = @[@256,@192,@128,@64];
    for (int i = 0; i < ySleepType.count; i++) {
        NSNumber * sleepNum = ySleepType[i];
        ChartLimitLine *limitLine = [[ChartLimitLine alloc] initWithLimit:sleepNum.doubleValue label:@""];
        limitLine.lineWidth = 1.0;//线宽
        limitLine.lineColor = [UIColor colorWithHexString:@"#e5e4df"];//线颜色
        limitLine.lineDashLengths = @[@1.f, @0.f];//虚线样式
//        limitLine.labelPosition = ChartLimitLabelPositionTopRight;//位置
//        limitLine.valueTextColor = [self colorWithHexString:@"#057748"];//label文字颜色
//        limitLine.valueFont = [UIFont systemFontOfSize:10.0];//label字体
        [yAxis addLimitLine:limitLine];
    }
    
    // X轴设置
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom; // 设置x轴数据在底部
    xAxis.axisLineColor = [UIColor colorWithHexString:@"#1b86a4"];     // X轴颜色
    xAxis.granularityEnabled = NO;                 // 设置重复的值显示
//    xAxis.gridColor = [UIColor grayColor]; //网线颜色
    xAxis.drawGridLinesEnabled = NO; //是否要画网格线
    xAxis.valueFormatter = self;
    xAxis.labelTextColor =  [UIColor grayColor];    // 文字颜色
    xAxis.labelFont = [UIFont systemFontOfSize:14];
    [xAxis setLabelCount:5 force:YES];
//    xAxis.granularity = 5;// 间隔为1
    
    _chartView.rightAxis.enabled = NO;
    _chartView.legend.enabled = NO; // 关闭图例显示
    
    // 展现动画
    [_chartView animateWithXAxisDuration:2.0 yAxisDuration:2.0];
    
}
//睡眠质量波形图 初始化
- (void)drawChartForSQChartView{
    
    self.SQChartView = [[AAChartView alloc]init];
    self.SQChartView.delegate = self;
    self.SQChartView.scrollEnabled = NO;//禁用 AAChartView 滚动效果
    //    设置aaChartVie 的内容高度(content height)
    //  self.SQChartView.contentHeight = 160;
    //    设置aaChartVie 的内容宽度(content  width)
    //  self.SQChartView.contentWidth = kSCREEN_WIDTH-70;
    [self addSubview:self.SQChartView];
//    self.SQChartView.backgroundColor = [UIColor greenColor];
    
    //设置 AAChartView 的背景色是否为透明
    self.SQChartView.isClearBackgroundColor = YES;
    
    self.SQChartModel= AAChartModel.new
    .chartTypeSet(AAChartTypeAreaspline)//图表类型 AAChartTypeAreaspline AAChartTypeSpline
    .titleSet(@"")//图表主标题
    .subtitleSet(@"")//图表副标题
    .yAxisLineWidthSet(@0)//Y轴轴线线宽为0即是隐藏Y轴轴线
    .colorsThemeSet(@[@"#1b86a4"])//设置主题颜色数组(线条颜色)
    .easyGradientColorsSet(YES)//是否开启主题渐变
    .yAxisTitleSet(@"")//设置 Y 轴标题
    .tooltipValueSuffixSet(@"℃")//设置浮动提示框单位后缀
    .tooltipEnabledSet(NO)//是否显示浮动提示框
    .backgroundColorSet(@"#4b2b7f")
    .yAxisGridLineWidthSet(@1)//y轴横向分割线宽度为0(即是隐藏分割线)
    .yAxisTickPositionsSet(@[@256,@192,@128,@64,@0])
//    .yAxisTickPositionsSet(@[@0,@64,@128,@192,@256])
    .yAxisReversedSet(YES) //y 轴翻转
    .xAxisLabelsEnabledSet(NO)//x 轴是否显示文字
    .yAxisLabelsEnabledSet(NO)//y 轴是否显示文字
    .touchEventEnabledSet(NO)//支持用户点击事件
    .seriesSet(@[
                 AASeriesElement.new
                 .nameSet(@"sleep")
                 .dataSet(@[@0]),
                 ]
               )
//    .markerSymbolStyleSet(AAChartSymbolStyleTypeInnerBlank)//marker点为空心效果
    .yAxisVisibleSet(YES)//y 轴是否可见
    .xAxisVisibleSet(YES)//x 轴是否可见
    .xAxisCrosshairWidthSet(@0)//Zero width to disable crosshair by default
//    .xAxisCrosshairColorSet(@"#ffffff")//浅石板灰准星线
    .xAxisCrosshairDashStyleTypeSet(AALineDashStyleTypeLongDashDotDot)
//    .categoriesSet(@[@"0:00", @"05:12", @"10:24", @"15:36", @"02:00"])//设置 X 轴坐标文字内容
//    .xAxisLabelsFontSizeSet(@13)//x 轴文字字体大小
//    .xAxisLabelsFontColorSet(@"#ffffff")//x 轴文字字体颜色
    .markerRadiusSet(@0)//marker点半径为0个像素
    .legendEnabledSet(NO);//是否显示图例 lengend(图表底部可点按的圆点和文字)
    
    /*配置 Y 轴标注线,解开注释,即可查看添加标注线之后的图表效果(NOTE:必须设置 Y 轴可见)*/
    //    [self configureTheYAxisPlotLineForAAChartView];
    
    [self.SQChartView aa_drawChartWithChartModel:self.SQChartModel];
    
}

//睡眠质量进度条
- (void)drawViewForProgressCellView{
    
//    NSArray *titleArray = @[@"Depp sleep",@"Middle sleep",@"Light sleep",@"Wake up",@"Heart rate",@"Breath rate"];

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
//初始化ChartView数据
- (void)initChartViewData{
    _chartView.data = nil;
    _myModel = nil;
    NSMutableArray * yVals = [NSMutableArray arrayWithObject:[[ChartDataEntry alloc] initWithX:0 y:0]];
    _chartView.xAxis.axisMaximum = 360*4;
    [_chartView.viewPortHandler setMaximumScaleX:1];//缩放的最大倍数
    _chartView.scaleXEnabled = NO;     // 关闭X轴缩放
    
    LineChartDataSet *set1 = nil;
    set1 = [[LineChartDataSet alloc] initWithEntries:yVals label:nil];
    set1.mode = LineChartModeHorizontalBezier; //设置平滑曲线
    set1.drawCirclesEnabled = NO; // 是否绘制拐点
    set1.lineWidth = 2.0;
    set1.circleRadius = 4.0;
    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    [set1 setColor:[UIColor colorWithHexString:@"#1b86a4"]];
    set1.fillColor = [UIColor colorWithHexString:@"#1b86a4"];
    
    LineChartData *data = [[LineChartData alloc] initWithDataSet:set1];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.f]];
    [data setDrawValues:NO];

    _chartView.data = data;
}
- (void)setChartDataWithSleepModel:(SleepQualityModel *)sleepModel{
    _chartView.data = nil;
    _myModel = sleepModel;
    
    [_chartView.viewPortHandler setMaximumScaleX:1];//缩放的最大倍数
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSInteger stateTimeInt = 0;
    NSInteger stateIntegerInt = 0;
    for (int i = 0; i < sleepModel.dataArray.count; i++)
    {
        NSDictionary * dict = sleepModel.dataArray[i];
        //状态
        NSString * stateStr = [dict objectForKey:@"state"];
        NSInteger stateInteger = [stateStr integerValue];
        //状态时长
        NSString * stateTimeStr = [dict objectForKey:@"stateTime"];
        
//        NSInteger stateTimeMidStr = stateTimeInt;
//        NSInteger stateIntegerMid = stateIntegerInt;
        
        stateTimeInt = stateTimeInt + [stateTimeStr intValue];
        stateIntegerInt = stateInteger;
        
//        if ( stateIntegerMid != stateInteger) {
//            int count = (int)(stateTimeMidStr - stateTimeInt);
//            count = abs(count);
//            NSLog(@"X轴差值：%d",count);
//            int timeCount = (int)(stateIntegerMid - stateIntegerInt);
//            timeCount = abs(timeCount);
//            NSLog(@"Y轴差值：%d",timeCount);
//        }
        [yVals1 addObject:[[ChartDataEntry alloc] initWithX:stateTimeInt y:stateInteger]];
//        NSLog(@"stateTimeInt = %ld   ,   stateInteger = %ld",(long)stateTimeInt,(long)stateInteger);
        
    }
    
    _chartView.xAxis.axisMaximum = stateTimeInt;
    [_chartView.viewPortHandler setMaximumScaleX:stateTimeInt/5];//缩放的最大倍数
    _chartView.scaleXEnabled = YES;     // 开启X轴缩放
    
    LineChartDataSet *set1 = nil;
    set1 = [[LineChartDataSet alloc] initWithEntries:yVals1 label:nil];
    set1.mode = LineChartModeHorizontalBezier; //设置平滑曲线
//    set1.cubicIntensity = 0.2;
    set1.drawCirclesEnabled = NO; // 是否绘制拐点
    set1.lineWidth = 2.0;
    set1.circleRadius = 4.0;
//    set1.drawCirclesEnabled = YES; // 是否绘制拐点
//    [set1 setCircleColor:UIColor.blackColor];// 拐点 圆的颜色
    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    [set1 setColor:[UIColor colorWithHexString:@"#1b86a4"]];
    set1.fillColor = [UIColor colorWithHexString:@"#1b86a4"];
    set1.drawHorizontalHighlightIndicatorEnabled = NO;
    set1.fillFormatter = [ChartDefaultFillFormatter withBlock:^CGFloat(id<ILineChartDataSet>  _Nonnull dataSet, id<LineChartDataProvider>  _Nonnull dataProvider) {
        return self.chartView.leftAxis.axisMaximum;
    }];

    NSArray *gradientColors = @[
        (id)[UIColor colorWithRed:27/255.f green:134/255.f blue:163/255.f alpha:1.f].CGColor,
        (id)[UIColor colorWithRed:150/255.f green:242/255.f blue:248/255.f alpha:0.1f].CGColor
    ];
    CGGradientRef gradientRef = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    set1.fillAlpha = 1.0f;//透明度
    set1.fill = [ChartFill fillWithLinearGradient:gradientRef angle:90.0f];//赋值填充颜色对象
    CGGradientRelease(gradientRef);//释放gradientRef
    set1.drawFilledEnabled = YES;        // 是否填充颜色

    LineChartData *data = [[LineChartData alloc] initWithDataSet:set1];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.f]];
    [data setDrawValues:NO];

    _chartView.data = data;
    
}

//刷新-全部数据（睡眠质量、心率、呼吸、翻身）
- (void)xyw_refreshDayBackViewWithData:(NSInteger)selectData sizeTime:(NSInteger)sizeTime{
    selectData += 5*60*60;
    [self xyw_refreshSleepQualityDataWithData:selectData sizeTime:sizeTime];
    [self xyw_refreshHeartRateDataWithData:selectData sizeTime:sizeTime];
    [self xyw_refreshBreathRateDataWithData:selectData sizeTime:sizeTime];
    [self xyw_refreshTurnOverDataWithData:selectData sizeTime:sizeTime];
}
//刷新-睡眠质量
- (void)xyw_refreshSleepQualityDataWithData:(NSInteger)selectData sizeTime:(NSInteger)sizeTime{
    
//    //date转不带“-”的字符串
//    NSString* str = [UIFactory dateForNumString:selectData];
//    //String转date
//    NSDate * date = [UIFactory stringReturnDate:str];
//    //转时间戳
//    NSTimeInterval a =[date timeIntervalSince1970]; // *1000 是精确到毫秒，不乘就是精确到秒
    
    NSInteger beginTime = selectData;
    NSInteger endTime = beginTime + sizeTime;
    
    NSMutableArray * chartData = [NSMutableArray array];//存放波形图数据的数组
    CGFloat deepSleepTime = 0;//深睡时长
    CGFloat midSleepTime = 0;//中睡时长
    CGFloat lightSleepTime = 0;//浅睡时长
    CGFloat awakeTime = 0;//清醒时长
    CGFloat allStateTime = 0;//总时长
    
    NSMutableArray *dateSleepQualityArray = [SleepQualityModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    if (dateSleepQualityArray.count>0) {
        SleepQualityModel * model = nil;
        for (int i = 0; i < dateSleepQualityArray.count; i++) {
            SleepQualityModel * testModel = dateSleepQualityArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
                
                if (![self.sleepTimeArr containsObject:testModel.dataDate]) {
                    [self.sleepTimeArr addObject:testModel.dataDate];
                }
                
                model = testModel;
            }
        }
        
        if (model) {
            for (NSDictionary * dict in model.dataArray) {
                //状态
                NSString * stateStr = [dict objectForKey:@"state"];
                NSInteger stateInteger = [stateStr integerValue];
                //状态时长
                NSString * stateTimeStr = [dict objectForKey:@"stateTime"];
                NSInteger stateTimeInt = [stateTimeStr intValue];
//                [chartData addObject:[NSNumber numberWithFloat:stateInteger]];
//                [chartData addObject:[NSNumber numberWithFloat:stateInteger += 1]];
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
            /*刷新-波形图,刷新图表 shouldHideData*/
            [self setChartDataWithSleepModel:model];
        }else{
            /*刷新-波形图,初始化图表*/
            [self initChartViewData];
        }
        
        //刷新-波形图
//        [self.SQChartView aa_onlyRefreshTheChartDataWithChartModelSeries:@[@{@"data":chartData}]];
        
        NSDictionary *gradientColorDic1 =
        @{@"linearGradient": @{
                  @"x1": @0.0,
                  @"y1": @1.0,
                  @"x2": @0.0,
                  @"y2": @0.0
                  },
          @"stops": @[@[@0.00, @"rgba(27,134,163,0.9)"],//深粉色, alpha 透明度 1 27,134,163
                      @[@1.00, @"rgba(150,242,248,0.1)"],//热情的粉红, alpha 透明度 0.1
                      ]//颜色字符串设置支持十六进制类型和 rgba 类型
          };
        
//        self.SQChartModel.seriesSet(@[
//                     AASeriesElement.new
//                     .nameSet(@"sleep")
//                     .lineWidthSet(@2.0)
//                     .colorSet(@"#1b86a3")//猩红色, alpha 透明度 1
//                     .fillColorSet((id)gradientColorDic1)
////                     .colorSet((id)[AAGradientColor configureGradientColorWithStartColorString:@"#1b86a3" endColorString:@"#96F2F8"])
//                     .dataSet(chartData),
//                     ]
//                   );
        
        /*刷新-波形图 更新 AAChartModel 内容之后,刷新图表*/
//        [self.SQChartView aa_refreshChartWithChartModel:self.SQChartModel];
        
        
        
        
        //刷新-睡眠总时长
        allStateTime = deepSleepTime + midSleepTime + lightSleepTime + awakeTime;
        int hour = 0;
        int minute = 0;
        if (allStateTime != 0) {
            hour = floorf(allStateTime/60);//取整
            minute = floorf((int)allStateTime%60);//取整
            
            self.spaceTime = allStateTime * 60 / 4;
            NSMutableArray * titleXArr = [NSMutableArray array];
            for (int i = 0; i < 5; i++) {
                NSInteger time = [model.dataDate integerValue] + self.spaceTime*i;
                NSDate * date= [NSDate dateWithTimeIntervalSince1970:time];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                NSString *dateString = [formatter stringFromDate:date];
                [titleXArr addObject:dateString];
            }
            self.titleXArr = titleXArr;
        }else{
            self.titleXArr = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00",];
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
                        progressCellView.time = [NSString stringWithFormat:@"%.f",deepSleepTime];
                        progressCellView.percentage = (CGFloat)(deepSleepTime / allStateTime);
                        break;
                    case 1:
                        progressCellView.time = [NSString stringWithFormat:@"%.f",midSleepTime];
                        progressCellView.percentage = (CGFloat)(midSleepTime / allStateTime);
                        break;
                    case 2:
                        progressCellView.time = [NSString stringWithFormat:@"%.f",lightSleepTime];
                        progressCellView.percentage = (CGFloat)(lightSleepTime / allStateTime);
                        break;
                    case 3:
                        progressCellView.time = [NSString stringWithFormat:@"%.f",awakeTime];
                        progressCellView.percentage = (CGFloat)(awakeTime / allStateTime);
                        break;
                    default:
                        break;
                }
//                NSLog(@"progressCellView.percentage = %f",progressCellView.percentage);
            }
        }
        
    }else{
        /*刷新-波形图,初始化图表*/
        [self initChartViewData];
        NSLog(@"没有可刷新的睡眠质量数据");
        return;
    }
    
    
    
}
//刷新-心率数据
- (void)xyw_refreshHeartRateDataWithData:(NSInteger)selectData sizeTime:(NSInteger)sizeTime{
    
    NSInteger beginTime = selectData;
    NSInteger endTime = beginTime + sizeTime;
    
    NSMutableArray * chartData = [NSMutableArray array];//存放波形图数据的数组
    int allData = 0;//总和
    int allDataNum = 0;//总和个数
    NSMutableArray * dateHeartRateArray = [HeartRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    if (dateHeartRateArray.count>0) {
        
        HeartRateModel * model = nil;
        for (int i = 0; i < dateHeartRateArray.count; i++) {
            HeartRateModel * testModel = dateHeartRateArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
                model = testModel;
            }
        }
        if (model) {
            for (NSDictionary * dict in model.dataArray) {
                //心率
                NSInteger heartRateValue = [[dict objectForKey:@"value"] integerValue];
                [chartData addObject:[NSNumber numberWithFloat:heartRateValue]];
//                [chartData addObject:[NSNumber numberWithFloat:heartRateValue += 1]];
                if (heartRateValue != 0) {
                    allData += heartRateValue;
                    allDataNum++;
                }
            }
        }
        
        //刷新-波形图 @[@0, @36, @72, @108, @144, @180, @225]
        [self.reportHeartRateView xyw_refreshChatrDataWithYtitleArr:@[@0, @45, @90, @135, @180] pointArr:chartData];
        if (model) {
//            NSInteger spaceTime = 5 * 60 * (model.dataArray.count - 1) / 4;
            NSMutableArray * titleXArr = [NSMutableArray array];
            for (int i = 0; i < 5; i++) {
                NSInteger time = [model.dataDate integerValue] + self.spaceTime*i;
                NSDate * date= [NSDate dateWithTimeIntervalSince1970:time];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                NSString *dateString = [formatter stringFromDate:date];
                [titleXArr addObject:dateString];
            }
            self.reportHeartRateView.titleXArr = titleXArr;
        }else{
            self.reportHeartRateView.titleXArr = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00",];
        }
        
        //刷新-波形图平均值
        NSString * valueStr = model && model.dataArray.count > 0 ? [NSString stringWithFormat:@"%d%@",allData/allDataNum,NSLocalizedString(@"SMVC_HeartRateUnit", nil)]:[NSString stringWithFormat:@"--%@",NSLocalizedString(@"SMVC_HeartRateUnit", nil)];
        self.reportHeartRateView.valueStr = valueStr;
        //刷新-进度条（平均心率）
        for (XYWProgressCellView * progressCellView in self.progressArr) {
            if (progressCellView.index == 4) {
                if (model && model.dataArray.count > 0) {
                    progressCellView.time = [NSString stringWithFormat:@"%d",allData/allDataNum];
                    progressCellView.percentage = (CGFloat)((float)allData / allDataNum / 180);
                    
                }else{
                    progressCellView.time = @"0";
                    progressCellView.percentage = 0;
                }
                
            }
        }
        
    }else{
        NSLog(@"没有可刷新的心率数据");
        return;
    }
    
}
//刷新-呼吸数据
- (void)xyw_refreshBreathRateDataWithData:(NSInteger)selectData sizeTime:(NSInteger)sizeTime{
    
    NSInteger beginTime = selectData;
    NSInteger endTime = beginTime + sizeTime;
    
    NSMutableArray * chartData = [NSMutableArray array];//存放波形图数据的数组
    int allData = 0;//总和
    int allDataNum = 0;//总和个数
    NSMutableArray * datebreathRateArray = [RespiratoryRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    if (datebreathRateArray.count>0) {
        
        RespiratoryRateModel * model = nil;
        for (int i = 0; i < datebreathRateArray.count; i++) {
            RespiratoryRateModel * testModel = datebreathRateArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
                model = testModel;
            }
        }
        
        if (model) {
            for (NSDictionary * dict in model.dataArray) {
                //呼吸率
                NSInteger respiratoryRateValue = [[dict objectForKey:@"value"] integerValue];
                [chartData addObject:[NSNumber numberWithFloat:respiratoryRateValue]];
//                [chartData addObject:[NSNumber numberWithFloat:respiratoryRateValue += 1]];
                if (respiratoryRateValue != 0) {
                    allData += respiratoryRateValue;
                    allDataNum++;
                }
            }
        }
        
        //刷新-波形图 @[@0, @8, @16, @24, @32, @40, @48]
        [self.reportBreathRateView xyw_refreshChatrDataWithYtitleArr:@[@0, @10, @20, @30, @40] pointArr:chartData];
        if (model) {
//            NSInteger spaceTime = 5 * 60 * (model.dataArray.count - 1) / 4;
            NSMutableArray * titleXArr = [NSMutableArray array];
            for (int i = 0; i < 5; i++) {
                NSInteger time = [model.dataDate integerValue] + self.spaceTime*i;
                NSDate * date= [NSDate dateWithTimeIntervalSince1970:time];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                NSString *dateString = [formatter stringFromDate:date];
                [titleXArr addObject:dateString];
            }
            self.reportBreathRateView.titleXArr = titleXArr;
        }else{
            self.reportBreathRateView.titleXArr = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00",];
        }
        //刷新-波形图平均值
        NSString * valueStr = model && model.dataArray.count > 0 ? [NSString stringWithFormat:@"%d%@",allData/allDataNum,NSLocalizedString(@"SMVC_HeartRateUnit", nil)]:[NSString stringWithFormat:@"--%@",NSLocalizedString(@"SMVC_HeartRateUnit", nil)];
        self.reportBreathRateView.valueStr = valueStr;
        //刷新-进度条（平均呼吸率）
        for (XYWProgressCellView * progressCellView in self.progressArr) {
            if (progressCellView.index == 5) {
                if (model && model.dataArray.count > 0) {
                    progressCellView.time = [NSString stringWithFormat:@"%d",allData/allDataNum];
                    progressCellView.percentage = (CGFloat)((float)allData / allDataNum / 40);
                }else{
                    progressCellView.time = @"0";
                    progressCellView.percentage = 0;
                }
            }
        }
    }else{
        NSLog(@"没有可刷新的呼吸数据");
        return;
    }
    
}
//刷新-翻身数据
- (void)xyw_refreshTurnOverDataWithData:(NSInteger)selectData sizeTime:(NSInteger)sizeTime{
    
    NSInteger beginTime = selectData;
    NSInteger endTime = beginTime + sizeTime;
    
    NSMutableArray * chartData = [NSMutableArray array];//存放波形图数据的数组
    int allData = 0;//总和
    NSMutableArray * datebreathRateArray = [TurnOverModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
    if (datebreathRateArray.count>0) {
        
        TurnOverModel * model = nil;
        for (int i = 0; i < datebreathRateArray.count; i++) {
            TurnOverModel * testModel = datebreathRateArray[i];
            //开始时间 < 时间戳 < 结束时间
            if ([testModel.dataDate integerValue]<endTime && [testModel.dataDate integerValue]>=beginTime) {
                model = testModel;
            }
        }
        
        if (model) {
            for (NSDictionary * dict in model.dataArray) {
                //翻身
                NSInteger turnOverValue = [[dict objectForKey:@"value"] integerValue];
                turnOverValue = turnOverValue & 0x0f;//取低四位
                allData += turnOverValue;
                [chartData addObject:[NSNumber numberWithFloat:turnOverValue > 8 ? 8 : turnOverValue]];
            }
        }
        
        //刷新-波形图 @[@0.0, @1.6, @3.2, @4.8, @6.4, @8.0, @9.6]
        [self.reportTurnOverView xyw_refreshChatrDataWithYtitleArr:@[@0, @2, @4, @6, @8] pointArr:chartData];
        if (model) {
//            NSInteger spaceTime = 3 * 60 * (model.dataArray.count - 1) / 4;
            NSMutableArray * titleXArr = [NSMutableArray array];
            for (int i = 0; i < 5; i++) {
                NSInteger time = [model.dataDate integerValue] + self.spaceTime*i;
                NSDate * date= [NSDate dateWithTimeIntervalSince1970:time];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm"];
                NSString *dateString = [formatter stringFromDate:date];
                [titleXArr addObject:dateString];
            }
            self.reportTurnOverView.titleXArr = titleXArr;
        }else{
            self.reportTurnOverView.titleXArr = @[@"00:00",@"06:00",@"12:00",@"18:00",@"00:00",];
        }
        //刷新-波形图平均值
        NSString * valueStr = [NSString stringWithFormat:@"--%@",NSLocalizedString(@"RMVC_TurnOverHourTime", nil)];
        if (allData>0 && model.dataArray.count>0) {
            CGFloat turnTimes = allData*20/model.dataArray.count;
            valueStr = [NSString stringWithFormat:@"%.f%@",turnTimes,NSLocalizedString(@"RMVC_TurnOverHourTime", nil)];
        }
        self.reportTurnOverView.valueStr = valueStr;
        
    }else{
        NSLog(@"没有可刷新的翻身数据");
        return;
    }
    
}

#pragma mark - ChartViewDelegate
//图表中的数值被选中
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}
//图标中的空白区域被点击
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}
//图表缩放
- (void)chartScaled:(ChartViewBase *)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    NSLog(@"scaleX = %f       scaleY = %f",scaleX,scaleY);
}
#pragma mark - IAxisValueFormatter

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    
//    return months[(int)value % months.count];
//    NSLog(@"value = %d",(int)value);
    
//    NSLog(@"_chartView.scaleX = %f",_chartView.scaleX);
    
    if (_myModel&&_myModel.dataDate.length>0) {
        return [self timeStampToHourSystemWithIndexValue:value dataDate:_myModel.dataDate];
    }else{
//        return [NSString stringWithFormat:@"%d",(int)value];
        return [self timeStampToHourSystemWithIndexValue:value dataDate:@"1575648001"];
    }
    
}
//时间戳转小时时间制式
- (NSString *)timeStampToHourSystemWithIndexValue:(double)value dataDate:(NSString*)dataDate{
    NSInteger time = [dataDate integerValue] + (NSInteger)value * 60;
    NSDate * date= [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}
#pragma mark --------------------------------------------------------------------
#pragma mark --layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    
    [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.mas_top).offset(55);
            make.left.mas_equalTo(weakSelf.mas_left).offset(55);
            make.right.mas_equalTo(weakSelf.mas_right).offset(-30);
    //        make.width.equalTo(@(kSCREEN_WIDTH-70));
            make.height.equalTo(@165);
        }];
    
//    [self.SQChartView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.mas_top).offset(55);
//        make.left.mas_equalTo(weakSelf.mas_left).offset(55);
//        make.right.mas_equalTo(weakSelf.mas_right).offset(-30);
////        make.width.equalTo(@(kSCREEN_WIDTH-70));
//        make.height.equalTo(@165);
//    }];
    //chart 遮罩布
//    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.left.right.mas_equalTo(weakSelf.chartView);
//    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset(6);
        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
        make.height.equalTo(@40);
    }];
    
    __block CGFloat yLabSpaceHeight = 13;//上下间离
    __block CGFloat yLabWidth = labelWidth-35;
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
    
    __block CGFloat xLabWidth = 40;
    __block CGFloat xLabHeight = 14;
    __block CGFloat xLabSpaceWidth = (kSCREEN_WIDTH - (65+40) - xLabWidth*5)/4;//左右间离
//    __block CGFloat xLabSpaceWidth = 32;
    __block NSInteger m = 0;
    for (UILabel * lab in self.xLabViews) {
//        lab.backgroundColor = [UIColor redColor];
        m = lab.tag - 10;
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.chartView.mas_bottom).offset(-17);
//            make.left.equalTo(@(70+(xLabSpaceWidth+xLabWidth)*m));
            make.left.mas_equalTo(weakSelf.mas_left).offset(65+(xLabSpaceWidth+xLabWidth)*m);
            make.width.equalTo(@(xLabWidth));
            make.height.equalTo(@(xLabHeight));
//            make.width.equalTo(@0);
//            make.height.equalTo(@0);
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
            make.top.mas_equalTo(weakSelf.chartView.mas_bottom).offset(30 + (spaceheight + height)*j);
            make.left.mas_equalTo(weakSelf.mas_left).offset(15+i*(width+spaceWidth));
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        cellViewY = 60 + spaceheight + height + height;
    }
    
    [self.monitorTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.chartView.mas_bottom).offset(cellViewY);
        make.height.equalTo(@14);
        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
    }];

    [self.reportHeartRateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.monitorTitleLab.mas_bottom).offset(15);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.right.mas_equalTo(weakSelf.mas_right);
        make.height.equalTo(@(232));
    }];

    [self.reportBreathRateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.reportHeartRateView.mas_bottom).offset(5);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.right.mas_equalTo(weakSelf.mas_right);
        make.height.equalTo(@(232));
    }];
    [self.reportTurnOverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.reportBreathRateView.mas_bottom).offset(5);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.right.mas_equalTo(weakSelf.mas_right);
        make.height.equalTo(@(232));
    }];
    
}

@end
