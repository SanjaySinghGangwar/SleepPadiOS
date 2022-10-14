//
//  XYWReportBaseChartView.m
//  SleepBand
//
//  Created by admin on 2019/6/5.
//  Copyright © 2019 admin. All rights reserved.
//

#import "XYWReportBaseChartView.h"
#import "AAChartKit.h"

@interface XYWReportBaseChartView ()<AAChartViewEventDelegate>

@property (nonatomic, strong) AAChartModel * myChartModel;
@property (nonatomic, strong) AAChartView * myChartView;
@property (nonatomic, strong) UIView * coverView;//图表遮罩布

//@property (nonatomic, strong) UIImageView * iconImgView;//iconView
//@property (nonatomic, strong) UILabel * titleLab;//标题
@property (nonatomic, strong) UIButton * titleBtn;//标题按钮
@property (nonatomic, strong) UIImageView * backgroundImgView;//波形-的背景image
@property (nonatomic, strong) UILabel * valueLab;//平均值Lab

@property (nonatomic, strong) NSArray<UILabel*> * yLabViews;
@property (nonatomic, strong) NSArray<UILabel*> * xLabViews;

@end

@implementation XYWReportBaseChartView

#pragma mark -- init
- (instancetype)initWithIconStr:(NSString*)iconStr
                          title:(NSString*)title
                       bgImgStr:(NSString*)backgroundImageStr
                       valueStr:(NSString*)valueStr
                     themeColor:(NSString*)themeColor
                 gridYLineColor:(NSString*)gridYLineColor
                      titleYArr:(NSArray*)titleYArr{
    
    if (self = [super init]) {
        // 设置属性值
        self.backgroundColor = [UIColor clearColor];
        self.iconStr = iconStr;
        self.title = title;
        self.backgroundImageStr = backgroundImageStr;
        self.valueStr = valueStr;
        self.themeColor = themeColor;
        self.gridYLineColor = gridYLineColor;
//        self.titleXArr = @[@"00:00", @"05:12", @"10:24", @"15:36", @"02:00"];
//        self.titleYArr = titleYArr;
        // 创建临时变量
        //...
        //波形-的背景image
        UIImageView * backgroundImgView = [[UIImageView alloc]init];
        [self addSubview:backgroundImgView];
        backgroundImgView.image = [UIImage imageNamed:backgroundImageStr];
        self.backgroundImgView = backgroundImgView;
        
//        //iconView
//        UIImageView * iconImgView = [[UIImageView alloc]init];
//        [self addSubview:iconImgView];
//        iconImgView.image = [UIImage imageNamed:iconStr];
//        self.iconImgView = iconImgView;
//        //标题
//        UILabel *titleLab = [[UILabel alloc]init];
//        [self addSubview:titleLab];
//        titleLab.font = [UIFont systemFontOfSize:15];
//        titleLab.textColor = [UIColor colorWithHexString:@"#1b86a4"];
//        titleLab.textAlignment = NSTextAlignmentCenter;
//        titleLab.text = title;
//        self.titleLab = titleLab;
        //标题按钮
        UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:titleBtn];
        [titleBtn setImage:[UIImage imageNamed:iconStr] forState:UIControlStateNormal];
        [titleBtn setTitle:title forState:UIControlStateNormal];
        [titleBtn setTitleColor:[UIColor colorWithHexString:@"#1b86a4"] forState:UIControlStateNormal];
        [titleBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        self.titleBtn = titleBtn;
        
        //chart
        [self drawChartForMyChartViewWithThemeColor:themeColor gridYLineColor:gridYLineColor];
        
        //coverView 遮罩布
        UIView * coverView = [[UIView alloc] init];
        coverView.backgroundColor = [UIColor clearColor];
        self.coverView = coverView;
        [self addSubview:self.coverView];
        
        //平均值Lab
        UILabel * valueLab = [[UILabel alloc]init];
        [self addSubview:valueLab];
        valueLab.font = [UIFont systemFontOfSize:13];
        valueLab.textColor = [UIColor colorWithHexString:@"#1b86a4"];
        valueLab.textAlignment = NSTextAlignmentRight;
        valueLab.text = valueStr;
        self.valueLab = valueLab;
        
        if (titleYArr.count != 5) {
            titleYArr = @[@"4",@"3",@"2",@"1",@"0"];
        }
        NSMutableArray * yLabViews = [NSMutableArray array];
        for (int i = 0; i<5; i++) {
            UILabel * lab = [[UILabel alloc]init];
            [self addSubview:lab];
            lab.tag = i;
            lab.font = [UIFont systemFontOfSize:10];
            lab.textColor = [UIColor grayColor];
            lab.textAlignment = NSTextAlignmentRight;
            lab.text = titleYArr[i];
            [yLabViews addObject:lab];
        }
        self.yLabViews = yLabViews;
        
    }
    return self;
}

#pragma mark -- set
-(void)setValueStr:(NSString *)valueStr{
    if (_valueStr != valueStr) {
        _valueStr = valueStr;
        _valueLab.text = valueStr;
    }
}
- (void)setTitleXArr:(NSArray *)titleXArr{
    if (_titleXArr != titleXArr) {
        _titleXArr = titleXArr;
        NSMutableArray * xLabViews = [NSMutableArray array];
        for (int i = 0; i < titleXArr.count; i++) {
            if ([self viewWithTag:i+10]) {
                [[self viewWithTag:i+10] removeFromSuperview];
            }
            UILabel * lab = [[UILabel alloc]init];
            [self addSubview:lab];
            lab.tag = i + 10;
            lab.font = [UIFont systemFontOfSize:11];
            lab.textColor = [UIColor grayColor];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.text = titleXArr[i];
            [xLabViews addObject:lab];
        }
        self.xLabViews = xLabViews;
    }
}

-(void)setTitleYArr:(NSArray *)titleYArr{
    if (_titleYArr != titleYArr) {
        _titleYArr = titleYArr;
        for (UILabel * lab in _yLabViews) {
            lab.text = titleYArr[lab.tag];
        }
    }
}

- (void)drawChartForMyChartViewWithThemeColor:(NSString*)themeColor gridYLineColor:(NSString*)gridYLineColor{
    
    self.myChartView = [[AAChartView alloc]init];
    self.myChartView.delegate = self;
    self.myChartView.scrollEnabled = NO;//禁用 AAChartView 滚动效果
    //    设置aaChartVie 的内容高度(content height)
    //    self.aaChartView.contentHeight = chartViewHeight*2;
    //    设置aaChartVie 的内容宽度(content  width)
    //    self.aaChartView.contentWidth = chartViewWidth*2;
    [self addSubview:self.myChartView];
    self.myChartView.backgroundColor = [UIColor clearColor];
    
    //设置 AAChartView 的背景色是否为透明
    self.myChartView.isClearBackgroundColor = YES;
    
    self.myChartModel= AAChartModel.new
    .chartTypeSet(AAChartTypeSpline)//图表类型
    .titleSet(@"")//图表主标题
    .subtitleSet(@"")//图表副标题
    .yAxisLineWidthSet(@0)//Y轴轴线线宽为0即是隐藏Y轴轴线
    .colorsThemeSet(@[themeColor])//设置主体颜色数组(线条颜色)
    .yAxisTitleSet(@"")//设置 Y 轴标题
    .tooltipValueSuffixSet(@"℃")//设置浮动提示框单位后缀
    .tooltipEnabledSet(NO)//是否显示浮动提示框
    .backgroundColorSet(@"#4b2b7f")
    .yAxisGridLineWidthSet(@0.5)//y轴横向分割线宽度为0(即是隐藏分割线)
    .yAxisTickPositionsSet(@[@0, @1, @2, @3, @4, @5])
    .xAxisLabelsEnabledSet(NO)//x 轴是否显示文字
    .yAxisLabelsEnabledSet(YES)//y 轴是否显示文字
    .touchEventEnabledSet(NO)//支持用户点击事件
    .seriesSet(@[
                 AASeriesElement.new
                 .nameSet(@"sleep")
                 .lineWidthSet(@1.0)
                 .dataSet(@[@0]),
                 ]
               )
    .markerSymbolStyleSet(AAChartSymbolStyleTypeBorderBlank)//设置折线连接点样式为:边缘白色
    .yAxisVisibleSet(YES)//y 轴是否可见
    .xAxisVisibleSet(NO)//x 轴是否可见
    .yAxisLabelsFontSizeSet(@12)//y 轴文字字体大小
    .gridYLineColorSet(gridYLineColor)//y 轴分割线颜色
    .xAxisCrosshairWidthSet(@0)//Zero width to disable crosshair by default
//    .xAxisCrosshairColorSet(@"#ffffff")//浅石板灰准星线
    .xAxisCrosshairDashStyleTypeSet(AALineDashStyleTypeLongDashDotDot)
    .categoriesSet(@[@"0", @"1", @"2", @"3", @"4"])//设置 X 轴坐标文字内容
    .markerRadiusSet(@0)
    .legendEnabledSet(NO);//是否显示图例 lengend(图表底部可点按的圆点和文字)
    
    [self.myChartView aa_drawChartWithChartModel:_myChartModel];
}

- (void)xyw_refreshChatrDataWithYtitleArr:(NSArray*)titleArr pointArr:(NSArray*)pointArr{
    
    self.myChartModel
    .yAxisTickPositionsSet(titleArr)
    .seriesSet(@[
                 AASeriesElement.new
                 .nameSet(@"sleep")
                 .lineWidthSet(@1.0)
                 .dataSet(pointArr),
                 ]
               );
    
    /*更新 AAChartModel 内容之后,刷新图表*/
    [self.myChartView aa_refreshChartWithChartModel:self.myChartModel];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    
    //波形-的背景image  649 × 395
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.top.mas_equalTo(weakSelf.mas_top).offset(15);
        make.width.equalTo(@325);
        make.height.equalTo(@198);
    }];
    
    //标题按钮
    [self.titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset(-5);
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.width.equalTo(@140);
        make.height.equalTo(@28);
    }];
    
    //iconView
//    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.mas_top).offset(0);
//        make.left.mas_equalTo(weakSelf.mas_centerX).offset(-15-7-30);
//        make.width.equalTo(@15);
//        make.height.equalTo(@15);
//    }];
//    //标题
//    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(weakSelf.iconImgView);
//        make.left.mas_equalTo(weakSelf.iconImgView.mas_right).offset(7);
//        make.width.equalTo(@100);
//        make.height.equalTo(@28);
//    }];
    
    //平均值Lab valueLab
    [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
        make.top.mas_equalTo(weakSelf.titleBtn.mas_bottom).offset(20);
        make.right.mas_equalTo(weakSelf.backgroundImgView.mas_right).offset(-20);
        make.height.equalTo(@13);
    }];
    
    //chart
    [self.myChartView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerX.mas_equalTo(weakSelf.backgroundImgView);
        make.top.mas_equalTo(weakSelf.valueLab.mas_bottom).offset(6);
        //        make.width.mas_equalTo(weakSelf.backgroundImgView.mas_width).offset(-40);
        make.left.mas_equalTo(weakSelf.backgroundImgView.mas_left).offset(5);
        make.right.mas_equalTo(weakSelf.backgroundImgView.mas_right).offset(-14);
        make.height.equalTo(@130);
    }];
    
    //chart 遮罩布
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(weakSelf.myChartView);
    }];
    
    __block CGFloat yLabSpaceHeight = 12;//上下间离
    __block CGFloat yLabWidth = 22;
    __block CGFloat yLabHeight = 14;
    __block NSInteger i = 0;
    for (UILabel * lab in self.yLabViews) {
        i = lab.tag;
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.backgroundImgView.mas_top).offset(78+(yLabSpaceHeight+yLabHeight)*i);
            make.left.mas_equalTo(weakSelf.backgroundImgView.mas_left).offset(26);
//            make.width.equalTo(@(yLabWidth));
//            make.height.equalTo(@(yLabHeight));
            make.width.equalTo(@0);
            make.height.equalTo(@0);
        }];
    }
    
    if (!self.xLabViews || self.xLabViews.count == 0) return;
    
    __block CGFloat xLabSpaceWidth = 24;//左右间离
    if (self.xLabViews.count == 5) {
        xLabSpaceWidth = 19;
    }else if (self.xLabViews.count == 7) {
        xLabSpaceWidth = 2;
    }
    __block CGFloat xLabWidth = 36;
    __block CGFloat xLabHeight = 13;
    __block NSInteger j = 0;
    for (UILabel * lab in self.xLabViews) {
        j = lab.tag - 10;
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.backgroundImgView.mas_bottom).offset(-xLabHeight-23);
            make.left.mas_equalTo(weakSelf.backgroundImgView.mas_left).offset(44+(xLabSpaceWidth+xLabWidth)*j);
            make.width.equalTo(@(xLabWidth));
            make.height.equalTo(@(xLabHeight));
        }];
    }
}

@end
