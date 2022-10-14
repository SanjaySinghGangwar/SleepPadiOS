//
//  CycleTableViewCell.m
//  SleepBand
//
//  Created by admin on 2018/7/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "CycleTableViewCell.h"

@implementation CycleTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}
-(void)setUI{
    WS(weakSelf);
    
//    self.backgroundColor = [UIColor clearColor];
//
//    UIView *bgView = [[UIView alloc]init];
//    [self.contentView addSubview:bgView];
//    bgView.backgroundColor = [UIColor whiteColor];
//    bgView.alpha = kAlpha;
//    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(weakSelf.contentView);
//        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom).offset(-2);
//    }];
    
    self.titleArray = @[@"ACMVC_Sunday",@"ACMVC_Monday",@"ACMVC_Tuesday",@"ACMVC_Wednesday",@"ACMVC_Thursday",@"ACMVC_Friday",@"ACMVC_Saturday"];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
        make.height.equalTo(@14);
        make.left.mas_equalTo(weakSelf.contentView.mas_left).offset(0);
        make.top.mas_equalTo(weakSelf.contentView.mas_top).offset(11.5);
    }];
    
    //左右按钮之间的距离
    CGFloat width = 34;
    CGFloat gapX = (kSCREEN_WIDTH-68-(width*7))/6;
    
    
    for (int i = 0; i < self.titleArray.count; i++) {
        UIButton *item = [[UIButton alloc] init];
        item.selected = NO;
        item.tag = 1000 +i;
//        item.layer.cornerRadius = width/2;
//        item.layer.borderWidth = 1;
//        item.layer.borderColor = [UIColor whiteColor].CGColor;
//        item.backgroundColor = [UIColor clearColor];
        [item setBackgroundImage:[UIImage imageNamed:@"addalarm_repeat_bg_unselect"] forState:UIControlStateNormal];
        [item setBackgroundImage:[UIImage imageNamed:@"addalarm_repeat_select"] forState:UIControlStateSelected];
        [item setTitle:NSLocalizedString(self.titleArray[i], nil) forState:UIControlStateNormal];
        [item setTitleColor:[UIColor colorWithHexString:@"#B1ACA8"] forState:UIControlStateNormal];
        [item setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateSelected];
        item.titleLabel.font = [UIFont systemFontOfSize:10];
//        item.titleLabel.text = NSLocalizedString(self.titleArray[i], nil);
        item.frame = CGRectMake(i*(width+gapX), 37.5, width, 27);
        [self.contentView addSubview:item];
        [self changeItemUI:item];
        [item addTarget:self action:@selector(setItemState:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIView *lineView = [[UIView alloc]init];
    [self.contentView addSubview:lineView];
    //    self.lineView.hidden = YES;
    lineView.backgroundColor = [UIColor colorWithHexString:@"#d8d5d3"];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.contentView);
        make.height.equalTo(@1);
    }];
}
-(void)setRepeat:(NSArray *)array{
    for (int i = 0; i < self.titleArray.count; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:1000+i];
        button.selected = NO;
        [self changeItemUI:button];
    }
    for (int j = 0; j < array.count; j++) {
        int selectRepeat = [array[j] intValue];
        UIButton *button = (UIButton *)[self viewWithTag:1000+selectRepeat];
        button.selected = YES;
        [self changeItemUI:button];
    }
}
-(void)changeItemUI:(UIButton *)sender{
    if (sender.selected) {
        sender.backgroundColor = [UIColor whiteColor];
    }else{
        sender.backgroundColor = [UIColor clearColor];
    }
}
-(void)setItemState:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self changeItemUI:sender];
    NSString *value = [NSString stringWithFormat:@"%ld",sender.tag-1000];
    self.repeatBlock(value);
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
