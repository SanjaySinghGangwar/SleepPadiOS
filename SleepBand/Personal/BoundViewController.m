//
//  BoundViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "BoundViewController.h"
#import "SelectAreaCodeViewController.h"


@interface BoundViewController ()<UITextFieldDelegate>
@property (strong,nonatomic)UITextField *phoneNumCountryField;
@property (strong,nonatomic)UILabel *phoneNumAreacodeLabel;
@property (strong,nonatomic)UITextField *phoneNumTextField;
@property (strong,nonatomic)UITextField *emailTextField;
@property (strong,nonatomic)UITextField *codeField;
@property (strong,nonatomic)UIButton *sendBtn;
@property (strong,nonatomic)NSTimer *sendTimer;
@property (assign,nonatomic)int sendTime;
@property (copy,nonatomic)NSString *countryCode;
@property (copy,nonatomic)NSString *language;
@end

@implementation BoundViewController
-(void)dealloc{
    [self.sendTimer invalidate];
    self.sendTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.phoneNumCountryField) {
        [self selectCountry];
        return NO;
    }
    return YES;
}

#pragma mark - 选择国家
-(void)selectCountry
{
    WS(weakSelf);
    
    SelectAreaCodeViewController *selectAreaCode = [[SelectAreaCodeViewController alloc] init];
    selectAreaCode.selectAreaCodeBlock = ^(NSString *area, NSString *language,NSString *code) {
        weakSelf.phoneNumCountryField.text = area;
        weakSelf.phoneNumAreacodeLabel.text = [NSString stringWithFormat:@"+%d",[code intValue]];
        weakSelf.countryCode = code;
        weakSelf.language = language;
    };
    [self.navigationController pushViewController:selectAreaCode animated:YES];
}

#pragma mark - 检查信息
-(BOOL)checkInputInformation
{
    if (!self.isPhone)
    {
        //检查邮箱格式
        NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
        if(![pre evaluateWithObject:self.emailTextField.text]){
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"LVC_AlertEmailFormatError", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            return NO;
        }
    }else{
        
        //检查纯数字
        NSString *phoneStr = [self.phoneNumTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        if(phoneStr.length > 0) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"LVC_AlertPhoneFormatError", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            return NO;
            
        }
    }
    return YES;
}
#pragma mark - 发送验证码
-(void)codeSend
{
    WS(weakSelf);
    if ((self.phoneNumCountryField.text > 0 && self.phoneNumTextField.text.length > 0) || self.emailTextField.text.length > 0) {
        if([self checkInputInformation]){
            if (self.sendBtn.userInteractionEnabled) {
                NSDictionary *dict;
                if(self.isPhone){
                    dict = @{
                             @"type":@"1",
                             @"areaCode":self.countryCode,
                             @"phoneNumber":self.phoneNumTextField.text,
                             @"email":@""
                             };
                    
                }else
                {
                    dict = @{
                             @"type":@"2",
                             @"areaCode":@"",
                             @"phoneNumber":@"",
                             @"email":self.emailTextField.text
                             };
                }
                if (self.sendTimer == nil) {
                    self.sendTime = 60;
                    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
                }
                [self.sendTimer setFireDate:[NSDate date]];
                [[MSCoreManager sharedManager] getVerificationCodeForData:dict WithResponse:^(ResponseInfo *info) {
                    if ([info.code isEqualToString:@"200"]) {
                        
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendSuccess", nil)];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        
                    }else
                    {
                        [SVProgressHUD showErrorWithStatus:info.message];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        [weakSelf.sendTimer setFireDate:[NSDate distantFuture]];
                        weakSelf.sendTime = 60;
                        weakSelf.sendBtn.userInteractionEnabled = YES;
                        [weakSelf.sendBtn setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
                    }
                }];
            }
        }
    }else
    {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}

-(void)exitEdit
{
    [self.view endEditing:YES];
}

#pragma mark - 倒数
-(void)countDown
{
    if (self.sendTime == 1) {
        [self.sendTimer setFireDate:[NSDate distantFuture]];
        self.sendTime = 60;
        self.sendBtn.userInteractionEnabled = YES;
        [self.sendBtn setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
    }else{
        if (self.sendTime == 60) {
            self.sendBtn.userInteractionEnabled = NO;
        }
        self.sendTime -- ;
        [self.sendBtn setTitle:[NSString stringWithFormat:@"%ds",self.sendTime] forState:UIControlStateNormal];
    }
}

-(void)submit
{
    WS(weakSelf);
    [SVProgressHUD show];
    NSString *account = self.emailTextField.text.length ? self.emailTextField.text : self.phoneNumTextField.text;
    
    if (!self.isBound) {
        //绑定
        [[MSCoreManager sharedManager] postBindEmailOrPhoneForAccount:account WithCode:self.codeField.text areaCode:self.countryCode isPhone:self.isPhone WithResponse:^(ResponseInfo *info) {
            [SVProgressHUD dismiss];
            if ([info.code isEqualToString:@"200"]) {
                NSString *alert = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"AVC_Bind", nil),NSLocalizedString(@"Success", nil)];;
                [SVProgressHUD showSuccessWithStatus:alert];
                [NSThread sleepForTimeInterval:0.5];
                [SVProgressHUD dismiss];
                weakSelf.bindBlock(weakSelf.isPhone, weakSelf.isBound, account);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                [SVProgressHUD showErrorWithStatus:info.message];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }];
    }else{
        //解绑
        [[MSCoreManager sharedManager] postBindEmailOrPhoneWithIsPhone:self.isPhone WithResponse:^(ResponseInfo *info) {
            [SVProgressHUD dismiss];
            if ([info.code isEqualToString:@"200"]) {
                NSString *alert;
                alert = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"AVC_CancelBind", nil),NSLocalizedString(@"Success", nil)];
                [SVProgressHUD showSuccessWithStatus:alert];
                [NSThread sleepForTimeInterval:0.5];
                [SVProgressHUD dismiss];
                weakSelf.bindBlock(weakSelf.isPhone, weakSelf.isBound, account);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                [SVProgressHUD showErrorWithStatus:info.message];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
        }];
    }
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUI
{
    WS(weakSelf);
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitEdit)]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"signup_icon_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(0);
        make.width.equalTo(@54);
        make.height.equalTo(@44);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.isPhone) {
        if(!self.isBound){
            titleLabel.text = NSLocalizedString(@"AVC_BindPhone", nil);
        }else{
            titleLabel.text = NSLocalizedString(@"AVC_CancelBind", nil);
        }
    }else{
        if(!self.isBound){
            titleLabel.text = NSLocalizedString(@"AVC_BindEmail", nil);
        }else{
            titleLabel.text = NSLocalizedString(@"AVC_CancelBind", nil);
        }
    }
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.codeField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.codeField.textColor = textFieldTextColor;
    self.codeField.font = textFieldTextFont;
    self.codeField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *codeHolderText = NSLocalizedString(@"RVC_CodePlaceholder", nil);
    NSMutableAttributedString *codeTextHolder = [[NSMutableAttributedString alloc] initWithString:codeHolderText];
    [codeTextHolder addAttribute:NSForegroundColorAttributeName
                           value:textFieldPlaceholderColor
                           range:NSMakeRange(0, codeHolderText.length)];
    self.codeField.attributedPlaceholder = codeTextHolder;
    //左侧
    UIView *codePaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *codeLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    codeLeftIV.image = [UIImage imageNamed:@"signup_icon_sms"];
    [codePaddingLeftView addSubview:codeLeftIV];
    self.codeField.leftView = codePaddingLeftView;
    self.codeField.leftViewMode = UITextFieldViewModeAlways;
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendBtn setTitle:NSLocalizedString(@"RVC_Send", nil) forState:UIControlStateNormal];
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightLight];
    [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"#575756"] forState:UIControlStateNormal];
    self.sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //    self.forgotButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    //    [self.view addSubview:self.forgotButton];
    CGSize sendSize = [self.sendBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.sendBtn.titleLabel.font}];
    [self.sendBtn addTarget:self action:@selector(codeSend) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn.frame = CGRectMake(0, (textFieldHeight-27)/2, sendSize.width+1, 27);
    self.codeField.rightView = self.sendBtn;
    self.codeField.rightViewMode = UITextFieldViewModeAlways;
    self.codeField.delegate = self;
    
    [self.view addSubview:self.codeField];
    
    UIView *codeTextLineV = [[UIView alloc]init];
    codeTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:codeTextLineV];

    
    if (self.isPhone) {
        [self setPhoneUI];
        [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.phoneNumTextField.mas_bottom).offset(1);
            make.left.right.equalTo(weakSelf.phoneNumTextField);
            make.height.equalTo(@(textFieldHeight));
        }];
    }else{
        [self setEmailUI];
        [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.emailTextField.mas_bottom).offset(1);
            make.left.right.equalTo(weakSelf.emailTextField);
            make.height.equalTo(@(textFieldHeight));
        }];
    }
    
    [codeTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.codeField.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.codeField);
        make.height.equalTo(@1);
    }];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:submitBtn];
    [submitBtn setImage:[UIImage imageNamed:@"me_btn_save"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(codeTextLineV.mas_bottom).offset(55+150);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@45);
        make.height.equalTo(@36);
    }];

    UILabel *btnTitleL = [[UILabel alloc]init];
    btnTitleL.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    btnTitleL.textColor = [UIColor colorWithHexString:@"#575756"];
    btnTitleL.textAlignment = NSTextAlignmentCenter;
    if (!self.isBound) {
        btnTitleL.text = NSLocalizedString(@"Submit", nil);
    }else{
        btnTitleL.text = NSLocalizedString(@"AVC_CancelBind", nil);
    }
    [self.view addSubview:btnTitleL];
    [btnTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(submitBtn.mas_bottom).offset(10);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@100);
        make.height.equalTo(@12);
    }];
    
    UIImageView *bottomImageV = [[UIImageView alloc]init];
    bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
    [self.view addSubview:bottomImageV];
    [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
    }];
}

-(void)setUI2
{
    WS(weakSelf);
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitEdit)]];
    
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"signup_icon_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(0);
        make.width.equalTo(@54);
        make.height.equalTo(@44);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.isPhone) {
        if(!self.isBound){
            titleLabel.text = NSLocalizedString(@"AVC_BindPhone", nil);
        }else{
            titleLabel.text = NSLocalizedString(@"AVC_CancelBind", nil);
        }
    }else{
        if(!self.isBound){
            titleLabel.text = NSLocalizedString(@"AVC_BindEmail", nil);
        }else{
            titleLabel.text = NSLocalizedString(@"AVC_CancelBind", nil);
        }
    }
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    //通用视图
    UIView *codeView = [[UIView alloc]init];
    codeView.layer.cornerRadius = textFieldCornerRadius;
    codeView.alpha = kAlpha;
    codeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:codeView];

    self.codeField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.codeField.textColor = textFieldTextColor;
    self.codeField.font = textFieldTextFont;
    self.codeField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *codeTextHolderText = NSLocalizedString(@"RVC_CodePlaceholder", nil);
    NSMutableAttributedString *codeTextHolder = [[NSMutableAttributedString alloc] initWithString:codeTextHolderText];
    [codeTextHolder addAttribute:NSForegroundColorAttributeName
                           value:textFieldPlaceholderColor
                           range:NSMakeRange(0, codeTextHolderText.length)];
    [codeTextHolder addAttribute:NSFontAttributeName
                           value:textFieldTextFont
                           range:NSMakeRange(0, codeTextHolderText.length)];
    self.codeField.attributedPlaceholder = codeTextHolder;
    UIView *codePaddingLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, textFieldHeight)];
    self.codeField.leftView = codePaddingLeftView;
    self.codeField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *codePaddingRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, textFieldHeight)];
    //验证码发送按钮
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.frame = CGRectMake(1, 5, 59, textFieldHeight-10);
    [self.sendBtn setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [codePaddingRightView addSubview:self.sendBtn];
    [self.sendBtn addTarget:self action:@selector(codeSend) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    UIView *sendPaddingLine = [[UIView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-20)/2, 1, 20)];
    sendPaddingLine.backgroundColor = [UIColor whiteColor];
    [codePaddingRightView addSubview:sendPaddingLine];
    self.codeField.rightView = codePaddingRightView;
    self.codeField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:self.codeField];
    [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(codeView);
    }];
    
    if (self.isPhone) {
        [self setPhoneUI];
        [codeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+50+textFieldHeight*2+textFieldMarginTop*2);
            make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
            make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
            make.height.equalTo(@(textFieldHeight));
        }];
    }else{
        [self setEmailUI];
        [codeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+50+textFieldHeight+textFieldMarginTop);
            make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
            make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
            make.height.equalTo(@(textFieldHeight));
        }];
    }
    
    UIButton *SubmitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:SubmitBtn];
    if (!self.isBound) {
        [SubmitBtn setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    }else{
        [SubmitBtn setTitle:NSLocalizedString(@"AVC_CancelBind", nil) forState:UIControlStateNormal];
    }
    [SubmitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [SubmitBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    SubmitBtn.backgroundColor = [UIColor whiteColor];
    SubmitBtn.alpha = kButtonAlpha;
    SubmitBtn.layer.cornerRadius = textFieldCornerRadius;
    [SubmitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(codeView.mas_bottom).offset(55);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
        make.height.equalTo(@(textFieldHeight));
    }];
}
-(void)setPhoneUI{
    WS(weakSelf);
//    UIView *phoneNumCountryView = [[UIView alloc]init];
//    phoneNumCountryView.layer.cornerRadius = textFieldCornerRadius;
//    phoneNumCountryView.alpha = kAlpha;
//    phoneNumCountryView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:phoneNumCountryView];
//    [phoneNumCountryView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+50);
//        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
//        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin);
//        make.height.equalTo(@(textFieldHeight));
//    }];
    
    
    self.phoneNumCountryField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.phoneNumCountryField.textColor = textFieldTextColor;
    self.phoneNumCountryField.font = textFieldTextFont;
    self.phoneNumCountryField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *holderText = NSLocalizedString(@"LVC_PhoneCountryPlaceholder", nil);
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName
                        value:textFieldPlaceholderColor
                        range:NSMakeRange(0, holderText.length)];
    [placeholder addAttribute:NSFontAttributeName
                        value:textFieldTextFont
                        range:NSMakeRange(0, holderText.length)];
    self.phoneNumCountryField.attributedPlaceholder = placeholder;
    //左侧
    UIView *countryPaddingLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *countryLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    countryLeftIV.image = [UIImage imageNamed:@"signup_icon_country"];
    [countryPaddingLeftView addSubview:countryLeftIV];
    self.phoneNumCountryField.leftView = countryPaddingLeftView;
    self.phoneNumCountryField.leftViewMode = UITextFieldViewModeAlways;
    //右侧
    UIView *countryPaddingRightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, textFieldHeight)];
    UIImageView *countryRightIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 46)];
    countryRightIV.image = [UIImage imageNamed:@"signup_country_arrow"];
    [countryPaddingRightView addSubview:countryRightIV];
    [countryPaddingRightView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectCountry)]];
    self.phoneNumCountryField.rightView = countryPaddingRightView;
    self.phoneNumCountryField.rightViewMode = UITextFieldViewModeAlways;
    self.phoneNumCountryField.delegate = self;
    [self.view addSubview:self.phoneNumCountryField];
//    CGSize phoneNumCountrySize = [self.phoneNumCountryField.text sizeWithAttributes:@{NSFontAttributeName:self.phoneNumCountryField.font}];
//    float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
    [self.phoneNumCountryField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *phoneNumCountryLineV = [[UIView alloc]init];
    phoneNumCountryLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:phoneNumCountryLineV];
    [phoneNumCountryLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.phoneNumCountryField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.phoneNumCountryField);
        make.height.equalTo(@1);
    }];
    
    self.phoneNumTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumTextField.textColor = self.phoneNumCountryField.textColor;
    self.phoneNumTextField.font = self.phoneNumCountryField.font;
    self.phoneNumTextField.backgroundColor = self.phoneNumCountryField.backgroundColor;
    //placeholder
    NSString *phoneNumHolderText = NSLocalizedString(@"LVC_PhonePlaceholder", nil);
    NSMutableAttributedString *phoneNumHolder = [[NSMutableAttributedString alloc] initWithString:phoneNumHolderText];
    [phoneNumHolder addAttribute:NSForegroundColorAttributeName
                           value:textFieldPlaceholderColor
                           range:NSMakeRange(0, phoneNumHolderText.length)];
    [phoneNumHolder addAttribute:NSFontAttributeName
                           value:textFieldTextFont
                           range:NSMakeRange(0, phoneNumHolderText.length)];
    self.phoneNumTextField.attributedPlaceholder = phoneNumHolder;
    UIView *phoneNumPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *phoneNumPaddingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    phoneNumPaddingImageView.image = [UIImage imageNamed:@"signup_icon_phone"];
    [phoneNumPaddingLeftView addSubview: phoneNumPaddingImageView];
    
    self.phoneNumTextField.leftView = phoneNumPaddingLeftView;
    self.phoneNumTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //    UIView *phoneNumPaddingRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, textFieldHeight)];
    self.phoneNumAreacodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, textFieldHeight)];
    self.phoneNumAreacodeLabel.text = [NSString stringWithFormat:@"+%d",[self.countryCode intValue]];
    self.phoneNumAreacodeLabel.textColor = textFieldTextColor;
    self.phoneNumAreacodeLabel.textAlignment = NSTextAlignmentRight;
    self.phoneNumAreacodeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    //    self.phoneNumAreacodeLabel.text = @"+101";
    //    [phoneNumPaddingRightView addSubview: self.phoneNumAreacodeLabel];
    self.phoneNumTextField.rightView = self.phoneNumAreacodeLabel;
    self.phoneNumTextField.rightViewMode = UITextFieldViewModeAlways;
    self.phoneNumTextField.delegate = self;
    [self.view addSubview:self.phoneNumTextField];
    [self.phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumCountryField.mas_bottom).offset(textFieldMarginTop);
        make.left.right.equalTo(weakSelf.phoneNumCountryField);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *phoneNumAreacodeLineV = [[UIView alloc]init];
    phoneNumAreacodeLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:phoneNumAreacodeLineV];
    [phoneNumAreacodeLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.phoneNumTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.phoneNumTextField);
        make.height.equalTo(@1);
    }];
}
-(void)clearPhoneNumText{
    self.phoneNumTextField.text = @"";
}
-(void)clearEmailText{
    self.emailTextField.text = @"";
}
-(void)setEmailUI{
    WS(weakSelf);
    self.emailTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.emailTextField.textColor = textFieldTextColor;
    self.emailTextField.font = textFieldTextFont;
    self.emailTextField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *emailTextHolderText = NSLocalizedString(@"LVC_EmailPlaceholder", nil);
    NSMutableAttributedString *emailTextHolder = [[NSMutableAttributedString alloc] initWithString:emailTextHolderText];
    [emailTextHolder addAttribute:NSForegroundColorAttributeName
                            value:textFieldPlaceholderColor
                            range:NSMakeRange(0, emailTextHolderText.length)];
    [emailTextHolder addAttribute:NSFontAttributeName
                            value:textFieldTextFont
                            range:NSMakeRange(0, emailTextHolderText.length)];
    self.emailTextField.attributedPlaceholder = emailTextHolder;
    
    UIView *emailPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *emailLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    emailLeftIV.image = [UIImage imageNamed:@"signup_icon_email"];
    [emailPaddingLeftView addSubview:emailLeftIV];
    self.emailTextField.leftView = emailPaddingLeftView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    //    //自定义清除按钮
    //    UIButton *emailTextClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [emailTextClearButton setImage:[UIImage imageNamed:@"register_del"] forState:UIControlStateNormal];
    //    [emailTextClearButton addTarget:self action:@selector(clearEmailText) forControlEvents:UIControlEventTouchUpInside];
    //    [emailTextClearButton setFrame:CGRectMake(0, 0, 38, 38)];
    //    self.emailTextField.rightView = emailTextClearButton;
    //    self.emailTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.emailTextField.delegate = self;
    [self.view addSubview:self.emailTextField];
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *emailTextLineV = [[UIView alloc]init];
    emailTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:emailTextLineV];
    [emailTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.emailTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.emailTextField);
        make.height.equalTo(@1);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
