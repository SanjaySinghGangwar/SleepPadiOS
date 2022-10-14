//
//  AlarmClockTableViewCell.m
//  SleepBand
//
//  Created by admin on 2018/7/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AlarmClockTableViewCell.h"

@implementation AlarmClockTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}
-(void)setUI{
    WS(weakSelf);

    self.backgroundColor = [UIColor whiteColor];
    
    
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.switchBtn];
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"alarm_switch_off"] forState:UIControlStateNormal];
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"alarm_switch_on"] forState:UIControlStateSelected];
    [self.switchBtn addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@34);
        make.height.equalTo(@17);
        make.centerY.equalTo(weakSelf.contentView);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(0);
    }];
    
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:34];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
        make.height.equalTo(@34);
        make.left.mas_equalTo(weakSelf.contentView.mas_left).offset(0);
        make.top.mas_equalTo(weakSelf.contentView.mas_top).offset(10);
//        make.centerY.equalTo(weakSelf.contentView);
    }];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    self.tagLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.timeLabel);
        make.height.equalTo(@16);
        make.left.mas_equalTo(weakSelf.timeLabel.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.switchBtn.mas_left).offset(-10);
    }];
    
    self.deviceIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.deviceIV];
    [self.deviceIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.timeLabel.mas_bottom).offset(7);
        make.width.equalTo(@13);
        make.height.equalTo(@21);
        make.left.equalTo(weakSelf.timeLabel);
    }];
    
    self.repeatLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.repeatLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    self.repeatLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.repeatLabel];
    [self.repeatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@14);
        make.centerY.equalTo(weakSelf.deviceIV);
        make.left.mas_equalTo(weakSelf.deviceIV.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.switchBtn.mas_left).offset(-10);
    }];
    
    UIView *lineView = [[UIView alloc]init];
    [self.contentView addSubview:lineView];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.contentView);
        make.height.equalTo(@1);
    }];
}
-(void)setClockValue:(AlarmClockModel *)model{
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",model.hour,model.minute];
    CGSize timeSize = [self.timeLabel.text sizeWithAttributes:@{NSFontAttributeName:self.timeLabel.font}];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(timeSize.width+5));
    }];
    if (model.isPhone) {
        if (model.isOn) {
            self.deviceIV.image = [UIImage imageNamed:@"alarm_redevice_phone_on"];
        }else{
            self.deviceIV.image = [UIImage imageNamed:@"alarm_redevice_phone_off"];
        }
    }else{
        if (model.isOn) {
            self.deviceIV.image = [UIImage imageNamed:@"alarm_redevice_sleepee_on"];
        }else{
            self.deviceIV.image = [UIImage imageNamed:@"alarm_redevice_sleepee_off"];
        }
    }
    if (model.remark.length == 0) {
        self.tagLabel.hidden = YES;
    }else{
        self.tagLabel.text = model.remark;
        self.tagLabel.hidden = NO;
    }
    if (model.type == ClockType_GetUp) {////起床闹钟
        self.tagLabel.hidden = NO;
        if (model.isIntelligentWake) {
            self.tagLabel.text = NSLocalizedString(@"ACMVC_IntelligentClock", nil);
        }else{
            self.tagLabel.text = NSLocalizedString(@"ACMVC_GetUp", nil);
        }
    }else if(model.type == ClockType_GoToBedEarly){//早睡闹钟
        self.tagLabel.text = NSLocalizedString(@"ACMVC_GoToBedEarly", nil);
        self.tagLabel.hidden = NO;
    }else if(model.type == ClockType_General){//普通闹钟
        self.tagLabel.hidden = NO;
        self.tagLabel.text = NSLocalizedString(@"ACMVC_General", nil);
    }else{//看护闹钟
        self.tagLabel.hidden = NO;
        self.tagLabel.text = NSLocalizedString(@"ACMVC_Nurse", nil);
    }
    if (model.isOn) {
        self.switchBtn.selected = YES;
        self.timeLabel.textColor = [UIColor colorWithHexString:@"#575756"];
        self.tagLabel.textColor = [UIColor colorWithHexString:@"#1C1C1B"];
        self.repeatLabel.textColor = self.tagLabel.textColor;
    }else{
        self.switchBtn.selected = NO;
        self.timeLabel.textColor = [UIColor colorWithHexString:@"#B1B1B1"];
        self.tagLabel.textColor = [UIColor colorWithHexString:@"#B1ACA8"];
        self.repeatLabel.textColor = self.tagLabel.textColor;
    }
    NSMutableString *strMS = [[NSMutableString alloc]init];
    if (model.repeat.count == 7) {
        [strMS appendString:NSLocalizedString(@"ACMVC_Everyday", nil)];
    }else{
        
        NSArray * weekArr = @[NSLocalizedString(@"ACMVC_Sunday", nil),
                              NSLocalizedString(@"ACMVC_Monday", nil),
                              NSLocalizedString(@"ACMVC_Tuesday", nil),
                              NSLocalizedString(@"ACMVC_Wednesday", nil),
                              NSLocalizedString(@"ACMVC_Thursday", nil),
                              NSLocalizedString(@"ACMVC_Friday", nil),
                              NSLocalizedString(@"ACMVC_Saturday", nil)];
        for (int i = 0; i<7; i++) {
            if ([model.repeat containsObject:[NSString stringWithFormat:@"%d",i]]) {
                [strMS appendString:weekArr[i]];
                if (i != model.repeat.count-1) {
                    [strMS appendString:@" "];
                }
            }
        }
        
    }
    self.repeatLabel.text = strMS;
//    CGSize textSize = [self.tagLabel.text sizeWithAttributes:@{NSFontAttributeName:self.tagLabel.font}];
//    [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(textSize.width+10));
//    }];
//    strMS = nil;
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
