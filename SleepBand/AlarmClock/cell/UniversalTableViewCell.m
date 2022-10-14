//
//  UniversalTableViewCell.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "UniversalTableViewCell.h"

@implementation UniversalTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}
-(void)setUI{
    WS(weakSelf);
    self.backgroundColor = [UIColor clearColor];
    
//    self.bgView = [[UIView alloc]init];
//    [self.contentView addSubview:self.bgView];
//    self.bgView.backgroundColor = [UIColor whiteColor];
//    self.bgView.alpha = kAlpha;
//    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.equalTo(weakSelf.contentView);
//        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom).offset(-2);
//        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
//    }];
    

    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@36);
        make.centerY.equalTo(weakSelf.contentView);
        make.left.mas_equalTo(weakSelf.contentView.mas_left).offset(0);
        make.width.equalTo(@150);
    }];
    
    self.arrowsView = [[UIImageView alloc]init];
    [self.contentView addSubview: self.arrowsView];
    self.arrowsView.image = [UIImage imageNamed:@"me_arrow_right"];
    [self.arrowsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.contentView);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
        make.width.equalTo(@30);
        make.height.equalTo(@47);
    }];
    
    self.valueLabel = [[UILabel alloc]init];
//    self.valueLabel.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:self.valueLabel];
    self.valueLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    self.valueLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(weakSelf.contentView);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
        //            make.left.mas_equalTo(weakSelf.titleLabel.mas_right).offset(0);
        make.width.equalTo(@(kSCREEN_WIDTH -68-218));
    }];
    
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.switchBtn];
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"alarm_switch_off"] forState:UIControlStateNormal];
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"alarm_switch_on"] forState:UIControlStateSelected];
    [self.switchBtn addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@38.5);
        make.height.equalTo(@27.5);
        make.centerY.equalTo(weakSelf.contentView);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
    }];
    
    self.buttonView = [[UIImageView alloc]init];
    [self.contentView addSubview: self.buttonView];
    [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.contentView);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
        make.width.equalTo(@30);
        make.height.equalTo(@46);
    }];
    
    self.lineView = [[UIView alloc]init];
    [self.contentView addSubview:self.lineView];
//    self.lineView.hidden = YES;
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"#d8d5d3"];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.contentView);
        make.height.equalTo(@1);
    }];
    
}
-(void)setType:(NSInteger )type{
    WS(weakSelf);
    if (self.isInfo) {
        self.valueLabel.hidden = YES;
        self.arrowsView.hidden = NO;
        self.switchBtn.hidden = YES;
        self.buttonView.hidden = YES;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@36);
            make.centerY.equalTo(weakSelf.contentView);
            make.left.mas_equalTo(weakSelf.contentView.mas_left).offset(0);
            make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-40);
        }];
    }else{
        if (type == CellType_Vaule) {
            self.valueLabel.hidden = NO;
            self.arrowsView.hidden = YES;
            self.switchBtn.hidden = YES;
            self.buttonView.hidden = YES;
            
            [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(weakSelf.contentView);
                make.left.mas_equalTo(weakSelf.titleLabel.mas_right).offset(0);
                make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
            }];
        }else if (type == CellType_VauleArrows){
            self.valueLabel.hidden = NO;
            self.arrowsView.hidden = NO;
            self.switchBtn.hidden = YES;
            self.buttonView.hidden = YES;
            [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(weakSelf.contentView);
                make.left.mas_equalTo(weakSelf.titleLabel.mas_right).offset(0);
                make.right.mas_equalTo(weakSelf.arrowsView.mas_left).offset(10);
            }];
        }else if (type == CellType_Arrows){
            self.valueLabel.hidden = YES;
            self.arrowsView.hidden = NO;
            self.switchBtn.hidden = YES;
            self.buttonView.hidden = YES;
        }else if (type == CellType_Switch){
            self.valueLabel.hidden = YES;
            self.arrowsView.hidden = YES;
            self.switchBtn.hidden = NO;
            self.buttonView.hidden = YES;
        }else{
            self.valueLabel.hidden = YES;
            self.arrowsView.hidden = YES;
            self.switchBtn.hidden = YES;
            self.buttonView.hidden = NO;
        }
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
-(void)switchBtn:(UISwitch *)sender{
    sender.selected = sender.selected ? NO:YES;
    self.switchBlock(sender.selected);
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
