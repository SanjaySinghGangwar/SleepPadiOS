//
//  RegisterViewController.m
//  QLife
//
//  Created by admin on 2018/5/25.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "RegisterViewController.h"
#import "SelectAreaCodeViewController.h"
#import "ResetPasswordViewController.h"
#import <SafariServices/SafariServices.h>
#import "SearchDeviceViewController.h"
#import "AppDelegate.h"

@interface RegisterViewController ()<UITextFieldDelegate>
@property (strong,nonatomic)UIButton *emailBtn;
@property (strong,nonatomic)UIButton *phoneNumBtn;
@property (strong,nonatomic)UIView *emailView;
@property (strong,nonatomic)UIView *phoneNumView;
@property (strong,nonatomic)UIView *normalView; //验证码 下一步
@property (strong,nonatomic)UIView *emailLine;
@property (strong,nonatomic)UIView *phoneNumLine;
@property (strong,nonatomic)UITextField *phoneNumCountryField;
@property (strong,nonatomic)UILabel *phoneNumAreacodeLabel;
@property (strong,nonatomic)UITextField *phoneNumTextField;
@property (strong,nonatomic)UITextField *emailTextField;
@property (strong,nonatomic)UITextField *codeField;
@property (strong,nonatomic)UITextField *passwordTextField;
@property (strong,nonatomic)UITextField *confirmPasswordField;
@property (strong,nonatomic)UIButton *sendBtn;
@property (strong,nonatomic)NSTimer *sendTimer;
@property (strong,nonatomic)MSCoreManager *networkManager;
@property (assign,nonatomic)int sendTime;
@property (copy,nonatomic)NSString *countryCode;
@property (copy,nonatomic)NSString *language;
@property (strong,nonatomic)UIView *currencyView;
@property (strong,nonatomic)UIButton *agreeBtn;
@property (strong,nonatomic)AlertView *alertView;
@end

@implementation RegisterViewController
-(void)dealloc{
    [self.sendTimer invalidate];
    self.sendTimer = nil;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
-(MSCoreManager *)networkManager{
    if (_networkManager == nil) {
        _networkManager = [MSCoreManager sharedManager];
    }
    return _networkManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.countryCode = @"0086";
    [self setUI];
}
#pragma mark - 选择注册方式
-(void)selectRegisterType:(UIButton *)sender{
    WS(weakSelf);
    //    self.emailTextField.text = @"";
    //    self.codeField.text = @"";
    //    self.phoneNumCountryField.text = @"";
    //    self.phoneNumAreacodeLabel.text = @"";
    //    self.phoneNumTextField.text = @"";
    //    self.countryCode = @"";
    //    self.language = @"";
    
    if(sender == self.phoneNumBtn && !self.phoneNumBtn.selected){
        [self exitEdit];
        self.emailBtn.selected = NO;
        self.emailLine.hidden = YES;
        self.emailView.hidden = YES;
        
        self.emailTextField.text = @"";
        self.passwordTextField.text = @"";
        self.codeField.text = @"";
        self.confirmPasswordField.text = @"";
        
        
        self.phoneNumBtn.selected = YES;
        self.phoneNumLine.hidden = NO;
        self.phoneNumView.hidden = NO;
        
        [self.sendTimer setFireDate:[NSDate distantFuture]];
        self.sendTime = 60;
        self.sendBtn.userInteractionEnabled = YES;
        [self.sendBtn setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
        
        [self.currencyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.phoneNumView.mas_bottom).offset(0);
            make.left.right.equalTo(weakSelf.phoneNumView);
            make.height.equalTo(@(textFieldHeight*3));
        }];
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        return;
    }
    if(sender == self.emailBtn && !self.emailBtn.selected){
        [self exitEdit];
        
        self.phoneNumCountryField.text = @"";
        self.phoneNumAreacodeLabel.text = @"";
        self.phoneNumTextField.text = @"";
        self.passwordTextField.text = @"";
        self.codeField.text = @"";
        self.confirmPasswordField.text = @"";
        
        CGSize phoneNumCountrySize = [self.phoneNumCountryField.placeholder sizeWithAttributes:@{NSFontAttributeName:self.phoneNumCountryField.font}];
        float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
        [self.phoneNumCountryField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(phoneNumCountryWidth+5));
        }];
        
        self.phoneNumBtn.selected = NO;
        self.phoneNumLine.hidden = YES;
        self.phoneNumView.hidden = YES;
        
        [self.sendTimer setFireDate:[NSDate distantFuture]];
        self.sendTime = 60;
        self.sendBtn.userInteractionEnabled = YES;
        [self.sendBtn setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
        
        self.emailBtn.selected = YES;
        self.emailLine.hidden = NO;
        self.emailView.hidden = NO;
        
        //        [self.currencyView mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.top.mas_equalTo(weakSelf.emailView.mas_bottom).offset(0);
        //        }];
        [self.currencyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.emailView.mas_bottom).offset(0);
            make.left.right.equalTo(weakSelf.emailView);
            make.height.equalTo(@(textFieldHeight*3));
        }];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    WS(weakSelf);
    if (textField == self.phoneNumCountryField) {
        [self exitEdit];
        [self selectCountry];
        return NO;
    }else{
        __block CGRect rect = self.view.frame;
        if (rect.origin.y == 0) {
            [UIView animateWithDuration: 0.3 animations: ^{
                rect.origin.y -= 150;
                weakSelf.view.frame = rect;
            } completion: nil];
        }
    }
    return YES;
}
-(void)agreePrivacyPolicies{
    [self exitEdit];
    BOOL select = self.agreeBtn.selected;
    self.agreeBtn.selected = !select;
}
-(void)showPrivacyPolicies{
    [self exitEdit];
    NSURL *url;
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if([[appLanguages objectAtIndex:0] rangeOfString:@"zh-Han"].length > 0){
        url = [NSURL URLWithString:PRIVACYPOLICYCN];
    }else{
        url = [NSURL URLWithString:PRIVACYPOLICYEN];
    }
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safariVC animated:YES completion:nil];
}
#pragma mark - 选择国家
-(void)selectCountry{
    WS(weakSelf);
    SelectAreaCodeViewController *selectAreaCode = [[SelectAreaCodeViewController alloc] init];
    selectAreaCode.selectAreaCodeBlock = ^(NSString *area,NSString *language, NSString *code) {
        weakSelf.phoneNumCountryField.text = area;
        CGSize phoneNumCountrySize = [weakSelf.phoneNumCountryField.text sizeWithAttributes:@{NSFontAttributeName:weakSelf.phoneNumCountryField.font}];
        float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
        [weakSelf.phoneNumCountryField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(phoneNumCountryWidth+5));
        }];
        weakSelf.phoneNumAreacodeLabel.text = [NSString stringWithFormat:@"+%d",[code intValue]];
        weakSelf.countryCode = [NSString stringWithFormat:@"00%d",[code intValue]];
        weakSelf.language = language;
    };
    [self.navigationController pushViewController:selectAreaCode animated:YES];
}
#pragma mark - 发送验证码
-(void)codeSend{
    WS(weakSelf);
    if ((self.phoneNumCountryField.text > 0 && self.phoneNumTextField.text.length > 0) || self.emailTextField.text.length > 0) {
        if([self checkRegistrationInformation]){
            if (self.sendBtn.userInteractionEnabled) {
                [self exitEdit];
                NSDictionary *dict;
                
                if(self.phoneNumTextField.text.length > 0){
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
                [self.networkManager getVerificationCodeForData:dict WithResponse:^(ResponseInfo *info) {
                    if ([info.code isEqualToString:@"200"]) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendSuccess", nil)];
                        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    }else{
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
    }else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}
#pragma mark - 倒数
-(void)countDown{
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
#pragma mark - 检查注册信息
-(BOOL)checkRegistrationInformation{
    if (self.emailBtn.selected) {
        //检查邮箱格式
        NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
        if(![pre evaluateWithObject:self.emailTextField.text]){
            [self alert:NSLocalizedString(@"LVC_AlertEmailFormatError", nil)];
            return NO;
        }
    }else{
        //检查纯数字
        NSString *phoneStr = [self.phoneNumTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        if(phoneStr.length > 0) {
            [self alert:NSLocalizedString(@"LVC_AlertPhoneFormatError", nil)];
            return NO;
        }
    }
    return YES;
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
#pragma mark - 注册
-(void)signIn{
    WS(weakSelf);
    if (((self.phoneNumCountryField.text > 0 && self.phoneNumTextField.text.length > 0) || self.emailTextField.text.length > 0) && self.codeField.text.length >0 && self.passwordTextField.text.length >0 && self.confirmPasswordField.text.length >0) {
        if([self checkRegistrationInformation]){
            if ([self.passwordTextField.text isEqualToString:self.confirmPasswordField.text]) {
                [SVProgressHUD show];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
                
                NSDictionary *dict = @{
                                       @"type":weakSelf.phoneNumBtn.selected ? @"1" : @"2",
                                       @"phoneNumber":self.phoneNumTextField.text,
                                       @"email":self.emailTextField.text,
                                       @"areaCode":self.countryCode,
                                       @"password":self.passwordTextField.text,
                                       @"verifyCode":self.codeField.text
                                       };
                
                if (self.isRegister) {
                    //注册
                    [weakSelf.networkManager postRegisterForData:dict WithResponse:^(ResponseInfo *info) {
                        [SVProgressHUD dismiss];
                        if ([info.code isEqualToString:@"200"]) {
                            [weakSelf.sendTimer setFireDate:[NSDate distantFuture]];
                            weakSelf.sendTime = 60;
                            weakSelf.sendBtn.userInteractionEnabled = YES;
                            [weakSelf.sendBtn setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
                            [weakSelf login];
                        }else{
                            [weakSelf alert:info.message];
                        }
                    }];
                }else{
                    //忘记密码
                    [self.networkManager postSetPasswordForData:dict WithResponse:^(ResponseInfo *info) {
                        [SVProgressHUD dismiss];
                        if ([info.code isEqualToString:@"200"]) {
                            
                            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"RPVC_AlertResetSuccess", nil)];
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        }else{
                            [SVProgressHUD showErrorWithStatus:info.message];
                            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                        }
                    }];
                }
                
            }else{
                [self alert:NSLocalizedString(@"RPVC_AlertPasswordError", nil)];
            }
        }
    }else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}

//自动登录
-(void)login{
    WS(weakSelf);
    NSDictionary *dict = @{
                            @"areaCode":weakSelf.countryCode,
                            @"phoneNumber":weakSelf.phoneNumTextField.text,
                            @"password":weakSelf.passwordTextField.text,
                            @"project":@"sleep",
                            @"type":weakSelf.phoneNumBtn.selected ? @"1" : @"2",
                            @"email":weakSelf.emailTextField.text};
    [self.networkManager postLoginForData:dict WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            //创建用户
            [MSCoreManager sharedManager].userModel = [UserModel mj_objectWithKeyValues:info.data[@"userInfo"]];
            [MSCoreManager sharedManager].userModel.token = info.data[@"token"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"1" forKey:@"isLogin"];
            [defaults setObject:weakSelf.networkManager.userModel.deviceCode forKey:@"lastConnectDevice"];
            [defaults setObject:@{@"countryCode":dict[@"areaCode"],
                                  @"account":weakSelf.phoneNumBtn.selected ? dict[@"phoneNumber"] : dict[@"email"],
                                  @"password_phone":weakSelf.phoneNumBtn.selected ? dict[@"password"] : @"",
                                  @"password_mail":weakSelf.phoneNumBtn.selected ? @"" : dict[@"password"]
                                  } forKey:@"LoginMessage"];
            [defaults synchronize];
            //添加请求头
            [weakSelf.networkManager.httpManager setRequestHeader:@{@"token":info.data[@"token"]}];
            //存储账号密码
            NSString *serviceName= @"com.keychainSleepBandLoginAccount.data";
            NSString *account = weakSelf.phoneNumBtn.selected ? dict[@"phoneNumber"] : dict[@"email"];
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
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)exitEdit{
    WS(weakSelf);
    __block CGRect rect = weakSelf.view.frame;
    if (rect.origin.y != 0) {
        [UIView animateWithDuration: 0.3 animations: ^{
            rect.origin.y += 150;
            weakSelf.view.frame = rect;
        } completion: nil];
    }
    [self.view endEditing:YES];
}
-(void)clearPhoneNumText{
    self.phoneNumTextField.text = @"";
}
-(void)clearEmailText{
    self.emailTextField.text = @"";
}

#pragma mark - 密码是否可见 （密码明文/暗文）
//注册密码
-(void)changePasswordVisible:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.passwordTextField.secureTextEntry = !sender.selected;
}
//确认注册密码
-(void)changeConfirmPasswordVisible:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.confirmPasswordField.secureTextEntry = !sender.selected;
}

#pragma mark - 设置界面
-(void)setUI{
    WS(weakSelf);
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitEdit)]];
    
    UIImageView *rightImageView = [[UIImageView alloc]init];
    rightImageView.image = [UIImage imageNamed:@"signup_bgz"];
    [self.view addSubview:rightImageView];
    [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.right.equalTo(weakSelf.view.mas_right).offset(-20);
        make.width.equalTo(@53);
        make.height.equalTo(@88);
    }];
    
    UIImageView *iconImageView = [[UIImageView alloc]init];
    iconImageView.image = [UIImage imageNamed:@"signup_icon_logo"];
    [self.view addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+25);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@80);
        make.height.equalTo(@80);
    }];
    
    UIImageView *bottomImageView = [[UIImageView alloc]init];
    bottomImageView.image = [UIImage imageNamed:@"signup_bg_bottom"];
    [self.view addSubview:bottomImageView];
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
    }];
    
    //    UIImageView *bgImageView = [[UIImageView alloc]init];
    //    bgImageView.image = [UIImage imageNamed:@"bg"];
    //    [self.view addSubview:bgImageView];
    //    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.left.bottom.right.equalTo(weakSelf.view);
    //    }];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];

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
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"signup_icon_back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(0);
        make.width.equalTo(@54);
        make.height.equalTo(@44);
    }];
    
    //使用邮箱
    self.emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emailBtn setTitle:NSLocalizedString(@"LVC_EmailLogin", nil) forState:UIControlStateNormal];
    self.emailBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.emailBtn setTitleColor:[UIColor colorWithHexString:@"#B1ACA8"] forState:UIControlStateNormal];
    [self.emailBtn setTitleColor:[UIColor colorWithHexString:@"#1B86A4"] forState:UIControlStateSelected];
    [self.view addSubview:self.emailBtn];
    [self.emailBtn addTarget:self action:@selector(selectRegisterType:) forControlEvents:UIControlEventTouchUpInside];
    CGSize emailSize = [self.emailBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.emailBtn.titleLabel.font}];
    CGFloat spaceHeigh = kSCREEN_HEIGHT > 568 ? 30.0 : 0;
    
    [self.emailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconImageView.mas_bottom).offset(spaceHeigh);
        make.right.equalTo(weakSelf.view.mas_right).offset(-33);
        make.width.equalTo(@(emailSize.width+5));
        make.height.equalTo(@30);
    }];
    
    UIView *lineV = [[UIView alloc]init];
    lineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.emailBtn.mas_bottom).offset(0);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(33);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-33);
        make.height.equalTo(@1);
    }];
    
    self.emailLine = [[UIView alloc]init];
    self.emailLine.backgroundColor = [UIColor colorWithHexString:@"#1B86A4"];
    [self.view addSubview:self.emailLine];
    self.emailLine.hidden = YES;
    [self.emailLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.emailBtn.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf.emailBtn);
        make.width.equalTo(weakSelf.emailBtn);
        make.height.equalTo(@1);
    }];
    
    
    
    
    //使用电话号码
    self.phoneNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.phoneNumBtn setTitle:NSLocalizedString(@"LVC_PhoneLogin", nil) forState:UIControlStateNormal];
    self.phoneNumBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.phoneNumBtn.selected = YES;
    [self.phoneNumBtn setTitleColor:[UIColor colorWithHexString:@"#1B86A4"] forState:UIControlStateSelected];
    [self.phoneNumBtn setTitleColor:[UIColor colorWithHexString:@"#B1ACA8"] forState:UIControlStateNormal];
    [self.view addSubview:self.phoneNumBtn];
    [self.phoneNumBtn addTarget:self action:@selector(selectRegisterType:) forControlEvents:UIControlEventTouchUpInside];
    CGSize phoneSize = [self.phoneNumBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.phoneNumBtn.titleLabel.font}];
    [self.phoneNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.emailBtn);
        make.left.equalTo(weakSelf.view.mas_left).offset(33);
        make.width.equalTo(@(phoneSize.width+5));
        make.height.equalTo(weakSelf.emailBtn);
        
    }];
    
    
    self.phoneNumLine = [[UIView alloc]init];
    self.phoneNumLine.backgroundColor = [UIColor colorWithHexString:@"#1B86A4"];
    [self.view addSubview:self.phoneNumLine];
    [self.phoneNumLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumBtn.mas_bottom).offset(0);
        make.centerX.equalTo(weakSelf.phoneNumBtn);
        make.width.equalTo(weakSelf.emailBtn);
        make.height.equalTo(weakSelf.emailLine);
    }];
    
    self.phoneNumView = [[UIView alloc]init];
    [self.view addSubview:self.phoneNumView];
    [self.phoneNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumLine.mas_bottom).offset(0);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(33);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-33);
        make.height.equalTo(@(textFieldHeight*2));
    }];
    
    self.phoneNumCountryField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.phoneNumCountryField.text = NSLocalizedString(@"Country", nil);
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
    [self.phoneNumView addSubview:self.phoneNumCountryField];
    CGSize phoneNumCountrySize = [self.phoneNumCountryField.text sizeWithAttributes:@{NSFontAttributeName:self.phoneNumCountryField.font}];
    float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
    [self.phoneNumCountryField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(weakSelf.phoneNumView);
        make.width.equalTo(@(phoneNumCountryWidth+5));
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *phoneNumCountryLineV = [[UIView alloc]init];
    phoneNumCountryLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.phoneNumView addSubview:phoneNumCountryLineV];
    [phoneNumCountryLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.phoneNumCountryField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.phoneNumView);
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
    [self.phoneNumView addSubview:self.phoneNumTextField];
    [self.phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumCountryField.mas_bottom).offset(textFieldMarginTop);
        make.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *phoneNumAreacodeLineV = [[UIView alloc]init];
    phoneNumAreacodeLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.phoneNumView addSubview:phoneNumAreacodeLineV];
    [phoneNumAreacodeLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.phoneNumTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@1);
    }];
    
    
    
    
    
    
    
    self.emailView = [[UIView alloc]init];
    [self.view addSubview:self.emailView];
    self.emailView.hidden = YES;
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.phoneNumView);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(33);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-33);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    //    UIView *emailTextView = [[UIView alloc]init];
    //    //    emailTextView.layer.cornerRadius = textFieldCornerRadius;
    //    emailTextView.alpha = kAlpha;
    //    emailTextView.backgroundColor = [UIColor whiteColor];
    //    [self.emailView addSubview:emailTextView];
    //    [emailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.left.right.equalTo(weakSelf.emailView);
    //        make.height.equalTo(@(textFieldHeight));
    //    }];
    
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
    [self.emailView addSubview:self.emailTextField];
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakSelf.emailView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *emailTextLineV = [[UIView alloc]init];
    emailTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.emailView addSubview:emailTextLineV];
    [emailTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.emailTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.emailView);
        make.height.equalTo(@1);
    }];
    
    self.currencyView = [[UIView alloc]init];
    self.currencyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.currencyView];
    [self.currencyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumView.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@(textFieldHeight*3));
    }];
    
    self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.passwordTextField.secureTextEntry = true;
    self.passwordTextField.textColor = textFieldTextColor;
    self.passwordTextField.font = textFieldTextFont;
    self.passwordTextField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *passwordTextHolderText;
    if (self.isRegister) {
        passwordTextHolderText  = NSLocalizedString(@"RVC_SetPassword", nil);
    }else{
        passwordTextHolderText  = NSLocalizedString(@"FPVC_SetPassword", nil);
    }
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
    [self.currencyView addSubview:self.passwordTextField];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakSelf.currencyView);
        make.height.equalTo(@(textFieldHeight));
    }];
    //右侧
    UIButton *invisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invisibleBtn.frame =CGRectMake(0, (textFieldHeight-30)/2, 35, 35);
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_nosee"] forState:UIControlStateNormal];
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_see"] forState:UIControlStateSelected];
    [invisibleBtn addTarget:self action:@selector(changePasswordVisible:) forControlEvents:UIControlEventTouchUpInside];
    self.passwordTextField.rightView = invisibleBtn;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.delegate = self;
    
    UIView *passwordTextLineV = [[UIView alloc]init];
    passwordTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.currencyView addSubview:passwordTextLineV];
    [passwordTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.passwordTextField);
        make.height.equalTo(@1);
    }];
    
    
    self.confirmPasswordField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.confirmPasswordField.secureTextEntry = true;
    self.confirmPasswordField.textColor = textFieldTextColor;
    self.confirmPasswordField.font = textFieldTextFont;
    self.confirmPasswordField.backgroundColor = textFieldBackgroundColor;
    //placeholder
    NSString *confirmPasswordHolderText;
    if (self.isRegister) {
      confirmPasswordHolderText  = NSLocalizedString(@"RVC_ConfirmPassword", nil);
    }else{
        confirmPasswordHolderText  = NSLocalizedString(@"FPVC_ConfirmPassword", nil);
    }
    
    NSMutableAttributedString *confirmPasswordTextHolder = [[NSMutableAttributedString alloc] initWithString:confirmPasswordHolderText];
    [confirmPasswordTextHolder addAttribute:NSForegroundColorAttributeName
                                      value:textFieldPlaceholderColor
                                      range:NSMakeRange(0, confirmPasswordHolderText.length)];
    self.confirmPasswordField.attributedPlaceholder = confirmPasswordTextHolder;
    //左侧
    UIView *confirmPasswordPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *confirmPasswordLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    confirmPasswordLeftIV.image = [UIImage imageNamed:@"signup_icon_password"];
    [confirmPasswordPaddingLeftView addSubview:confirmPasswordLeftIV];
    self.confirmPasswordField.leftView = confirmPasswordPaddingLeftView;
    self.confirmPasswordField.leftViewMode = UITextFieldViewModeAlways;
    [self.currencyView addSubview:self.confirmPasswordField];
    [self.confirmPasswordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.currencyView);
        make.height.equalTo(@(textFieldHeight));
    }];
    //右侧
    UIButton *confirmInvisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmInvisibleBtn.frame =CGRectMake(0, (textFieldHeight-30)/2, 35, 35);
    [confirmInvisibleBtn setImage:[UIImage imageNamed:@"login_pwd_nosee"] forState:UIControlStateNormal];
    [confirmInvisibleBtn setImage:[UIImage imageNamed:@"login_pwd_see"] forState:UIControlStateSelected];
    [confirmInvisibleBtn addTarget:self action:@selector(changeConfirmPasswordVisible:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmPasswordField.rightView = confirmInvisibleBtn;
    self.confirmPasswordField.rightViewMode = UITextFieldViewModeAlways;
    self.confirmPasswordField.delegate = self;
    
    UIView *confirmPasswordTextLineV = [[UIView alloc]init];
    confirmPasswordTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.currencyView addSubview:confirmPasswordTextLineV];
    [confirmPasswordTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.confirmPasswordField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.confirmPasswordField);
        make.height.equalTo(@1);
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
    
    [self.currencyView addSubview:self.codeField];
    [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.confirmPasswordField.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.currencyView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    UIView *codeTextLineV = [[UIView alloc]init];
    codeTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.currencyView addSubview:codeTextLineV];
    [codeTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.codeField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.codeField);
        make.height.equalTo(@1);
    }];
    
    if (self.isRegister) {
        titleLabel.text = NSLocalizedString(@"RVC_Title", nil);
        [self setRegisterUI];
    }else{
        titleLabel.text = NSLocalizedString(@"FPVC_ForgotPassword", nil);
        [self setForgotPasswordUI];
    }
    
}

-(void)setForgotPasswordUI{
    WS(weakSelf);
    UIView *saveView = [[UIView alloc]init];
    [self.view addSubview:saveView];
    [saveView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signIn)]];
    
    
    UIImageView *saveImageView = [[UIImageView alloc]init];
    saveImageView.image = [UIImage imageNamed:@"me_btn_save"];
    [saveView addSubview:saveImageView];
    [saveImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(saveView.mas_top).offset(0);
        make.centerX.equalTo(saveView);
        make.width.equalTo(@45);
        make.height.equalTo(@36);
    }];
    
    UILabel *saveTitleL = [[UILabel alloc]init];
    [saveView addSubview:saveTitleL];
    saveTitleL.text = NSLocalizedString(@"Save", nil);
    saveTitleL.textColor = textFieldTextColor;
    saveTitleL.textAlignment = NSTextAlignmentCenter;
    saveTitleL.font = [UIFont systemFontOfSize:13];
    CGSize saveTitleSize = [saveTitleL.text sizeWithAttributes:@{NSFontAttributeName:saveTitleL.font}];
    [saveTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(saveImageView.mas_bottom).offset(5);
        make.centerX.equalTo(saveView);
        make.width.equalTo(@(saveTitleSize.width+5));
        make.height.equalTo(@13);
    }];
    
    [saveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-32-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@(saveTitleSize.width+5));
        make.height.equalTo(@55);
    }];
}

-(void)setRegisterUI
{
    WS(weakSelf);
    self.agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.agreeBtn];
    [self.agreeBtn setImage:[UIImage imageNamed:@"signup_icon_agreement_ok"] forState:UIControlStateSelected];
    [self.agreeBtn setImage:[UIImage imageNamed:@"signup_icon_agreement"] forState:UIControlStateNormal];
//    [self.agreeBtn setContentMode:UIViewContentModeCenter];
    [self.agreeBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 16, 8, 0)];
    [self.agreeBtn addTarget:self action:@selector(agreePrivacyPolicies) forControlEvents:UIControlEventTouchUpInside];
    [self.agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.currencyView.mas_bottom).offset(5);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(17);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    UILabel *agreeTitleL = [[UILabel alloc]init];
    [self.view addSubview:agreeTitleL];
    agreeTitleL.text = NSLocalizedString(@"RVC_AgreeTitle", nil);
    agreeTitleL.textColor = [UIColor colorWithHexString:@"#575756"];
    agreeTitleL.textAlignment = NSTextAlignmentLeft;
    agreeTitleL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    agreeTitleL.userInteractionEnabled = YES;
    [agreeTitleL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(agreePrivacyPolicies)]];
    [agreeTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.agreeBtn);
        make.left.mas_equalTo(weakSelf.agreeBtn.mas_right).offset(3);
        make.width.equalTo(@200);
        make.height.equalTo(@14);
    }];
    
    UILabel *agreePrivacyPoliciesL = [[UILabel alloc]init];
    [self.view addSubview:agreePrivacyPoliciesL];
    agreePrivacyPoliciesL.text = NSLocalizedString(@"RVC_AgreePrivacyPolicies", nil);
    agreePrivacyPoliciesL.textColor = [UIColor colorWithHexString:@"#1B86A4"];
    agreePrivacyPoliciesL.textAlignment = NSTextAlignmentLeft;
    agreePrivacyPoliciesL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    agreePrivacyPoliciesL.userInteractionEnabled = YES;
    [agreePrivacyPoliciesL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPrivacyPolicies)]];
    CGSize agreePrivacyPoliciesSize = [agreePrivacyPoliciesL.text sizeWithAttributes:@{NSFontAttributeName:agreePrivacyPoliciesL.font}];
    [agreePrivacyPoliciesL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(agreeTitleL.mas_bottom).offset(0);
        make.left.mas_equalTo(agreeTitleL.mas_left).offset(0);
        make.width.equalTo(@(agreePrivacyPoliciesSize.width+2));
        make.height.equalTo(@14);
    }];
    
    UIView *agreePrivacyPoliciesLineV = [[UIView alloc]init];
    agreePrivacyPoliciesLineV.backgroundColor = [UIColor colorWithHexString:@"#1B86A4"];
    [self.view addSubview:agreePrivacyPoliciesLineV];
    [agreePrivacyPoliciesLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(agreePrivacyPoliciesL.mas_bottom).offset(2);
        make.left.right.equalTo(agreePrivacyPoliciesL);
        make.height.equalTo(@1);
    }];
    
    UIView *signUpView = [[UIView alloc]init];
    [self.view addSubview:signUpView];
    [signUpView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signIn)]];
    
    
    UIImageView *signUpImageView = [[UIImageView alloc]init];
    signUpImageView.image = [UIImage imageNamed:@"signup_btn_signup"];
    [signUpView addSubview:signUpImageView];
    [signUpImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(signUpView.mas_top).offset(0);
        make.centerX.equalTo(signUpView);
        make.width.equalTo(@45);
        make.height.equalTo(@36);
    }];
    
    UILabel *signUpTitleL = [[UILabel alloc]init];
    [signUpView addSubview:signUpTitleL];
    signUpTitleL.text = NSLocalizedString(@"RVC_Title", nil);
    signUpTitleL.textColor = textFieldTextColor;
    signUpTitleL.textAlignment = NSTextAlignmentCenter;
    signUpTitleL.font = [UIFont systemFontOfSize:13];
    CGSize signUpTitleSize = [signUpTitleL.text sizeWithAttributes:@{NSFontAttributeName:signUpTitleL.font}];
    [signUpTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(signUpImageView.mas_bottom).offset(5);
        make.centerX.equalTo(signUpView);
        make.width.equalTo(@(signUpTitleSize.width+5));
        make.height.equalTo(@15);
    }];
    
    [signUpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-32-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@(signUpTitleSize.width+5));
        make.height.equalTo(@55);
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
