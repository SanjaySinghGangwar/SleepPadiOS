//
//  XYWProgressCellView.m
//  SleepBand
//
//  Created by admin on 2019/6/4.
//  Copyright © 2019 admin. All rights reserved.
//

#import "XYWProgressCellView.h"

@interface XYWProgressCellView ()

@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * titleLab;
@property (nonatomic, strong) UIView * progressView;
@property (nonatomic, strong) UIView * progressBackView;
@property (nonatomic, strong) UILabel * timeLab;

@end

@implementation XYWProgressCellView

- (instancetype)initWithIconStr:(NSString*)iconStr
                          title:(NSString*)title
                     percentage:(CGFloat)percentage
                           time:(NSString*)time
                          index:(NSInteger)index{
    
    if (self = [super init]) {
        // 设置属性值
        self.backgroundColor = [UIColor clearColor];
        self.iconStr = iconStr;
        self.title = title;
        self.percentage = percentage;
        self.time = time;
        self.index = index;
        
        // 创建临时变量
        //...
        
        UIImageView *iconView = [[UIImageView alloc]init];
        iconView.image = [UIImage imageNamed:self.iconStr];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *titleLab = [[UILabel alloc]init];
        [self addSubview:titleLab];
        titleLab.font = [UIFont systemFontOfSize:13];
        titleLab.textColor = [UIColor colorWithHexString:@"#b1aca8"];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = self.title;
        self.titleLab = titleLab;
        
        UIView *progressBackView = [[UIView alloc]init];
        [self addSubview:progressBackView];
        progressBackView.backgroundColor = [UIColor  colorWithHexString:@"#f1f1f1"];
        progressBackView.layer.cornerRadius = 8;
        self.progressBackView = progressBackView;
        
        UIView *progressView = [[UIView alloc]init];
        [self addSubview:progressView];
        progressView.backgroundColor = [UIColor  colorWithHexString:@"#94AEBD"];
        progressView.layer.cornerRadius = 8;
        self.progressView = progressView;
        
        UILabel *timeLab = [[UILabel alloc]init];
        [self addSubview:timeLab];
        timeLab.textColor = [UIColor  colorWithHexString:@"#b1aca8"];
        timeLab.backgroundColor = [UIColor clearColor];
        timeLab.textAlignment = NSTextAlignmentCenter;
        timeLab.font = [UIFont systemFontOfSize:18.0];
//        boldSystemFontOfSize
        timeLab.text = self.time;
        //日进度条
        NSMutableAttributedString *AttributedStr;
        if (self.index == 4 || self.index == 5)
        {
            NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);//次/分
            NSString * timeString = [NSString stringWithFormat:@"%@%@",self.time,unit];
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(timeString.length - unit.length, unit.length)];

        }else
        {
            
            int minNum = [self.time intValue];
            int h = 0;
            int min = 0;
            if (minNum >0) {
                h = floor(minNum / 60);
                min = minNum % 60;
            }
            
            NSString * hUnit= NSLocalizedString(@"RMVC_Hour", nil);//h
            NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);//min
            
            NSString * timeString = [NSString stringWithFormat:@"%02d%@%02d%@",h,hUnit,min,minUnit];
            
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(timeString.length-minUnit.length, minUnit.length)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(timeString.length-minUnit.length-2-hUnit.length, hUnit.length)];

        }
        timeLab.attributedText = AttributedStr;
        self.timeLab = timeLab;
        
    }
    return self;
}

- (void)setTime:(NSString *)time{
    if (_time != time) {
        _time = time;
        
        //日进度条
        NSMutableAttributedString *AttributedStr;
        
        if (_index == 4 || _index == 5){
            NSString * unit = NSLocalizedString(@"SMVC_HeartRateUnit", nil);//次/分
            NSString * timeString = [NSString stringWithFormat:@"%@%@",self.time,unit];
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(timeString.length - unit.length, unit.length)];
        }else{
            int minNum = [self.time intValue];
            int h = 0;
            int min = 0;
            if (minNum >0) {
                h = floor(minNum / 60);
                min = minNum % 60;
            }
            
            NSString * hUnit= NSLocalizedString(@"RMVC_Hour", nil);//h
            NSString * minUnit= NSLocalizedString(@"RMVC_Minute", nil);//min
            
            NSString * timeString = [NSString stringWithFormat:@"%02d%@%02d%@",h,hUnit,min,minUnit];
            
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(timeString.length-minUnit.length, minUnit.length)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:10.0]
                                  range:NSMakeRange(timeString.length-minUnit.length-2-hUnit.length, hUnit.length)];
        }
        _timeLab.attributedText = AttributedStr;
    }
}

- (void)setPercentage:(CGFloat)percentage{
        _percentage = percentage;
        int width = (kSCREEN_WIDTH - 60)/3*percentage;
        WS(weakSelf);
        [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.progressBackView.mas_left);
            make.top.mas_equalTo(weakSelf.titleLab.mas_bottom).offset(4);
//            make.width.equalTo(@10);
            make.width.mas_equalTo(width);
            make.height.equalTo(@16);
        }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    WS(weakSelf);
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.mas_top);
        make.width.equalTo(@19.5);
        make.height.equalTo(@19.5);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.iconView.mas_bottom).offset(4);
        make.width.mas_equalTo(weakSelf);
        make.height.equalTo(@16);
    }];
    [self.progressBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.titleLab.mas_bottom).offset(4);
        make.width.mas_equalTo(weakSelf);
        make.height.equalTo(@16);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.progressBackView.mas_left);
        make.top.mas_equalTo(weakSelf.titleLab.mas_bottom).offset(4);
//        make.width.equalTo(@10);
//        make.width.mas_equalTo(weakSelf.progressBackView.mas_width).multipliedBy(weakSelf.percentage);
        make.height.equalTo(@16);
    }];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.progressBackView.mas_bottom).offset(4);
        make.width.mas_equalTo(weakSelf);
        make.height.equalTo(@24);
    }];
    
}

@end
