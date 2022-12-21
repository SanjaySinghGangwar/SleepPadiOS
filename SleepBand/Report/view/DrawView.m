//
//  DrawView.m
//  SleepBand
//
//  Created by admin on 2018/7/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "DrawView.h"
#import "SleepQualityModel.h"

#define labelWidth 79

@interface DrawView ()<UIScrollViewDelegate>


@end

@implementation DrawView

-(void)removeFromSuperviewForView:(UIView *)subView
{
    //移除所有子视图
    [subView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //移除所有子layer
    [subView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
}

#pragma mark - 手动测试报告
//手动测试，睡眠质量UI
-(void)setManualSleepViewUI
{
    WS(weakSelf);
    UILabel *titleLabel = [[UILabel alloc]init];
    [self addSubview:titleLabel];
    
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"RMVC_ActualSleepTime", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.mas_top).offset(12);
        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
        make.height.equalTo(@28);
        
    }];
    
    self.valueLabel = [[UILabel alloc]init];
    [self addSubview:self.valueLabel];
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0min"]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:36.0]
                          range:NSMakeRange(0, 1)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:21.0]
                          range:NSMakeRange(1, 3)];
    self.valueLabel.attributedText = AttributedStr;
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(14);
        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
        make.height.equalTo(@40);
        
    }];
    
    UILabel *woberLabel = [[UILabel alloc]init];
    [self addSubview:woberLabel];
    woberLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    woberLabel.textColor = [UIColor whiteColor];
    woberLabel.textAlignment = NSTextAlignmentCenter;
    woberLabel.text = NSLocalizedString(@"RMVC_Sober", nil);
    [woberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.valueLabel.mas_bottom).offset(22);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
        
    }];
    
   
    UILabel *lightLabel = [[UILabel alloc]init];
    [self addSubview:lightLabel];
    lightLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    lightLabel.textColor = [UIColor whiteColor];
    lightLabel.textAlignment = NSTextAlignmentCenter;
    lightLabel.text = NSLocalizedString(@"RMVC_LightSleep", nil);
    [lightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(woberLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
        
    }];
    
    //中度
    UILabel *middleLabel = [[UILabel alloc]init];
    [self addSubview:middleLabel];
    middleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    middleLabel.textColor = [UIColor whiteColor];
    middleLabel.textAlignment = NSTextAlignmentCenter;
    middleLabel.text = NSLocalizedString(@"RMVC_MiddleSleep", nil);
    [middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(lightLabel.mas_bottom).offset(9);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
        
    }];
    
    //深度
    UILabel *deepLabel = [[UILabel alloc]init];
    [self addSubview:deepLabel];
    deepLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    deepLabel.textColor = [UIColor whiteColor];
    deepLabel.textAlignment = NSTextAlignmentCenter;
    deepLabel.text = NSLocalizedString(@"RMVC_DeepSleep", nil);
    [deepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(middleLabel.mas_bottom).offset(9);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
        
    }];
    

    //左右按钮之间的距离
    int count = 3;
    CGFloat width = 2;
    CGFloat gapX = (kSCREEN_WIDTH-(width*(count-1)))/count;
    
//    NSArray *titleArray = @[NSLocalizedString(@"RMVC_DeepSleepTime", nil),NSLocalizedString(@"RMVC_LightSleepTime", nil),NSLocalizedString(@"RMVC_SoberTime", nil),NSLocalizedString(@"RMVC_AverageHeartRate", nil),NSLocalizedString(@"RMVC_AverageRespiratoryRate", nil),NSLocalizedString(@"RMVC_MiddleSleepTime", nil)];
//    NSArray *iconArray = @[@"report_icon_deep",@"report_icon_light",@"report_icon_wakeup",@"report_icon_bpm",@"report_icon_bm",@"report_icon_fallasleep"];
    NSArray *titleArray = @[NSLocalizedString(@"RMVC_DeepSleepTime", nil),NSLocalizedString(@"RMVC_MiddleSleepTime", nil),NSLocalizedString(@"RMVC_LightSleepTime", nil),NSLocalizedString(@"RMVC_SoberTime", nil),NSLocalizedString(@"RMVC_AverageHeartRate", nil),NSLocalizedString(@"RMVC_AverageRespiratoryRate", nil)];
    
    NSArray *iconArray = @[@"report_icon_deep",@"report_icon_fallasleep",@"report_icon_light",@"report_icon_wakeup",@"report_icon_bpm",@"report_icon_bm"];
    
    for (int i = 0; i < count*2; i++)
    {
        CGFloat y;
        UIView *backgroundView = [[UIView alloc]init];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.alpha = kAlpha;
        if (i < 3)
        {
            y = 282;
            backgroundView.frame = CGRectMake(i*(gapX+width), y, gapX, 80);
            
        }else
        {
            y = 364;
            backgroundView.frame = CGRectMake((i-3)*(gapX+width), y, gapX, 80);
        }
        [self addSubview:backgroundView];
        
        UIImageView *iconIV = [[UIImageView alloc]init];
        iconIV.image = [UIImage imageNamed:iconArray[i]];
        [self addSubview:iconIV];
        [iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(backgroundView);
            make.left.mas_equalTo(backgroundView.mas_left).offset(10);
            make.width.equalTo(@27);
            make.height.equalTo(@28);
            
        }];
        
        UILabel *titleL = [[UILabel alloc]init];
        [self addSubview:titleL];
        titleL.font = [UIFont systemFontOfSize:12];
        titleL.textColor = [UIColor whiteColor];
        titleL.textAlignment = NSTextAlignmentLeft;
        titleL.text = titleArray[i];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(backgroundView.mas_top).offset(12);
            make.left.mas_equalTo(iconIV.mas_right).offset(12);
            make.right.mas_equalTo(backgroundView.mas_right).offset(-10);
            make.height.equalTo(@21);
            
        }];
        
        UILabel *valueL = [[UILabel alloc]init];
        valueL.tag = 100+i;
        [self addSubview:valueL];
        valueL.textColor = [UIColor whiteColor];
        valueL.textAlignment = NSTextAlignmentLeft;
        
        //测试数据
        //NSDate *data = [NSDate date];
        
        NSDateFormatter *dateMMFormatter = [[NSDateFormatter alloc] init];
        [dateMMFormatter setDateFormat:@"MM"];
        NSDateFormatter *dateDDFormatter = [[NSDateFormatter alloc] init];
        [dateDDFormatter setDateFormat:@"dd"];
        
        //    NSString *sleepTimeMM = [dateMMFormatter stringFromDate:sleepData[@"actualSleepTime"]];
        //    NSString *sleepTimeDD = [dateDDFormatter stringFromDate:sleepData[@"actualSleepTime"]];
        //测试数据
        //        NSString *sleepTimeMM = [NSString stringWithFormat:@"%02ld",[[dateMMFormatter stringFromDate:data]  integerValue]];
        //        NSString *sleepTimeDD = [dateDDFormatter stringFromDate:data];
        NSMutableAttributedString *AttributedStr;
        if (i == 4 || i == 5)
        {
            
            NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",unit]];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont boldSystemFontOfSize:18.0]
                                  range:NSMakeRange(0, 1)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(1, unit.length)];
            
        }else
        {
            
            NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",minUnit]];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont boldSystemFontOfSize:18.0]
                                  range:NSMakeRange(0, 1)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(1, minUnit.length)];
            
        }
        
        valueL.attributedText = AttributedStr;
        [valueL mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.top.mas_equalTo(titleL.mas_bottom).offset(0);
            make.left.mas_equalTo(titleL.mas_left).offset(0);
            make.right.mas_equalTo(backgroundView.mas_right).offset(0);
            make.height.equalTo(@37);

        }];
        
    }
    
    self.scrollDayView = [[UIScrollView alloc]initWithFrame:CGRectMake(labelWidth-15, 100, kSCREEN_WIDTH-labelWidth, 168)];
    [self addSubview:self.scrollDayView];
    self.scrollDayView.delegate = self;
    self.scrollDayView.bounces = NO;
    self.scrollDayView.showsHorizontalScrollIndicator = NO;
    self.scrollDayView.showsVerticalScrollIndicator = NO;
    self.scrollDayView.contentSize = CGSizeMake((kSCREEN_WIDTH-labelWidth), 168);
//        self.scrollDayView.backgroundColor = [UIColor yellowColor];
    //    self.scrollDayView.alpha = 0.3;
    
    //画虚线
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor whiteColor].CGColor;
    border.fillColor = nil;
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 27)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth), 27)];
    [pat moveToPoint:CGPointMake(0, 56)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth), 56)];
    [pat moveToPoint:CGPointMake(0, 85)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth), 85)];
    [pat moveToPoint:CGPointMake(0, 114)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth), 114)];
    [pat moveToPoint:CGPointMake(0, 143)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth), 143)];
    border.path = pat.CGPath;
    border.lineWidth = 0.5;
    border.lineCap = @"butt";
    //  第一个是线条长度   第二个是间距
    border.lineDashPattern = @[@4, @4];
    [self.scrollDayView.layer addSublayer:border];
    
    //X轴画图区域宽度
//    float XDrawWidth = (kSCREEN_WIDTH-labelWidth);
    float XScaleWidth = (kSCREEN_WIDTH-labelWidth)/8;
    //X轴刻度
    for (int i = 0; i < 8 ; i ++)
    {
        UILabel *scaleLabel = [[UILabel alloc] init];
        scaleLabel.tag = 300 +i;
        if (i == 0)
        {
            scaleLabel.frame = CGRectMake(labelWidth-15, 253, 40, 10);
            scaleLabel.textAlignment = NSTextAlignmentLeft;
            
        }else if (i == 7)
        {
            scaleLabel.frame = CGRectMake(kSCREEN_WIDTH-55, 253, 40, 10);
            scaleLabel.textAlignment = NSTextAlignmentRight;
            
        }else
        {
            scaleLabel.frame = CGRectMake(labelWidth-15+i*XScaleWidth, 253, 40, 10);
            scaleLabel.textAlignment = NSTextAlignmentCenter;
            
        }
        scaleLabel.font = [UIFont systemFontOfSize:10];
        scaleLabel.textColor = [UIColor whiteColor];
        [self addSubview:scaleLabel];
    }
    self.sleepQualityDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kSCREEN_WIDTH-labelWidth), 168)];
    [self.scrollDayView addSubview:self.sleepQualityDayView];
    self.sleepQualityDayCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 27, (kSCREEN_WIDTH-labelWidth), 116)];
    [self.scrollDayView addSubview:self.sleepQualityDayCoverView];
    
}



-(void)drawManualSleepViewForSleepData:(NSArray *)arrayData WithStartTime:(NSDate *)startTime WithEndTime:(NSDate *)endTime  WithGetUpIndex:(NSArray *)indexArray WithData:(BOOL)hasData
{
    
    //    WS(weakSelf);
    [self removeFromSuperviewForView:self.sleepQualityDayView];
    [self removeFromSuperviewForView:self.sleepQualityDayCoverView];
    
    //X轴画图区域宽度
    float XDrawWidth = kSCREEN_WIDTH-labelWidth;
    
    NSString *startDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:startTime]];
    NSString *startHour = [startDate substringWithRange:NSMakeRange(11, 2)];
    NSString *startMinute = [startDate substringWithRange:NSMakeRange(14, 2)];
    
    NSString *endDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:endTime]];
    NSString *endHour = [endDate substringWithRange:NSMakeRange(11, 2)];
    NSString *endMinute = [endDate substringWithRange:NSMakeRange(14, 2)];
    
    int startTotalMinute = [startHour intValue]*60 + [startMinute intValue];
    int endTotalMinute = [endHour intValue]*60 + [endMinute intValue];
    
    //三分钟一个点,计算出实际取点的时间
    int startPointHour = startTotalMinute/60;
    int startPointMinute = startTotalMinute%60/3*3;
    int endPointHour = endTotalMinute/60;
    int endPointMinute = endTotalMinute%60/3*3;
    
    int startPointTotalMinute = startPointHour*60 + startPointMinute;
    int endPointTotalMinute = endPointHour*60 + endPointMinute;
    
    //计算每分钟像素
    float minutePX;
    //判断起始结束是否同一天
    if ([[startDate substringToIndex:10] isEqualToString:[endDate substringToIndex:10]])
    {
        //同一天
        minutePX = XDrawWidth / (endPointTotalMinute - startPointTotalMinute);
        
    }else
    {
        //两天
        int firstDayMinute = 24*60-startPointTotalMinute;
        minutePX = XDrawWidth / (endPointTotalMinute + firstDayMinute);
        
    }

//    NSLog(@"%@,%@,%d,%d,%d,%d,%f",startDate,endDate,startTotalMinute,endTotalMinute,startPointTotalMinute,endPointTotalMinute,minutePX);

//    //X轴刻度
    for (int i = 0; i < 8 ; i ++)
    {
        UILabel *scaleLabel = (UILabel *)[self viewWithTag:300+i];
        if (i == 0)
        {
            scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",[startHour intValue],[startMinute intValue]];
            
        }else if (i == 7)
        {
            
            scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",[endHour intValue],[endMinute intValue]];
            
        }else
        {
            int labelTotlaMinute = ((int)(i*(XDrawWidth/7)-20+34)/minutePX);
            if (labelTotlaMinute + startTotalMinute < 24*60)
            {
                int labelHour = (labelTotlaMinute + startTotalMinute)/60;
                int labelMinute = (labelTotlaMinute + startTotalMinute) %60;
                scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",labelHour,labelMinute];
                
            }else
            {
                int labelHour = (labelTotlaMinute + startTotalMinute - 24*60)/60;
                int labelMinute = (labelTotlaMinute + startTotalMinute - 24*60) %60;
                scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",labelHour,labelMinute];
            }
        }
    }
    
    if (hasData)
    {
        //每分钟的像素
        double minutePx = XDrawWidth/arrayData.count;
        //Y轴4刻度的每刻度像素
        double valuePx = 116.0000/4;
        
        //遮挡视图
        CAGradientLayer *gradientLayer= [CAGradientLayer layer];
        UIColor *colorOne = [UIColor colorWithRed:(255/255.0)  green:(255/255.0)  blue:(255/255.0)  alpha:0.3];
        UIColor *colorTwo = [UIColor colorWithRed:(255/255.0)  green:(255/255.0)  blue:(255/255.0)  alpha:0.0];
        gradientLayer.colors = @[
                                 (id)colorTwo.CGColor,
                                 (id)colorOne.CGColor
                                 ];
        // 设置渐变方向(0~1)
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        
        // 设置渐变色的起始位置和终止位置(颜色的分割点)
        gradientLayer.locations = @[@(0.15f)];
        //    gradientLayer.borderWidth  = 0.0;
        gradientLayer.frame =  CGRectMake(0, 0, kSCREEN_WIDTH-labelWidth, 116);
        [self.sleepQualityDayCoverView.layer addSublayer:gradientLayer];
        
        //画图
        UIBezierPath *line = [UIBezierPath bezierPath];
        UIBezierPath *shadePath = [UIBezierPath bezierPath];
        
        //当前tagIndex
        int tagIndex = 0;
        BOOL isBedAway = NO;
        if (indexArray.count > 2){
            tagIndex = 1;
            if([indexArray[0] intValue] == 3) {
                isBedAway = YES;
            }
        }
        int tagCount = 0;
        double lastXPoint = 0;
//
//        //ceshi 0
//        int ceshi = 0 ;
//        int ceshiIndex = 0 ;
//        UILabel *ceshiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
//        ceshiLabel.textColor = [UIColor whiteColor];
//        ceshiLabel.font = [UIFont systemFontOfSize:12];
//        [self.sleepQualityDayView addSubview:ceshiLabel];
        //ceshi 1
        
        for(int i = 0 ; i < arrayData.count ; i ++)
        {
            //ceshi 0
//            if ([arrayData[i] doubleValue] != 0 && ceshi == 0) {
//                ceshi = 1;
//                ceshiIndex = i;
//                NSInteger seconds = ceshiIndex*10;
//
//                //format of hour
//                NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
//                //format of minute
//                NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
//                //format of second
//                NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
//                //format of time
//                ceshiLabel.text  = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
//            }
            //ceshi 1
            
            double XPoint = minutePx *i;
            //曲线高度+27，遮盖图不用
            double YPoint = (4-[arrayData[i] doubleValue]) *valuePx+27;
            if (tagIndex < indexArray.count) {
                if (tagIndex != 0 && [indexArray[tagIndex] intValue] != -65536) {
                    int tagIndexNum = [indexArray[tagIndex] intValue];
                    if(tagIndexNum == i){
                        if (isBedAway == NO) {
                            if(tagIndex%2 != 0){
                                //趟下床
                                if (tagCount == 1) {
                                    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-2.5, 17, 5, 9)];
                                    imageV.image = [UIImage imageNamed:@"report_icon_leavetime"];
                                    [self.sleepQualityDayView addSubview:imageV];

                                    UIImageView *lastImageV = [[UIImageView alloc]initWithFrame:CGRectMake(lastXPoint-2.5, 17, 5, 9)];
                                    lastImageV.image = [UIImage imageNamed:@"report_icon_leavetime"];
                                    [self.sleepQualityDayView addSubview:lastImageV];
                                    tagCount = 0;
                                }
                            }else{
                                //离床
                                UIImageView *bedAwayIV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-6.5, 5, 13, 10)];
                                bedAwayIV.image = [UIImage imageNamed:@"report_icon_leave"];
                                [self.sleepQualityDayView addSubview:bedAwayIV];
                                lastXPoint = XPoint;
                                tagCount++;

                            }
                        }else{
                            if(tagIndex%2 != 0){
                                //离床
                                UIImageView *bedAwayIV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-6.5, 5, 13, 10)];
                                bedAwayIV.image = [UIImage imageNamed:@"report_icon_leave"];
                                [self.sleepQualityDayView addSubview:bedAwayIV];
                                lastXPoint = XPoint;
                                tagCount++;
                            }else{
                                //趟下床
                                if (tagCount == 1) {
                                    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-2.5, 17, 5, 9)];
                                    imageV.image = [UIImage imageNamed:@"report_icon_leavetime"];
                                    [self.sleepQualityDayView addSubview:imageV];
                                    UIImageView *lastImageV = [[UIImageView alloc]initWithFrame:CGRectMake(lastXPoint-2.5, 17, 5, 9)];
                                    lastImageV.image = [UIImage imageNamed:@"report_icon_leavetime"];
                                    [self.sleepQualityDayView addSubview:lastImageV];
                                    tagCount = 0;
                                }
                            }
                        }
                        tagIndex++;
                    }
                }
            }
            if (i == 0)
            {
                [line moveToPoint:CGPointMake(XPoint, YPoint)];
                [shadePath moveToPoint:CGPointMake(0, 0)];
                [shadePath addLineToPoint:CGPointMake(0, YPoint-27)];
                
            }else
            {
                if (i == arrayData.count-1)
                {
                    [line addLineToPoint:CGPointMake(XDrawWidth,YPoint)];
                    [shadePath addLineToPoint:CGPointMake(XPoint, YPoint-27)];
                    [shadePath addLineToPoint:CGPointMake(XPoint, 0)];
                    [shadePath closePath];
                    
                }else
                {
                    [line addLineToPoint:CGPointMake(XPoint,YPoint)];
                    [shadePath addLineToPoint:CGPointMake(XPoint, YPoint-27)];
                }
            }
        }
        
        //遮盖图
        CAShapeLayer *shadeLayer = [CAShapeLayer layer];
        shadeLayer.path = shadePath.CGPath;
        self.sleepQualityDayCoverView.layer.mask = shadeLayer;
        
        //绘画图
        [line stroke];
        //添加CAShapeLayer
        CAShapeLayer *shapeLine = [[CAShapeLayer alloc]init];
        //设置颜色
        shapeLine.fillColor = [UIColor clearColor].CGColor;
        shapeLine.strokeColor = [UIColor whiteColor].CGColor;
        //设置宽度
        shapeLine.lineWidth = 1.0;
        //把CAShapeLayer添加到当前视图CAShapeLayer
        [self.sleepQualityDayView.layer addSublayer:shapeLine];
        //把Polyline的路径赋予shapeLine
        shapeLine.path = line.CGPath;
        
    }
}


#pragma mark --手动测试，通用UI
//手动测试，通用UI
-(void)setUniversalManualViewUIForDrawType:(SleepDrawDayViewType)type{
    //    WS(weakSelf);
    UIView *backgroundView = [[UIView alloc]init];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.alpha = kAlpha;
    backgroundView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, 220);
    [self addSubview:backgroundView];
    
    UIImageView *iconIV = [[UIImageView alloc]init];
    if (type == SleepDrawDayViewType_AverageHeartRate)
    {
        iconIV.image = [UIImage imageNamed:@"report_icon_bpm"];
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate)
    {
        iconIV.image = [UIImage imageNamed:@"report_icon_bm"];
        
    }else
    {
        iconIV.image = [UIImage imageNamed:@"report_icon_turnover"];
    }
    [self addSubview:iconIV];
    [iconIV mas_makeConstraints:^(MASConstraintMaker *make)
     {
        make.top.mas_equalTo(backgroundView.mas_top).offset(7);
        make.left.mas_equalTo(backgroundView.mas_left).offset(10);
        make.width.equalTo(@27);
        make.height.equalTo(@28);
         
    }];
    
    UILabel *titleL = [[UILabel alloc] init];
    [self addSubview:titleL];
    titleL.font = [UIFont systemFontOfSize:15];
    titleL.textColor = [UIColor whiteColor];
    titleL.textAlignment = NSTextAlignmentLeft;
    if (type == SleepDrawDayViewType_AverageHeartRate) {
        
        titleL.text = NSLocalizedString(@"RMVC_AverageHeartRate", nil);
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate){
        
        titleL.text = NSLocalizedString(@"RMVC_AverageRespiratoryRate", nil);
    }else{
        titleL.text = NSLocalizedString(@"RMVC_TurnOver", nil);
    }
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconIV);
        make.left.mas_equalTo(iconIV.mas_right).offset(8);
        make.right.mas_equalTo(backgroundView.mas_right).offset(-150);
        make.height.equalTo(@28);
    }];
    
    self.valueLabel = [[UILabel alloc]init];
    [self addSubview:self.valueLabel];
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    //测试数据
    NSString *unitStr;
    if (type == SleepDrawDayViewType_AverageHeartRate)
    {
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate){
        
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else{
        
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);
    }
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",unitStr]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:21.0]
                          range:NSMakeRange(0, 1)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:12.0]
                          range:NSMakeRange(1,unitStr.length)];
    self.valueLabel.attributedText = AttributedStr;
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
        make.centerY.equalTo(iconIV);
        make.left.mas_equalTo(titleL.mas_right).offset(10);
        make.right.mas_equalTo(backgroundView.mas_right).offset(-10);
        make.height.equalTo(@28);
         
    }];
    
    //画虚线
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor whiteColor].CGColor;
    border.fillColor = nil;
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(34, 183)];
    [pat addLineToPoint:CGPointMake(34, 45)];
    border.path = pat.CGPath;
    border.lineWidth = 0.5;
    border.lineCap = @"butt";
    //  第一个是 线条长度   第二个是间距
    border.lineDashPattern = @[@4, @4];
    [self.layer addSublayer:border];
    
    if (type == SleepDrawDayViewType_AverageHeartRate)
    {
        self.yScaleArray = @[@"150",@"100",@"50",@"0"];
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate)
    {
        self.yScaleArray = @[@"40",@"30",@"20",@"10",@"0"];
        
    }else
    {
        self.yScaleArray = @[@"9",@"6",@"3",@"0"];
    }
    
    for (int i = 0; i < self.yScaleArray.count; i++)
    {
        UILabel *yTitleL = [[UILabel alloc]init];
        [self addSubview:yTitleL];
        yTitleL.textColor = [UIColor whiteColor];
        yTitleL.font = [UIFont systemFontOfSize:11];
        yTitleL.textAlignment = NSTextAlignmentRight;
        CGFloat height = 14;
        CGFloat marginTop = 45;
        CGFloat padding;
        if (type == SleepDrawDayViewType_AverageRespiratoryRate)
        {
            padding = 34.5;
            
        }else
        {
            padding = 46;
        }
        yTitleL.text = self.yScaleArray[i];
        yTitleL.frame = CGRectMake(0, marginTop+padding*i-height/2, 28, height);
        
    }
    
    //X轴画图区域宽度
    float XDrawWidth = (kSCREEN_WIDTH-49);
    float XScaleWidth = (kSCREEN_WIDTH-49)/7;
    //X轴刻度
    for (int i = 0; i < 8 ; i ++)
    {
        UILabel *scaleLabel = [[UILabel alloc] init];
        scaleLabel.tag = 300 +i;
        if (i == 0) {
            scaleLabel.frame = CGRectMake(20, 193, 40, 10);
            scaleLabel.textAlignment = NSTextAlignmentLeft;
        }else if (i == 7){
            scaleLabel.frame = CGRectMake(XDrawWidth-30+34, 193, 40, 10);
            scaleLabel.textAlignment = NSTextAlignmentRight;
        }else{
            scaleLabel.frame = CGRectMake(i*XScaleWidth-20+34, 193, 40, 10);
            scaleLabel.textAlignment = NSTextAlignmentCenter;
        }
        scaleLabel.font = [UIFont systemFontOfSize:10];
        scaleLabel.textColor = [UIColor whiteColor];
        [self addSubview:scaleLabel];
        
    }
    self.scrollDayView = [[UIScrollView alloc]initWithFrame:CGRectMake(34, 45, kSCREEN_WIDTH-49, 168)];
    [self addSubview:self.scrollDayView];
    self.scrollDayView.bounces = NO;
    self.scrollDayView.delegate = self;
    self.scrollDayView.showsHorizontalScrollIndicator = NO;
    self.scrollDayView.showsVerticalScrollIndicator = NO;
    self.scrollDayView.contentSize = CGSizeMake((kSCREEN_WIDTH-49), 168);
    self.universalDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kSCREEN_WIDTH-49), 168)];
    [self.scrollDayView addSubview:self.universalDayView];
    
}


#pragma mark --手动测试，通用画图
//手动测试，通用画图
-(NSString *)drawUniversalManualViewDrawType:(SleepDrawDayViewType)type WithData:(NSArray *)dataArray WithStartTime:(NSDate *)startTime WithEndTime:(NSDate *)endTime
{
    //    WS(weakSelf);
    [self removeFromSuperviewForView:self.universalDayView];
    [self.scrollDayView setContentOffset:CGPointMake(0,0) animated:NO];
    
    
    //X轴画图区域宽度
    float XDrawWidth = kSCREEN_WIDTH-49;
    
    NSString *startDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:startTime]];
    NSString *startHour = [startDate substringWithRange:NSMakeRange(11, 2)];
    NSString *startMinute = [startDate substringWithRange:NSMakeRange(14, 2)];
    
    NSString *endDate = [NSString stringWithFormat:@"%@",[UIFactory NSDateForNoUTC:endTime]];
    NSString *endHour = [endDate substringWithRange:NSMakeRange(11, 2)];
    NSString *endMinute = [endDate substringWithRange:NSMakeRange(14, 2)];
    
    int startTotalMinute = [startHour intValue]*60 + [startMinute intValue];
    int endTotalMinute = [endHour intValue]*60 + [endMinute intValue];
    
    //三分钟一个点,计算出实际取点的时间
    int startPointHour = startTotalMinute/60;
    int startPointMinute = startTotalMinute%60/3*3;
    int endPointHour = endTotalMinute/60;
    int endPointMinute = endTotalMinute%60/3*3;
    
    int startPointTotalMinute = startPointHour*60 + startPointMinute;
    int endPointTotalMinute = endPointHour*60 + endPointMinute;
    
    
    
    //计算每分钟像素
    float minutePX;
    //判断起始结束是否同一天
    if ([[startDate substringToIndex:10] isEqualToString:[endDate substringToIndex:10]]) {
        //同一天
        minutePX = XDrawWidth / (endPointTotalMinute - startPointTotalMinute);
    }else{
        //两天
        int firstDayMinute = 24*60-startPointTotalMinute;
        minutePX = XDrawWidth / (endPointTotalMinute + firstDayMinute);
    }
    
    //    //X轴刻度
    for (int i = 0; i < 8 ; i ++) {
        UILabel *scaleLabel = (UILabel *)[self viewWithTag:300+i];
        if (i == 0) {
            scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",[startHour intValue],[startMinute intValue]];
        }else if (i == 7){
            scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",[endHour intValue],[endMinute intValue]];
        }else{
            int labelTotlaMinute = ((int)(i*(XDrawWidth/7)-20+34)/minutePX);
            if (labelTotlaMinute + startTotalMinute < 24*60) {
                int labelHour = (labelTotlaMinute + startTotalMinute)/60;
                int labelMinute = (labelTotlaMinute + startTotalMinute) %60;
                scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",labelHour,labelMinute];
            }else{
                int labelHour = (labelTotlaMinute + startTotalMinute - 24*60)/60;
                int labelMinute = (labelTotlaMinute + startTotalMinute - 24*60) %60;
                scaleLabel.text = [NSString stringWithFormat:@"%02d:%02d",labelHour,labelMinute];
            }
        }
    }
    
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor whiteColor].CGColor;
    border.fillColor = nil;
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 138)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-kMargin)*3, 138)];
    border.path = pat.CGPath;
    border.lineWidth = 0.5;
    border.lineCap = @"butt";
    //  第一个是 线条长度   第二个是间距
    border.lineDashPattern = @[@4, @4];
    [self.universalDayView.layer addSublayer:border];
    
    
    //总和
    float sum = 0;
    //最小数下标
    int minIndex = 0;
    int min = 0;
    //最大数下标
    int maxIndex = 0;
    int max = 0;
    //有效数据个数
    int count  = 0;
    for(int i = 0 ; i < dataArray.count ; i++){
        int num = [dataArray[i] intValue];
        if (num != 0 && num != 240 && num != 255) {
            sum = sum+num;
            count ++;
        }
        //        NSLog(@"%d,%d",num,sum);
        if (min == 0 && num != 0 && num != 240 && num != 255) {
            min = num;
            minIndex = i;
        }
        if (i == 0) {
            max = num;
            maxIndex = i;
        }else{
            if(num != 240 && num != 255 && num > max){
                max = num;
                maxIndex = i;
                continue;
            }
            if(num != 0 && num < min){
                min = num;
                minIndex = i;
                continue;
            }
        }
    }
    
    //平均数
    NSString *average = [NSString stringWithFormat:@"%d",(int)roundf(sum/count)];
    
    NSString *unitStr;
    if (type == SleepDrawDayViewType_AverageHeartRate)
    {
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate)
    {
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else
    {
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);
    }
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",average,unitStr]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:21.0]
                          range:NSMakeRange(0, average.length)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:12.0]
                          range:NSMakeRange(average.length,unitStr.length)];
    self.valueLabel.attributedText = AttributedStr;
    
    if (sum != 0)
    {
        //每分钟的像素
        double minutePx = XDrawWidth/dataArray.count;
        int yMax = [self.yScaleArray[0] intValue];
        //Y轴250刻度的每刻度像素
        double valuePx = 138.0/yMax;
        //折线图
        UIBezierPath *line = [UIBezierPath bezierPath];
        //        NSMutableArray *pointArray = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < dataArray.count ; i ++)
        {
            double XPoint = minutePx *i;
            double num = [dataArray[i] intValue];
            if (num == 240 || num == 255) {
                
                if(i == 0)
                {
                    num = 0;
                    
                }else{
                    double lastNum = [dataArray[i-1] intValue];
                    if (lastNum == 240 || lastNum == 255) {
                        if (i == 1) {
                            num = 0;
                        }else{
                            double beforeLastNum = [dataArray[i-2] intValue];
                            if (beforeLastNum == 240 || beforeLastNum == 255) {
                                num = 0;
                            }else{
                                num = beforeLastNum;
                            }
                        }
                    }else{
                        num = lastNum;
                    }
                }
            }
            double YPoint = (yMax-num) *valuePx;
            if (i == 0) {
                [line moveToPoint:CGPointMake(XPoint, YPoint)];
            }else{
                if (i == dataArray.count-1) {
                    [line addLineToPoint:CGPointMake(XDrawWidth,YPoint)];
                }else{
                    [line addLineToPoint:CGPointMake(XPoint,YPoint)];
                }
            }
            if (type != SleepDrawDayViewType_TurnOver)
            {
                if (i == minIndex && min !=0)
                {
                    UILabel *minLabel = [[UILabel alloc]initWithFrame:CGRectMake(XPoint-9, YPoint+2, 18, 10)];
                    minLabel.font = [UIFont systemFontOfSize:10];
                    minLabel.text = [NSString stringWithFormat:@"%d",min];
                    minLabel.textAlignment = NSTextAlignmentCenter;
                    minLabel.textColor = [UIColor colorWithHexString:@"#66edad"];
                    [self.universalDayView addSubview:minLabel];
                    
                }
                if (i == maxIndex && max !=0)
                {
                    UILabel *maxLabel = [[UILabel alloc]initWithFrame:CGRectMake(XPoint-9, YPoint-12, 18, 10)];
                    maxLabel.font = [UIFont systemFontOfSize:10];
                    maxLabel.textAlignment = NSTextAlignmentCenter;
                    maxLabel.text = [NSString stringWithFormat:@"%d",max];
                    maxLabel.textColor = [UIColor colorWithHexString:@"#ffa96e"];
                    [self.universalDayView addSubview:maxLabel];
                    
                }
            }
        }
        
        //添加到画布
        [line stroke];
        //添加CAShapeLayer
        CAShapeLayer *shapeLine = [[CAShapeLayer alloc]init];
        
        //        shapeLine.lineJoin = kCALineJoinMiter;
        //        shapeLine.lineJoin = kCALineJoinRound;
        shapeLine.lineJoin = kCALineJoinBevel;
        //设置颜色
        shapeLine.fillColor = [UIColor clearColor].CGColor;
        shapeLine.strokeColor = [UIColor whiteColor].CGColor;
        //设置宽度
        shapeLine.lineWidth = 1.0;
        //把CAShapeLayer添加到当前视图CAShapeLayer
        [self.universalDayView.layer addSublayer:shapeLine];
        //把Polyline的路径赋予shapeLine
        shapeLine.path = line.CGPath;
        
    }
    return average;
}

#pragma mark --睡眠带报告
#pragma mark - 日数据
//天，睡眠质量UI
-(void)setSleepDayViewUI
{
    WS(weakSelf);
//    UILabel *titleLabel = [[UILabel alloc]init];
//    [self addSubview:titleLabel];
//    titleLabel.font = [UIFont systemFontOfSize:14];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = NSLocalizedString(@"RMVC_ActualSleepTime", nil);
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.mas_top).offset(12);
//        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
//        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
//        make.height.equalTo(@28);
//    }];
    
    //睡眠的时长
    self.valueLabel = [[UILabel alloc]init];
    [self addSubview:self.valueLabel];
    self.valueLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;

    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0min"]];
    
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:22.0]
                          range:NSMakeRange(0, 1)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:16.0]
                          range:NSMakeRange(1, 3)];
    self.valueLabel.attributedText = AttributedStr;
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.mas_top).offset(6);
        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
        make.height.equalTo(@40);
        
    }];

    //清醒lab
    UILabel *woberLabel = [[UILabel alloc]init];
    [self addSubview:woberLabel];
    woberLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    woberLabel.textColor = [UIColor colorWithHexString:@"#b1aca8"];
    woberLabel.textAlignment = NSTextAlignmentCenter;
    woberLabel.text = NSLocalizedString(@"RMVC_Sober", nil);
    woberLabel.backgroundColor = [UIColor redColor];
    [woberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.valueLabel.mas_bottom).offset(22);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
        
    }];
    
    //浅睡lab
    UILabel *lightLabel = [[UILabel alloc]init];
    [self addSubview:lightLabel];
    lightLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    lightLabel.textColor = [UIColor colorWithHexString:@"#b1aca8"];
    lightLabel.textAlignment = NSTextAlignmentCenter;
    lightLabel.text = NSLocalizedString(@"RMVC_LightSleep", nil);
    lightLabel.backgroundColor = [UIColor redColor];
    [lightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(woberLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
        
    }];
    
    //中睡lab
    UILabel *middleLabel = [[UILabel alloc]init];
    [self addSubview:middleLabel];
    middleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    middleLabel.textColor = [UIColor colorWithHexString:@"#b1aca8"];
    middleLabel.textAlignment = NSTextAlignmentCenter;
    middleLabel.text = NSLocalizedString(@"RMVC_MiddleSleep", nil);
    middleLabel.backgroundColor = [UIColor redColor];
    [middleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(lightLabel.mas_bottom).offset(9);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
    }];
    
    //深睡lab
    UILabel *deepLabel = [[UILabel alloc]init];
    [self addSubview:deepLabel];
    deepLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    deepLabel.textColor = [UIColor colorWithHexString:@"#b1aca8"];
    deepLabel.textAlignment = NSTextAlignmentCenter;
    deepLabel.text = NSLocalizedString(@"RMVC_DeepSleep", nil);
    [deepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(middleLabel.mas_bottom).offset(9);
        make.left.mas_equalTo(weakSelf.mas_left).offset(10);
        make.width.equalTo(@(labelWidth-35));
        make.height.equalTo(@20);
        
    }];
    
    //左右按钮之间的距离
    int count = 3;
    CGFloat width = 15;
    CGFloat gapX = (kSCREEN_WIDTH-60-(width*(count-1)))/count;
    
//    NSArray *titleArray = @[NSLocalizedString(@"RMVC_DeepSleepTime", nil),NSLocalizedString(@"RMVC_LightSleepTime", nil),NSLocalizedString(@"RMVC_SoberTime", nil),NSLocalizedString(@"RMVC_AverageHeartRate", nil),NSLocalizedString(@"RMVC_AverageRespiratoryRate", nil),NSLocalizedString(@"RMVC_MiddleSleepTime", nil)];
//    NSArray *iconArray = @[@"report_icon_deep",@"report_icon_light",@"report_icon_wakeup",@"report_icon_bpm",@"report_icon_bm",@"report_icon_fallasleep"];
    
     NSArray *titleArray = @[@"Deep sleep",@"Middle sleep",@"Light sleep",@"Wake up",@"Heart rate",@"Breath rate"];
     NSArray *iconArray  =  @[@"report_icon_deep",@"report_icon_middle",@"report_icon_light",@"report_icon_wakeup",
                       @"report_icon_heartrate",@"report_icon_breath"];
    
    for (int i = 0; i < count*2; i++)
    {
        CGFloat y;
        UIView *backgroundView = [[UIView alloc]init];
        
        if (i < 3)
        {
            y = 282-50;
            backgroundView.frame = CGRectMake(30+i*(gapX+width), y, gapX, 62-5);
            
        }else
        {
            y = 282-50+62-5+30;
            backgroundView.frame = CGRectMake(30+(i-3)*(gapX+width), y, gapX, 62-5);
        }
        [self addSubview:backgroundView];
        
        UIImageView *iconIV = [[UIImageView alloc]init];
        iconIV.image = [UIImage imageNamed:iconArray[i]];
        [backgroundView addSubview:iconIV];
        [iconIV mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.centerX.equalTo(backgroundView);
            make.top.mas_equalTo(backgroundView.mas_top).offset(0);
            make.width.equalTo(@19.5);
            make.height.equalTo(@19.5);
            
        }];
        
        UILabel *titleL = [[UILabel alloc]init];
        [backgroundView addSubview:titleL];
        titleL.font = [UIFont systemFontOfSize:12];
        titleL.textColor = [UIColor colorWithHexString:@"#b1aca8"];
        titleL.backgroundColor = [UIColor redColor];
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.text = titleArray[i];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(iconIV.mas_bottom).offset(4);
            make.left.mas_equalTo(backgroundView.mas_left).offset(0);
            make.right.mas_equalTo(backgroundView.mas_right).offset(0);
            make.height.equalTo(@12);
            
        }];
        
        UIView *view1 = [[UIView alloc]init];
        [backgroundView addSubview:view1];
        //view1.backgroundColor = [UIColor lightGrayColor];
        view1.backgroundColor = [UIColor greenColor];
        view1.layer.cornerRadius = 7;
        [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(titleL.mas_bottom).offset(4);
            make.left.mas_equalTo(backgroundView.mas_left).offset(0);
            make.right.mas_equalTo(backgroundView.mas_right).offset(-0);
            make.height.equalTo(@15);
            
        }];
        
        UILabel *valueL = [[UILabel alloc]init];
        valueL.tag = 100+i;
        [backgroundView addSubview:valueL];
        valueL.textColor = [UIColor  colorWithHexString:@"#b1aca8"];
        valueL.backgroundColor = [UIColor blueColor];
        valueL.textAlignment = NSTextAlignmentCenter;
        //测试数据
        // NSDate *data = [NSDate date];
        
        //测试(假数据)
//        [self drawReportLine];
        
        NSDateFormatter *dateMMFormatter = [[NSDateFormatter alloc] init];
        [dateMMFormatter setDateFormat:@"MM"];
        NSDateFormatter *dateDDFormatter = [[NSDateFormatter alloc] init];
        [dateDDFormatter setDateFormat:@"dd"];
        
        
        //NSString *sleepTimeMM = [dateMMFormatter stringFromDate:sleepData[@"actualSleepTime"]];
        //NSString *sleepTimeDD = [dateDDFormatter stringFromDate:sleepData[@"actualSleepTime"]];
        
        //测试数据
        
        //NSString *sleepTimeMM = [NSString stringWithFormat:@"%02ld",[[dateMMFormatter stringFromDate:data]  integerValue]];
        //NSString *sleepTimeDD = [dateDDFormatter stringFromDate:data];
        
        //日进度条
        NSMutableAttributedString *AttributedStr;
        if (i == 4 || i == 5)
        {
            NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);//次/分
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",unit]];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:13.0]
                                  range:NSMakeRange(0, 1)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:9.0]
                                  range:NSMakeRange(1, unit.length)];
            
        }else
        {
            NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);//min
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",minUnit]];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:13.0]
                                  range:NSMakeRange(0, 1)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:9.0]
                                  range:NSMakeRange(1, minUnit.length)];
            
        }
        
        valueL.attributedText = AttributedStr;
        [valueL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(view1.mas_bottom).offset(6);
            make.left.mas_equalTo(titleL.mas_left).offset(0);
            make.right.mas_equalTo(backgroundView.mas_right).offset(0);
            make.height.equalTo(@13);
            
        }];
    }
    
    //日波形-scroll
    self.scrollDayView = [[UIScrollView alloc]initWithFrame:CGRectMake(labelWidth-15, 100-47, kSCREEN_WIDTH-labelWidth-15, 168)];
    [self addSubview:self.scrollDayView];
    self.scrollDayView.delegate = self;
    self.scrollDayView.bounces = NO;
    self.scrollDayView.backgroundColor = [UIColor greenColor];
    self.scrollDayView.showsHorizontalScrollIndicator = NO;
    self.scrollDayView.showsVerticalScrollIndicator = NO;
    self.scrollDayView.contentSize = CGSizeMake((kSCREEN_WIDTH-labelWidth), 168);
    //self.scrollDayView.alpha = 0.3;
    
    //画虚线 (清醒，浅睡，中睡，深睡)
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor colorWithHexString:@"#e5e4df"].CGColor;
    border.fillColor = nil;
    
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 27)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth-15), 27)];
    [pat moveToPoint:CGPointMake(0, 56)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth-15), 56)];
    [pat moveToPoint:CGPointMake(0, 85)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth-15), 85)];
    [pat moveToPoint:CGPointMake(0, 114)];
    [pat addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth-15), 114)];
    border.path = pat.CGPath;
    
//    border.lineWidth = 0.5;
//    border.lineCap = @"butt";
//    //  第一个是 线条长度   第二个是间距
//    border.lineDashPattern = @[@4, @4];
    [self.scrollDayView.layer addSublayer:border];
    
//    CAShapeLayer *border2 = [CAShapeLayer layer];
//    border2.strokeColor = [UIColor colorWithHexString:@"#1b86a4"].CGColor;
//    border2.fillColor = [UIColor redColor].CGColor;;
//
//    UIBezierPath *pat2 = [UIBezierPath bezierPath];
//    [pat2 moveToPoint:CGPointMake(0, 143)];
//    [pat2 addLineToPoint:CGPointMake((kSCREEN_WIDTH-labelWidth), 143)];
//    border2.path = pat2.CGPath;
//    //    border.lineWidth = 0.5;
//    //    border.lineCap = @"butt";
//    //    //  第一个是 线条长度   第二个是间距
//    //    border.lineDashPattern = @[@4, @4];
//    [self.scrollDayView.layer addSublayer:border2];
    
    self.sleepQualityDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kSCREEN_WIDTH-labelWidth), 168)];
    [self.scrollDayView addSubview:self.sleepQualityDayView];
    
//    self.sleepQualityDayCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 27, (kSCREEN_WIDTH-labelWidth)*3, 116)];
//    [self.scrollDayView addSubview:self.sleepQualityDayCoverView];
    
}


-(void)scrollViewDidScroll:(UIScrollView*)scrollView{
//    self.contentOffsetBlock(scrollView);
}

/**
 天，睡眠质量画图
 
 @param arrayData 曲线数组
 @param hour 用户设置的睡眠报告起始点
 @param indexArray 离床下标
 @param hasData 是否有数据
 */
-(void)drawSleepDayViewForSleepData:(NSArray *)arrayData WithHour:(int)hour WithGetUpIndex:(NSArray *)indexArray WithData:(BOOL)hasData
{
    //    WS(weakSelf);
    [self removeFromSuperviewForView:self.sleepQualityDayView];
//    [self removeFromSuperviewForView:self.sleepQualityDayCoverView];
    [self.scrollDayView setContentOffset:CGPointMake(0,0) animated:NO];
    
    //X轴画图区域宽度
    float XDrawWidth = (kSCREEN_WIDTH-labelWidth);
    float XScaleWidth = (kSCREEN_WIDTH-labelWidth)/5;
    //X轴刻度
    for (int i = 0; i < 6; i++)
    {
        NSString * scaleXValue;
        if ((hour + i*3) < 24)
        {
            scaleXValue = [NSString stringWithFormat:@"%02d:00",hour+i*3];
            
        }else
        {
            scaleXValue = [NSString stringWithFormat:@"%02d:00",hour+i*3-24];
        }
        UILabel *scaleLabel ;
        if (i == 0)
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 148, 40, 10)];
            scaleLabel.textAlignment = NSTextAlignmentLeft;
            
        }else if (i == 5)
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(XDrawWidth-40, 148, 40, 10)];
            scaleLabel.textAlignment = NSTextAlignmentRight;
            
        }else
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*XScaleWidth-20, 148, 40, 10)];
            scaleLabel.textAlignment = NSTextAlignmentCenter;
        }
        scaleLabel.text = scaleXValue;
        scaleLabel.font = [UIFont systemFontOfSize:12];
        scaleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
        [self.sleepQualityDayView addSubview:scaleLabel];
        
    }
    if (hasData)
    {
        //每分钟的像素
        double minutePx = XDrawWidth/arrayData.count;
        //Y轴4刻度的每刻度像素
        double valuePx = 116.0000/4;
        
//        //遮挡视图
//        CAGradientLayer *gradientLayer= [CAGradientLayer layer];
//        UIColor *colorOne = [UIColor colorWithRed:(255/255.0)  green:(255/255.0)  blue:(255/255.0)  alpha:0.3];
//        UIColor *colorTwo = [UIColor colorWithRed:(255/255.0)  green:(255/255.0)  blue:(255/255.0)  alpha:0.0];
//        gradientLayer.colors = @[
//                                 (id)colorTwo.CGColor,
//                                 (id)colorOne.CGColor
//                                 ];
//        // 设置渐变方向(0~1)
//        gradientLayer.startPoint = CGPointMake(0, 0);
//        gradientLayer.endPoint = CGPointMake(0, 1);
//
//        // 设置渐变色的起始位置和终止位置(颜色的分割点)
//        gradientLayer.locations = @[@(0.15f)];
//        //    gradientLayer.borderWidth  = 0.0;
//        gradientLayer.frame =  CGRectMake(0, 0, (kSCREEN_WIDTH-labelWidth)*3, 116);
//        [self.sleepQualityDayCoverView.layer addSublayer:gradientLayer];
        
        //画图
        UIBezierPath *line = [UIBezierPath bezierPath];
        UIBezierPath *shadePath = [UIBezierPath bezierPath];
        
        //当前tagIndex
        int tagIndex = 0;
        BOOL isBedAway = NO;
        if (indexArray.count > 2)
        {
            tagIndex = 1;
            if([indexArray[0] intValue] == 3)
            {
                isBedAway = YES;
            }
        }
        int tagCount = 0;
        double lastXPoint = 0;
        
        //ceshi 0
//        int ceshi = 0 ;
//        int ceshiIndex = 0 ;
//        UILabel *ceshiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
//        ceshiLabel.textColor = [UIColor whiteColor];
//        ceshiLabel.font = [UIFont systemFontOfSize:12];
//        [self.sleepQualityDayView addSubview:ceshiLabel];
        //ceshi 1
        
        for(int i = 0 ; i < arrayData.count ; i ++){
            //ceshi 0
//            if ([arrayData[i] doubleValue] != 0 && ceshi == 0) {
//                ceshi = 1;
//                ceshiIndex = i;
//                NSInteger seconds = ceshiIndex*10;
//                
//                //format of hour
//                NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
//                //format of minute
//                NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
//                //format of second
//                NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
//                //format of time
//                ceshiLabel.text  = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
//            }
            //ceshi 1
            
            double XPoint = minutePx *i;
            //曲线高度+27，遮盖图不用
            double YPoint = (4-[arrayData[i] doubleValue]) *valuePx+27;
            
            
            if (tagIndex < indexArray.count)
            {
                
                if (tagIndex != 0 && [indexArray[tagIndex] intValue] != -65536)
                {
                    int tagIndexNum = [indexArray[tagIndex] intValue];
                    
                    if(tagIndexNum == i)
                    {
                        if (isBedAway == NO)
                        {
                            if(tagIndex%2 != 0)
                            {
                                //趟下床
                                if (tagCount == 1)
                                {
                                    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-2.5, 17, 5, 9)];
                                    imageV.image = [UIImage imageNamed:@""];
                                    [self.sleepQualityDayView addSubview:imageV];
                                    
                                    UIImageView *lastImageV = [[UIImageView alloc]initWithFrame:CGRectMake(lastXPoint-2.5, 17, 5, 9)];
                                    lastImageV.image = [UIImage imageNamed:@""];
                                    [self.sleepQualityDayView addSubview:lastImageV];
                                    tagCount = 0;
                                }
                                
                            }else
                            {
                                //离床
                                UIImageView *bedAwayIV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-6.5, 5, 14, 9)];
                                bedAwayIV.image = [UIImage imageNamed:@"report_icon_bedaway"];
                                [self.sleepQualityDayView addSubview:bedAwayIV];
                                lastXPoint = XPoint;
                                tagCount++;
                                
                            }
                            
                        }else
                        {
                            
                            if(tagIndex%2 != 0)
                            {
                                //离床
                                UIImageView *bedAwayIV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-6.5, 5, 14, 9)];
                                bedAwayIV.image = [UIImage imageNamed:@"report_icon_bedaway"];
                                [self.sleepQualityDayView addSubview:bedAwayIV];
                                lastXPoint = XPoint;
                                tagCount++;
                                
                            }else
                            {
                                //趟下床
                                if (tagCount == 1)
                                {
                                    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(XPoint-2.5, 17, 5, 9)];
                                    imageV.image = [UIImage imageNamed:@""];
                                    [self.sleepQualityDayView addSubview:imageV];
                                    UIImageView *lastImageV = [[UIImageView alloc]initWithFrame:CGRectMake(lastXPoint-2.5, 17, 5, 9)];
                                    lastImageV.image = [UIImage imageNamed:@""];
                                    [self.sleepQualityDayView addSubview:lastImageV];
                                    tagCount = 0;
                                }
                            }
                        }
                        tagIndex++;
                    }
                }
            }
            if (i == 0)
            {
                [line moveToPoint:CGPointMake(XPoint, YPoint)];
                [shadePath moveToPoint:CGPointMake(0, 0)];
                [shadePath addLineToPoint:CGPointMake(0, YPoint-27)];
                
            }else
            {
                
                if (i == arrayData.count-1)
                {
                    [line addLineToPoint:CGPointMake(XDrawWidth,YPoint)];
                    [shadePath addLineToPoint:CGPointMake(XPoint, YPoint-27)];
                    [shadePath addLineToPoint:CGPointMake(XPoint, 0)];
                    [shadePath closePath];
                    
                }else
                {
                    [line addLineToPoint:CGPointMake(XPoint,YPoint)];
                    [shadePath addLineToPoint:CGPointMake(XPoint, YPoint-27)];
                }
            }
        }
        //遮盖图
//        CAShapeLayer *shadeLayer = [CAShapeLayer layer];
//        shadeLayer.path = shadePath.CGPath;
//        self.sleepQualityDayCoverView.layer.mask = shadeLayer;
        
        //绘画图
        [line stroke];
        //添加CAShapeLayer
        CAShapeLayer *shapeLine = [[CAShapeLayer alloc]init];
        //设置颜色
        shapeLine.fillColor = [UIColor clearColor].CGColor;
        shapeLine.strokeColor = [UIColor colorWithHexString:@"#21a0bf"].CGColor;
        //设置宽度
        shapeLine.lineWidth = 2.0;
        //把CAShapeLayer添加到当前视图CAShapeLayer
        [self.sleepQualityDayView.layer addSublayer:shapeLine];
        //把Polyline的路径赋予shapeLine
        shapeLine.path = line.CGPath;
        
    }
}

#pragma mark --天，通用UI (睡眠监测以下)
//天，通用UI
-(void)setUniversalDayViewUIForDrawType:(SleepDrawDayViewType)type
{
      WS(weakSelf);
//    UIView *backgroundView = [[UIView alloc]init];
//    backgroundView.backgroundColor = [UIColor whiteColor];
//    backgroundView.alpha = kAlpha;
//    backgroundView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, 220);
//    [self addSubview:backgroundView];
    
    //心率，呼吸率，翻身 image
    UIImageView *iconIV = [[UIImageView alloc]init];
    if (type == SleepDrawDayViewType_AverageHeartRate) {
        
        iconIV.image = [UIImage imageNamed:@"realtime_icon_heartrate"];
        
         //心率波形--
         //[self drawHeartRateLine];
        
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate){
        
        iconIV.image = [UIImage imageNamed:@"realtime_icon_breath"];
        
        //呼吸率波形
        [self drawBreatheLine];
        
    }else
    {
        iconIV.image = [UIImage imageNamed:@"report_icon_turn"];
        //翻身波形
        
    }
    [self addSubview:iconIV];
    [iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.mas_top).offset(20);
        make.left.mas_equalTo(weakSelf.mas_centerX).offset(-15-7-30);
        make.width.equalTo(@15);
        make.height.equalTo(@15);
        
    }];
    
    //标题
    UILabel *titleL = [[UILabel alloc]init];
    [self addSubview:titleL];
    titleL.font = [UIFont systemFontOfSize:15];
    titleL.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    titleL.textAlignment = NSTextAlignmentLeft;
    if (type == SleepDrawDayViewType_AverageHeartRate) {
        
        titleL.text = @"heart rate";
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate){
        
        titleL.text = @"breath rate";
        
    }else
    {
        titleL.text = @"turn/move";
    }
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(iconIV);
        make.left.mas_equalTo(iconIV.mas_right).offset(7);
        make.width.equalTo(@100);
        make.height.equalTo(@28);
        
    }];
    
    //波形-的背景image
    UIImageView *imagev = [[UIImageView alloc]init];
    if (type == SleepDrawDayViewType_AverageRespiratoryRate) {
        
        imagev.image = [UIImage imageNamed:@"realtime_bg_breath"];
        
    }else
    {
        imagev.image = [UIImage imageNamed:@"realtime_bg_heartrate"];
    }
    [self addSubview:imagev];
    [imagev mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.mas_top).offset(0);
        make.width.equalTo(@375);
        make.height.equalTo(@232);
        
    }];
    
    self.valueLabel = [[UILabel alloc]init];
    [self addSubview:self.valueLabel];
    //self.valueLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    self.valueLabel.textColor = [UIColor redColor];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    //测试数据
    
    
    NSString *unitStr;
    if (type == SleepDrawDayViewType_AverageHeartRate) {
        
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate){
        
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else
    {
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);
    }
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",unitStr]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:15.0]
                          range:NSMakeRange(0, 1)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:10.0]
                          range:NSMakeRange(1,unitStr.length)];
    self.valueLabel.attributedText = AttributedStr;
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(@100);
        make.top.mas_equalTo(iconIV.mas_bottom).offset(30);
        make.right.mas_equalTo(imagev.mas_right).offset(-48);
        make.height.equalTo(@15);
        
    }];
    
//    //画虚线
//    CAShapeLayer *border = [CAShapeLayer layer];
//    border.strokeColor = [UIColor whiteColor].CGColor;
//    border.fillColor = nil;
//    UIBezierPath *pat = [UIBezierPath bezierPath];
//    [pat moveToPoint:CGPointMake(34, 183)];
//    [pat addLineToPoint:CGPointMake(34, 45)];
//    border.path = pat.CGPath;
////    border.lineWidth = 0.5;
////    border.lineCap = @"butt";
//    //  第一个是 线条长度   第二个是间距
////    border.lineDashPattern = @[@4, @4];
//    [self.layer addSublayer:border];
//
//    if (type == SleepDrawDayViewType_AverageHeartRate) {
//        self.yScaleArray = @[@"150",@"100",@"50",@"0"];
//    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate){
//        self.yScaleArray = @[@"40",@"30",@"20",@"10",@"0"];
//    }else{
//        self.yScaleArray = @[@"9",@"6",@"3",@"0"];
//    }
//    for (int i = 0; i < self.yScaleArray.count; i++) {
//        UILabel *yTitleL = [[UILabel alloc]init];
//        [self addSubview:yTitleL];
//        yTitleL.textColor = [UIColor whiteColor];
//        yTitleL.font = [UIFont systemFontOfSize:11];
//        yTitleL.textAlignment = NSTextAlignmentRight;
//        CGFloat height = 14;
//        CGFloat marginTop = 45;
//        CGFloat padding;
//        if (type == SleepDrawDayViewType_AverageRespiratoryRate) {
//            padding = 34.5;
//        }else{
//            padding = 46;
//        }
//        yTitleL.text = self.yScaleArray[i];
//        yTitleL.frame = CGRectMake(0, marginTop+padding*i-height/2, 28, height);
//    }
    
    self.scrollDayView = [[UIScrollView alloc]initWithFrame:CGRectMake(53+20, 75+14, 375-101, 232-75-15-15)];
    [self addSubview:self.scrollDayView];
    self.scrollDayView.bounces = NO;
    self.scrollDayView.delegate = self;
    self.scrollDayView.showsHorizontalScrollIndicator = NO;
    self.scrollDayView.showsVerticalScrollIndicator = NO;
    self.scrollDayView.contentSize = CGSizeMake((375-101), 232-75-15-15);
    self.universalDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (375-101), 232-75-15-15)];
    [self.scrollDayView addSubview:self.universalDayView];
//    self.scrollDayView.backgroundColor = [UIColor yellowColor];
//    self.scrollDayView.alpha = 0.3;
    
}

#pragma mark--天，通用画图
//天，通用画图
-(NSString *)drawUniversalDayViewDrawType:(SleepDrawDayViewType)type WithData:(NSArray *)dataArray WithHour:(int)hour
{
    
    NSLog(@"mmm dataArray=%@,hour=%d",dataArray, hour);
    //    WS(weakSelf);
    [self removeFromSuperviewForView:self.universalDayView];
    [self.scrollDayView setContentOffset:CGPointMake(0,0) animated:NO];
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor colorWithHexString:@"#1b86a4"].CGColor;
    border.fillColor = nil;
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 232-75-15-23-15)];//(0,104)
    [pat addLineToPoint:CGPointMake((375-101), 232-75-15-23-15)];//(274,104)
    border.path = pat.CGPath;
    border.lineWidth = 0.5;
//    border.lineCap = @"butt";
//    //  第一个是 线条长度   第二个是间距
//    border.lineDashPattern = @[@4, @4];
    [self.universalDayView.layer addSublayer:border];
    
    
    //总和
    float sum = 0;
    //最小数下标
    int minIndex = 0;
    int min = 0;
    //最大数下标
    int maxIndex = 0;
    int max = 0;
    
    //有效数据个数
    int count  = 0;
    
    //for(int i = 0 ; i < dataArray.count ; i++)
    for(int i = 0 ; i < 10 ; i++)
    {
        int num = 10;//[dataArray[i] intValue];
        if (num != 0 && num != 240 && num != 255)
        {
            sum = sum+num;
            count ++;
        }
        //        NSLog(@"%d,%d",num,sum);
        if (min == 0 && num != 0 && num != 240 && num != 255)
        {
            min = num;
            minIndex = i;
            
        }
        if (i == 0)
        {
            max = num;
            maxIndex = i;
            
        }else
        {
            if(num != 240 && num != 255 && num > max)
            {
                max = num;
                maxIndex = i;
                continue;
            }
            if(num != 0 && num < min)
            {
                min = num;
                minIndex = i;
                continue;
            }
        }
    }
    //平均数
    NSString *average = [NSString stringWithFormat:@"%d",(int)roundf(sum/count)];
    //NSString *average = [NSString stringWithFormat:@"%d",200];
    NSLog(@" averageaverage=%@",average);
    
    NSString *unitStr;
    if (type == SleepDrawDayViewType_AverageHeartRate)
    {
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else if (type == SleepDrawDayViewType_AverageRespiratoryRate)
    {
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else
    {
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);
    }
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",average,unitStr]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:15.0]
                          range:NSMakeRange(0, average.length)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:10.0]
                          range:NSMakeRange(average.length,unitStr.length)];
    self.valueLabel.attributedText = AttributedStr;
    
    //X轴画图区域宽度
    float XDrawWidth = (375-101);//274
    float XScaleWidth = (375-101)/4;//68.5
    
    //X轴刻度
    for (int i = 0; i < 5 ; i ++)
    {
        NSString * scaleXValue;
        if ((hour + i*3) < 24) {
            
            scaleXValue = [NSString stringWithFormat:@"%02d:00",hour+i*3];
            
        }else
        {
            scaleXValue = [NSString stringWithFormat:@"%02d:00",hour+i*3-24];
        }
        
        UILabel *scaleLabel;
        if (i==0)
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 232-75-15-23-15+5, 40, 10)];//(0,109,40,10)
            scaleLabel.textAlignment = NSTextAlignmentLeft;
            
        }else if (i == 4)
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(XDrawWidth-40, 232-75-15-23-15+5, 40, 10)];//(28.5,109,40,10)
            scaleLabel.textAlignment = NSTextAlignmentRight;
            
        }else
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*XScaleWidth-20, 232-75-15-23-15+5, 40, 10)];//(i*XScaleWidth-20,109,40,10)
            scaleLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        scaleLabel.text = scaleXValue;
        scaleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightLight];
        scaleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
        [self.universalDayView addSubview:scaleLabel];
        
    }
    
    
    if (sum != 0)
    {
        //每分钟的像素
        double minutePx = XDrawWidth/dataArray.count;
        int yMax = [self.yScaleArray[0] intValue];
        //Y轴250刻度的每刻度像素
        double valuePx = (232-75-15-23-15)/yMax;//104
        //折线图
        UIBezierPath *line = [UIBezierPath bezierPath];
        //        NSMutableArray *pointArray = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < dataArray.count; i ++)
        {
            double XPoint = minutePx *i;
            double num = [dataArray[i] intValue];
            if (num == 240 || num == 255) {
                
                if(i == 0)
                {
                    num = 0;
                    
                }else
                {
                    double lastNum = [dataArray[i-1] intValue];
                    if (lastNum == 240 || lastNum == 255) {
                        if (i == 1)
                        {
                            num = 0;
                            
                        }else
                        {
                            double beforeLastNum = [dataArray[i-2] intValue];
                            if (beforeLastNum == 240 || beforeLastNum == 255)
                            {
                                num = 0;
                                
                            }else
                            {
                                num = beforeLastNum;
                            }
                        }
                    }else
                    {
                        num = lastNum;
                    }
                }
            }
            double YPoint = (yMax-num) *valuePx;
            if (i == 0)
            {
                [line moveToPoint:CGPointMake(XPoint, YPoint)];
                
            }else
            {
                if (i == dataArray.count-1)
                {
                    [line addLineToPoint:CGPointMake(XDrawWidth,YPoint)];
                    
                }else
                {
                    [line addLineToPoint:CGPointMake(XPoint,YPoint)];
                }
            }
            
            
//            if (type != SleepDrawDayViewType_TurnOver) {
//                if (i == minIndex && min !=0) {
//                    UILabel *minLabel = [[UILabel alloc]initWithFrame:CGRectMake(XPoint-9, YPoint+2, 18, 10)];
//                    minLabel.font = [UIFont systemFontOfSize:10];
//                    minLabel.text = [NSString stringWithFormat:@"%d",min];
//                    minLabel.textAlignment = NSTextAlignmentCenter;
//                    minLabel.textColor = [UIColor colorWithHexString:@"#66edad"];
//                    [self.universalDayView addSubview:minLabel];
//                }
//                if (i == maxIndex && max !=0) {
//                    UILabel *maxLabel = [[UILabel alloc]initWithFrame:CGRectMake(XPoint-9, YPoint-12, 18, 10)];
//                    maxLabel.font = [UIFont systemFontOfSize:10];
//                    maxLabel.textAlignment = NSTextAlignmentCenter;
//                    maxLabel.text = [NSString stringWithFormat:@"%d",max];
//                    maxLabel.textColor = [UIColor colorWithHexString:@"#ffa96e"];
//                    [self.universalDayView addSubview:maxLabel];
//                }
//            }
        }
        //添加到画布
        [line stroke];
        //添加CAShapeLayer
        CAShapeLayer *shapeLine = [[CAShapeLayer alloc]init];
        
        //        shapeLine.lineJoin = kCALineJoinMiter;
        //        shapeLine.lineJoin = kCALineJoinRound;
        shapeLine.lineJoin = kCALineJoinBevel;
        //设置颜色
        //shapeLine.fillColor = [UIColor clearColor].CGColor;
        shapeLine.fillColor = [UIColor redColor].CGColor;
        
        if (type != SleepDrawDayViewType_AverageRespiratoryRate)//平均呼吸率
        {
            shapeLine.strokeColor = [UIColor colorWithHexString:@"#d1b793"].CGColor;
    
        }else
        {
            shapeLine.strokeColor = [UIColor colorWithHexString:@"#21a0bf"].CGColor;
        }
        
        //设置宽度
        shapeLine.lineWidth = 5.0;
        //把CAShapeLayer添加到当前视图CAShapeLayer
        [self.universalDayView.layer addSublayer:shapeLine];
        //把Polyline的路径赋予shapeLine
        shapeLine.path = line.CGPath;
        
    }
    return average;
}

#pragma egeg -调试
-(NSString *)drawUniversalDayViewDrawTe:(SleepDrawDayViewType)type
                               WithData:(NSArray *)dataArray
                               WithHour:(int)hour
{
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor colorWithHexString:@"#1b86a4"].CGColor;
    border.fillColor = nil;
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(0, 232-75-15-23-15)];//(0,104)
    [pat addLineToPoint:CGPointMake((375-101), 232-75-15-23-15)];//(274,104)
    border.path = pat.CGPath;
    border.lineWidth = 0.5;
    [self.universalDayView.layer addSublayer:border];
    
    
    //X轴画图区域宽度
    float XDrawWidth = (375-101);//274
    float XScaleWidth = (375-101)/4;//68.5
    
    //X轴刻度
    for (int i = 0; i < 5 ; i ++)
    {
        NSString * scaleXValue;
        if ((hour + i*3) < 24) {
            
            scaleXValue = @"50";// [NSString stringWithFormat:@"%02d:00",hour+i*3];
            
        }else
        {
            scaleXValue = @"20";//[NSString stringWithFormat:@"%02d:00",hour+i*3-24];
        }
        
        UILabel *scaleLabel;
        if (i==0)
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 232-75-15-23-15+5, 40, 10)];//(0,109,40,10)
            scaleLabel.textAlignment = NSTextAlignmentLeft;
            
        }else if (i == 4)
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(XDrawWidth-40, 232-75-15-23-15+5, 40, 10)];//(28.5,109,40,10)
            scaleLabel.textAlignment = NSTextAlignmentRight;
            
        }else
        {
            scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*XScaleWidth-20, 232-75-15-23-15+5, 40, 10)];//(i*XScaleWidth-20,109,40,10)
            scaleLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        scaleLabel.text = scaleXValue;
        scaleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightLight];
        scaleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
        [self.universalDayView addSubview:scaleLabel];
        
    }

    //总和
    float sum = 0;
    //Y轴
    if ( sum != 0)
    {
        //每分钟的像素
        double minutePx = XDrawWidth/dataArray.count;
        
        
        
    }
    
    
    
    
    return @"";
}

#pragma mark - 周/月数据
//周月，睡眠质量UI
-(void)setSleepViewUI
{
    WS(weakSelf);
//    UILabel *titleLabel = [[UILabel alloc]init];
//    [self addSubview:titleLabel];
//    titleLabel.font = [UIFont systemFontOfSize:14];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = NSLocalizedString(@"RMVC_AverageSleepTime", nil);
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.mas_top).offset(12);
//        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
//        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
//        make.height.equalTo(@28);
//    }];
    
    //
    self.valueLabel = [[UILabel alloc]init];
    [self addSubview:self.valueLabel];
    self.valueLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0min"]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:22.0]
                          range:NSMakeRange(0, 1)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:16.0]
                          range:NSMakeRange(1, 3)];
    self.valueLabel.attributedText = AttributedStr;
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.mas_top).offset(6);
        make.left.mas_equalTo(weakSelf.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-kMargin);
        make.height.equalTo(@40);
        
    }];
    
    
    //左右按钮之间的距离
    int count = 3;
    CGFloat width = 15;
    CGFloat gapX = (kSCREEN_WIDTH-60-(width*(count-1)))/count;
    
    //    NSArray *titleArray = @[NSLocalizedString(@"RMVC_DeepSleepTime", nil),NSLocalizedString(@"RMVC_LightSleepTime", nil),NSLocalizedString(@"RMVC_SoberTime", nil),NSLocalizedString(@"RMVC_AverageHeartRate", nil),NSLocalizedString(@"RMVC_AverageRespiratoryRate", nil),NSLocalizedString(@"RMVC_MiddleSleepTime", nil)];
    //    NSArray *iconArray = @[@"report_icon_deep",@"report_icon_light",@"report_icon_wakeup",@"report_icon_bpm",@"report_icon_bm",@"report_icon_fallasleep"];
    
    NSArray *titleArray = @[@"Depp sleep",@"Middle sleep",@"Light sleep",@"Wake up",@"Heart rate",@"Breath rate"];
    NSArray *iconArray = @[@"report_icon_deep",@"report_icon_middle",@"report_icon_light",@"report_icon_wakeup",@"report_icon_heartrate",@"report_icon_breath"];
    
    for (int i = 0; i < count*2; i++)
    {
        
        CGFloat y;
        UIView *backgroundView = [[UIView alloc]init];
        
        if (i < 3)
        {
            y = 282-40;
            backgroundView.frame = CGRectMake(30+i*(gapX+width), y, gapX, 62-5);
            
        }else
        {
            y = 282-40+62-5+30;
            backgroundView.frame = CGRectMake(30+(i-3)*(gapX+width), y, gapX, 62-5);
        }
        [self addSubview:backgroundView];
        
        UIImageView *iconIV = [[UIImageView alloc]init];
        iconIV.image = [UIImage imageNamed:iconArray[i]];
        [backgroundView addSubview:iconIV];
        [iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(backgroundView);
            make.top.mas_equalTo(backgroundView.mas_top).offset(0);
            make.width.equalTo(@19.5);
            make.height.equalTo(@19.5);
            
        }];
        
        UILabel *titleL = [[UILabel alloc]init];
        [backgroundView addSubview:titleL];
        titleL.font = [UIFont systemFontOfSize:12];
        titleL.textColor = [UIColor colorWithHexString:@"#b1aca8"];
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.text = titleArray[i];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(iconIV.mas_bottom).offset(4);
            make.left.mas_equalTo(backgroundView.mas_left).offset(0);
            make.right.mas_equalTo(backgroundView.mas_right).offset(0);
            make.height.equalTo(@12);
            
        }];
        
        UIView *view1 = [[UIView alloc]init];
        [backgroundView addSubview:view1];
        view1.backgroundColor = [UIColor lightGrayColor];
        view1.layer.cornerRadius = 7;
        [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(titleL.mas_bottom).offset(4);
            make.left.mas_equalTo(backgroundView.mas_left).offset(0);
            make.right.mas_equalTo(backgroundView.mas_right).offset(-0);
            make.height.equalTo(@15);
            
        }];
        
        UILabel *valueL = [[UILabel alloc]init];
        valueL.tag = 200+i;
        [backgroundView addSubview:valueL];
        valueL.textColor = [UIColor  colorWithHexString:@"#b1aca8"];
        valueL.textAlignment = NSTextAlignmentCenter;
        //测试数据
        
        //        NSDate *data = [NSDate date];
        
        NSDateFormatter *dateMMFormatter = [[NSDateFormatter alloc] init];
        [dateMMFormatter setDateFormat:@"MM"];
        NSDateFormatter *dateDDFormatter = [[NSDateFormatter alloc] init];
        [dateDDFormatter setDateFormat:@"dd"];
        
        //    NSString *sleepTimeMM = [dateMMFormatter stringFromDate:sleepData[@"actualSleepTime"]];
        //    NSString *sleepTimeDD = [dateDDFormatter stringFromDate:sleepData[@"actualSleepTime"]];
        //测试数据
        //        NSString *sleepTimeMM = [NSString stringWithFormat:@"%02ld",[[dateMMFormatter stringFromDate:data]  integerValue]];
        //        NSString *sleepTimeDD = [dateDDFormatter stringFromDate:data];
        
        NSMutableAttributedString *AttributedStr;
        if (i == 4 || i == 5)
        {
            
            NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",unit]];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:13.0]
                                  range:NSMakeRange(0, 1)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:9.0]
                                  range:NSMakeRange(1, unit.length)];
            
        }else
        {
            NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",minUnit]];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:13.0]
                                  range:NSMakeRange(0, 1)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:9.0]
                                  range:NSMakeRange(1, minUnit.length)];
        }
        valueL.attributedText = AttributedStr;
        [valueL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(view1.mas_bottom).offset(6);
            make.left.mas_equalTo(titleL.mas_left).offset(0);
            make.right.mas_equalTo(backgroundView.mas_right).offset(0);
            make.height.equalTo(@13);
            
        }];
    }
    
    //画虚线
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor colorWithHexString:@"#b1aca8"].CGColor;
    border.fillColor = nil;
    UIBezierPath *pat = [UIBezierPath bezierPath];
    [pat moveToPoint:CGPointMake(34, 127-40)];
    [pat addLineToPoint:CGPointMake(kSCREEN_WIDTH-34, 127-40)];
    border.path = pat.CGPath;
    border.lineWidth = 0.5;
//    border.lineCap = @"butt";
//    //  第一个是 线条长度   第二个是间距
//    border.lineDashPattern = @[@4, @4];
    [self.layer addSublayer:border];
    
    
    //最大睡眠时间
    self.maxSleepTimeLabel = [[UILabel alloc]init];
    [self addSubview:self.maxSleepTimeLabel];
    self.maxSleepTimeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    self.maxSleepTimeLabel.textColor = [UIColor colorWithHexString:@"#21a0bf"];
    self.maxSleepTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.maxSleepTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.mas_top).offset(127-50);
        make.left.mas_equalTo(weakSelf.mas_left).offset(11);
        make.width.equalTo(@23);
        make.height.equalTo(@20);
        
    }];
    
    
    CAShapeLayer *border2 = [CAShapeLayer layer];
    border2.strokeColor = [UIColor colorWithHexString:@"#e5e4df"].CGColor;
    border2.fillColor = nil;
    UIBezierPath *pat2 = [UIBezierPath bezierPath];
    [pat2 moveToPoint:CGPointMake(34, 127-40+((243-40-(127-40))/5))];
    [pat2 addLineToPoint:CGPointMake(kSCREEN_WIDTH-34, 127-40+((243-40-(127-40))/5))];
    [pat2 moveToPoint:CGPointMake(34, 127-40+((243-40-(127-40))/5)*2)];
    [pat2 addLineToPoint:CGPointMake(kSCREEN_WIDTH-34, 127-40+((243-40-(127-40))/5)*2)];
    [pat2 moveToPoint:CGPointMake(34, 127-40+((243-40-(127-40))/5)*3)];
    [pat2 addLineToPoint:CGPointMake(kSCREEN_WIDTH-34, 127-40+((243-40-(127-40))/5)*3)];
    [pat2 moveToPoint:CGPointMake(34, 127-40+((243-40-(127-40))/5)*4)];
    [pat2 addLineToPoint:CGPointMake(kSCREEN_WIDTH-34,127-40+((243-40-(127-40))/5)*4)];
    border2.path = pat2.CGPath;
    //    border.lineWidth = 0.5;
    //    border.lineCap = @"butt";
    //    //  第一个是 线条长度   第二个是间距
    //    border.lineDashPattern = @[@4, @4];
    [self.layer addSublayer:border2];
    
    
    CAShapeLayer *borderShape = [CAShapeLayer layer];
    borderShape.strokeColor = [UIColor colorWithHexString:@"#1b86a4"].CGColor;
    borderShape.fillColor = nil;
    UIBezierPath *patBezier = [UIBezierPath bezierPath];
    [patBezier moveToPoint:CGPointMake(34, 243-40)];
    [patBezier addLineToPoint:CGPointMake(kSCREEN_WIDTH-34, 243-40)];
    borderShape.path = patBezier.CGPath;
    //  第一个是 线条长度   第二个是间距
    [self.layer addSublayer:borderShape];
    
    //周月睡眠质量视图
    self.sleepQualityView = [[UIView alloc] initWithFrame:CGRectMake(34, 127-40, kSCREEN_WIDTH-68, 168)];
    [self addSubview:self.sleepQualityView];
    
}

#pragma mark --周月，睡眠质量画图
//周月，睡眠质量画图
-(void)drawSleepViewForData:(NSArray *)dataArray withSleepDateArray:(NSArray *)dateArray withHeartRateDateArray:(NSArray *)heartRateArray withRespiratoryRateDateArray:(NSArray *)respiratoryRateArray
{
    
    [self removeFromSuperviewForView:self.sleepQualityView];
    int barWidth;
    if (dateArray.count == 7)
    {
        barWidth = 24;//周
        
    }else
    {
        barWidth = 6;//月
    }
    
    int sumTime = 0 ;
    int validDay = 0;
    int sumLightSleepTime = 0 ;
    int sumMidSleepTime = 0 ;
    int sumDeepSleepTime = 0 ;
    int sumAwakeTime = 0 ;
    int maxTime = 0;
    
    
    //X轴画图区域宽度
    float XDrawWidth = kSCREEN_WIDTH-68;
    float XScaleWidth = (XDrawWidth - barWidth*dateArray.count) / (dateArray.count-1);
    for(int i = 0 ;i < dateArray.count;i++)
    {
        SleepQualityModel *model = dataArray[i];
        int lightSleepTime = [model.lightSleepTime intValue];
        int awakeTime = [model.awakeTime intValue];
        int midSleepTime = [model.midSleepTime intValue];
        int deepSleepTime = [model.deepSleepTime intValue];
        int modelTime =  lightSleepTime + midSleepTime + deepSleepTime;
        
        if (modelTime != 0)
        {
            validDay++;
        }
        sumTime = sumTime + modelTime;
        sumAwakeTime = sumAwakeTime + awakeTime;
        sumMidSleepTime = sumMidSleepTime + midSleepTime;
        sumDeepSleepTime = sumDeepSleepTime + deepSleepTime;
        sumLightSleepTime = sumLightSleepTime +lightSleepTime;
        if (i == 0)
        {
            maxTime = modelTime;
            
        }else
        {
            if (modelTime > maxTime)
            {
                maxTime = modelTime;
            }
        }
    }
    
    
    int average = 0;
    for(int i = 0 ; i < 4 ; i++)
    {
        if (i == 0)
        {
            average = sumDeepSleepTime/validDay;
            
        }else if (i == 1)
        {
            average = sumMidSleepTime/validDay;
            
        }else if (i == 2)
        {
            average = sumLightSleepTime/validDay;
            
        }else
        {
            average = sumAwakeTime/validDay;
        }
        [self setSleepQualityTimeForType:i withAverage:(int)average];
    }
    
    maxTime = [self setMaxSleepTimeLabelValue:maxTime];
    
    [self setAverageDaySleepTime:sumTime withCount:validDay];
    
    [self setAverageHeartRateOrRespiratoryRateForType:SleepQualityValueType_AverageHeartRate withDataArray:heartRateArray];
    [self setAverageHeartRateOrRespiratoryRateForType:SleepQualityValueType_AverageRespiratoryRate withDataArray:respiratoryRateArray];
    //Y轴250刻度的每刻度像素
    double valuePx = 116.0/maxTime;
    
    for(int i = 0 ;i < dateArray.count;i++)// x轴
    {
        SleepQualityModel *model = dataArray[i];
        int lightSleepTime = [model.lightSleepTime intValue];
        int midSleepTime = [model.midSleepTime intValue];
        int deepSleepTime = [model.deepSleepTime intValue];
        //        int modelTime = lightSleepTime + midSleepTime + deepSleepTime;
        if (maxTime != 0)
        {
            double XStartPoint = (barWidth+XScaleWidth) *i;
            for(int j = 0 ; j < 3 ; j++)//y轴
            {
                double YStartPoint;
                double height;
                UILabel *label = [[UILabel alloc]init];
                if (j == 0)
                {
                    height = deepSleepTime*valuePx;//深
                    YStartPoint = 116.0 - height;
                    label.backgroundColor = [UIColor colorWithHexString:@"#1b86a3"];
                    
                }else if (j == 1)
                {
                    height = midSleepTime*valuePx;//中
                    YStartPoint = 116.0 - deepSleepTime*valuePx - height;
                    label.backgroundColor = [UIColor colorWithHexString:@"#23abcb"];
                    
                }else
                {
                    height = lightSleepTime*valuePx;//浅
                    YStartPoint = 116.0 - deepSleepTime*valuePx - midSleepTime*valuePx - height;
                    label.backgroundColor = [UIColor colorWithHexString:@"#48d8ef"];
                }
                label.frame = CGRectMake(XStartPoint, YStartPoint, barWidth, height);
                [self.sleepQualityView addSubview:label];
                
            }
        }
        
        if (dateArray.count == 7 || (i == 0 || i == 7 || i == 14  || i== 21 || i == dateArray.count-1) )
        {
            UILabel *xScaleLabel = [[UILabel alloc]init];
            if (dateArray.count == 7)
            {
                xScaleLabel.frame = CGRectMake(i*(barWidth+XScaleWidth), 123, barWidth, 10);
                xScaleLabel.textAlignment = NSTextAlignmentCenter;
                
            }else
            {
                xScaleLabel.frame = CGRectMake(i*(barWidth+XScaleWidth)-5, 123, 16, 10);
                xScaleLabel.textAlignment = NSTextAlignmentCenter;
                
            }
            xScaleLabel.text = [NSString stringWithFormat:@"%d",[[dateArray[i] substringWithRange:NSMakeRange(6, 2)] intValue]];
            xScaleLabel.font = [UIFont systemFontOfSize:11];
            xScaleLabel.textColor = [UIColor lightGrayColor];
            [self.sleepQualityView addSubview:xScaleLabel];
        }
        
    }
    
}

#pragma mark --设置周月最大睡眠时间
//设置周月最大睡眠时间
-(int)setMaxSleepTimeLabelValue:(int)maxTime
{
    int maxTimeHour = maxTime/3600;
    int maxTimeMinute = (maxTime%3600)/60;
    if (maxTimeHour > 0)
    {
        if (maxTimeMinute > 0)
        {
            self.maxSleepTimeLabel.text = [NSString stringWithFormat:@"%dh",maxTimeHour+1];
            maxTime = maxTimeHour*3600 + 3600;
            
        }else
        {
            self.maxSleepTimeLabel.text = [NSString stringWithFormat:@"%dh",maxTimeHour];
        }
        
    }else
    {
        if (maxTimeMinute > 0)
        {
            self.maxSleepTimeLabel.text = @"1h";
            maxTime = 3600;
            
        }else
        {
            self.maxSleepTimeLabel.text = @"";
            maxTime = 0;
        }
    }
    return maxTime;
}

#pragma mark --设置日均睡眠时间
//设置日均睡眠时间
-(void)setAverageDaySleepTime:(int)sumTime withCount:(NSInteger)count
{
    NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);
    NSString * hourUnit= NSLocalizedString(@"RMVC_Hour", nil);
    NSString *sumTimeHour = [NSString stringWithFormat:@"%ld",sumTime/count/3600];
    NSString *sumTimeMinute = [NSString stringWithFormat:@"%ld",((sumTime/count)%3600)/60];
    NSMutableAttributedString *sumTimeAttributedStr;
    if (sumTime == 0) {
        sumTimeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0min"]];
        [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                     value:[UIFont boldSystemFontOfSize:22.0]
                                     range:NSMakeRange(0, 1)];
        [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:16.0]
                                     range:NSMakeRange(1, 3)];
    }else{
        
        if ([sumTimeHour intValue] == 0) {
            sumTimeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",sumTimeMinute,minUnit]];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:22.0]
                                         range:NSMakeRange(0, sumTimeMinute.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont systemFontOfSize:16.0]
                                         range:NSMakeRange(sumTimeMinute.length, minUnit.length)];
        }else
        {
            
            sumTimeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@%@%@",sumTimeHour,hourUnit,sumTimeMinute,minUnit]];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:22.0]
                                         range:NSMakeRange(0, sumTimeHour.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont systemFontOfSize:16.0]
                                         range:NSMakeRange(sumTimeHour.length, hourUnit.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont boldSystemFontOfSize:22.0]
                                         range:NSMakeRange(sumTimeHour.length+1, sumTimeMinute.length)];
            [sumTimeAttributedStr addAttribute:NSFontAttributeName
                                         value:[UIFont systemFontOfSize:16.0]
                                         range:NSMakeRange(sumTimeHour.length+1+sumTimeMinute.length, minUnit.length)];
        }
    }
    self.valueLabel.attributedText = sumTimeAttributedStr;
}

#pragma mark --设置日均深、中、浅、醒时间时间
//设置日均深、中、浅、醒时间时间
-(void)setSleepQualityTimeForType:(SleepQualityValueType)type withAverage:(int)average
{
    
    NSString * minUnit = NSLocalizedString(@"RMVC_Minute", nil);
    NSString * hourUnit = NSLocalizedString(@"RMVC_Hour", nil);
    
    UILabel *timeLabel = (UILabel *)[self viewWithTag:200+type];
    NSMutableAttributedString *timeAttributedStr;
    NSString *timeHour = [NSString stringWithFormat:@"%d",average/3600];
    NSString *timeMinute = [NSString stringWithFormat:@"%d",(average%3600)/60];
    //        NSString *timeSecond = [NSString stringWithFormat:@"%d",time%60];
    
    if ([timeHour intValue] == 0 && [timeMinute intValue]== 0)
    {
        NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);
        timeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",minUnit]];
        [timeAttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont boldSystemFontOfSize:13.0]
                                  range:NSMakeRange(0, 1)];
        [timeAttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:9.0]
                                  range:NSMakeRange(1, minUnit.length)];
    }else
    {
        if ([timeHour intValue] == 0)
        {
            timeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",timeMinute,minUnit]];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont boldSystemFontOfSize:13.0]
                                      range:NSMakeRange(0, timeMinute.length)];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:9.0]
                                      range:NSMakeRange(timeMinute.length, minUnit.length)];
        }else
        {
            timeAttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@%@%@",timeHour,hourUnit,timeMinute,minUnit]];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont boldSystemFontOfSize:13.0]
                                      range:NSMakeRange(0, timeHour.length)];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:9.0]
                                      range:NSMakeRange(timeHour.length, hourUnit.length)];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont boldSystemFontOfSize:13.0]
                                      range:NSMakeRange(timeHour.length+1, timeMinute.length)];
            [timeAttributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:9.0]
                                      range:NSMakeRange(timeHour.length+1+timeMinute.length, minUnit.length)];
        }
    }
    timeLabel.attributedText = timeAttributedStr;
}

#pragma mark --计算平均周月平均心率，呼吸率
//计算平均周月平均心率，呼吸率
-(NSArray *)computeAverageHeartRateOrRespiratoryRateForDataArray:(NSArray *)dataArray
{
    NSMutableArray *dayAverageArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < dataArray.count ; i++)
    {
        int sum = 0 ;
        int validCount = 0 ;
        int average = 0 ;
        NSArray *array = dataArray[i];
        for(int j = 0 ; j < array.count; j ++)
        {
            int num = [array[j] intValue];
            if (num != 0 && num != 240 && num != 255)
            {
                sum = sum + num;
                validCount++;
            }
            
        }
        average = (int)roundf(sum/validCount);
        [dayAverageArray addObject:[NSNumber numberWithInt:average]];
    }
    return dayAverageArray;
}

#pragma mark --计算平均周月离床次数
//计算平均周月离床次数
-(NSArray *)computeAverageBedAwayForDataArray:(NSArray *)dataArray
{
    NSMutableArray *dayBedAwayAverageArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < dataArray.count ; i ++)
    {
        int validCount = 0 ;
        NSArray *array = dataArray[i];
        //1 躺下床
        //3 离床
        BOOL isBedAway = NO;
        for(int j = 0 ; j < array.count; j++)
        {
            int num = [array[j] intValue];
            if(j == 0)
            {
                if(num == 1)
                {
                    isBedAway = NO;
                    
                }else
                {
                    isBedAway = YES;
                }
                continue;
            }
            if (num != -65536)
            {
                if(isBedAway)
                {
                    if(j%2 != 0)
                    {
                        validCount++;
                    }
                    
                }else
                {
                    if(j%2 == 0)
                    {
                        validCount++;
                    }
                }
            }
        }
        [dayBedAwayAverageArray addObject:[NSNumber numberWithInt:validCount]];
    }
    return dayBedAwayAverageArray;
}

#pragma mark --设置周月平均心率，呼吸率
//设置周月平均心率，呼吸率
-(void)setAverageHeartRateOrRespiratoryRateForType:(SleepQualityValueType)type withDataArray:(NSArray *)dataArray
{
    NSArray *averageValueArray = [self computeAverageHeartRateOrRespiratoryRateForDataArray:dataArray];
    int sum = 0 ;
    int validCount = 0 ;
    for(int i = 0 ; i < averageValueArray.count;i++)
    {
        int value = [averageValueArray[i] intValue];
        sum = sum + value;
        if (value != 0)
        {
            validCount++;
        }
    }
    NSString *averageValue = [NSString stringWithFormat:@"%d",(int)roundf(sum/validCount)];
    UILabel *label = (UILabel *)[self viewWithTag:200+type];
    NSMutableAttributedString *attributedStr;
    NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);
    attributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",averageValue,unit]];
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:13.0]
                          range:NSMakeRange(0, averageValue.length)];
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:9.0]
                          range:NSMakeRange(averageValue.length, unit.length)];
    label.attributedText = attributedStr;
    
}

#pragma mark --周月，通用UI
//周月，通用UI
-(void)setUniversalWeekMonthViewUIForDrawType:(SleepDrawWeekMonthViewType)type
{
        WS(weakSelf);
//    UIView *backgroundView = [[UIView alloc]init];
//    backgroundView.backgroundColor = [UIColor whiteColor];
//    backgroundView.alpha = kAlpha;
//    backgroundView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, 220);
//    [self addSubview:backgroundView];
    
    //image
    UIImageView *iconIV = [[UIImageView alloc]init];
    [self addSubview:iconIV];
    [iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.mas_top).offset(20);
        make.left.mas_equalTo(weakSelf.mas_centerX).offset(-15-7-30);
        make.width.equalTo(@15);
        make.height.equalTo(@15);
        
    }];
    
    //lab
    UILabel *titleL = [[UILabel alloc]init];
    [self addSubview:titleL];
    titleL.font = [UIFont systemFontOfSize:15];
    titleL.textColor = [UIColor colorWithHexString:@"#1b86a4"];
    titleL.textAlignment = NSTextAlignmentLeft;
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconIV);
        make.left.mas_equalTo(iconIV.mas_right).offset(7);
        make.width.equalTo(@100);
        make.height.equalTo(@28);
    }];
    
    //image
    UIImageView *imagev = [[UIImageView alloc]init];
    [self addSubview:imagev];
    [imagev mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.mas_top).offset(0);
        make.width.equalTo(@375);
        make.height.equalTo(@232);
    }];
    
    NSString *unitStr;
    if (type == SleepDrawWeekMonthViewType_AverageHeartRate)//平均心率
    {
        imagev.image = [UIImage imageNamed:@"realtime_bg_heartrate"];
        iconIV.image = [UIImage imageNamed:@"realtime_icon_heartrate"];
        titleL.text = @"heart rate";
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        self.yScaleArray = @[@"150",@"120",@"80",@"40"];
        
    }else if (type == SleepDrawWeekMonthViewType_AverageRespiratoryRate)//平均呼吸率
    {
        imagev.image = [UIImage imageNamed:@"realtime_bg_breath"];
        iconIV.image = [UIImage imageNamed:@"realtime_icon_breath"];
        titleL.text = @"breath rate";
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        self.yScaleArray = @[@"40",@"30",@"20",@"10"];
        
    }else if (type == SleepDrawWeekMonthViewType_FrequencyOfBedAway)//离床次数
    {
        imagev.image = [UIImage imageNamed:@"realtime_bg_heartrate"];
        iconIV.image = [UIImage imageNamed:@"report_icon_turn"];
        titleL.text = @"turn/move";
        self.yScaleArray = @[@"4",@"3",@"2",@"1"];
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);
        
    }else{

    }
   
    //
    if (type == SleepDrawWeekMonthViewType_AverageHeartRate ||
        type == SleepDrawWeekMonthViewType_AverageRespiratoryRate ||
        type == SleepDrawWeekMonthViewType_FrequencyOfBedAway)
    {
        self.valueLabel = [[UILabel alloc]init];
        [self addSubview:self.valueLabel];
        self.valueLabel.textColor = [UIColor colorWithHexString:@"#1b86a4"];
        self.valueLabel.textAlignment = NSTextAlignmentRight;
        
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"0%@",unitStr]];
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont boldSystemFontOfSize:15.0]
                              range:NSMakeRange(0, 1)];
        [AttributedStr addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:10.0]
                              range:NSMakeRange(1,unitStr.length)];
        self.valueLabel.attributedText = AttributedStr;
        [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(@100);
            make.top.mas_equalTo(iconIV.mas_bottom).offset(30);
            make.right.mas_equalTo(imagev.mas_right).offset(-48);
            make.height.equalTo(@15);
            
        }];
        
    }
    
    //画虚线
//    CAShapeLayer *border = [CAShapeLayer layer];
//    border.strokeColor = [UIColor whiteColor].CGColor;
//    border.fillColor = nil;
//    UIBezierPath *pat = [UIBezierPath bezierPath];
//    [pat moveToPoint:CGPointMake(34, 183)];
//    [pat addLineToPoint:CGPointMake(34, 45)];
//    [pat moveToPoint:CGPointMake(34, 183)];
//    [pat addLineToPoint:CGPointMake(kSCREEN_WIDTH-kMargin, 183)];
//    border.path = pat.CGPath;
//    border.lineWidth = 0.5;
//    border.lineCap = @"butt";
//    //  第一个是 线条长度   第二个是间距
//    border.lineDashPattern = @[@4, @4];
//    [self.layer addSublayer:border];
    //    if (type != SleepDrawWeekMonthViewType_FrequencyOfBedAway) {
    
    for (int i = 0; i < self.yScaleArray.count; i++)
    {
        UILabel *yTitleL = [[UILabel alloc]init];
//        yTitleL.layer.borderWidth = 1;
        [self addSubview:yTitleL];
        yTitleL.textColor = [UIColor blackColor];
        yTitleL.font = [UIFont systemFontOfSize:11];
        yTitleL.textAlignment = NSTextAlignmentRight;
        CGFloat height = 11;
        CGFloat marginTop = 85-5.5;
        CGFloat padding;
        
        //平均心率 和 //离床次数
        if (type == SleepDrawWeekMonthViewType_AverageRespiratoryRate || type == SleepDrawWeekMonthViewType_FrequencyOfBedAway)
        {
            padding = 25;
            
        }else
        {
            padding = 25;
        }
        yTitleL.text = self.yScaleArray[i];
        yTitleL.frame = CGRectMake(43, marginTop+padding*i+i*1.2, 28, height);
    }
    
    CAShapeLayer *borderShape = [CAShapeLayer layer];
    borderShape.strokeColor = [UIColor colorWithHexString:@"#1b86a4"].CGColor;
    borderShape.fillColor = nil;
    UIBezierPath *patBezier = [UIBezierPath bezierPath];
    
    if(type == SleepDrawWeekMonthViewType_AverageRespiratoryRate)//平均心率
    {
        [patBezier moveToPoint:CGPointMake((kSCREEN_WIDTH-375)/2+40+14-1, 85+5.5+100-2+4.5)];
        [patBezier addLineToPoint:CGPointMake((kSCREEN_WIDTH-375)/2+40+14+274-2-1, 85+5.5+100-2+4.5)];
        
    }else
    {
        [patBezier moveToPoint:CGPointMake((kSCREEN_WIDTH-375)/2+40+14, 85+5.5+100-2+4.5)];
        [patBezier addLineToPoint:CGPointMake((kSCREEN_WIDTH-375)/2+40+14+274-2, 85+5.5+100-2+4.5)];
    }
    
    borderShape.path = patBezier.CGPath;
    //  第一个是 线条长度   第二个是间距
    [self.layer addSublayer:borderShape];
    
    //    }
    self.universalWeekMonthView = [[UIView alloc] initWithFrame:CGRectMake((kSCREEN_WIDTH-375)/2, 85+5.5, 375, 130)];
//        self.universalWeekMonthView.backgroundColor = [UIColor yellowColor];
//        self.universalWeekMonthView.alpha = 0.2;
    [self addSubview:self.universalWeekMonthView];
    
}

#pragma mark --周月，通用柱状画图
//周月，通用柱状画图
-(void)drawUniversalWeekMonthViewDrawType:(SleepDrawWeekMonthViewType)type WithData:(NSArray *)dataArray WithDateArray:(NSArray *)dateArray
{
    //    WS(weakSelf);
    [self removeFromSuperviewForView:self.universalWeekMonthView];
    NSArray *averageValueArray;
    NSString *averageValue;
    
    if (type == SleepDrawWeekMonthViewType_AverageHeartRate || type == SleepDrawWeekMonthViewType_AverageRespiratoryRate)
    {
        //计算平均周月平均心率，呼吸率
        averageValueArray  = [self computeAverageHeartRateOrRespiratoryRateForDataArray:dataArray];
        
        int sum = 0;
        int validCount = 0;
        for(int i = 0 ; i < averageValueArray.count; i++)
        {
            int value = [averageValueArray[i] intValue];
            if (value != 0)
            {
                sum = sum + value;
                validCount++;
            }
        }
        averageValue = [NSString stringWithFormat:@"%d",(int)roundf(sum/validCount)];
        
    }else
    {
        //计算平均周月离床次数
        averageValueArray  = [self computeAverageBedAwayForDataArray:dataArray];
        int sum = 0;
        int validCount = 0;
        for(int i = 0 ; i < averageValueArray.count;i++)
        {
            int value = [averageValueArray[i] intValue];
            if (value != 0)
            {
                sum = sum + value;
                validCount++;
            }
        }
        averageValue = [NSString stringWithFormat:@"%d",(int)roundf(sum/validCount)];
    }
    
    NSString *unitStr;
    if (type == SleepDrawWeekMonthViewType_AverageHeartRate || type == SleepDrawWeekMonthViewType_AverageRespiratoryRate)
    {
        
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);// 次/分
        
        
    }else if (type == SleepDrawWeekMonthViewType_FrequencyOfBedAway)
    {
        
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);//次
        
    }else
    {
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);//次
    }
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",averageValue,unitStr]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:21.0]
                          range:NSMakeRange(0, averageValue.length)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:12.0]
                          range:NSMakeRange(averageValue.length,unitStr.length)];
    self.valueLabel.attributedText = AttributedStr;
    
    int barWidth;
    if (dateArray.count == 7)
    {
        barWidth = 24;
        
    }else
    {
        barWidth = 6;
    }
    
    //X轴画图区域宽度
    float XDrawWidth = 276;
    //X轴刻度
    float XScaleWidth = XDrawWidth / (dateArray.count-1);
    
        //每分钟的像素
//        float XPointScaleWidth = (XDrawWidth - barWidth*dateArray.count) / (dateArray.count-1);

        int yMax;
        if (type == SleepDrawWeekMonthViewType_AverageHeartRate)
        {
            yMax = 150;
            
        }else if (type == SleepDrawWeekMonthViewType_AverageRespiratoryRate)
        {
            yMax = 40;
            
        }else if (type == SleepDrawWeekMonthViewType_FrequencyOfBedAway)//离床次数
        {
            yMax = 20;
            
        }else
        {
            yMax = 150;
        }
        //Y轴250刻度的每刻度像素
        double valuePx = 138.0/yMax;

    for (int i = 0; i < dateArray.count; i ++)
    {
        if (dateArray.count == 7 || (i == 0 || i == 7 || i == 14  || i== 21 || i == dateArray.count-1) )
        {
            UILabel *xScaleLabel;
            if (i==0)
            {
                xScaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40+14, 110-2, 16, 10)];
                
            }else if (i == dateArray.count-1)
            {
                xScaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40+14+274-18, 110-2, 16, 10)];
                
            }else
            {
                xScaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40+14+i*XScaleWidth-8, 110-2, 16, 10)];
            }
            
            //测试
//            xScaleLabel.layer.borderWidth = 1;
//            xScaleLabel.layer.borderColor = [UIColor blackColor].CGColor;
            //
            xScaleLabel.textAlignment = NSTextAlignmentCenter;
            xScaleLabel.text = [NSString stringWithFormat:@"%d",[[dateArray[i] substringWithRange:NSMakeRange(6, 2)] intValue]];
            xScaleLabel.font = [UIFont systemFontOfSize:12];
            xScaleLabel.textColor = [UIColor blackColor];
            [self.universalWeekMonthView addSubview:xScaleLabel];
            
        }
    }
    
    for (int i = 0; i < dateArray.count; i++)
    {
        double YPoint = (yMax-[averageValueArray[i] doubleValue]) *valuePx;
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor whiteColor];
        [self.universalWeekMonthView addSubview:label];
        
        if (i==0)
        {
            label.frame = CGRectMake(20-barWidth/2, YPoint, barWidth, 138-YPoint);
            
        }else if (i == dateArray.count-1)
        {
            label.frame = CGRectMake(XDrawWidth+20-barWidth/2, YPoint, barWidth, 138-YPoint);
            
        }else
        {
            label.frame = CGRectMake(20+i*XScaleWidth-barWidth/2, YPoint, barWidth, 138-YPoint);
        }
        NSLog(@"YPoint=%f",YPoint);
    }
    
}

#pragma mark --周月，通用折线图画图
//周月，通用折线图画图
-(void)drawLineGraphUniversalWeekMonthViewDrawType:(SleepDrawWeekMonthViewType)type WithData:(NSArray *)dataArray WithDateArray:(NSArray *)dateArray
{
    //    WS(weakSelf);
    [self removeFromSuperviewForView:self.universalWeekMonthView];
    NSArray *averageValueArray;
    NSString *averageValue;
    if (type == SleepDrawWeekMonthViewType_AverageHeartRate || type == SleepDrawWeekMonthViewType_AverageRespiratoryRate) {
        averageValueArray  = [self computeAverageHeartRateOrRespiratoryRateForDataArray:dataArray];
        int sum = 0 ;
        int validCount = 0 ;
        for(int i = 0 ; i < averageValueArray.count;i++)
        {
            int value = [averageValueArray[i] intValue];
            if (value != 0)
            {
                sum = sum + value;
                validCount++;
            }
        }
        averageValue = [NSString stringWithFormat:@"%d",sum/validCount];
        
    }else
    {
        averageValueArray  = [self computeAverageBedAwayForDataArray:dataArray];
        int sum = 0;
        int validCount = 0 ;
        for(int i = 0 ; i < averageValueArray.count;i++){
            int value = [averageValueArray[i] intValue];
            if (value != 0)
            {
                sum = sum + value;
                validCount++;
            }
        }
        averageValue = [NSString stringWithFormat:@"%d",sum/validCount];
     }
    
    NSString *unitStr;
    if (type == SleepDrawWeekMonthViewType_AverageHeartRate || type == SleepDrawWeekMonthViewType_AverageRespiratoryRate)
    {
        unitStr = NSLocalizedString(@"SMVC_HeartRateUnit", nil);
        
    }else if (type == SleepDrawWeekMonthViewType_FrequencyOfBedAway)
    {
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);
        
    }else
    {
        unitStr = NSLocalizedString(@"RMVC_TurnOvertime", nil);
    }
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",averageValue,unitStr]];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont boldSystemFontOfSize:21.0]
                          range:NSMakeRange(0, averageValue.length)];
    [AttributedStr addAttribute:NSFontAttributeName
                          value:[UIFont systemFontOfSize:12.0]
                          range:NSMakeRange(averageValue.length,unitStr.length)];
    self.valueLabel.attributedText = AttributedStr;
    
    //X轴画图区域宽度
    float XDrawWidth = kSCREEN_WIDTH-49;
    float XScaleWidth;
    XScaleWidth = XDrawWidth/(dateArray.count-1);
    
    //X轴刻度
    for (int i = 0; i < dateArray.count ; i ++)
    {
        if (dateArray.count == 7 || (i == 0 || i == 7 || i == 14  || i== 21 || i == dateArray.count-1) ) {
            UILabel *xScaleLabel = [[UILabel alloc]init];
            if (i==0)
            {
                xScaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 143, 16, 10)];
                xScaleLabel.textAlignment = NSTextAlignmentLeft;
                
            }else if (i == dateArray.count-1)
            {
                xScaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(XDrawWidth-16, 143, 16, 10)];
                xScaleLabel.textAlignment = NSTextAlignmentRight;
                
            }else
            {
                xScaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*XScaleWidth-8, 143, 16, 10)];
                xScaleLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            xScaleLabel.text = [NSString stringWithFormat:@"%d",[[dateArray[i] substringWithRange:NSMakeRange(6, 2)] intValue]];
            xScaleLabel.font = [UIFont systemFontOfSize:12];
            xScaleLabel.textColor = [UIColor whiteColor];
            [self.universalWeekMonthView addSubview:xScaleLabel];
            
        }
    }
    
    //每分钟的像素
    double minutePx = XScaleWidth;
    int yMax;
    if (type == SleepDrawWeekMonthViewType_AverageHeartRate)
    {
        yMax = 150;
        
    }else if (type == SleepDrawWeekMonthViewType_AverageRespiratoryRate)
    {
        yMax = 40;
        
    }else if (type == SleepDrawWeekMonthViewType_FrequencyOfBedAway)
    {
        yMax = 20;
        
    }else
    {
        yMax = 150;
    }
    
    //Y轴250刻度的每刻度像素
    double valuePx = 138.0/yMax;
    //折线图
    UIBezierPath *line = [UIBezierPath bezierPath];
    //        NSMutableArray *pointArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < averageValueArray.count ; i ++)
    {
        double XPoint = minutePx *i;
        double YPoint = (yMax-[averageValueArray[i] doubleValue]) *valuePx;
        if (i == 0)
        {
            if([averageValueArray[i] doubleValue] == 0)
            {
                [line moveToPoint:CGPointMake(XPoint, YPoint)];
                
            }else
            {
                [line moveToPoint:CGPointMake(XPoint+8, YPoint)];
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(XPoint+5, YPoint-3, 6, 6)];
                label.layer.cornerRadius = 3;
                label.layer.borderWidth = 1;
                label.layer.borderColor = [UIColor whiteColor].CGColor;
                label.backgroundColor = [UIColor whiteColor];
                label.clipsToBounds = YES;
                [self.universalWeekMonthView addSubview:label];
                
            }
        }else{
            
            if (i == dataArray.count-1) {
                if([averageValueArray[i] doubleValue] == 0){
                    
                    [line addLineToPoint:CGPointMake(XDrawWidth,YPoint)];
                    
                }else
                {
                    [line addLineToPoint:CGPointMake(XDrawWidth-8,YPoint)];
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(XPoint-11, YPoint-3, 6, 6)];
                    label.layer.cornerRadius = 3;
                    label.layer.borderWidth = 1;
                    label.layer.borderColor = [UIColor whiteColor].CGColor;
                    label.backgroundColor = [UIColor whiteColor];
                    label.clipsToBounds = YES;
                    [self.universalWeekMonthView addSubview:label];
                    
                }
                
            }else
            {
                [line addLineToPoint:CGPointMake(XPoint,YPoint)];
                if([averageValueArray[i] doubleValue] != 0)
                {
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(XPoint-3, YPoint-3, 6, 6)];
                    label.layer.cornerRadius = 3;
                    label.layer.borderWidth = 1;
                    label.layer.borderColor = [UIColor whiteColor].CGColor;
                    label.backgroundColor = [UIColor whiteColor];
                    label.clipsToBounds = YES;
                    [self.universalWeekMonthView addSubview:label];
                }
            }
        }
    }
    //添加到画布
    [line stroke];
    //添加CAShapeLayer
    CAShapeLayer *shapeLine = [[CAShapeLayer alloc]init];
    shapeLine.lineJoin = kCALineJoinBevel;
    //设置颜色
    shapeLine.fillColor = [UIColor clearColor].CGColor;
    shapeLine.strokeColor = [UIColor whiteColor].CGColor;
    //设置宽度
    shapeLine.lineWidth = 1.0;
    //把CAShapeLayer添加到当前视图CAShapeLayer
    [self.universalWeekMonthView.layer addSublayer:shapeLine];
    //把Polyline的路径赋予shapeLine
    shapeLine.path = line.CGPath;
    
}

#pragma mark - 心率采样值实时图
//心率采样值实时图
-(void)drawSampleView
{
    self.drawViewDataArray = [[NSMutableArray alloc]init];
    self.bezierPath = [UIBezierPath bezierPath];
    //总高150
    self.lastPoint = CGPointMake(10000, 105/2);
    [self.bezierPath moveToPoint:self.lastPoint];
    self.shapeLayer = [[CAShapeLayer alloc]init];
    if (!self.isRR)
    {
        self.shapeLayer.strokeColor = [UIColor colorWithHexString:@"#CEAC87"].CGColor;
//        self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
        
    }else
    {
        self.shapeLayer.strokeColor = [UIColor colorWithHexString:@"#1B86A4"].CGColor;
//        self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    }
    self.shapeLayer.lineWidth = 2.0;
    self.shapeLayer.fillColor = nil;
    [self.layer addSublayer:self.shapeLayer];
    self.shapeLayer.path = self.bezierPath.CGPath;
    
}

//追加数据
-(void)addData:(NSArray *)array
{
//    NSLog(@"追加数据-> array=%@",array);
    
    CGFloat height = 105.0; //视图高度
    CGFloat space = 0.7;  //点间隔
    CGFloat scaledDown;
    
    //例如值范围在0-2048.0
    if (!self.isRR)
    {
        scaledDown = 100.0/height;
        
    }else
    {
        scaledDown = 2048.0/height;
    }
    //积累数据
//    [self.drawViewDataArray addObjectsFromArray:array];
//    NSLog(@"xxxcount=%ld, self.drawViewDataArray=%@", self.drawViewDataArray.count,self.drawViewDataArray);
    
    for(int i = 0 ; i < array.count ; i ++)
    {
        CGFloat point;
        if (!self.isRR)
        {
            //xxx [array[i] intValue]=1024,array[i]=1024
            point  = ([array[i] intValue]-974) / scaledDown;
            
        }else
        {
            point  = ([array[i] intValue]-0) / scaledDown;
        }
        
        if (point >= 105)
        {
            point = 104;
            
        }
        
        if (point < 0 )
        {
            point = 0;
        }
        
        if (point > 104)
        {
//            NSLog(@"%f,%d",point,[array[i] intValue]);
        }
        
        if (self.lastPoint.x == 10000)
        {
            [self.bezierPath moveToPoint:CGPointMake(0, height-point)];
            self.lastPoint = CGPointMake(0, height-point);
        }
        
        if (self.lastPoint.x +space > 272)
        {
            [self.bezierPath removeAllPoints];
            [self.bezierPath moveToPoint:CGPointMake(0, height-point)];
            self.lastPoint = CGPointMake(0, height-point);
            
        }else
        {
            [self.bezierPath addLineToPoint:CGPointMake(self.lastPoint.x +space, height-point)];
            self.lastPoint = CGPointMake(self.lastPoint.x +space, height-point);
        }
        self.shapeLayer.path = self.bezierPath.CGPath;
        //NSLog(@"... shapeLayer.path=%@,bezierPath.CGPath=%@",self.shapeLayer.path,self.bezierPath.CGPath);
        
    }
    
}


#pragma mark --报告数据 （三个波形图）
//回复读取睡眠质量数据
- (void)reportAddData:(NSArray*)array
{
    NSLog(@"drawview 回复睡眠质量数据 array=%@",array);
    
    self.reortDataArray = [[NSMutableArray alloc]init];
    self.reportBezierPath = [UIBezierPath bezierPath];
    //总高150
    self.reportPoint  = CGPointMake(10000, 105/2);
    [self.reportBezierPath moveToPoint:self.reportPoint];
    self.reportShapeLayer = [[CAShapeLayer alloc]init];
    if (!self.isRR)
    {
        self.shapeLayer.strokeColor = [UIColor colorWithHexString:@"#CEAC87"].CGColor;
        self.reportShapeLayer.strokeColor = [UIColor redColor].CGColor;
        
    }else
    {
        self.reportShapeLayer.strokeColor = [UIColor colorWithHexString:@"#1B86A4"].CGColor;
        self.reportShapeLayer.strokeColor = [UIColor blueColor].CGColor;
    }
    self.reportShapeLayer.lineWidth = 2.0;
    self.reportShapeLayer.fillColor = nil;
    [self.layer addSublayer:self.reportShapeLayer];
    self.reportShapeLayer.path = self.reportBezierPath.CGPath;
}

//回复读取呼吸心率数据
- (void)reportBrHrData:(NSArray *)array
{
    NSLog(@"drawview array=%@",array);
    
    NSLog(@"array=%@,self.drawViewDataArray=%@",array,self.drawViewDataArray);
    
    CGFloat height = 105.0; //视图高度
    CGFloat space = 0.7;  //点间隔
    CGFloat scaledDown;
    
    //例如值范围在0-2048.0
    if (!self.isRR)
    {
        scaledDown = 100.0/height;
        
    }else
    {
        scaledDown = 2048.0/height;
    }
    
    for(int i = 0 ; i < array.count ; i ++)
    {
        CGFloat point;
        if (!self.isRR)
        {
            //xxx [array[i] intValue]=1024,array[i]=1024
            point  = ([array[i] intValue]-974) / scaledDown;
            
        }else
        {
            point  = ([array[i] intValue]-0) / scaledDown;
        }
        
        if (point >= 105)
        {
            point = 104;
        }
        
        if (point < 0 )
        {
            point = 0;
        }
        
        if (point > 104)
        {
            //NSLog(@"%f,%d",point,[array[i] intValue]);
        }
        
        if (self.lastPoint.x == 10000)
        {
            [self.bezierPath moveToPoint:CGPointMake(0, height-point)];
            self.lastPoint = CGPointMake(0, height-point);
        }
        
        if (self.lastPoint.x +space > 272)
        {
            [self.bezierPath removeAllPoints];
            [self.bezierPath moveToPoint:CGPointMake(0, height-point)];
            self.lastPoint = CGPointMake(0, height-point);
            
        }else
        {
            [self.bezierPath addLineToPoint:CGPointMake(self.lastPoint.x +space, height-point)];
            self.lastPoint = CGPointMake(self.lastPoint.x +space, height-point);
        }
        self.shapeLayer.path = self.bezierPath.CGPath;
        //NSLog(@"... shapeLayer.path=%@,bezierPath.CGPath=%@",self.shapeLayer.path,self.bezierPath.CGPath);
    }
    
}

#pragma mark --report 假数据
//报告 (假数据)
- (void)drawReportLine
{
    //eg 曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(65, 76)];//起始点
    //结束点、两个控制点
    [path addCurveToPoint:CGPointMake(330, 76) controlPoint1:CGPointMake(125, 80) controlPoint2:CGPointMake(185, 160)];
    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    animation.duration = 5;
//    animation.fromValue = @(0);
//    animation.toValue = @(1);
//    animation.repeatCount = 100;
    
    CAShapeLayer *layer3 = [CAShapeLayer layer];
    layer3.path = path.CGPath;
    layer3.lineWidth = 2.0;
    layer3.backgroundColor = [UIColor clearColor].CGColor;
    layer3.strokeColor = [UIColor blackColor].CGColor;
    layer3.fillColor = [UIColor clearColor].CGColor;
    //[layer3 addAnimation:animation forKey:@"strokeEndAnimation"];
    [self.layer addSublayer:layer3];
    
}

//心率波形图 (假数据)
- (void)drawHeartRateLine
{
    //eg 曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(65, 86)];//起始点
    //结束点、两个控制点
    [path addCurveToPoint:CGPointMake(280, 86) controlPoint1:CGPointMake(125, 200) controlPoint2:CGPointMake(185, 260)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 5;
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.repeatCount = 100;
    
    CAShapeLayer *layer3 = [CAShapeLayer layer];
    layer3.path = path.CGPath;
    layer3.lineWidth = 2.0;
    layer3.backgroundColor = [UIColor clearColor].CGColor;
    layer3.strokeColor = [UIColor blackColor].CGColor;
    layer3.fillColor = [UIColor clearColor].CGColor;
    [layer3 addAnimation:animation forKey:@"strokeEndAnimation"];
    [self.layer addSublayer:layer3];

}

//呼吸波形图 (假数据)
- (void)drawBreatheLine
{
    //eg 曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(65, 96)];//起始点
    //结束点、两个控制点
    [path addCurveToPoint:CGPointMake(260, 96) controlPoint1:CGPointMake(125, 200) controlPoint2:CGPointMake(185, 260)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 5;
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.repeatCount = 100;
    
    CAShapeLayer *layer3 = [CAShapeLayer layer];
    layer3.path = path.CGPath;
    layer3.lineWidth = 2.0;
    layer3.backgroundColor = [UIColor clearColor].CGColor;
    layer3.strokeColor = [UIColor blackColor].CGColor;
    layer3.fillColor = [UIColor clearColor].CGColor;
    [layer3 addAnimation:animation forKey:@"strokeEndAnimation"];
    [self.layer addSublayer:layer3];
    
}


@end
