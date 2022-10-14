//
//  InformationViewController.m
//  SleepBand
//
//  Created by admin on 2018/12/12.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "InformationViewController.h"

@interface InformationViewController ()<UITextViewDelegate>
@property (assign,nonatomic)BOOL isChina;
@property (strong,nonatomic)UITextView *textView;
@property (strong,nonatomic)UILabel *textCountLabel;
@property (assign,nonatomic)int textCount;
@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *language = [appLanguages objectAtIndex:0];
    if([language rangeOfString:@"zh-Han"].length > 0){
        self.isChina = YES;
    }else{
        self.isChina = NO;
    }
    [self setUI];
}

-(void)confirm
{
    [self exitEdit];
    if(self.textView.text > 0 && ![self.textView.text isEqualToString:NSLocalizedString(@"IVC_PlaceHolder", nil)]){
        
        WS(weakSelf);
        [MSCoreManager sharedManager].httpManager.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [[MSCoreManager sharedManager].httpManager setRequestHeader:@{@"token":[MSCoreManager sharedManager].userModel.token}];
        NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if([[appLanguages objectAtIndex:0] rangeOfString:@"zh-Han"].length > 0){
            [[MSCoreManager sharedManager].httpManager setRequestHeader:@{@"Accept-Language":AppleLanguages_zh_CN}];
        }else{
            [[MSCoreManager sharedManager].httpManager setRequestHeader:@{@"Accept-Language":AppleLanguages_en_US}];
        }
        //sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [[MSCoreManager sharedManager] getFeedbackForData:@{@"content":self.textView.text} WithResponse:^(ResponseInfo *info) {
            if ([info.code isEqualToString:@"200"]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendSuccess", nil)];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDismissWithDelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [SVProgressHUD showErrorWithStatus:info.message];
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            }
            [MSCoreManager sharedManager].httpManager.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            [[MSCoreManager sharedManager].httpManager setRequestHeader:@{@"token":[MSCoreManager sharedManager].userModel.token}];
            NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            if([[appLanguages objectAtIndex:0] rangeOfString:@"zh-Han"].length > 0){
                [[MSCoreManager sharedManager].httpManager setRequestHeader:@{@"Accept-Language":AppleLanguages_zh_CN}];
            }else{
                [[MSCoreManager sharedManager].httpManager setRequestHeader:@{@"Accept-Language":AppleLanguages_en_US}];
            }
        } ];
    }
}

-(void)exitEdit{
    [self.view endEditing:YES];
}

-(void)back{
    [self exitEdit];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setFeedbackUI{
    WS(weakSelf);

    
    UIView *bgView = [[UIView alloc]init];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [UIColor colorWithHexString:@"#D7F0F2"];
    bgView.layer.cornerRadius = 10;
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+10);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        //        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.height.equalTo(@145);
    }];
    
    self.textView = [[UITextView alloc]init];
    [self.view addSubview:self.textView];
    self.textView.text = NSLocalizedString(@"IVC_PlaceHolder", nil);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.textColor = [UIColor colorWithHexString:@"#9BA9AA"];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_top).offset(14);
        make.left.mas_equalTo(bgView.mas_left).offset(14);
        make.right.mas_equalTo(bgView.mas_right).offset(-14);
        make.bottom.mas_equalTo(bgView.mas_bottom).offset(-14);
    }];
    
    self.textCountLabel = [[UILabel alloc]init];
    [self.view addSubview:self.textCountLabel];
    self.textCountLabel.font = [UIFont boldSystemFontOfSize:12];
    self.textCountLabel.textColor = [UIColor colorWithHexString:@"#9BA9AA"];
    self.textCountLabel.textAlignment = NSTextAlignmentCenter;
    self.textCountLabel.text = @"0/60";
    [self.textCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@12);
        make.width.equalTo(@40);
        make.right.mas_equalTo(bgView.mas_right).offset(-14);
        make.bottom.mas_equalTo(bgView.mas_bottom).offset(-14);
    }];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setImage:[UIImage imageNamed:@"me_btn_save"] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_bottom).offset(50+150);
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
    
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:NSLocalizedString(@"IVC_PlaceHolder", nil)]) {
        textView.text = @"";
        textView.textColor = [UIColor colorWithHexString:@"#757F7F"];
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
//    NSLog(@"%@",textView.text);
    //判断加上输入的字符，是否超过界限
    if (textView.text.length > 60)
    {
        textView.text = [textView.text substringToIndex:60];
    }
    self.textCount = (int)textView.text.length;
    self.textCountLabel.text = [NSString stringWithFormat:@"%d/60",self.textCount];

}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"%lu,%@,%@",(unsigned long)range.length,textView.text,text);
    if ([text isEqualToString:@""]) {
        /**< 在这里处理删除键的逻辑 */
//        NSLog(@"删除");
        if (textView.text.length != 0) {
            self.textCount--;
            self.textCountLabel.text = [NSString stringWithFormat:@"%d/60",self.textCount+1];
        }
    }else{

    }
    return YES;
}
-(void)setOperationGuideUI
{
    WS(weakSelf);

    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.showsVerticalScrollIndicator = FALSE;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        
    }];
    
    UIView *profileView = [[UIView alloc]init];
    [scrollView addSubview:profileView];
    [profileView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.and.right.equalTo(scrollView).with.insets(UIEdgeInsetsZero);
        make.width.equalTo(scrollView);
    }];
    
    UIView *bgView = [[UIView alloc]init];
    [profileView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(profileView);
        make.bottom.mas_equalTo(profileView.mas_bottom).offset(0);
    }];
    
//    UILabel *titleInfoLabel = [[UILabel alloc]init];
//    [bgView addSubview:titleInfoLabel];
//    titleInfoLabel.font = [UIFont boldSystemFontOfSize:16];
//    titleInfoLabel.textColor = kControllerTitleColor;
//    titleInfoLabel.textAlignment = NSTextAlignmentLeft;
//    titleInfoLabel.text = self.titleStr;
//    [titleInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(bgView.mas_top).offset(0);
//        make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
//        make.height.equalTo(@40);
//        make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
//    }];
    
    
    UILabel *titleInfoLabel = [[UILabel alloc]init];
    [bgView addSubview:titleInfoLabel];
    titleInfoLabel.font = [UIFont boldSystemFontOfSize:14];
    titleInfoLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    titleInfoLabel.textAlignment = NSTextAlignmentLeft;
    titleInfoLabel.text = self.titleStr;
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [titleInfoLabel.text boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-2*kMargin,MAXFLOAT) options:options attributes:@{NSFontAttributeName:titleInfoLabel.font} context:nil];
    titleInfoLabel.numberOfLines = 0;
    [titleInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_top).offset(0);
        make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
        make.height.equalTo(@(rect.size.height+1));
        make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
    }];
    
    
    UIImageView *imageVF = [[UIImageView alloc]init];
    imageVF.image = [UIImage imageNamed:@"me_operationguide_icon_one"];
    [bgView addSubview:imageVF];
    [imageVF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleInfoLabel.mas_bottom).offset(18);
        make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
        make.width.equalTo(@31.5);
        make.height.equalTo(@25);
    }];
    
    UILabel *titleLabelF = [[UILabel alloc]init];
    [bgView addSubview:titleLabelF];
    titleLabelF.font = [UIFont boldSystemFontOfSize:14];
    titleLabelF.textColor = [UIColor colorWithHexString:@"#575756"];
    titleLabelF.textAlignment = NSTextAlignmentLeft;
    titleLabelF.text = NSLocalizedString(@"PMVC_DeviceConnection", nil);
    [titleLabelF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(imageVF);
        make.left.mas_equalTo(imageVF.mas_right).offset(8);
        make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
    }];
    
    UIView *lastView;
    
    NSArray *messageArray = @[@"PMVC_Step1Message",@"PMVC_Step2Message",@"PMVC_Step3Message",@"PMVC_Step4Message",@"PMVC_Step5Message",@"PMVC_Step6Message"];
    NSArray *imageArray = @[@"me_operationguide_one_stept1",@"me_operationguide_one_stept2",@"me_operationguide_one_stept3",@"me_operationguide_one_stept4",@"me_operationguide_two_no1",@"me_operationguide_two_no2"];
    NSArray *sizeArray = @[@[@"231",@"176"],@[@"165",@"269"],@[@"240",@"179"],@[@"240",@"179"],@[@"209",@"184.5"],@[@"91",@"184"]];
    
    for (int i = 0; i < 4; i++) {
        UIView *stepBgView = [[UIView alloc]init];
        stepBgView.layer.borderColor = [UIColor colorWithHexString:@"#A3BBD3"].CGColor;
        stepBgView.layer.borderWidth = 1;
        stepBgView.layer.cornerRadius = 8;
        [bgView addSubview:stepBgView];
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect stepMessageRect = [NSLocalizedString(messageArray[i],nil) boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-4*kMargin,MAXFLOAT) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
        if (i == 0) {
            [stepBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(imageVF.mas_bottom).offset(10);
                make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
                make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
                make.height.equalTo(@(stepMessageRect.size.height+25+[sizeArray[i][1] intValue]+16 + 10));
            }];
        }else{
            [stepBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lastView.mas_bottom).offset(12);
                make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
                make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
                make.height.equalTo(@(stepMessageRect.size.height+25+[sizeArray[i][1] intValue]+16 + 10));
            }];
        }

        
        UIImageView *stepImageVF = [[UIImageView alloc]init];
        stepImageVF.image = [UIImage imageNamed:@"me_operationguid_stept_bg"];
        [stepBgView addSubview:stepImageVF];
        [stepImageVF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(stepBgView);
            make.width.equalTo(@57);
            make.height.equalTo(@25);
        }];
        
        UILabel *stepLabelF = [[UILabel alloc]init];
        [stepImageVF addSubview:stepLabelF];
        stepLabelF.font = [UIFont systemFontOfSize:14];
        stepLabelF.textColor = [UIColor colorWithHexString:@"#ffffff"];
        stepLabelF.textAlignment = NSTextAlignmentCenter;
        stepLabelF.clipsToBounds = YES;
        stepLabelF.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"PMVC_Step", nil),i+1];
        [stepLabelF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.height.equalTo(stepImageVF);
        }];
        
        UIImageView *stepImageVS = [[UIImageView alloc]init];
        stepImageVS.image = [UIImage imageNamed:imageArray[i]];
//        if (self.isChina) {
//            stepImageVS.image = [UIImage imageNamed:imageArray[i][0]];
//        }else{
//            stepImageVS.image = [UIImage imageNamed:imageArray[i][1]];
//        }
        [stepBgView addSubview:stepImageVS];
        [stepImageVS mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(stepLabelF.mas_bottom).offset(10);
            make.centerX.equalTo(stepBgView);
            make.width.equalTo(@([sizeArray[i][0] intValue]));
            make.height.equalTo(@([sizeArray[i][1] intValue]));
        }];
        
        UILabel *stepLabelS = [[UILabel alloc]init];
        [stepBgView addSubview:stepLabelS];
        stepLabelS.font = [UIFont systemFontOfSize:12];
        stepLabelS.textColor = [UIColor colorWithHexString:@"#575756"];
        stepLabelS.textAlignment = NSTextAlignmentCenter;
        stepLabelS.text = NSLocalizedString(messageArray[i],nil);
        stepLabelS.numberOfLines = 0 ;
        [stepLabelS mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(stepImageVS.mas_bottom).offset(8);
            make.left.mas_equalTo(stepBgView.mas_left).offset(kMargin);
            make.right.mas_equalTo(stepBgView.mas_right).offset(-kMargin);
            make.height.equalTo(@(stepMessageRect.size.height));
        }];
        
        lastView = stepBgView;
    }
    
    UIImageView *imageVS = [[UIImageView alloc]init];
    imageVS.image = [UIImage imageNamed:@"me_operationguide_icon_two"];
    [bgView addSubview:imageVS];
    [imageVS mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastView.mas_bottom).offset(20);
        make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
        make.width.equalTo(@31.5);
        make.height.equalTo(@25);
    }];
    
    UILabel *titleLabelS = [[UILabel alloc]init];
    [bgView addSubview:titleLabelS];
    titleLabelS.font = [UIFont boldSystemFontOfSize:14];
    titleLabelS.textColor = [UIColor colorWithHexString:@"#575756"];
    titleLabelS.textAlignment = NSTextAlignmentLeft;
    titleLabelS.text = NSLocalizedString(@"PMVC_SleepStatistic", nil);
    [titleLabelS mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(imageVS);
        make.left.mas_equalTo(imageVS.mas_right).offset(8);
        make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
    }];
    
    for (int i = 4 ; i < 6; i++) {
        UIView *stepBgView = [[UIView alloc]init];
        stepBgView.layer.borderColor = [UIColor colorWithHexString:@"#A3BBD3"].CGColor;
        stepBgView.layer.borderWidth = 1;
        stepBgView.layer.cornerRadius = 8;
        [bgView addSubview:stepBgView];
        
//        CGSize phoneSize = [NSLocalizedString(messageArray[i],nil) sizeWithAttributes:@{NSFontAttributeName:stepLabelS.font}];
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect stepMessageRect = [NSLocalizedString(messageArray[i],nil) boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-4*kMargin,MAXFLOAT) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
        if (i == 4) {
            [stepBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(imageVS.mas_bottom).offset(20);
                make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
                make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
                make.height.equalTo(@(stepMessageRect.size.height+25+[sizeArray[i][1] intValue]+16 + 10));
            }];
        }else{
            [stepBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lastView.mas_bottom).offset(12);
                make.left.mas_equalTo(bgView.mas_left).offset(kMargin);
                make.right.mas_equalTo(bgView.mas_right).offset(-kMargin);
                make.height.equalTo(@(stepMessageRect.size.height+25+[sizeArray[i][1] intValue]+16 + 10));
            }];
        }
        
        
//        UIImageView *stepImageVF = [[UIImageView alloc]init];
//        stepImageVF.image = [UIImage imageNamed:@"Operationguide_bg"];
//        [stepBgView addSubview:stepImageVF];
//        [stepImageVF mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.equalTo(stepBgView);
//            make.width.equalTo(@57);
//            make.height.equalTo(@25);
//        }];
        
        UILabel *stepLabelF = [[UILabel alloc]init];
        [bgView addSubview:stepLabelF];
        stepLabelF.font = [UIFont systemFontOfSize:14];
        stepLabelF.backgroundColor = [UIColor colorWithHexString:@"#a3bbd3"];
        stepLabelF.textColor = [UIColor colorWithHexString:@"#ffffff"];
        stepLabelF.textAlignment = NSTextAlignmentCenter;
        stepLabelF.clipsToBounds = YES;
        if (i == 4) {
            stepLabelF.text = NSLocalizedString(@"PMVC_SleepStatisticTitle1", nil);
        }else{
            stepLabelF.text = NSLocalizedString(@"PMVC_SleepStatisticTitle2", nil);
        }
        CGRect titleRect = [stepLabelF.text boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-2*kMargin,MAXFLOAT) options:options attributes:@{NSFontAttributeName:stepLabelF.font} context:nil];
        [stepLabelF mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.left.equalTo(stepBgView);
                        make.width.equalTo(@(titleRect.size.width+20));
                        make.height.equalTo(@25);
        }];
        
        [bgView setNeedsLayout];
        [bgView layoutIfNeeded];
        
        UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:stepLabelF.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
        CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
        maskLayer1.frame = stepLabelF.bounds;
        maskLayer1.path = maskPath1.CGPath;
        stepLabelF.layer.mask = maskLayer1;
        
        UIImageView *stepImageVS = [[UIImageView alloc]init];
        stepImageVS.image = [UIImage imageNamed:imageArray[i]];
//        if (self.isChina) {
//            stepImageVS.image = [UIImage imageNamed:imageArray[i][0]];
//        }else{
//            stepImageVS.image = [UIImage imageNamed:imageArray[i][1]];
//        }
        [stepBgView addSubview:stepImageVS];
        [stepImageVS mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(stepLabelF.mas_bottom).offset(10);
            make.centerX.equalTo(stepBgView);
            make.width.equalTo(@([sizeArray[i][0] intValue]));
            make.height.equalTo(@([sizeArray[i][1] intValue]));
        }];
        
        UILabel *stepLabelS = [[UILabel alloc]init];
        [stepBgView addSubview:stepLabelS];
        stepLabelS.font = [UIFont systemFontOfSize:12];
        stepLabelS.textColor = [UIColor colorWithHexString:@"#575756"];
        stepLabelS.textAlignment = NSTextAlignmentCenter;
        stepLabelS.text = NSLocalizedString(messageArray[i],nil);
        stepLabelS.numberOfLines = 0 ;
        [stepLabelS mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(stepImageVS.mas_bottom).offset(8);
            make.left.mas_equalTo(stepBgView.mas_left).offset(kMargin);
            make.right.mas_equalTo(stepBgView.mas_right).offset(-kMargin);
//            make.height.equalTo(@(stepMessageRect.size.height));
            make.height.equalTo(@(stepMessageRect.size.height+2));
        }];
        
        lastView = stepBgView;
    }
    
    
    
    [bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(profileView);
        make.bottom.mas_equalTo(lastView.mas_bottom).offset(20);
    }];
    
    [profileView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(bgView.mas_bottom).offset(0);
    }];
}
-(void)setOtherUI{
    WS(weakSelf);
    
    UILabel *titleInfoLabel = [[UILabel alloc]init];
    [self.view addSubview:titleInfoLabel];
    titleInfoLabel.font = [UIFont systemFontOfSize:14];
    titleInfoLabel.textColor = [UIColor colorWithHexString:@"#575756"];
    titleInfoLabel.textAlignment = NSTextAlignmentLeft;
    titleInfoLabel.text = self.titleStr;
    titleInfoLabel.adjustsFontSizeToFitWidth = YES;
    titleInfoLabel.numberOfLines = 0;
//    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//    CGRect rect = [titleInfoLabel.text boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH-2*kMargin,MAXFLOAT) options:options attributes:@{NSFontAttributeName:titleInfoLabel.font} context:nil];
//    titleInfoLabel.numberOfLines = 0;
//    NSLog(@"height = %f",rect.size.height);
    [titleInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+12);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
//        make.height.equalTo(@(rect.size.height+1));
        make.height.equalTo(@40);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
    }];
    
    
    
    self.textView = [[UITextView alloc]init];
    [self.view addSubview:self.textView];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;  //行间距
    paragraphStyle.firstLineHeadIndent = 30; /**首行缩进宽度*/
    paragraphStyle.alignment =NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:paragraphStyle};
    
//    if(!self.isChina && [self.valueStr isEqualToString:NSLocalizedString(@"SAVC_Info2", nil)]){
//        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//        attachment.image = [UIImage imageNamed:@"form"];
//        attachment.bounds = CGRectMake(0, 0, 346,440.5);
//
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.valueStr attributes:attributes];
//        [attributedString addAttribute:NSForegroundColorAttributeName value:kControllerTitleColor range:NSMakeRange(0, self.valueStr.length)];
//        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, self.valueStr.length)];
//        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
//        [attributedString insertAttributedString:attachmentString atIndex:self.valueStr.length];
//        self.textView.attributedText = attributedString;
//    }else{
        self.textView.attributedText = [[NSAttributedString alloc]initWithString:self.valueStr attributes:attributes];
//    }
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor colorWithHexString:@"#575756"];
    self.textView.editable = NO;
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleInfoLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-110);
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
    
    //解决进去之后contentOffset不是顶点的问题
    CGPoint offset = self.textView.contentOffset;
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
        [weakSelf.textView setContentOffset: offset];
    }];
}
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
    titleLabel.text = self.navTitleStr;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    if (self.isFeedback) {
        
        [self setFeedbackUI];
        
    }else{
        
        if (self.isOperationGuide) {
            
            [self setOperationGuideUI];
            
        }else{
            
            [self setOtherUI];
        }
    }
}

@end
