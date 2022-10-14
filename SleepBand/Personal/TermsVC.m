//
//  TermsVC.m
//  SleepBand
//
//  Created by admin on 2019/5/9.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "TermsVC.h"
#import <WebKit/WebKit.h>

@interface TermsVC ()<WKUIDelegate>

@end

@implementation TermsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUI];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
    titleLabel.text = NSLocalizedString(@"TermsVC_Title", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@250);
    }];
    
    
    WKWebView *webView = [[WKWebView alloc]init];
    webView.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(15);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-15);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20);
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
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
