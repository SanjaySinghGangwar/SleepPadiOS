//
//  AboutViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AboutViewController.h"
#import <WebKit/WebKit.h>
#import "TermsVC.h"

@interface AboutViewController ()<WKUIDelegate>

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WS(weakSelf);
    [self setUI];
    
    UIImageView *leftIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"signup_bgz"]];
    [self.view addSubview:leftIV];
    [leftIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.width.equalTo(@53);
        make.height.equalTo(@88);
    }];
    
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"signup_icon_logo"]];
    [self.view addSubview:logo];
    float width = 80;
    //    logo.layer.cornerRadius = width/2;
    //    logo.backgroundColor = [UIColor whiteColor];
    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44 + 98);
        make.centerX.equalTo(weakSelf.view);
        make.width.height.equalTo(@(width));
    }];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // 当前应用版本号码  int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString *CurVersion = [[NSString alloc]initWithFormat:@"V%@(%@)",appCurVersion,appCurVersionNum];
    
    UILabel *versionLabel = [[UILabel alloc]init];
    [self.view addSubview:versionLabel];
    versionLabel.font = [UIFont systemFontOfSize:15];
    versionLabel.textColor = kControllerTitleColor;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.text = CurVersion;
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(logo.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@15);
        make.width.equalTo(@250);
        
    }];
    
    
#if 0
    
    WKWebView *webView = [[WKWebView alloc]init];
    webView.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(15);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-15);
        make.top.mas_equalTo(versionLabel.mas_bottom).offset(20);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
    }];
    
    NSURL *url;
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if([[appLanguages objectAtIndex:0] rangeOfString:@"zh-Han"].length > 0)
    {
        url = [NSURL URLWithString:PRIVACYPOLICYCN];
        
    }else
    {
        url = [NSURL URLWithString:PRIVACYPOLICYEN];
    }
    webView.UIDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
#endif
    
    
    UIView *lineView = [[UIView alloc]init];
    [self.view addSubview:lineView];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#d8d5d3"];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
    
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(versionLabel.mas_bottom).offset(20);
        make.height.equalTo(@1);
        
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.backgroundColor = [UIColor greenColor];
//    [backButton setTitle:@"" forState:UIControlStateNormal];
    //[backButton setImage:[UIImage imageNamed:@"me_arrow_right"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(pushTermsView) forControlEvents:UIControlEventTouchUpInside];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(versionLabel.mas_bottom).offset(20);
        make.height.equalTo(@45);
        
    }];
    
    UILabel *TermsLabel = [[UILabel alloc]init];
//    TermsLabel.backgroundColor = [UIColor redColor];
    [backButton addSubview:TermsLabel];
    TermsLabel.textAlignment = NSTextAlignmentLeft;
    TermsLabel.font = textFieldTextFont;
    TermsLabel.textColor = kControllerTitleColor;
    TermsLabel.text = NSLocalizedString(@"TermsVC_Title", nil);
    [TermsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(backButton.mas_top).offset(0);
        make.left.mas_equalTo(backButton.mas_left).offset(0);
        make.height.equalTo(@45);
        make.width.mas_equalTo(backButton.mas_width).offset(-20);
        
    }];
    
    
    UIImageView *arrow_right = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"me_arrow_right"]];
    [backButton addSubview:arrow_right];
    [arrow_right mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(backButton.mas_top).offset(0);
        make.left.mas_equalTo(backButton.mas_left).offset(kSCREEN_WIDTH -100);
        make.right.mas_equalTo(backButton.mas_right).offset(-34);
        make.width.height.equalTo(@(45));
        
    }];
    
    
    UIView *lineView1 = [[UIView alloc]init];
    [self.view addSubview:lineView1];
    lineView1.backgroundColor = [UIColor colorWithHexString:@"#d8d5d3"];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(backButton.mas_bottom).offset(1);
        make.height.equalTo(@1);
        
    }];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{

//    [webView evaluateJavaScript:@"document.body.style.backgroundColor= rgba(0,0,0,0.2)" completionHandler:nil];

}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

//push
- (void)pushTermsView
{
    TermsVC *terms = [[TermsVC alloc]init];
    [self.navigationController pushViewController:terms animated:YES];
}

-(void)setUI
{
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
//    UIImageView *bgImageView = [[UIImageView alloc]init];
//    bgImageView.image = [UIImage imageNamed:@"bg"];
//    [self.view addSubview:bgImageView];
//    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.equalTo(weakSelf.view);
//    }];
    
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
    titleLabel.text = NSLocalizedString(@"AboutVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@250);
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
