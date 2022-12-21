//
//  LoginViewController.m
//  QLife
//
//  Created by admin on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "LoginViewController.h"
#import "SelectAreaCodeViewController.h"
#import "RegisterViewController.h"
//#import "ForgotPasswordViewController.h"
#import "AppDelegate.h"
#import "SearchDeviceViewController.h"
#import <SafariServices/SafariServices.h>



@interface LoginViewController ()<UINavigationControllerDelegate,UITextFieldDelegate>
@property (strong,nonatomic)UIButton *emailBtn;
@property (strong,nonatomic)UIButton *phoneNumBtn;
@property (strong,nonatomic)UIView *emailView;
@property (strong,nonatomic)UIView *phoneNumView;
@property (strong,nonatomic)UIView *normalView; //密码 登录 忘记密码 注册
@property (strong,nonatomic)UIView *emailLine;
@property (strong,nonatomic)UIView *phoneNumLine;
@property (strong,nonatomic)UITextField *phoneNumCountryField;
@property (strong,nonatomic)UILabel *phoneNumAreacodeLabel;
@property (strong,nonatomic)UITextField *phoneNumTextField;
@property (strong,nonatomic)IBOutlet UITextField *emailTextField;
@property (strong,nonatomic)IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong,nonatomic)UIButton *registerButton;
@property (strong,nonatomic)UIButton *forgotButton;
@property (strong,nonatomic)UIView *passwordTextView;
@property (strong,nonatomic)MSCoreManager *networkManager;
@property (copy,nonatomic)NSString *countryName;
@property (copy,nonatomic)NSString *countryCode;
@property (copy,nonatomic)NSString *password_phone;
@property (copy,nonatomic)NSString *password_mail;
@property (copy,nonatomic)NSString *phoneString;
@property (copy,nonatomic)NSString *emailString;
@property (strong,nonatomic)UIButton *rememberBtn;
@property (assign, nonatomic) BOOL isRemember;
@property (weak, nonatomic) IBOutlet UIImageView *signInSelectorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *signUpSelectorImageView;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UIView *signInView;

/// Sign up Fields
@property (weak, nonatomic) IBOutlet UITextField *signUpEmailField;
@property (weak, nonatomic) IBOutlet UITextField *signUpPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *signUpConfirmPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *signUpPinCodeField;

@property (strong,nonatomic)IBOutlet UIButton *signUpSendButton;
@property (strong,nonatomic)NSTimer *sendTimer;
@property (assign,nonatomic)int sendTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;


@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(BOOL)hasTopNotch {
    if (@available( iOS 11.0, * )) {
        if ([[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom > 0) {
            return YES;
        }
    }
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self hasTopNotch] == YES) {
        [self.heightConstraint setConstant:90];
    } else {
        [self.heightConstraint setConstant:60];
    }
    self.networkManager  = [MSCoreManager sharedManager];
    self.emailTextField.text = @"thehelpfulak@gmail.com";
    self.passwordTextField.text = @"12345678";
    //获取缓存User
    [self getLastAccount];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
}
//获取缓存User
- (void)getLastAccount{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isRemember = [defaults boolForKey:@"isRememberPassWord"];
    NSDictionary *loginMessage = [defaults objectForKey:@"LoginMessage"];
    //账号(邮箱/手机号)
    NSString * account = [loginMessage objectForKey:@"account"];
    if ([account rangeOfString:@"."].length > 0) {
        self.emailString = account;
        self.phoneString = @"";
    }else{
        self.emailString = @"";
        self.phoneString = account;
    }
    self.password_phone = [loginMessage objectForKey:@"password_phone"];
    self.password_mail = [loginMessage objectForKey:@"password_mail"];
    //国家code
    self.countryCode = [loginMessage objectForKey:@"countryCode"];
    //国家name
    self.countryName = @"";
    
    if (!self.countryCode || self.countryCode.length == 0) return;
    
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *filePath;
    //根据系统当前语言选择不同语言的区号文件
    if([[appLanguages objectAtIndex:0] rangeOfString:@"zh-Han"].length > 0){
        filePath = [[NSBundle mainBundle] pathForResource:@"TelephoneList" ofType:@"plist"];
    }else{
        //测试用
        filePath = [[NSBundle mainBundle] pathForResource:@"TelephoneListEN" ofType:@"plist"];
    }
    NSDictionary * areaDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSArray * areaDictKey = [[areaDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2){
        return [obj1 compare:obj2];
    }];
    for (NSString * key in areaDictKey) {
        NSArray * areaArr = [areaDict objectForKey:key];
        for (NSDictionary * dict in areaArr) {
            NSString * code = [dict objectForKey:@"code"];
            if ([code intValue] == [self.countryCode intValue]) {
                self.countryName = [dict objectForKey:@"country"];
                return;
            }
        }
    }
    
}

-(void)rememberPassword{
    
    [self exitEdit];
    BOOL select = self.rememberBtn.selected;
    self.rememberBtn.selected = !select;
    if (select) {
        NSLog(@"取消记住密码");
    }else{
        NSLog(@"记住密码");
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"firstLogin"] == nil  || [[defaults objectForKey:@"firstLogin"] isEqualToString:@"0"]) {
//        [self showPrivacyPolocy];
    }
}
//显示使用条款和隐私政策
-(void)showPrivacyPolocy{
    NSURL *url;
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if([[appLanguages objectAtIndex:0] rangeOfString:@"zh-Han"].length > 0){
        url = [NSURL URLWithString:PRIVACYPOLICYCN];
    }else{
        url = [NSURL URLWithString:PRIVACYPOLICYEN];
    }
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safariVC animated:YES completion:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"firstLogin"];
    [defaults synchronize];
}
#pragma mark - 检查输入数据
-(void)checkRegistrationInformation{
    [self exitEdit];
    if (self.phoneNumBtn.selected) {
        if(self.phoneNumCountryField.text.length > 0  && self.phoneNumTextField.text.length > 0 && self.passwordTextField.text.length > 0){
            //检查纯数字
            NSString *phoneStr = [self.phoneNumTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            if(phoneStr.length > 0) {
                [self alert:NSLocalizedString(@"LVC_AlertPhoneFormatError", nil)];
            }else{
                NSDictionary *dict = @{@"areaCode":self.countryCode,
                                       @"password":self.passwordTextField.text,
                                       @"phoneNumber":self.phoneNumTextField.text,
                                       @"password_phone":self.passwordTextField.text,
                                       @"project":@"sleep",
                                       @"type":@"1",
                                       @"email":@"",
                                       @"password_mail":@"",
                                       };
                [self loginWithDict:dict];
            }
        }else{
            [self alert:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
        }
    }else{
        if(self.emailTextField.text.length > 0 && self.passwordTextField.text.length > 0){
            NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
            if(![pre evaluateWithObject:self.emailTextField.text]){
                [self alert:NSLocalizedString(@"LVC_AlertEmailFormatError", nil)];
            }else{
                NSDictionary *dict = @{@"areaCode":@"",
                                       @"password":self.passwordTextField.text,
                                       @"phoneNumber":@"",
                                       @"password_phone":@"",
                                       @"project":@"sleep",
                                       @"type":@"2",
                                       @"email":self.emailTextField.text,
                                       @"password_mail":self.passwordTextField.text
                                       };
                [self loginWithDict:dict];
            }
        }else{
            [self alert:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
        }
    }
}
#pragma mark - 登录
-(void)loginWithDict:(NSDictionary *)dict{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    WS(weakSelf);
    NSLog(@"dict = %@",dict);
    [self.networkManager postLoginForData:dict WithResponse:^(ResponseInfo *info) {
        [SVProgressHUD dismiss];
        if ([info.code isEqualToString:@"200"]) {//Authorization
            //登录成功
            //创建用户 deviceCode
            weakSelf.networkManager.userModel = [UserModel mj_objectWithKeyValues:info.data[@"userInfo"]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            weakSelf.networkManager.userModel.token = info.data[@"token"];
            [defaults setObject:weakSelf.networkManager.userModel.deviceCode forKey:@"lastConnectDevice"];
//            [defaults setObject:@"" forKey:@"lastConnectDevice"];
            [defaults setObject:@"1" forKey:@"isLogin"];
            [defaults setObject:@{@"countryCode":dict[@"areaCode"],
                                  @"account":[[dict objectForKey:@"email"] isEqualToString:@""] ? dict[@"phoneNumber"] : dict[@"email"],
                                  @"password_phone":dict[@"password_phone"],
                                  @"password_mail":dict[@"password_mail"]
                                  } forKey:@"LoginMessage"];
            [defaults synchronize];
            
            [weakSelf.networkManager.httpManager setRequestHeader:@{@"token":info.data[@"token"]}];
            
            //登录成功
            [weakSelf loginSuccess:nil];
            //重置心率呼吸率开关状态
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isOpenHrRrNotify"];
            //保存"记住密码"按钮状态
            [[NSUserDefaults standardUserDefaults] setBool:self.rememberBtn.selected forKey:@"isRememberPassWord"];
            self.isRemember = self.rememberBtn.selected;
        }else{
            [self alert:info.message];
        }
    }];
    
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

-(void)loginSuccess:(NSString *)token
{
    //存储账号密码
    NSString *serviceName= @"com.keychainSleepBandLoginAccount.data";
    NSString *account = self.phoneNumTextField.text.length ? self.phoneNumTextField.text:self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    if ([SAMKeychain setPassword:password forService:serviceName account:account]) {
        NSLog(@"存储账号密码成功");
    }
    
//    self.emailTextField.text = @"";
//    self.phoneNumCountryField.text = @"";
//    self.phoneNumAreacodeLabel.text = @"";
//    self.phoneNumTextField.text = @"";
    if (!self.isRemember) {
        self.passwordTextField.text = @"";
    }
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //  有连接过设备就跳到主界面，并在主界面连接设备
    if ([defaults stringForKey:@"lastConnectDevice"].length > 1) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app setRootViewControllerForSleep];
        
        if ([BlueToothManager shareIsnstance].centralManager.state != CBManagerStatePoweredOn) return;
        if([BlueToothManager shareIsnstance].isScan) return;
        if([BlueToothManager shareIsnstance].isConnect) return;
        //搜索所有蓝牙外-(登录自动连接蓝牙)
        [[BlueToothManager shareIsnstance] scanAllPeripheral];
        
    }else{
        //  没有连接过设备就跳到选择设备界面
        SearchDeviceViewController *search = [[SearchDeviceViewController alloc]initWithNibName:@"SearchDeviceViewController" bundle: [NSBundle mainBundle]];
        search.isPushWithLogin = YES;
        [self.navigationController pushViewController:search animated:YES];
    }
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
            make.width.equalTo(@(phoneNumCountryWidth));
        }];
        weakSelf.countryCode = [NSString stringWithFormat:@"00%d",[code intValue]];
        weakSelf.phoneNumAreacodeLabel.text = [NSString stringWithFormat:@"+%d",[code intValue]];
    };
    [self.navigationController pushViewController:selectAreaCode animated:YES];
}
#pragma mark - 密码是否可见 （密码明文/暗文）
-(void)changePasswordVisible:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.passwordTextField.secureTextEntry = !sender.selected;
}
#pragma mark - 注册
-(void)registerUser{
    RegisterViewController *registerView = [[RegisterViewController alloc]init];
    registerView.isRegister = YES;
    [self.navigationController pushViewController:registerView animated:YES];
}
#pragma mark - 忘记密码
-(void)forgotPassword{
    [self exitEdit];
    [self.navigationController pushViewController:[[RegisterViewController alloc] init] animated:YES];
}

#pragma mark - Selector actions

- (IBAction)signInSelectorClicked:(id)sender {
    [self hideSelectorViews];
    [_signInView setHidden:FALSE];
    [_signInSelectorImageView setHidden:FALSE];
}
- (IBAction)signUpSelectorClicked:(id)sender {
    [self hideSelectorViews];
    [_signUpView setHidden:FALSE];
    [_signUpSelectorImageView setHidden:FALSE];
}

-(void)hideSelectorViews {
    [_signInSelectorImageView setHidden:YES];
    [_signUpSelectorImageView setHidden:YES];
    [_signInView setHidden:YES];
    [_signUpView setHidden:YES];
}

#pragma mark - Sign up Actions

- (IBAction)btnSignUpClicked:(id)sender {
    [self signUp];
}
- (IBAction)btnSendPinCodeClicked:(id)sender {
    [self codeSend];
}

-(void)codeSend {
    WS(weakSelf);
    if (self.signUpEmailField.text.length > 0) {
        if([self checkSignUpInformation]){
            if (self.signUpSendButton.userInteractionEnabled) {
                [self exitEdit];
                NSDictionary *dict;
                
                dict = @{
                         @"type":@"2",
                         @"areaCode":@"",
                         @"phoneNumber":@"",
                         @"email":self.signUpEmailField.text
                         };

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
                        weakSelf.signUpSendButton.userInteractionEnabled = YES;
                        [weakSelf.signUpSendButton setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
                    }
                }];
            }
        }
    }else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}

-(void)countDown{
    if (self.sendTime == 1) {
        [self.sendTimer setFireDate:[NSDate distantFuture]];
        self.sendTime = 60;
        self.signUpSendButton.userInteractionEnabled = YES;
        [self.signUpSendButton setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
    }else{
        if (self.sendTime == 60) {
            self.signUpSendButton.userInteractionEnabled = NO;
        }
        self.sendTime -- ;
        [self.signUpSendButton setTitle:[NSString stringWithFormat:@"%ds",self.sendTime] forState:UIControlStateNormal];
    }
    
}

-(BOOL)checkSignUpInformation {
    //检查邮箱格式
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    if(![pre evaluateWithObject:self.signUpEmailField.text]){
        [self alert:NSLocalizedString(@"LVC_AlertEmailFormatError", nil)];
        return NO;
    }
    return YES;
}

-(void)signUp{
    WS(weakSelf);
    if ((self.signUpEmailField.text.length > 0) && self.signUpPinCodeField.text.length >0 && self.signUpPasswordField.text.length >0 && self.signUpConfirmPasswordField.text.length >0) {
        if([self checkSignUpInformation]){
            if ([self.signUpPasswordField.text isEqualToString:self.signUpConfirmPasswordField.text]) {
                [SVProgressHUD show];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
                
                NSDictionary *dict = @{
                                       @"type": @"2",
                                       @"phoneNumber": @"",
                                       @"email": self.signUpEmailField.text,
                                       @"areaCode": @"",
                                       @"password": self.signUpPasswordField.text,
                                       @"verifyCode":self.signUpPinCodeField.text
                                       };
                
                    //注册
                    [weakSelf.networkManager postRegisterForData:dict WithResponse:^(ResponseInfo *info) {
                        [SVProgressHUD dismiss];
                        if ([info.code isEqualToString:@"200"]) {
                            [weakSelf.sendTimer setFireDate:[NSDate distantFuture]];
                            weakSelf.sendTime = 60;
                            weakSelf.signUpSendButton.userInteractionEnabled = YES;
                            [weakSelf.signUpSendButton setTitle:NSLocalizedString(@"RVC_Send", NIL) forState:UIControlStateNormal];
                            [weakSelf login];
                        }else{
                            [weakSelf alert:info.message];
                        }
                    }];
                
            }else{
                [self alert:NSLocalizedString(@"RPVC_AlertPasswordError", nil)];
            }
        }
    }else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"LVC_AlertInputEmpty", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
}

-(void)login{
    WS(weakSelf);
    NSDictionary *dict = @{
                            @"areaCode":weakSelf.countryCode,
                            @"phoneNumber":weakSelf.phoneNumTextField.text,
                            @"password":weakSelf.signUpPasswordField.text,
                            @"project":@"sleep",
                            @"type": @"2",
                            @"email":weakSelf.signUpEmailField.text};
    [self.networkManager postLoginForData:dict WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            //创建用户
            [MSCoreManager sharedManager].userModel = [UserModel mj_objectWithKeyValues:info.data[@"userInfo"]];
            [MSCoreManager sharedManager].userModel.token = info.data[@"token"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"1" forKey:@"isLogin"];
            [defaults setObject:weakSelf.networkManager.userModel.deviceCode forKey:@"lastConnectDevice"];
            [defaults setObject:@{@"countryCode":dict[@"areaCode"],
                                  @"account": dict[@"email"],
                                  @"password_phone":@"",
                                  @"password_mail":dict[@"password"]
                                  } forKey:@"LoginMessage"];
            [defaults synchronize];
            //添加请求头
            [weakSelf.networkManager.httpManager setRequestHeader:@{@"token":info.data[@"token"]}];
            //存储账号密码
            NSString *serviceName= @"com.keychainSleepBandLoginAccount.data";
            NSString *account = dict[@"email"];
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
#pragma mark - 手势监听 (测试/正式，服务器域名切换)
-(void)tapIconImg:(UITapGestureRecognizer *)sender{
    
    //弹窗确认，切换域名
    NSString * msg = @"当前域名:***";
    if([GET_NetWork_URL_Head isEqualToString:NetWork_URL_Head_test]){
        msg = @"当前域名:测试域名";
     }
    if([GET_NetWork_URL_Head isEqualToString:NetWork_URL_Head_cloud]){
        msg = @"当前域名:正式域名";
     }
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"切换域名" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *test = [UIAlertAction actionWithTitle:@"测试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:NetWork_URL_Head_test forKey:@"the_sleepee_http_url_head"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    UIAlertAction *cloud = [UIAlertAction actionWithTitle:@"正式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:NetWork_URL_Head_cloud forKey:@"the_sleepee_http_url_head"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [actionSheet addAction:cancel];
    [actionSheet addAction:test];
    [actionSheet addAction:cloud];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(void)exitEdit{
    WS(weakSelf);
    __block CGRect rect = weakSelf.view.frame;
    if (rect.origin.y != 0) {
        [UIView animateWithDuration: 0.3 animations: ^{
            rect.origin.y += 100;
            weakSelf.view.frame = rect;
        } completion: nil];
    }
    [self.view endEditing:YES];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    WS(weakSelf);
//    if (textField == self.phoneNumCountryField) {
//        [self exitEdit];
//        [self selectCountry];
//        return NO;
//    }else{
//        __block CGRect rect = self.view.frame;
//        if (rect.origin.y == 0) {
//            [UIView animateWithDuration: 0.3 animations: ^{
//                rect.origin.y -= 100;
//                weakSelf.view.frame = rect;
//            } completion: nil];
//        }
//    }
    return YES;
}
//-(void)refreshUI{
//    if (self.phoneNumView) {
//        if (self.phoneNumCountryField.text.length > 0) {
//            CGSize phoneNumCountrySize = [self.phoneNumCountryField.text sizeWithAttributes:@{NSFontAttributeName:self.phoneNumCountryField.font}];
//            float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
//            [self.phoneNumCountryField mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.equalTo(@(phoneNumCountryWidth));
//            }];
//        }else{
//            CGSize phoneNumCountrySize = [self.phoneNumCountryField.placeholder sizeWithAttributes:@{NSFontAttributeName:self.phoneNumCountryField.font}];
//            float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
//            [self.phoneNumCountryField mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.equalTo(@(phoneNumCountryWidth));
//            }];
//        }
//
//    }
//}
-(void)selectLoginType:(UIButton *)sender{
    WS(weakSelf);
    if(sender == self.phoneNumBtn && !self.phoneNumBtn.selected){
        [self exitEdit];
        self.emailBtn.selected = NO;
        self.emailLine.hidden = YES;
        self.emailView.hidden = YES;
        self.emailTextField.text = self.emailString;
        if (self.isRemember) {
            self.passwordTextField.text = self.password_phone;
        }else{
            self.passwordTextField.text = @"";
        }
        
        self.phoneNumBtn.selected = YES;
        self.phoneNumLine.hidden = NO;
        self.phoneNumView.hidden = NO;
        
        [self.passwordTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.phoneNumLine.mas_bottom).offset(textFieldHeight*2);
        }];
        
        //        [self.view layoutIfNeeded];
        return;
    }
    if(sender == self.emailBtn && !self.emailBtn.selected){
        [self exitEdit];
        self.phoneNumBtn.selected = NO;
        self.phoneNumLine.hidden = YES;
        self.phoneNumView.hidden = YES;
        self.phoneNumCountryField.text = self.countryName;
        self.phoneNumAreacodeLabel.text = self.countryCode;
        self.phoneNumTextField.text = self.phoneString;
        if (self.isRemember) {
            self.passwordTextField.text = self.password_mail;
        }else{
            self.passwordTextField.text = @"";
        }
        
        
        CGSize phoneNumCountrySize = [self.phoneNumCountryField.placeholder sizeWithAttributes:@{NSFontAttributeName:self.phoneNumCountryField.font}];
        float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
        [self.phoneNumCountryField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(phoneNumCountryWidth));
        }];
        
        
        self.emailBtn.selected = YES;
        self.emailLine.hidden = NO;
        self.emailView.hidden = NO;
        
        [self.passwordTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.phoneNumLine.mas_bottom).offset(textFieldHeight);
        }];
    }
}
-(void)clearPhoneNumText{
    self.phoneNumTextField.text = @"";
}
-(void)clearEmailText{
    self.emailTextField.text = @"";
}
#pragma mark - 设置界面
-(void)setUI{
    WS(weakSelf);
    
    [self.loginButton setTitle:NSLocalizedString(@"LVC_Title", nil) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(checkRegistrationInformation) forControlEvents:UIControlEventTouchUpInside];

    return;
    
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
    iconImageView.image = [UIImage imageNamed:@"login_icon_logo"];
    [self.view addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(rightImageView.mas_bottom).offset(-10);
        make.left.equalTo(weakSelf.view.mas_left).offset(33);
        make.width.equalTo(@158);
        make.height.equalTo(@37);
    }];
    iconImageView.userInteractionEnabled = YES;
    //创建手势 使用initWithTarget:action:的方法创建
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapIconImg:)];
    //设置轻拍次数
    tap.numberOfTapsRequired = 5;
    //设置手指字数
    tap.numberOfTouchesRequired = 1;
    //别忘了添加到testView上
    [iconImageView addGestureRecognizer:tap];
    
    UIImageView *bottomImageView = [[UIImageView alloc]init];
    bottomImageView.image = [UIImage imageNamed:@"signup_bg_bottom"];
    [self.view addSubview:bottomImageView];
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
    }];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitEdit)]];
    
    //使用邮箱
    self.emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emailBtn setTitle:NSLocalizedString(@"LVC_EmailLogin", nil) forState:UIControlStateNormal];
    self.emailBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.emailBtn setTitleColor:[UIColor colorWithHexString:@"#B1ACA8"] forState:UIControlStateNormal];
    [self.emailBtn setTitleColor:[UIColor colorWithHexString:@"#1B86A4"] forState:UIControlStateSelected];
    [self.view addSubview:self.emailBtn];
    [self.emailBtn addTarget:self action:@selector(selectLoginType:) forControlEvents:UIControlEventTouchUpInside];
    CGSize emailSize = [self.emailBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.emailBtn.titleLabel.font}];
    [self.emailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconImageView.mas_bottom).offset(20);
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
    [self.phoneNumBtn addTarget:self action:@selector(selectLoginType:) forControlEvents:UIControlEventTouchUpInside];
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
    
    UIView *phoneNumCountryView = [[UIView alloc]init];
    phoneNumCountryView.layer.cornerRadius = textFieldCornerRadius;
    phoneNumCountryView.alpha = kAlpha;
    phoneNumCountryView.backgroundColor = [UIColor whiteColor];
    [self.phoneNumView addSubview:phoneNumCountryView];
    [phoneNumCountryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    //国家name
    self.phoneNumCountryField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.phoneNumCountryField.text = self.countryName;
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
    CGSize phoneNumCountrySize = [self.phoneNumCountryField.placeholder sizeWithAttributes:@{NSFontAttributeName:self.phoneNumCountryField.font}];
    float phoneNumCountryWidth = phoneNumCountrySize.width+20+45;
    [self.phoneNumCountryField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(phoneNumCountryView);
        make.width.equalTo(@(phoneNumCountryWidth));
    }];
    
    UIView *phoneNumCountryLineV = [[UIView alloc]init];
    phoneNumCountryLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.phoneNumView addSubview:phoneNumCountryLineV];
    [phoneNumCountryLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.phoneNumCountryField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@1);
    }];
    
    UIView *phoneNumTextView = [[UIView alloc]init];
    phoneNumTextView.layer.cornerRadius = textFieldCornerRadius;
    phoneNumTextView.alpha = kAlpha;
    phoneNumTextView.backgroundColor = [UIColor whiteColor];
    [self.phoneNumView addSubview:phoneNumTextView];
    [phoneNumTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumCountryField.mas_bottom).offset(textFieldMarginTop);
        make.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    //手机号
    self.phoneNumTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumTextField.textColor = self.phoneNumCountryField.textColor;
    self.phoneNumTextField.font = self.phoneNumCountryField.font;
    self.phoneNumTextField.text = self.phoneString;
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
    
    //国家code
    self.phoneNumAreacodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, textFieldHeight)];
    self.phoneNumAreacodeLabel.text = self.countryCode;
    self.phoneNumAreacodeLabel.textColor = textFieldTextColor;
    self.phoneNumAreacodeLabel.textAlignment = NSTextAlignmentRight;
    self.phoneNumAreacodeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    self.phoneNumTextField.rightView = self.phoneNumAreacodeLabel;
    self.phoneNumTextField.rightViewMode = UITextFieldViewModeAlways;
    self.phoneNumTextField.delegate = self;
    [self.phoneNumView addSubview:self.phoneNumTextField];
    [self.phoneNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(phoneNumTextView);
    }];
    
    UIView *phoneNumAreacodeLineV = [[UIView alloc]init];
    phoneNumAreacodeLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.phoneNumView addSubview:phoneNumAreacodeLineV];
    [phoneNumAreacodeLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.phoneNumTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@1);
    }];
    
    

    
    [self.phoneNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumLine.mas_bottom).offset(0);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(33);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-33);
        make.bottom.mas_equalTo(weakSelf.phoneNumTextField.mas_bottom).offset(0);
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
    
    UIView *emailTextView = [[UIView alloc]init];
//    emailTextView.layer.cornerRadius = textFieldCornerRadius;
    emailTextView.alpha = kAlpha;
    emailTextView.backgroundColor = [UIColor whiteColor];
    [self.emailView addSubview:emailTextView];
    [emailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakSelf.emailView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    self.emailTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.emailTextField.textColor = textFieldTextColor;
    self.emailTextField.font = textFieldTextFont;
    self.emailTextField.backgroundColor = textFieldBackgroundColor;
    self.emailTextField.text = self.emailString;
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
        make.top.left.right.bottom.equalTo(emailTextView);
    }];
    
    UIView *emailTextLineV = [[UIView alloc]init];
    emailTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.emailView addSubview:emailTextLineV];
    [emailTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.emailTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.emailView);
        make.height.equalTo(@1);
    }];
    
    

    
    
    self.passwordTextView = [[UIView alloc]init];
    self.passwordTextView.layer.cornerRadius = textFieldCornerRadius;
    self.passwordTextView.alpha = kAlpha;
    self.passwordTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.passwordTextView];
    [self.passwordTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.phoneNumLine.mas_bottom).offset(textFieldHeight*2);
        make.left.right.equalTo(weakSelf.phoneNumView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    self.passwordTextField.secureTextEntry = true;
    self.passwordTextField.textColor = textFieldTextColor;
    self.passwordTextField.font = textFieldTextFont;
    self.passwordTextField.backgroundColor = textFieldBackgroundColor;
    if (self.isRemember) {
        self.passwordTextField.text = self.password_phone;
    }else{
        self.passwordTextField.text = @"";
    }
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
    UIView *passwordPaddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, textFieldHeight)];
    UIImageView *passwordLeftIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (textFieldHeight-27)/2, 27, 27)];
    passwordLeftIV.image = [UIImage imageNamed:@"signup_icon_password"];
    [passwordPaddingLeftView addSubview:passwordLeftIV];
    self.passwordTextField.leftView = passwordPaddingLeftView;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    //右侧
    CGSize forgotSize = [NSLocalizedString(@"LVC_ForgotPassword", nil) sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0 weight:UIFontWeightLight]}];
    UIView *passwordPaddingRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, forgotSize.width+35+5, textFieldHeight)];
    
    self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotButton setTitle:NSLocalizedString(@"LVC_ForgotPassword", nil) forState:UIControlStateNormal];
    self.forgotButton.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightLight];
    [self.forgotButton setTitleColor:[UIColor colorWithHexString:@"#575756"] forState:UIControlStateNormal];
    self.forgotButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.forgotButton addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
    self.forgotButton.frame = CGRectMake(passwordPaddingRightView.frame.size.width - forgotSize.width, (textFieldHeight-27)/2, forgotSize.width, 27);
    [passwordPaddingRightView addSubview:self.forgotButton];
    
    UIButton *invisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invisibleBtn.frame =CGRectMake(0, (textFieldHeight-30)/2, 35, 35);
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_nosee"] forState:UIControlStateNormal];
    [invisibleBtn setImage:[UIImage imageNamed:@"login_pwd_see"] forState:UIControlStateSelected];
    [invisibleBtn addTarget:self action:@selector(changePasswordVisible:) forControlEvents:UIControlEventTouchUpInside];
    [passwordPaddingRightView addSubview:invisibleBtn];
    
    self.passwordTextField.rightView = passwordPaddingRightView;
    self.passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.delegate = self;
    
    [self.view addSubview:self.passwordTextField];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(weakSelf.passwordTextView);
    }];
    
    UIView *passwordTextLineV = [[UIView alloc]init];
    passwordTextLineV.backgroundColor = [UIColor colorWithHexString:@"#B1ACA8"];
    [self.view addSubview:passwordTextLineV];
    [passwordTextLineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(-1);
        make.left.right.equalTo(weakSelf.passwordTextField);
        make.height.equalTo(@1);
    }];
    
    self.rememberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.rememberBtn];
    [self.rememberBtn setImage:[UIImage imageNamed:@"signup_icon_agreement_ok"] forState:UIControlStateSelected];
    [self.rememberBtn setImage:[UIImage imageNamed:@"signup_icon_agreement"] forState:UIControlStateNormal];
    [self.rememberBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 16, 8, 0)];
    [self.rememberBtn addTarget:self action:@selector(rememberPassword) forControlEvents:UIControlEventTouchUpInside];
    self.rememberBtn.selected = self.isRemember;
    [self.rememberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(5);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(17);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    UILabel *rememberL = [[UILabel alloc]init];
    [self.view addSubview:rememberL];
    rememberL.text = NSLocalizedString(@"LVC_RememberPassword", nil);
    rememberL.textColor = [UIColor colorWithHexString:@"#575756"];
    rememberL.textAlignment = NSTextAlignmentLeft;
    rememberL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    rememberL.userInteractionEnabled = YES;
    [rememberL addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rememberPassword)]];
    [rememberL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.rememberBtn);
        make.left.mas_equalTo(weakSelf.rememberBtn.mas_right).offset(3);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setTitle:NSLocalizedString(@"LVC_Register", nil) forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [self.registerButton setTitleColor:[UIColor colorWithHexString:@"#1B86A4"] forState:UIControlStateNormal];
    [self.view addSubview:self.registerButton];
    [self.registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    CGSize registerUserSize = [self.registerButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.registerButton.titleLabel.font}];
    [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view.mas_bottom).offset(-40-kTabbarSafeHeight);
        make.width.equalTo(@(registerUserSize.width+1));
        make.height.equalTo(@13);
    }];
    
    
    UIView *registerLine = [[UIView alloc]init];
    registerLine.backgroundColor = [UIColor colorWithHexString:@"#1B86A4"];
    [self.view addSubview:registerLine];
    [registerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.registerButton.mas_bottom).offset(2);
        make.centerX.equalTo(weakSelf.registerButton);
        make.width.equalTo(weakSelf.registerButton);
        make.height.equalTo(@1);
    }];
    
    UIView *loginView = [[UIView alloc]init];
    [self.view addSubview:loginView];
    [loginView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(checkRegistrationInformation)]];

    
    UIImageView *loginImageView = [[UIImageView alloc]init];
    loginImageView.image = [UIImage imageNamed:@"login_btn_login"];
    [loginView addSubview:loginImageView];
    [loginImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(loginView.mas_top).offset(0);
        make.centerX.equalTo(loginView);
        make.width.equalTo(@45);
        make.height.equalTo(@37);
    }];
    
    UILabel *loginTitleL = [[UILabel alloc]init];
    [loginView addSubview:loginTitleL];
    loginTitleL.text = NSLocalizedString(@"LVC_Title", nil);
    loginTitleL.textColor = textFieldTextColor;
    loginTitleL.textAlignment = NSTextAlignmentCenter;
    loginTitleL.font = [UIFont systemFontOfSize:13];
    CGSize loginTitleSize = [loginTitleL.text sizeWithAttributes:@{NSFontAttributeName:loginTitleL.font}];
    [loginTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(loginImageView.mas_bottom).offset(5);
        make.centerX.equalTo(loginView);
        make.width.equalTo(@(loginTitleSize.width+5));
        make.height.equalTo(@15);
    }];
    
    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.registerButton.mas_top).offset(-50);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@(loginTitleSize.width+5));
        make.height.equalTo(@55);
    }];
    
    
//    [self noPrivacyPolicy];
}
//界面没有隐私条款
-(void)noPrivacyPolicy{
    WS(weakSelf);
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setTitle:NSLocalizedString(@"LVC_Register", nil) forState:UIControlStateNormal];
    self.registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.registerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.registerButton];
    CGSize registerSize = [self.registerButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.registerButton.titleLabel.font}];
    [self.registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarSafeHeight-45);
        make.right.mas_equalTo(weakSelf.view.mas_centerX).offset(-30);
        make.width.equalTo(@(registerSize.width+30));
        make.height.equalTo(@26);
    }];
    
    
    
    UILabel *registerLine = [[UILabel alloc]initWithFrame:CGRectZero];
    registerLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:registerLine];
    [registerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarSafeHeight-45);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@1);
        make.height.equalTo(@26);
    }];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:NSLocalizedString(@"LVC_Title", nil) forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    self.loginButton.backgroundColor = [UIColor whiteColor];
    self.loginButton.alpha = kButtonAlpha;
    self.loginButton.layer.cornerRadius = textFieldCornerRadius;
    [self.view addSubview:self.loginButton];
    [self.loginButton addTarget:self action:@selector(checkRegistrationInformation) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.passwordTextField.mas_bottom).offset(50);
        make.left.right.equalTo(weakSelf.emailView);
        make.height.equalTo(@(textFieldHeight));
    }];
    
    

}
//界面增加隐私条款
-(void)addPrivacyPolicy{
    WS(weakSelf);
    UIView *bottomView = [[UIView alloc]init];
    [self.view addSubview:bottomView];
    //    bottomView.backgroundColor = [UIColor yellowColor];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarSafeHeight-45);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@200);
        make.height.equalTo(@26);
    }];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setTitle:NSLocalizedString(@"LVC_Register", nil) forState:UIControlStateNormal];
    //        self.registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //        self.registerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomView addSubview:self.registerButton];
    CGSize registerSize = [self.registerButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.registerButton.titleLabel.font}];
    [self.registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(bottomView);
        make.width.equalTo(@(registerSize.width+1));
    }];
    
    
    
    UILabel *registerLine = [[UILabel alloc]initWithFrame:CGRectZero];
    registerLine.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:registerLine];
    [registerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.left.mas_equalTo(weakSelf.registerButton.mas_right).offset(15);
        make.width.equalTo(@1);
    }];
    
    
    self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotButton setTitle:NSLocalizedString(@"LVC_ForgotPassword", nil) forState:UIControlStateNormal];
    self.forgotButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    [self.forgotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //        self.forgotButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //        self.forgotButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [bottomView addSubview:self.forgotButton];
    CGSize forgotSize = [self.forgotButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.forgotButton.titleLabel.font}];
    [self.forgotButton addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.left.mas_equalTo(registerLine.mas_right).offset(15);
        make.width.equalTo(@(forgotSize.width+1));
    }];
    
    UILabel *forgotLine = [[UILabel alloc]initWithFrame:CGRectZero];
    forgotLine.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:forgotLine];
    [forgotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.left.mas_equalTo(weakSelf.forgotButton.mas_right).offset(15);
        make.width.equalTo(@1);
    }];
    
    UIButton *privacyPolicyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [privacyPolicyBtn setTitle:NSLocalizedString(@"PrivacyPolicy", nil) forState:UIControlStateNormal];
    [privacyPolicyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    privacyPolicyBtn.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    [bottomView addSubview:privacyPolicyBtn];
    CGSize privacyPolicySize = [privacyPolicyBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:privacyPolicyBtn.titleLabel.font}];
    [privacyPolicyBtn addTarget:self action:@selector(showPrivacyPolocy) forControlEvents:UIControlEventTouchUpInside];
    [privacyPolicyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.left.mas_equalTo(forgotLine.mas_right).offset(15);
        make.width.equalTo(@(privacyPolicySize.width+1));
    }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    CGRect registerRect = self.registerButton.frame;
    CGRect privacyPolicyRect = privacyPolicyBtn.frame;
    
    [bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarSafeHeight-45);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@(privacyPolicyRect.origin.x+privacyPolicyRect.size.width - registerRect.origin.x));
        make.height.equalTo(@26);
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
