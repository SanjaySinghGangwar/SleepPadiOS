//
//  AlertView.m
//  SleepBand
//
//  Created by admin on 2019/2/15.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)init
{
    if(self = [super init]){
        self.hidden = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillHideNotification object:nil];
        self.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
    }
    return self;
}

- (void)keyboardAction:(NSNotification*)sender
{
    WS(weakSelf);
    // 通过通知对象获取键盘frame: [value CGRectValue]
    //    NSDictionary *useInfo = [sender userInfo];
    //    NSValue *value = [useInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // <注意>具有约束的控件通过改变约束值进行frame的改变处理
    if([sender.name isEqualToString:UIKeyboardWillShowNotification]){
        [self.alertBgIV mas_updateConstraints:^(MASConstraintMaker *make) {
            //            make.centerY.mas_equalTo(weakSelf.mas_centerY).offset(-[value CGRectValue].size.height);
            make.centerY.mas_equalTo(weakSelf.mas_centerY).offset(-100);
        }];
    }else{
        [self.alertBgIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.mas_centerY).offset(0);
        }];
    }
}


-(void)oKHidden
{
    [self hidden];
    self.alertCancelBlock(self.alertType);
}

-(void)hidden
{
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        weakSelf.hidden = YES;
        weakSelf.alpha = 1;
    }];
}

-(void)ok{
    [self hidden];
    if(self.textField){
        [self endEditing:YES];
    }
    if (self.alertType == AlertType_TextField) {
        self.alertTextBlock(self.alertType, self.textField.text);
    }else if (self.alertType == AlertType_ActionSheetPicker){
        if (self.informationType == InformationType_Age) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //设置时间格式
            formatter.dateFormat = @"yyyy-MM-dd";
            NSString *dateStr = [formatter  stringFromDate:self.datePicker.date];
            self.alertPickerBlock(self.informationType, dateStr);
        }else if (self.informationType == InformationType_Height || self.informationType == InformationType_Weight){
            NSInteger row = [self.universalPicker selectedRowInComponent:0];
            NSInteger row2 = [self.universalPicker selectedRowInComponent:1];
            NSString *value;
            if (self.units == 0) {
                if (self.informationType == InformationType_Height) {
                    value = [NSString stringWithFormat:@"%@cm",self.cmArray[row]];
                }else{
                    value = [NSString stringWithFormat:@"%@kg",self.kgArray[row]];
                }
            }else
            {
                if (self.informationType == InformationType_Height)
                {
                    value = [NSString stringWithFormat:@"%@ft%@in",self.ftArray[row],self.inArray[row2]];
                    
                }else
                {
                    value = [NSString stringWithFormat:@"%@lb",self.lbArray[row]];
                }
            }
            self.alertPickerBlock(self.informationType, value);
        }else{
            
        }
    }
    else{
        self.alertOkBlock(self.alertType);
    }
}

//只有OK按钮的提示框
-(instancetype)initWithAlertWithoutCancel
{
    if(self = [super init]){
        WS(weakSelf);
        UIView *bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithHexString:@"#A3BBD3"];
        bgView.alpha = 0.8;
        [self addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(weakSelf);
        }];
        
        UIImageView *alertBgIV = [[UIImageView alloc]init];
        alertBgIV.image = [UIImage imageNamed:@"me_box_bg"];
        [self addSubview:alertBgIV];
        [alertBgIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf);
            make.width.equalTo(@344);
            make.height.equalTo(@265);
        }];
        
        self.alertTitleL = [[UILabel alloc]init];
        self.alertTitleL.textAlignment = NSTextAlignmentCenter;
        self.alertTitleL.textColor = [UIColor colorWithHexString:@"#B1ACA8"];
        self.alertTitleL.font = [UIFont systemFontOfSize:15];
        self.alertTitleL.numberOfLines = 0 ;
        //        self.alertTitleL.text = @"123";
        [self addSubview:self.alertTitleL];
        [self.alertTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(alertBgIV.mas_left).offset(40);
            make.right.mas_equalTo(alertBgIV.mas_right).offset(-40);
            make.top.mas_equalTo(alertBgIV.mas_top).offset(77);
            make.height.equalTo(@60);
        }];
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.alertTitleL.mas_bottom).offset(50);
            make.centerX.equalTo(alertBgIV);
            make.width.equalTo(@232);
            make.height.equalTo(@1);
        }];
        
        UILabel *okL = [[UILabel alloc]init];
        okL.textAlignment = NSTextAlignmentCenter;
        okL.textColor = [UIColor colorWithHexString:@"#1B86A4"];
        okL.font = [UIFont systemFontOfSize:15];
        okL.text = NSLocalizedString(@"OK", nil);
        [self addSubview:okL];
        okL.userInteractionEnabled = YES;
        [okL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(alertBgIV);
            make.top.mas_equalTo(lineView.mas_bottom).offset(0);
            make.width.equalTo(@100);
            make.height.equalTo(@55);
        }];
        [okL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oKHidden)]];
        
        self.hidden = YES;
        
    }
    return self;
}

-(void)showAlertWithoutCancelWithTitle:(NSString *)title type:(AlertType)type
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.alertType = type;
    self.alertTitleL.text = title;
    
    UIWindow * window = [UIApplication sharedApplication].windows.lastObject;
    [window addSubview:self];
    
    self.hidden = NO;
}

-(void)showAlertWithType:(AlertType)type title:(NSString *)title menuArray:(NSArray *)menuArray
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.alertType = type;
    if (type == AlertType_UnBind || type == AlertType_Logout || type == AlertType_TextField || type == AlertType_UpData || type == AlertType_Disconnect) {
        [self setUniversalAlertUIWithTitle:title];
    }else if (type == AlertType_ActionSheet){
        [self setActionSheetAlertUIWithMenuArray:menuArray];
    }else{
        
    }
    
    UIWindow * window = [UIApplication sharedApplication].windows.lastObject;
    [window addSubview:self];
    
    self.hidden = NO;
}

-(void)showPickerActionSheetWithType:(InformationType)informationType alertType:(AlertType)alertType dataArray:(NSArray *)dataArray value:(NSString *)value units:(int)units
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.alertType = alertType;
    self.informationType = informationType;
    self.units = units;
    [self setActionSheetPickerUIWithMenuArray:dataArray value:value];
    
    UIWindow * window = [UIApplication sharedApplication].windows.lastObject;
    [window addSubview:self];
    
    self.hidden = NO;
    
}

-(void)setUniversalAlertUIWithTitle:(NSString *)title
{
    WS(weakSelf);
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithHexString:@"#A3BBD3"];
    bgView.alpha = 0.8;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(weakSelf);
    }];
    
    self.alertBgIV = [[UIImageView alloc]init];
    self.alertBgIV.userInteractionEnabled = YES;
    self.alertBgIV.image = [UIImage imageNamed:@"me_box_bg"];
    [self addSubview:self.alertBgIV];
    [self.alertBgIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.mas_centerX).offset(0);
        make.centerY.mas_equalTo(weakSelf.mas_centerY).offset(0);
        make.width.equalTo(@344);
        make.height.equalTo(@265);
    }];
    
    self.alertTitleL = [[UILabel alloc]init];
    self.alertTitleL.textAlignment = NSTextAlignmentCenter;
    self.alertTitleL.textColor = [UIColor colorWithHexString:@"#B1ACA8"];
    self.alertTitleL.text = title;
    [self.alertBgIV addSubview:self.alertTitleL];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.alertBgIV addSubview:lineView];
    
    if (self.alertType == AlertType_TextField) {
        self.alertTitleL.font = [UIFont systemFontOfSize:17];
        [self.alertTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.alertBgIV.mas_left).offset(40);
            make.right.mas_equalTo(weakSelf.alertBgIV.mas_right).offset(-40);
            make.top.mas_equalTo(weakSelf.alertBgIV.mas_top).offset(50);
            make.height.equalTo(@17);
        }];
        
        self.textField = [[UITextField alloc]initWithFrame:CGRectZero];
        self.textField.textColor = [UIColor colorWithHexString:@"#757F7F"];
        self.textField.placeholder = NSLocalizedString(@"PIVC_InputName", nil);
        self.textField.font = [UIFont systemFontOfSize:14];
        self.textField.backgroundColor = [UIColor colorWithHexString:@"#D7F0F2"];
        self.textField.layer.cornerRadius = 10;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 44)];
        self.textField.leftView = leftView;
        self.textField.leftViewMode = UITextFieldViewModeAlways;
        self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
        [self.alertBgIV addSubview:self.textField];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(weakSelf.alertTitleL.mas_bottom).offset(26);
            make.centerX.equalTo(weakSelf.alertBgIV);
            make.width.equalTo(@230);
            make.height.equalTo(@44);
            
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(weakSelf.textField.mas_bottom).offset(35);
            make.centerX.equalTo(weakSelf.alertBgIV);
            make.width.equalTo(@232);
            make.height.equalTo(@1);
            
        }];
        
    }else{
        self.alertTitleL.font = [UIFont systemFontOfSize:15];
        self.alertTitleL.numberOfLines = 0 ;
        [self.alertTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(weakSelf.alertBgIV.mas_left).offset(40);
            make.right.mas_equalTo(weakSelf.alertBgIV.mas_right).offset(-40);
            make.top.mas_equalTo(weakSelf.alertBgIV.mas_top).offset(77);
            make.height.equalTo(@60);
            
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(weakSelf.alertTitleL.mas_bottom).offset(35);
            make.centerX.equalTo(weakSelf.alertBgIV);
            make.width.equalTo(@232);
            make.height.equalTo(@1);
            
        }];
    }
    
    
    UILabel *cancelL = [[UILabel alloc]init];
    cancelL.textAlignment = NSTextAlignmentCenter;
    cancelL.textColor = [UIColor colorWithHexString:@"#B1ACA8"];
    cancelL.font = [UIFont systemFontOfSize:15];
    cancelL.text = NSLocalizedString(@"Cancel", nil);
    [self.alertBgIV addSubview:cancelL];
    cancelL.userInteractionEnabled = YES;
    [cancelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.alertTitleL.mas_left).offset(0);
        make.top.mas_equalTo(lineView.mas_bottom).offset(0);
        make.width.equalTo(@131.5);
        make.height.equalTo(@55);
    }];
    [cancelL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden)]];
    
    UIView *bottomLineView = [[UIView alloc]init];
    bottomLineView.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.alertBgIV addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(cancelL.mas_right).offset(0);
        make.centerY.equalTo(cancelL);
        make.width.equalTo(@1);
        make.height.equalTo(@25);
        
    }];
    
    
    UILabel *okL = [[UILabel alloc]init];
    okL.textAlignment = NSTextAlignmentCenter;
    okL.textColor = [UIColor colorWithHexString:@"#1B86A4"];
    okL.font = [UIFont systemFontOfSize:15];
    okL.text = NSLocalizedString(@"OK", nil);
    [self.alertBgIV addSubview:okL];
    okL.userInteractionEnabled = YES;
    [okL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(bottomLineView.mas_right).offset(0);
        make.top.mas_equalTo(lineView.mas_bottom).offset(0);
        make.width.equalTo(@131.5);
        make.height.equalTo(@55);
        
    }];
    [okL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ok)]];
}

-(void)setActionSheetAlertUIWithMenuArray:(NSArray *)menuArray
{
    WS(weakSelf);
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithHexString:@"#A3BBD3"];
    bgView.alpha = 0.8;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.equalTo(weakSelf);
        
    }];
    
    UIImageView *alertBgIV = [[UIImageView alloc]init];
    alertBgIV.image = [UIImage imageNamed:@"me_box_bottom_bg"];
    [self addSubview:alertBgIV];
    [alertBgIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(weakSelf.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf);
        make.width.equalTo(@375);
        make.height.equalTo(@210);
        
    }];
    
    UILabel *firstL = [[UILabel alloc]init];
    firstL.textAlignment = NSTextAlignmentCenter;
    firstL.textColor = [UIColor colorWithHexString:@"#1B86A4"];
    firstL.font = [UIFont systemFontOfSize:15];
    firstL.text = menuArray[0];
    [self addSubview:firstL];
    [firstL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(alertBgIV.mas_bottom).offset(-114);
        make.centerX.equalTo(weakSelf);
        make.width.equalTo(@200);
        make.height.equalTo(@56);
        
    }];
    firstL.userInteractionEnabled = YES;
    firstL.tag = 100;
    [firstL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionSheet:)]];
    
    UIView *lineViewF = [[UIView alloc]init];
    lineViewF.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self addSubview:lineViewF];
    [lineViewF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(firstL.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf);
        make.width.equalTo(@262);
        make.height.equalTo(@1);
        
    }];
    
    UILabel *secondL = [[UILabel alloc]init];
    secondL.textAlignment = NSTextAlignmentCenter;
    secondL.textColor = [UIColor colorWithHexString:@"#1B86A4"];
    secondL.font = [UIFont systemFontOfSize:15];
    secondL.text = menuArray[1];
    [self addSubview:secondL];
    [secondL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(lineViewF.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf);
        make.width.equalTo(@200);
        make.height.equalTo(@56);
        
    }];
    secondL.userInteractionEnabled = YES;
    secondL.tag = 101;
    [secondL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionSheet:)]];
    
    UIView *lineViewS = [[UIView alloc]init];
    lineViewS.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self addSubview:lineViewS];
    [lineViewS mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.top.mas_equalTo(secondL.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf);
        make.width.equalTo(@262);
        make.height.equalTo(@1);
        
    }];
    
    UILabel *thirdL = [[UILabel alloc]init];
    thirdL.textAlignment = NSTextAlignmentCenter;
    thirdL.textColor = [UIColor colorWithHexString:@"#B1ACA8"];
    thirdL.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    thirdL.text = NSLocalizedString(@"Cancel", nil);
    [self addSubview:thirdL];
    [thirdL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineViewS.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf);
        make.width.equalTo(@200);
        make.height.equalTo(@56);
    }];
    thirdL.userInteractionEnabled = YES;
    thirdL.tag = 102;
    [thirdL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionSheet:)]];
    
}

-(void)actionSheet:(UITapGestureRecognizer *)sender
{
    [self hidden];
    if (sender.view.tag == 102)
    {
        //        [self hidden];
    }else
    {
        self.alertActionSheetBlock(self.alertType, (int)sender.view.tag-100);
    }
}

-(void)setActionSheetPickerUIWithMenuArray:(NSArray *)menuArray value:(NSString *)value
{
    WS(weakSelf);
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithHexString:@"#A3BBD3"];
    bgView.alpha = 0.8;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(weakSelf);
    }];
    
    self.alertBgIV = [[UIImageView alloc]init];
    self.alertBgIV.image = [UIImage imageNamed:@"me_box_bottom_bg"];
    [self addSubview:self.alertBgIV];
    self.alertBgIV.userInteractionEnabled = YES;
    [self.alertBgIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf);
        make.width.equalTo(@375);
        make.height.equalTo(@210);
    }];
    
    UILabel *cancelL = [[UILabel alloc]init];
    cancelL.textAlignment = NSTextAlignmentLeft;
    cancelL.textColor = [UIColor colorWithHexString:@"#B1ACA8"];
    cancelL.font = [UIFont systemFontOfSize:15];
    cancelL.text = NSLocalizedString(@"Cancel", nil);
    [self.alertBgIV addSubview:cancelL];
    cancelL.userInteractionEnabled = YES;
    [cancelL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.alertBgIV.mas_left).offset(60);
        make.top.mas_equalTo(weakSelf.alertBgIV.mas_top).offset(35);
        make.right.mas_equalTo(weakSelf.alertBgIV.mas_centerX).offset(0);
        make.height.equalTo(@45);
        
    }];
    [cancelL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden)]];
    
    UILabel *okL = [[UILabel alloc]init];
    okL.textAlignment = NSTextAlignmentRight;
    okL.textColor = [UIColor colorWithHexString:@"#1B86A4"];
    okL.font = [UIFont systemFontOfSize:15];
    okL.text = NSLocalizedString(@"OK", nil);
    [self.alertBgIV addSubview:okL];
    okL.userInteractionEnabled = YES;
    [okL mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(weakSelf.alertBgIV.mas_right).offset(-60);
        make.top.mas_equalTo(weakSelf.alertBgIV.mas_top).offset(35);
        make.left.mas_equalTo(weakSelf.alertBgIV.mas_centerX).offset(0);
        make.height.equalTo(@45);
        
    }];
    [okL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ok)]];
    
    UIView *bottomLineView = [[UIView alloc]init];
    bottomLineView.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.alertBgIV addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(cancelL.mas_left).offset(0);
        make.right.mas_equalTo(okL.mas_right).offset(0);
        make.top.mas_equalTo(cancelL.mas_bottom).offset(0);
        make.height.equalTo(@1);
        
    }];
    
    if(self.informationType == InformationType_Age){
        self.datePicker = [[UIDatePicker alloc] init];
        //    //设置地区: zh-中国
        //    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        if (@available(iOS 13.4, *)) {
            /*
             苹果在 14 系统中修改了 datePicker 的preferredDatePickerStyle属性增加了UIDatePickerStyleInline,
             并且将默认样式调整到新增的 style 上,
             如果项目中没有设置 style 类型并且需要轮播那么就会出现问题
             */
            self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        [self.datePicker setValue:UIColor.blackColor forKey:@"textColor"];
        // 默认选中的颜色 为黑色 修改方法如下
        //通过NSSelectorFromString获取setHighlightsToday方法
        SEL selector= NSSelectorFromString(@"setHighlightsToday:");
        //创建NSInvocation
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
        BOOL no = NO;
        [invocation setSelector:selector];
        //setArgument中第一个参数的类picker，第二个参数是SEL，
        [invocation setArgument:&no atIndex:2];
        //让invocation执行setHighlightsToday方法
        [invocation invokeWithTarget:self.datePicker];
        
        if (value.length > 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            NSDate *birthday = [formatter dateFromString:value];
            [self.datePicker setDate:birthday animated:YES];
        }else{
            [self.datePicker setDate:[NSDate date] animated:YES];
        }
        [self.alertBgIV addSubview:self.datePicker];
        [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cancelL.mas_left).offset(0);
            make.right.mas_equalTo(okL.mas_right).offset(0);
            make.top.mas_equalTo(bottomLineView.mas_bottom).offset(0);
            make.bottom.mas_equalTo(weakSelf.alertBgIV.mas_bottom).offset(0);
            //        make.height.equalTo(@200);
        }];
    }else if (self.informationType == InformationType_Height || self.informationType == InformationType_Weight){
        
        [self setUnitArrayData];
        
        self.universalPicker = [[UIPickerView alloc] init];
        [self.alertBgIV addSubview:self.universalPicker];
        self.universalPicker.dataSource = self;
        self.universalPicker.delegate = self;
        self.universalPicker.showsSelectionIndicator = YES;
        
        [self.universalPicker setValue:UIColor.blackColor forKey:@"textColor"];
        
        [self.universalPicker mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(cancelL.mas_left).offset(0);
            make.right.mas_equalTo(okL.mas_right).offset(0);
            make.top.mas_equalTo(bottomLineView.mas_bottom).offset(0);
            make.bottom.mas_equalTo(weakSelf.alertBgIV.mas_bottom).offset(0);
            
        }];
        
        if (self.informationType == InformationType_Height){
            if (value.length == 0) {
                [self.universalPicker selectRow:0 inComponent:0 animated:NO];
                [self.universalPicker selectRow:0 inComponent:1 animated:NO];
            }else{
                if(self.units == 0){
                    NSString *height = [value substringToIndex:[value rangeOfString:@"cm"].location];
                    [self.universalPicker selectRow:[height intValue] inComponent:0 animated:NO];
                }else{
                    NSRange ftRange = [value rangeOfString:@"ft"];
                    NSString *ftValue = [value substringToIndex:ftRange.location];
                    NSRange inRange = [value rangeOfString:@"in"];
                    NSString *inValue = [value substringWithRange:NSMakeRange(ftRange.location+2, inRange.location-(ftRange.location+ftRange.length))];
                    [self.universalPicker selectRow:[ftValue intValue] inComponent:0 animated:NO];
                    [self.universalPicker selectRow:[inValue intValue] inComponent:1 animated:NO];
                }
            }
        }else{
            if (value.length == 0) {
                [self.universalPicker selectRow:0 inComponent:0 animated:NO];
                [self.universalPicker selectRow:0 inComponent:1 animated:NO];
            }else{
                if(self.units == 0){
                    NSString *weight = [value substringToIndex:[value rangeOfString:@"kg"].location];
                    [self.universalPicker selectRow:[weight intValue] inComponent:0 animated:NO];
                }else{
                    NSString *weight = [value substringToIndex:[value rangeOfString:@"lb"].location];
                    [self.universalPicker selectRow:[weight intValue] inComponent:0 animated:NO];
                }
            }
        }
    }else{
        
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    //    if (self.model.units == 1) {
    //        if (self.isHeight) {
    //            return 2;
    //        }
    //    }
    return 2;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.units == 0) {
        if (component == 0) {
            if (self.informationType == InformationType_Height) {
                return self.cmArray.count;
            }else{
                return self.kgArray.count;
            }
        }else{
            return 1;
        }
    }else{
        if (self.informationType == InformationType_Height) {
            if (component == 0) {
                return self.ftArray.count;
            }
            return self.inArray.count;
        }else{
            if (component == 0) {
                return self.lbArray.count;
            }else{
                return 1;
            }
        }
    }
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *str;
    if (self.units == 0) {
        if (component == 0) {
            if (self.informationType == InformationType_Height) {
                str = self.cmArray[row];
            }else{
                str = self.kgArray[row];
            }
        }else{
            if (self.informationType == InformationType_Height) {
                str = @"cm";
            }else{
                str = @"kg";
            }
        }
        
    }else{
        if (self.informationType == InformationType_Height) {
            if (component == 0) {
                str = self.ftArray[row];
            }else{
                str = self.inArray[row];
            }
        }else{
            if (component == 0) {
                str = self.lbArray[row];
            }else{
                str = @"lb";
            }
        }
    }
    return str;
    
}
-(void)setUnitArrayData{
    self.cmArray = [[NSMutableArray alloc]init];
    self.lbArray = [[NSMutableArray alloc]init];
    self.inArray = [[NSMutableArray alloc]init];
    self.ftArray = [[NSMutableArray alloc]init];
    self.kgArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < 300; i++){
        if (i < 9) {
            [self.ftArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (i < 12) {
            [self.inArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (i < 137) {
            [self.kgArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (i < 251) {
            [self.cmArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.lbArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    NSLog(@"%d , %d , %d , %d , %d",(int)self.cmArray.count,(int)self.lbArray.count,(int)self.inArray.count,(int)self.ftArray.count,(int)self.kgArray.count);
}
@end
