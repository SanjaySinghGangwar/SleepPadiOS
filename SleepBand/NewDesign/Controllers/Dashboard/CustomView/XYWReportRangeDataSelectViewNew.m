//
//  XYWReportRangeDataSelectViewNew.m
//  SleepBand
//
//  Created by admin on 2019/6/3.
//  Copyright © 2019 admin. All rights reserved.
//

#import "XYWReportRangeDataSelectViewNew.h"

#define  SelectedBGColor [UIColor colorWithHexString:@"#7000A1"]
#define  NormalBGColor [UIColor whiteColor]

@interface XYWReportRangeDataSelectViewNew ()

@end

@implementation XYWReportRangeDataSelectViewNew

- (instancetype)init{
    
    if (self = [super init]) {

        self.backgroundColor = [UIColor clearColor];
        self.selectTag = 100;

        //...

        UIFont * font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        
        UIButton *weekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [weekBtn setTitle:NSLocalizedString(@"RMVC_Week", nil) forState:UIControlStateNormal];
        weekBtn.backgroundColor = NormalBGColor;
        weekBtn.titleLabel.font = font;
        weekBtn.tag = 101;
        [weekBtn setTitleColor:[UIColor colorWithHexString:@"#b1aca8"] forState:UIControlStateNormal];
        [weekBtn addTarget:self action:@selector(rangeDataButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:weekBtn];
        self.weekBtn = weekBtn;

        UIButton *dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dayBtn setTitle:NSLocalizedString(@"RMVC_Day", nil) forState:UIControlStateNormal];
        dayBtn.backgroundColor = SelectedBGColor;
        dayBtn.titleLabel.font = font;
        dayBtn.tag = 100;
        [dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dayBtn addTarget:self action:@selector(rangeDataButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dayBtn];
        self.dayBtn = dayBtn;

        UIButton *monthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [monthBtn setTitle:NSLocalizedString(@"RMVC_Month", nil) forState:UIControlStateNormal];
        monthBtn.backgroundColor = NormalBGColor;
        monthBtn.titleLabel.font = font;
        monthBtn.tag = 102;
        [monthBtn setTitleColor:[UIColor colorWithHexString:@"#b1aca8"] forState:UIControlStateNormal];
        [monthBtn addTarget:self action:@selector(rangeDataButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:monthBtn];
        self.monthBtn = monthBtn;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    __weak typeof(self) weakSelf = self;
    [self.weekBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(@16);
         make.centerX.equalTo(weakSelf);
         make.width.equalTo(@((kSCREEN_WIDTH - 32)/3));
         make.height.equalTo(@43.5);
     }];
    [self.dayBtn mas_makeConstraints:^(MASConstraintMaker *make){
         make.top.equalTo(weakSelf.weekBtn);
         make.right.mas_equalTo(weakSelf.weekBtn.mas_left).offset(-8);
         make.width.equalTo(@((kSCREEN_WIDTH - 32)/3));
         make.height.equalTo(@43.5);
     }];
    [self.monthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.weekBtn);
        make.left.mas_equalTo(weakSelf.weekBtn.mas_right).offset(8);
        make.width.equalTo(@((kSCREEN_WIDTH - 32)/3));
        make.height.equalTo(@43.5);
    }];
    
}

#pragma mark

- (void)rangeDataButtonOnClick:(UIButton *)sender {
    
    if (self.selectTag == sender.tag) return;
    
    self.selectTag = sender.tag;
    
    [self refreshButtonBackgroundColor];
    
    if (_delegate && [_delegate respondsToSelector:@selector(XYWReportRangeDataSelectNewViewSelectIndex:)]) {
        
        NSInteger index = self.selectTag >= 100 ? self.selectTag-100 : self.selectTag-100;
        
        [_delegate XYWReportRangeDataSelectNewViewSelectIndex:index];
        
    }
    
}

#pragma mark

- (void)refreshButtonBackgroundColor{
    
    UIColor * normalTextColor = [UIColor colorWithHexString:@"#b1aca8"];
    UIColor * selectTextColor = [UIColor whiteColor];
    
    [self.dayBtn setTitleColor:self.selectTag == self.dayBtn.tag ? selectTextColor : normalTextColor forState:UIControlStateNormal];
    [self.weekBtn setTitleColor:self.selectTag == self.weekBtn.tag ? selectTextColor : normalTextColor forState:UIControlStateNormal];
    [self.monthBtn setTitleColor:self.selectTag == self.monthBtn.tag ? selectTextColor : normalTextColor forState:UIControlStateNormal];
    
    self.dayBtn.backgroundColor = self.selectTag == self.dayBtn.tag ? SelectedBGColor : NormalBGColor;
    self.weekBtn.backgroundColor = self.selectTag == self.weekBtn.tag ? SelectedBGColor : NormalBGColor;
    self.monthBtn.backgroundColor = self.selectTag == self.monthBtn.tag ? SelectedBGColor : NormalBGColor;
}


@end
