//
//  JournalCellView.m
//  SleepBand
//
//  Created by Mac on 27/12/22.
//  Copyright © 2022 admin. All rights reserved.
//

#import "JournalCellView.h"

@interface JournalCellView()

@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * titleLab;
@property (nonatomic, strong) UILabel * timeLab;

@end


@implementation JournalCellView


- (instancetype)initWithIconStr:(NSString*)iconStr
                          title:(NSString*)title
                           time:(NSString*)time
                          index:(NSInteger)index{
    
    if (self = [super init]) {

        self.backgroundColor = [UIColor clearColor];
        self.iconStr = iconStr;
        self.title = title;
        self.time = time;
        self.index = index;
        
        //...
        
        UIImageView *iconView = [[UIImageView alloc]init];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.image = [UIImage imageNamed:self.iconStr];
        self.iconView = iconView;
        [self addSubview:iconView];
        
        UILabel *titleLab = [[UILabel alloc]init];
        titleLab.font = [UIFont systemFontOfSize:14.0];
        titleLab.textColor = [UIColor whiteColor];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = self.title;
        self.titleLab = titleLab;
        [self addSubview:titleLab];


        UILabel *timeLab = [[UILabel alloc]init];
        timeLab.textColor = [UIColor  whiteColor];
        timeLab.backgroundColor = [UIColor clearColor];
        timeLab.textAlignment = NSTextAlignmentCenter;
        timeLab.font = [UIFont systemFontOfSize:18.0];
        timeLab.text = self.time;
        self.timeLab = timeLab;
        [self addSubview:timeLab];
        
        NSMutableAttributedString *AttributedStr;
        if (self.index == 2) {
            NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);
            NSString * timeString = [NSString stringWithFormat:@"%@ %@",self.time,unit];
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length - unit.length, unit.length)];
        } else if (self.index == 3) {
            NSString * unit= NSLocalizedString(@"SMVC_RespiratoryRateUnit", nil);
            NSString * timeString = [NSString stringWithFormat:@"%@ %@",self.time,unit];
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length - unit.length, unit.length)];
        } else {
            
            int minNum = [self.time intValue];
            int h = 0;
            int min = 0;
            if (minNum >0) {
                h = floor(minNum / 60);
                min = minNum % 60;
            }
            
            NSString * hUnit= @"hr"; //NSLocalizedString(@"RMVC_Hour", nil);//h
            NSString * minUnit= @"min"; //NSLocalizedString(@"RMVC_Minute", nil);//min
            NSString * timeString = [NSString stringWithFormat:@"%02d%@ %02d%@",h,hUnit,min,minUnit];
            
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length-minUnit.length, minUnit.length)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length-minUnit.length-2-hUnit.length, hUnit.length)];

        }
        timeLab.attributedText = AttributedStr;
        self.timeLab = timeLab;
        
    }
    return self;
}

- (void)setTime:(NSString *)time {
    if (_time != time) {
        _time = time;
        
        //日进度条
        NSMutableAttributedString *AttributedStr;
        
        if (_index == 2) {
            NSString * unit= NSLocalizedString(@"SMVC_HeartRateUnit", nil);
            NSString * timeString = [NSString stringWithFormat:@"%@ %@",self.time,unit];
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length - unit.length, unit.length)];
        } else if (_index == 3) {
            NSString * unit= NSLocalizedString(@"SMVC_RespiratoryRateUnit", nil);
            NSString * timeString = [NSString stringWithFormat:@"%@ %@",self.time,unit];
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length - unit.length, unit.length)];
        }else{
            int minNum = [self.time intValue];
            int h = 0;
            int min = 0;
            if (minNum >0) {
                h = floor(minNum / 60);
                min = minNum % 60;
            }
            
            NSString * hUnit= @"hr"; //NSLocalizedString(@"RMVC_Hour", nil);//h
            NSString * minUnit= @"min"; //NSLocalizedString(@"RMVC_Minute", nil);//min
            NSString * timeString = [NSString stringWithFormat:@"%02d%@ %02d%@",h,hUnit,min,minUnit];
            
            AttributedStr = [[NSMutableAttributedString alloc]initWithString:timeString];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length-minUnit.length, minUnit.length)];
            [AttributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:18.0]
                                  range:NSMakeRange(timeString.length-minUnit.length-2-hUnit.length, hUnit.length)];
        }
        _timeLab.attributedText = AttributedStr;
    }
}


- (void)layoutviews {
    WS(weakSelf);
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.width.equalTo(@48);
        make.height.equalTo(@48);
    }];
    
    if (_index == 2 || _index == 3) {
        [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.iconView.mas_top).offset(2);
            make.left.mas_equalTo(weakSelf.iconView.mas_right).offset(8);
            make.height.equalTo(@24);
        }];
        
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.timeLab.mas_bottom).offset(4);
            make.left.mas_equalTo(weakSelf.timeLab.mas_left);
            make.height.equalTo(@18);
        }];
    } else {
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.iconView.mas_top).offset(2);
            make.left.mas_equalTo(weakSelf.iconView.mas_right).offset(8);
            make.height.equalTo(@18);
        }];
        
        [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.titleLab.mas_bottom).offset(4);
            make.left.mas_equalTo(weakSelf.titleLab.mas_left);
            make.height.equalTo(@24);
        }];
    }
    
   
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutviews];
}
@end
