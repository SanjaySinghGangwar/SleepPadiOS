//
//  XYWReportRangeDataSelectView.h
//  SleepBand
//
//  Created by admin on 2019/6/3.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XYWReportRangeDataSelectViewDelegate <NSObject>

- (void)XYWReportRangeDataSelectViewSelectIndex:(NSInteger)index;

@end

@interface XYWReportRangeDataSelectView : UIView
//- (void)zxs_refreshArcButtonsWithIndex:(NSInteger)index;
//
//- (void)zxs_refreshArcButtonsForSelected:(BOOL)selected;
//
//- (void)zxs_refreshArcButtonsForUserInteractionEnabled:(BOOL)enabled;
//
//- (void)zxs_refreshSectorShapeLayersWithIndex:(NSInteger)index;
//
//- (void)zxs_hideSectorShapeLayers;

@property (nonatomic, weak) id <XYWReportRangeDataSelectViewDelegate> delegate;
@property (strong,nonatomic)UIButton *dayBtn;
@property (strong,nonatomic)UIButton *weekBtn;
@property (strong,nonatomic)UIButton *monthBtn;
@property (assign,nonatomic)NSInteger selectTag;
@property (nonatomic, strong) NSArray *imgArr;
@property (nonatomic, strong) NSArray *textArr;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
