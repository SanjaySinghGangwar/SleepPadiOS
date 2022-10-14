//
//  AccountViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AccountViewController.h"
#import "UniversalTableViewCell.h"
#import "UserModel.h"
#import "BoundViewController.h"
#import "ResetPasswordViewController.h"
#import "AppDelegate.h"

@interface AccountViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)UITableView *accountTableView;
@property (strong,nonatomic)NSArray *menuArray;
@property (strong,nonatomic)UserModel *model;
@property (strong,nonatomic)MSCoreManager *coreManager;
@property (strong,nonatomic)AlertView *alertView;
@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coreManager = [MSCoreManager sharedManager];
    self.model = self.coreManager.userModel;
    self.menuArray = @[NSLocalizedString(@"Email", nil),NSLocalizedString(@"Phone", nil),NSLocalizedString(@"AVC_ChangePasswordTitle", nil),NSLocalizedString(@"注销账号", nil)];
    [self setUI];
}
#pragma mark - 退出登录
-(void)logout{
//    WS(weakSelf);
    //弹窗确认，退出登录
    [self.alertView showAlertWithType:AlertType_Logout title:NSLocalizedString(@"AVC_Logout", nil) menuArray:nil];
    self.alertView.alertOkBlock = ^(AlertType type){
        if (type == AlertType_Logout) {
            
            BlueToothManager *manager = [BlueToothManager shareIsnstance];
            [manager stopScan];
            if(manager.isConnect){
                [manager manualCancelConnect];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"0" forKey:@"isLogin"];
            [defaults synchronize];
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate setRootViewControllerForLogin];
        }
    };

}

#pragma mark - 后台注销
- (void)UnregisterNetWorkAction{
    
    [[MSCoreManager sharedManager] postUnregisterForData:nil WithResponse:^(ResponseInfo *info) {
        [SVProgressHUD dismiss];
        if ([info.code isEqualToString:@"200"]) {
            [SVProgressHUD showSuccessWithStatus:info.message];
        }else{
            [SVProgressHUD showErrorWithStatus:info.message];
        }
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }];
    
}
#pragma mark - 返回
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.menuArray[indexPath.row];
    cell.lineView.hidden = NO;
    if (indexPath.row == 0) {
        [cell setType:CellType_VauleArrows];
        if (self.model.email.length == 0)
        {
            cell.valueLabel.text = NSLocalizedString(@"AVC_UnBind", nil);
            
        }else
        {
            cell.valueLabel.text = self.model.email;
        }
    }else if (indexPath.row == 1) {
        [cell setType:CellType_VauleArrows];
        if (self.model.phoneNumber.length == 0) {
            cell.valueLabel.text = NSLocalizedString(@"AVC_UnBind", nil);
        }else{
            cell.valueLabel.text = self.model.phoneNumber;
        }
    }else{
        [cell setType:CellType_Arrows];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0://跳转邮箱绑定
            [self tableViewDidSelectRowAtIndexPath:indexPath];
            break;
        case 1://跳转手机绑定
            [self tableViewDidSelectRowAtIndexPath:indexPath];
            break;
        case 2:{//跳转修改密码
            ResetPasswordViewController *reset = [[ResetPasswordViewController alloc]init];
            reset.accountDict = @{@"account":self.model.email.length ? self.model.email:self.model.phoneNumber ,@"phoneNumber" : self.model.phoneNumber ,@"email" : self.model.email};
            reset.resetPasswordType = ResetPasswordType_ChangePassword;
            [self.navigationController pushViewController:reset animated:YES];
        }
            break;
        case 3://注销提示
        {
            //弹窗确认
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提醒", nil) message:NSLocalizedString(@"是否确认注销您的账号,确认后账号将会在三天内注销成功,注销成功后账号数据将被完全删除,不可恢复!请谨慎操作.", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Submit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self UnregisterNetWorkAction];//后台注销
            }];
            [actionSheet addAction:cancel];
            [actionSheet addAction:ok];
            [self presentViewController:actionSheet animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
}
-(void)tableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    if (indexPath.row == 0) {//邮箱
        BoundViewController *bound = [[BoundViewController alloc]init];
        bound.bindBlock = ^(BOOL isPhone, BOOL isBound, NSString *account) {
            if (isBound) {
                weakSelf.model.email = @"";
            }else{
                weakSelf.model.email = account;
            }
            NSLog(@"%@",[MSCoreManager sharedManager].userModel.email);
            [weakSelf.accountTableView reloadData];
        };
        bound.isPhone = NO;
        if (self.model.email.length == 0) {
            bound.isBound = NO;
            [self.navigationController pushViewController:bound animated:YES];
        }else{
            [self.alertView showAlertWithType:AlertType_ActionSheet title:nil menuArray:@[NSLocalizedString(@"AVC_ChangeBind", nil),NSLocalizedString(@"AVC_CancelBind", nil)]];
            self.alertView.alertActionSheetBlock = ^(AlertType type, int index) {
                if (type == AlertType_ActionSheet) {
                    if (index == 0) {//更改绑定
                        bound.isBound = NO;
                        [weakSelf.navigationController pushViewController:bound animated:YES];
                    }else{//解绑
                        [[MSCoreManager sharedManager] postBindEmailOrPhoneWithIsPhone:NO WithResponse:^(ResponseInfo *info) {
                            [SVProgressHUD dismiss];
                            if ([info.code isEqualToString:@"200"]) {
                                NSString *alert;
                                alert = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"AVC_CancelBind", nil),NSLocalizedString(@"Success", nil)];
                                [SVProgressHUD showSuccessWithStatus:alert];
                                [NSThread sleepForTimeInterval:0.5];
                                [SVProgressHUD dismiss];
                                weakSelf.model.email = @"";
                                [weakSelf.accountTableView reloadData];
                            }else{
                                [SVProgressHUD showErrorWithStatus:info.message];
                                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                            }
                        }];
                    }
                    weakSelf.alertView.hidden = YES;
                }
            };
        }
    }else{//手机
        BoundViewController *bound = [[BoundViewController alloc]init];
        bound.bindBlock = ^(BOOL isPhone, BOOL isBound, NSString *account) {
            if (isBound) {
                weakSelf.model.phoneNumber = @"";
            }else{
                weakSelf.model.phoneNumber = account;
            }
            NSLog(@"%@",[MSCoreManager sharedManager].userModel.phoneNumber);
            [weakSelf.accountTableView reloadData];
        };
        bound.isPhone = YES;
        if (self.model.phoneNumber.length == 0) {
            bound.isBound = NO;
            [self.navigationController pushViewController:bound animated:YES];
        }else{
            
            [self.alertView showAlertWithType:AlertType_ActionSheet title:nil menuArray:@[NSLocalizedString(@"AVC_ChangeBind", nil),NSLocalizedString(@"AVC_CancelBind", nil)]];
            self.alertView.alertActionSheetBlock = ^(AlertType type, int index) {
                if (type == AlertType_ActionSheet) {
                    if (index == 0) {//更改绑定
                        bound.isBound = NO;
                        [weakSelf.navigationController pushViewController:bound animated:YES];
                    }else{//解绑
                        [[MSCoreManager sharedManager] postBindEmailOrPhoneWithIsPhone:YES WithResponse:^(ResponseInfo *info) {
                            [SVProgressHUD dismiss];
                            if ([info.code isEqualToString:@"200"]) {
                                NSString *alert;
                                alert = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"AVC_CancelBind", nil),NSLocalizedString(@"Success", nil)];
                                [SVProgressHUD showSuccessWithStatus:alert];
                                [NSThread sleepForTimeInterval:0.5];
                                [SVProgressHUD dismiss];
                                weakSelf.model.phoneNumber = @"";
                                [weakSelf.accountTableView reloadData];
                            }else{
                                [SVProgressHUD showErrorWithStatus:info.message];
                                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                            }
                        }];
                    }
                    weakSelf.alertView.hidden = YES;
                }
            };
        }
    }
}

-(void)setUI
{
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    titleLabel.text = NSLocalizedString(@"PMVC_AccountTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.accountTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.accountTableView];
    self.accountTableView.backgroundColor = [UIColor clearColor];
    self.accountTableView.showsVerticalScrollIndicator = NO;
    self.accountTableView.delegate = self;
    self.accountTableView.dataSource = self;
    self.accountTableView.bounces = NO;
    [self.accountTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-101);
    }];
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100+150)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake((kSCREEN_WIDTH-68)/2-22.5, 42+150, 45, 36);
    [logoutBtn setImage:[UIImage imageNamed:@"me_btn_logout"] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutBtn];
    
    UILabel *logoutBtnTitleL = [[UILabel alloc]initWithFrame:CGRectMake((kSCREEN_WIDTH-68)/2-50, 42+150+78, 100, 15)];
    logoutBtnTitleL.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    logoutBtnTitleL.textColor = [UIColor colorWithHexString:@"#575756"];
    logoutBtnTitleL.textAlignment = NSTextAlignmentCenter;
    logoutBtnTitleL.text = NSLocalizedString(@"AVC_Logout", nil);
    [footerView addSubview:logoutBtnTitleL];
    
    self.accountTableView.tableFooterView = footerView;
    
    self.accountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.accountTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIImageView *bottomImageV = [[UIImageView alloc]init];
    bottomImageV.image = [UIImage imageNamed:@"search_bg_bottom"];
    [self.view addSubview:bottomImageV];
    [bottomImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(@375);
        make.height.equalTo(@101);
    }];
    
    self.alertView = [[AlertView alloc]init];
//    [self.view addSubview:self.alertView];
//    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.bottom.equalTo(weakSelf.view);
//    }];
    
}
-(void)setUI2{
    WS(weakSelf);
    
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
    titleLabel.text = NSLocalizedString(@"PMVC_AccountTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.accountTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.accountTableView];
    self.accountTableView.backgroundColor = [UIColor clearColor];
    self.accountTableView.showsVerticalScrollIndicator = NO;
    self.accountTableView.delegate = self;
    self.accountTableView.dataSource = self;
    self.accountTableView.bounces = NO;
    [self.accountTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarHeight);
    }];
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(kMargin*2, 55, kSCREEN_WIDTH-kMargin*4, 45);
    logoutBtn.backgroundColor = [UIColor whiteColor];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    logoutBtn.layer.cornerRadius = textFieldCornerRadius;
    [logoutBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [logoutBtn setTitle:NSLocalizedString(@"AVC_Logout", nil) forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutBtn];
    self.accountTableView.tableFooterView = footerView;
    
    self.accountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.accountTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    

    
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
