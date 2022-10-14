//
//  XYWReportRangeDataSelectView.m
//  SleepBand
//
//  Created by admin on 2019/6/3.
//  Copyright © 2019 admin. All rights reserved.
//

#import "XYWReportRangeDataSelectView.h"

#define  SelectedColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_select"]]
#define  NormalColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"report_bg_togglebtn_none"]]

@interface XYWReportRangeDataSelectView ()

@end

@implementation XYWReportRangeDataSelectView

- (instancetype)init{
    
    if (self = [super init]) {
        // 设置属性值
        self.backgroundColor = [UIColor clearColor];
        self.selectTag = 100;
        // 创建临时变量
        //...
        // 周btn
        UIButton *weekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [weekBtn setTitle:NSLocalizedString(@"RMVC_Week", nil) forState:UIControlStateNormal];
        weekBtn.backgroundColor = NormalColor;
        weekBtn.titleLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight];
        weekBtn.tag = 101;
        [weekBtn setTitleColor:[UIColor colorWithHexString:@"#b1aca8"] forState:UIControlStateNormal];
        [weekBtn addTarget:self action:@selector(rangeDataButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:weekBtn];
        self.weekBtn = weekBtn;
        // 天btn
        UIButton *dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dayBtn setTitle:NSLocalizedString(@"RMVC_Day", nil) forState:UIControlStateNormal];
        dayBtn.backgroundColor = SelectedColor;
        dayBtn.titleLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight];
        dayBtn.tag = 100;
        [dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dayBtn addTarget:self action:@selector(rangeDataButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dayBtn];
        self.dayBtn = dayBtn;
        //月btn
        UIButton *monthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [monthBtn setTitle:NSLocalizedString(@"RMVC_Month", nil) forState:UIControlStateNormal];
        monthBtn.backgroundColor = NormalColor;
        monthBtn.titleLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightLight];
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
         make.width.equalTo(@54);
         make.height.equalTo(@43.5);
     }];
    [self.dayBtn mas_makeConstraints:^(MASConstraintMaker *make){
         make.top.equalTo(weakSelf.weekBtn);
         make.right.mas_equalTo(weakSelf.weekBtn.mas_left).offset(-30);
         make.width.equalTo(@54);
         make.height.equalTo(@43.5);
     }];
    [self.monthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.weekBtn);
        make.left.mas_equalTo(weakSelf.weekBtn.mas_right).offset(30);
        make.width.equalTo(@54);
        make.height.equalTo(@43.5);
    }];
    
}

#pragma mark - 事件
// 点击按钮
- (void)rangeDataButtonOnClick:(UIButton *)sender {
    
    if (self.selectTag == sender.tag) return;
    
    self.selectTag = sender.tag;
    
    [self refreshButtonBackgroundColor];
    
    if (_delegate && [_delegate respondsToSelector:@selector(XYWReportRangeDataSelectViewSelectIndex:)]) {
        
        NSInteger index = self.selectTag >= 100 ? self.selectTag-100 : self.selectTag-100;
        
        [_delegate XYWReportRangeDataSelectViewSelectIndex:index];
        
    }
    
}

#pragma mark - 自定义
// 刷新按钮
- (void)refreshButtonBackgroundColor{
    
    UIColor * normalTextColor = [UIColor colorWithHexString:@"#b1aca8"];
    UIColor * selectTextColor = [UIColor whiteColor];
    
    [self.dayBtn setTitleColor:self.selectTag == self.dayBtn.tag ? selectTextColor : normalTextColor forState:UIControlStateNormal];
    [self.weekBtn setTitleColor:self.selectTag == self.weekBtn.tag ? selectTextColor : normalTextColor forState:UIControlStateNormal];
    [self.monthBtn setTitleColor:self.selectTag == self.monthBtn.tag ? selectTextColor : normalTextColor forState:UIControlStateNormal];
    
    self.dayBtn.backgroundColor = self.selectTag == self.dayBtn.tag ? SelectedColor : NormalColor;
    self.weekBtn.backgroundColor = self.selectTag == self.weekBtn.tag ? SelectedColor : NormalColor;
    self.monthBtn.backgroundColor = self.selectTag == self.monthBtn.tag ? SelectedColor : NormalColor;
}

//
//- (void)zxs_refreshArcButtonsWithIndex:(NSInteger)index {
//    NSArray *arcButtons = self.arcButtons;
//    for (UIButton *arcButton in arcButtons) {
//        if (arcButton.tag == index) {
//            arcButton.selected = YES;
//            arcButton.userInteractionEnabled = NO;
//
//        } else {
//            arcButton.selected = NO;
//            arcButton.userInteractionEnabled = YES;
//        }
//    }
//}
//
//- (void)zxs_refreshArcButtonsForSelected:(BOOL)selected {
//    NSArray *arcButtons = self.arcButtons;
//    for (UIButton *arcButton in arcButtons) {
//        arcButton.selected = selected;
//    }
//}
//
//- (void)zxs_refreshArcButtonsForUserInteractionEnabled:(BOOL)enabled {
//    NSArray *arcButtons = self.arcButtons;
//    for (UIButton *arcButton in arcButtons) {
//        arcButton.userInteractionEnabled = enabled;
//    }
//}
//
//- (void)zxs_refreshSectorShapeLayersWithIndex:(NSInteger)index {
//    NSArray *sectorShapeLayers = self.sectorShapeLayers;
//    for (CAShapeLayer *sectorShapeLayer in sectorShapeLayers) {
//        sectorShapeLayer.hidden = YES;
//    }
//
//    CAShapeLayer *sectorShapeLayer = sectorShapeLayers[index];
//    sectorShapeLayer.hidden = NO;
//}
//
//- (void)zxs_hideSectorShapeLayers {
//    NSArray *sectorShapeLayers = self.sectorShapeLayers;
//    for (CAShapeLayer *sectorShapeLayer in sectorShapeLayers) {
//        sectorShapeLayer.hidden = YES;
//    }
//}

@end
