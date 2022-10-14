//
//  SelectAreaCodeTableViewCell.m
//  QLife
//
//  Created by admin on 2018/5/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SelectAreaCodeTableViewCell.h"

@implementation SelectAreaCodeTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

-(void)setUI
{
    WS(weakSelf);
    self.backgroundColor = [UIColor clearColor];
    self.countryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.countryLabel.font = [UIFont systemFontOfSize:14];
    self.countryLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    [self.contentView addSubview:self.countryLabel];
    [self.countryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.contentView.mas_left).offset(0);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-80);
        make.top.bottom.equalTo(weakSelf.contentView);
        
    }];
    
    self.codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.codeLabel.font = [UIFont systemFontOfSize:11];
    self.codeLabel.textAlignment = NSTextAlignmentRight;
    self.codeLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    [self.contentView addSubview:self.codeLabel];
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@65);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-10);
        make.top.bottom.equalTo(weakSelf.contentView);
    }];
    
    UIView *line = [[UIView alloc]init];
    [self.contentView addSubview:line];
    line.backgroundColor = [UIColor colorWithHexString:@"#b1ada8"];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-5);
        make.left.bottom.equalTo(weakSelf.contentView);
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
