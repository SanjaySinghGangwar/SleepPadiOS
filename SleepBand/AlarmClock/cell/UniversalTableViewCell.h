//
//  UniversalTableViewCell.h
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger,CellType){
    CellType_Vaule,  //只有值
    CellType_VauleArrows,  //值+图标
    CellType_Arrows,  //只有图标
    CellType_Switch,  //只有开关
    CellType_Button  //只有按钮
};

typedef void(^switchBlock)(BOOL isOn);

@interface UniversalTableViewCell : UITableViewCell
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIView *lineView;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UILabel *valueLabel;
@property (strong,nonatomic) UIImageView *arrowsView;
@property (strong,nonatomic) UIImageView *buttonView;
@property (copy,nonatomic) switchBlock switchBlock;
@property (strong,nonatomic) UIButton *switchBtn;
@property (assign,nonatomic) NSInteger cellTpye;
@property (assign,nonatomic) BOOL isInfo;
-(void)setType:(NSInteger )type;
@end
