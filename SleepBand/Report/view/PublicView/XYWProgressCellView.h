//
//  XYWProgressCellView.h
//  SleepBand
//
//  Created by admin on 2019/6/4.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYWProgressCellView : UIView

@property (nonatomic, strong) NSString * iconStr;//图片
@property (nonatomic, strong) NSString * title;//标题
@property (nonatomic, assign) CGFloat percentage;//进度百分比
@property (nonatomic, strong) NSString * time;//时长
@property (nonatomic, assign) NSInteger index;//角标标识符

- (instancetype)initWithIconStr:(NSString*)iconStr
                          title:(NSString*)title
                     percentage:(CGFloat)percentage
                           time:(NSString*)time
                          index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
