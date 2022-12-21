//
//  ResetPasswordViewController.m
//  QLife
//
//  Created by admin on 2018/5/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "AppDelegate.h"
#import "SearchDeviceViewController.h"

@interface ResetPasswordViewController ()
@property (strong,nonatomic) UITextField *passwordTextField;
@property (strong,nonatomic) UITextField *confirmPasswordTextField;
@property (strong,nonatomic)MSCoreManager *networkManager;
@property (strong,nonatomic)AlertView *alertView;


@end

@implementation ResetPasswordViewController
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkManager = [MSCoreManager sharedManager];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
}
#pragma mark - 密码是否可见
-(void)changePasswordVisible:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.passwordTextField.secureTextEntry = !sender.selected;
    
}
#pragma mark - 密码是否可见
-(void)changeConfirmPasswordVisible:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.confirmPasswordTextField.secureTextEntry = !sender.selected;
    
}
#pragma mark - 提醒（不带取消按钮）
-(void)alert:(NSString *)alertMessage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:alertMessage];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4d4d4d"] range:NSMakeRange(0, alertMessage.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, alertMessage.length)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:true completion:nil];
}
#pragma mark - 提交
-(void)checkInformation{
    [self exitEdit];
    if (self.passwordTextField.text.length > 0 && self.confirmPasswordTextField.text.length > 0 ) {
        //注销代码：UI逻辑改变，不需要校验对比两个密码。两个输入框为原密码和新密码，不在是新密码和确认新密码
//        if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
//            [self alert:NSLocalizedString(@"RPVC_AlertPasswordError", nil)];
//        }else{
//            if (self.resetPasswordType == ResetPasswordType_Register) {
//                [self registerUser];
//            }else if (self.resetPasswordType == ResetPasswordType_ChangePassword) {
//                [self changePassword];
//            }else{
//                [self resetPassword];
//            }
//        }
        if (self.resetPasswordType == ResetPasswordType_Register) {
            [self registerUser];
        }else if (self.resetPasswordType == ResetPasswordType_ChangePassword) {
            [self changePassword];
        }else{
            [self resetPassword];
        }
    }else{
        [self alert:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
    }
}
-(void)changePassword{
    WS(weakSelf);
//    NSDictionary *dict = @{
//                           @"userId":@([MSCoreManager sharedManager].userModel.userId),
//                           @"account":self.accountDict[@"account"],
//                           @"password":self.passwordTextField.text,
//                           @"confirmPassword":self.confirmPasswordTextField.text
//                           };
    NSDictionary *dict = @{
                           @"currentPassword":self.passwordTextField.text,
                           @"newPassword":self.confirmPasswordTextField.text
                           };
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [self.networkManager postEditPasswordForData:dict WithResponse:^(ResponseInfo *info) {
        [SVProgressHUD dismiss];
        if ([info.code isEqualToString:@"200"]) {
            [weakSelf resetSuccess:NSLocalizedString(@"RPVC_AlertResetSuccess", nil)];
        }else{
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
}
-(void)resetPassword{
    WS(weakSelf);
    NSDictionary *dict = @{
//                           @"userId":@([MSCoreManager sharedManager].userModel.userId),
                           @"account":self.accountDict[@"account"],
                           @"code":self.accountDict[@"code"],
                           @"password":self.passwordTextField.text,
                           @"confirmPassword":self.confirmPasswordTextField.text
                           };
//    NSDictionary *dicts = @{
//                           @"type":[NSString stringWithFormat:@"%@",self.accountDict[@"phoneNumber"]].length>0 ? @"1" : @"2",
//                           @"areaCode":self.accountDict[@"countryCode"],
//                           @"phoneNumber":self.accountDict[@"phoneNumber"],
//                           @"email":self.accountDict[@"email"],
//                           @"verifyCode":self.accountDict[@"code"],
//                           @"password":self.passwordTextField.text
//                           };

    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [self.networkManager postSetPasswordForData:dict WithResponse:^(ResponseInfo *info) {
        [SVProgressHUD dismiss];
        if ([info.code isEqualToString:@"200"]) {
            [weakSelf resetSuccess:NSLocalizedString(@"RPVC_AlertResetSuccess", nil)];
        }else{
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
    }];
}
-(void)resetSuccess:(NSString *)alertMessage{
    WS(weakSelf);
    [self.alertView showAlertWithoutCancelWithTitle:alertMessage type:AlertType_ResetPassword];
    self.alertView.alertCancelBlock = ^(AlertType type){
        if (type == AlertType_ResetPassword) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"0" forKey:@"isLogin"];
            [defaults synchronize];
            if (weakSelf.resetPasswordType == ResetPasswordType_ChangePassword) {
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [app setRootViewControllerForLogin];
            }else{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    };
    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    //    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:alertMessage];
    //    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4d4d4d"] range:NSMakeRange(0, alertMessage.length)];
    //    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, alertMessage.length)];
    //    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    //
    //    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //        [defaults setObject:@"0" forKey:@"isLogin"];
    //        [defaults synchronize];
    //        if (weakSelf.resetPasswordType == ResetPasswordType_ChangePassword) {
    //            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //            [app setRootViewControllerForLogin];
    //        }else{
    //            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    //        }
    //
    //    }];
    //    [alertController addAction:okAction];
    //    [self presentViewController:alertController animated:true completion:nil];
}
-(void)registerUser{
//    WS(weakSelf);
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.accountDict];
//
//    NSDictionary *dicts = @{
//                           @"type":[NSString stringWithFormat:@"%@",self.accountDict[@"phoneNumber"]].length>0 ? @"1" : @"2",
//                           @"phoneNumber":self.accountDict[@"phoneNumber"],
//                           @"email":self.accountDict[@"email"],
//                           @"areaCode":self.accountDict[@"countryCode"],
//                           @"password":self.passwordTextField.text,
//                           @"verifyCode":self.codeField.text
//                           };
//
//    [dict setObject:@"" forKey:@"nation"];
//    [dict setObject:self.passwordTextField.text forKey:@"password"];
//    [dict setObject:self.confirmPasswordTextField.text forKey:@"confirmPassword"];
//    [SVProgressHUD show];
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
//    [self.networkManager postRegisterForData:dict WithResponse:^(ResponseInfo *info) {
//        [SVProgressHUD dismiss];
//        if ([info.code isEqualToString:@"200"]) {
//            [weakSelf login];
//        }else{
//            [self alert:info.message];
//        }
//    }];
}
//自动登录
-(void)login{
    WS(weakSelf);
    NSDictionary *dict = @{
                           @"areaCode":self.accountDict[@"countryCode"],
                           @"phoneNumber":self.accountDict[@"phoneNumber"],
                           @"password":self.passwordTextField.text,
                           @"project":@"sleep",
                           @"type":[NSString stringWithFormat:@"%@",self.accountDict[@"phoneNumber"]].length>0 ? @"1" : @"2",
                           @"email":self.accountDict[@"email"]};
    
    [self.networkManager postLoginForData:dict WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            /* yes-手机登录  no-邮箱登录 */
            BOOL isPhoneAccount = [NSString stringWithFormat:@"%@",dict[@"phoneNumber"]].length > 0;
            //创建用户
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"1" forKey:@"isLogin"];
            [defaults setObject:weakSelf.networkManager.userModel.deviceCode forKey:@"lastConnectDevice"];
            [defaults setObject:@{@"countryCode":dict[@"areaCode"],
                                  @"account":isPhoneAccount ? dict[@"phoneNumber"] : dict[@"email"],
                                  @"password_phone":isPhoneAccount ? dict[@"password"] : @"",
                                  @"password_mail":isPhoneAccount ? @"" : dict[@"password"]
                                  } forKey:@"LoginMessage"];
            [defaults synchronize];
            //添加请求头
            [weakSelf.networkManager.httpManager setRequestHeader:@{@"token":info.data[@"token"]}];
            [weakSelf.networkManager.httpManager setRequestHeader:@{@"deviceCode":weakSelf.networkManager.userModel.deviceCode}];
            //存储账号密码
            NSString *serviceName= @"com.keychainSleepBandLoginAccount.data";
            NSString *account = [NSString stringWithFormat:@"%@",weakSelf.accountDict[@"phoneNumber"]].length>0 ? weakSelf.accountDict[@"phoneNumber"] : weakSelf.accountDict[@"email"];
            NSString *password = dict[@"password"];
            if ([SAMKeychain setPassword:password forService:serviceName account:account]) {
                NSLog(@"存储账号密码成功");
            }
            SearchDeviceViewController *search = [[SearchDeviceViewController alloc]initWithNibName:@"SearchDeviceViewController" bundle: [NSBundle mainBundle]];
            search.isPushWithLogin = YES;
            [weakSelf.navigationController pushViewController:search animated:YES];
        }else{
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}
#pragma mark - 返回
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)exitEdit{
    [self.view endEditing:YES];
}
#pragma mark - 设置界面
-(void)setUI{
    
    WS(weakSelf);
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitEdit)]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    UIImageView *bgImageView = [[UIImageView alloc]init];
    //    bgImageView.image = [UIImage imageNamed:@"bg"];
    //    [self.view addSubview:bgImageView];
    //    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.left.bottom.right.equalTo(weakSelf.view);
    //    }];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    if (self.resetPasswordType == ResetPasswordType_ChangePassword)
    {
        titleLabel.text = NSLocalizedString(@"AVC_ChangePasswordTitle", nil);
        
    }else
    {
        titleLabel.text = NSLocalizedString(@"RPVC_ResetPassword", nil);
    }
    titleLabel.font = kControllerTitleFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = kControllerTitleColor;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
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
    
    self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.passwordTextField.secureTextEntry = true;
    self.passwordTextField.textColor = textFieldTextColor;
    self.passwordTextField.font = textFieldTextFont;
    self.passwordTextField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *passwordTextHolderText;
    passwordTextHolderText  = NSLocalizedString(@"LVC_PasswordPlaceholder", nil);
    NSMutableAttributedString *passwordTextHolder = [[NSMutableAttributedString alloc] initWithString:passwordTextHolderText];
    [passwordTextHolder addAttribute:NSForegroundColorAttributeName
                               value:textFieldPlaceholderColor
                               range:NSMakeRange(0, passwordTextHolderText.length)];
    [passwordTextHolder addAttribute:NSFontAttributeName
                               value:textFieldTextFont
                               range:NSMakeRange(0, passwordTextHolderText.length)];
    self.passwordTextField.attributedPlaceholder = passwordTextHolder;
    //左侧
    UIView *passwordPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *passwordLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    passwordLeftIV.image = [UIImage imageNamed:@"signup_icon_password"];
    [passwordPaddingLeftView addSubview:passwordLeftIV];
    self.passwordTextField.leftView = passwordPaddingLeftView;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    //右侧
    UIButton *invisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invisibleBtn.frame =CGRectMake(0, (textFieldHeight-35)/2, 35, 35);
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_nosee"] forState:UIControlStateNormal];
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_see"] forState:UIControlStateSelected];
    [invisibleBtn addTarget:self action:@selector(changePasswordVisible:) forControlEvents:UIControlEventTouchUpInside];
    self.passwordTextField.rightView = invisibleBtn;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:self.passwordTextField];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *passwordTextLineV = [[UIView alloc]init];
    passwordTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:passwordTextLineV];
    [passwordTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.passwordTextField);
        make.height.equalTo(@1);
    }];
    
    
    self.confirmPasswordTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.confirmPasswordTextField.secureTextEntry = true;
    self.confirmPasswordTextField.textColor = textFieldTextColor;
    self.confirmPasswordTextField.font = textFieldTextFont;
    self.confirmPasswordTextField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *confirmPasswordHolderText;
//    confirmPasswordHolderText  = NSLocalizedString(@"RPVC_ConfirmPasswordPlaceholder", nil);
    confirmPasswordHolderText  = NSLocalizedString(@"FPVC_SetPassword", nil);
    NSMutableAttributedString *confirmPasswordTextHolder = [[NSMutableAttributedString alloc] initWithString:confirmPasswordHolderText];
    [confirmPasswordTextHolder addAttribute:NSForegroundColorAttributeName
                                      value:textFieldPlaceholderColor
                                      range:NSMakeRange(0, confirmPasswordHolderText.length)];
    self.confirmPasswordTextField.attributedPlaceholder = confirmPasswordTextHolder;
    //左侧
    UIView *confirmPasswordPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *confirmPasswordLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    confirmPasswordLeftIV.image = [UIImage imageNamed:@"signup_icon_password"];
    [confirmPasswordPaddingLeftView addSubview:confirmPasswordLeftIV];
    self.confirmPasswordTextField.leftView = confirmPasswordPaddingLeftView;
    self.confirmPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    //右侧
    UIButton *confirmInvisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmInvisibleBtn.frame =CGRectMake(0, (textFieldHeight-35)/2, 35, 35);
    [confirmInvisibleBtn setImage:[UIImage imageNamed:@"login_pwd_nosee"] forState:UIControlStateNormal];
    [confirmInvisibleBtn setImage:[UIImage imageNamed:@"login_pwd_see"] forState:UIControlStateSelected];
    [confirmInvisibleBtn addTarget:self action:@selector(changeConfirmPasswordVisible:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmPasswordTextField.rightView = confirmInvisibleBtn;
    self.confirmPasswordTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:self.confirmPasswordTextField];
    [self.confirmPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.passwordTextField);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *confirmPasswordTextLineV = [[UIView alloc]init];
    confirmPasswordTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:confirmPasswordTextLineV];
    [confirmPasswordTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.confirmPasswordTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.confirmPasswordTextField);
        make.height.equalTo(@1);
    }];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setImage:[UIImage imageNamed:@"me_btn_save"] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(checkInformation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(confirmPasswordTextLineV.mas_bottom).offset(50+150);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@45);
        make.height.equalTo(@36);
        
    }];
    
    UILabel *okBtnTitleL = [[UILabel alloc]init];
    okBtnTitleL.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    okBtnTitleL.textColor = [UIColor colorWithHexString:@"#575756"];
    okBtnTitleL.textAlignment = NSTextAlignmentCenter;
    okBtnTitleL.text = NSLocalizedString(@"Submit", nil);
    [self.view addSubview:okBtnTitleL];
    [okBtnTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(okBtn.mas_bottom).offset(10);
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
    
    self.alertView = [[AlertView alloc]initWithAlertWithoutCancel];
//    [self.view addSubview:self.alertView];
//    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.bottom.equalTo(weakSelf.view);
//    }];
    
}
-(void)setUI2{
    
    WS(weakSelf);
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitEdit)]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    UIImageView *bgImageView = [[UIImageView alloc]init];
    //    bgImageView.image = [UIImage imageNamed:@"bg"];
    //    [self.view addSubview:bgImageView];
    //    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.left.bottom.right.equalTo(weakSelf.view);
    //    }];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    if (self.resetPasswordType == ResetPasswordType_ChangePassword) {
        titleLabel.text = NSLocalizedString(@"AVC_ChangePasswordTitle", nil);
    }else{
        titleLabel.text = NSLocalizedString(@"RPVC_ResetPassword", nil);
    }
    titleLabel.font = kControllerTitleFont;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = kControllerTitleColor;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
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
    
    UIView *passwordTextView = [[UIView alloc]init];
    passwordTextView.layer.cornerRadius = textFieldCornerRadius;
    passwordTextView.alpha = kAlpha;
    passwordTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:passwordTextView];
    [passwordTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+22);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin*2);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-kMargin*2);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.passwordTextField.secureTextEntry = true;
    self.passwordTextField.textColor = textFieldTextColor;
    self.passwordTextField.font = textFieldTextFont;
    self.passwordTextField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *passwordTextHolderText = NSLocalizedString(@"LVC_PasswordPlaceholder", nil);
    NSMutableAttributedString *passwordTextHolder = [[NSMutableAttributedString alloc] initWithString:passwordTextHolderText];
    [passwordTextHolder addAttribute:NSForegroundColorAttributeName
                               value:textFieldPlaceholderColor
                               range:NSMakeRange(0, passwordTextHolderText.length)];
    [passwordTextHolder addAttribute:NSFontAttributeName
                               value:textFieldTextFont
                               range:NSMakeRange(0, passwordTextHolderText.length)];
    self.passwordTextField.attributedPlaceholder = passwordTextHolder;
    //左侧
    UIView *passwordPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 41, textFieldHeight)];
    UIImageView *passwordLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, (textFieldHeight-20)/2, 17, 20)];
    passwordLeftIV.image = [UIImage imageNamed:@"register_pwd"];
    [passwordPaddingLeftView addSubview:passwordLeftIV];
    self.passwordTextField.leftView = passwordPaddingLeftView;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    //右侧
    UIView *passwordPaddingRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, textFieldHeight)];
    UIButton *invisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invisibleBtn.frame =CGRectMake(6, (textFieldHeight-20)/2, 18, 20);
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_nosee"] forState:UIControlStateNormal];
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_see"] forState:UIControlStateSelected];
    [invisibleBtn addTarget:self action:@selector(changePasswordVisible:) forControlEvents:UIControlEventTouchUpInside];
    [passwordPaddingRightView addSubview:invisibleBtn];
    self.passwordTextField.rightView = passwordPaddingRightView;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.passwordTextField];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(passwordTextView);
    }];
    
    UIView *confirmPasswordTextView = [[UIView alloc]init];
    confirmPasswordTextView.layer.cornerRadius = textFieldCornerRadius;
    confirmPasswordTextView.alpha = kAlpha;
    confirmPasswordTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:confirmPasswordTextView];
    [confirmPasswordTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(textFieldMarginTop);
        make.left.right.equalTo(passwordTextView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    self.confirmPasswordTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.confirmPasswordTextField.secureTextEntry = true;
    self.confirmPasswordTextField.textColor = textFieldTextColor;
    self.confirmPasswordTextField.font = textFieldTextFont;
    self.confirmPasswordTextField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *confirmPasswordTextHolderText = NSLocalizedString(@"RPVC_ConfirmPasswordPlaceholder", nil);
    NSMutableAttributedString *confirmPasswordTextHolder = [[NSMutableAttributedString alloc] initWithString:confirmPasswordTextHolderText];
    [confirmPasswordTextHolder addAttribute:NSForegroundColorAttributeName
                                      value:textFieldPlaceholderColor
                                      range:NSMakeRange(0, confirmPasswordTextHolderText.length)];
    [confirmPasswordTextHolder addAttribute:NSFontAttributeName
                                      value:textFieldTextFont
                                      range:NSMakeRange(0, confirmPasswordTextHolderText.length)];
    self.confirmPasswordTextField.attributedPlaceholder = confirmPasswordTextHolder;
    //左侧
    UIView *confirmPasswordPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 41, textFieldHeight)];
    UIImageView *confirmPasswordLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, (textFieldHeight-20)/2, 17, 20)];
    confirmPasswordLeftIV.image = [UIImage imageNamed:@"register_pwd"];
    [confirmPasswordPaddingLeftView addSubview:confirmPasswordLeftIV];
    self.confirmPasswordTextField.leftView = confirmPasswordPaddingLeftView;
    self.confirmPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    //右侧
    UIView *confirmPasswordPaddingRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, textFieldHeight)];
    UIButton *confirmInvisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmInvisibleBtn.frame =CGRectMake(6, (textFieldHeight-20)/2, 18, 20);
    [confirmInvisibleBtn setImage:[UIImage imageNamed:@"login_pwd_nosee"] forState:UIControlStateNormal];
    [confirmInvisibleBtn setImage:[UIImage imageNamed:@"login_pwd_see"] forState:UIControlStateSelected];
    [confirmInvisibleBtn addTarget:self action:@selector(changeConfirmPasswordVisible:) forControlEvents:UIControlEventTouchUpInside];
    [confirmPasswordPaddingRightView addSubview:confirmInvisibleBtn];
    self.confirmPasswordTextField.rightView = confirmPasswordPaddingRightView;
    self.confirmPasswordTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.confirmPasswordTextField];
    [self.confirmPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(confirmPasswordTextView);
    }];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:NSLocalizedString(@"Submit", NIL) forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:nextButton];
    [nextButton addTarget:self action:@selector(checkInformation) forControlEvents:UIControlEventTouchUpInside];
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.alpha = kButtonAlpha;
    nextButton.layer.cornerRadius = textFieldCornerRadius;
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.confirmPasswordTextField.mas_bottom).offset(50);
        make.left.right.equalTo(passwordTextView);
        make.height.equalTo(@(textFieldHeight));
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
