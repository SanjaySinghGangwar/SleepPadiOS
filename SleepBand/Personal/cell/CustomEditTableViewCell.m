//
//  CustomEditTableViewCell.m
//  SleepBand
//
//  Created by admin on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "CustomEditTableViewCell.h"

@implementation CustomEditTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}
-(void)setUI{
    WS(weakSelf);
    self.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [[UIView alloc]init];
    [self.contentView addSubview:bgView];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = kAlpha;
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(weakSelf.contentView);
        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom).offset(-2);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
    }];
    
    self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectBtn setImage:[UIImage imageNamed:@"edit_icon_add"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"edit_icon_del"] forState:UIControlStateSelected];
    self.selectBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:self.selectBtn];
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView.mas_left).offset(kMargin);
        make.top.mas_equalTo(weakSelf.contentView.mas_top).offset(12);
        make.height.width.equalTo(@20);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView);
        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom).offset(-2);
        make.left.mas_equalTo(weakSelf.selectBtn.mas_right).offset(7);
        make.width.equalTo(@200);
    }];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
