//
//  HelpViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "HelpViewController.h"
#import "UniversalTableViewCell.h"
#import "InformationViewController.h"

@interface HelpViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic)UITableView *tableView;
@property (strong,nonatomic)NSArray *titleArray;
@property (strong,nonatomic)NSArray *infoArray;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArray = @[NSLocalizedString(@"PMVC_Title1", nil),NSLocalizedString(@"PMVC_Title2", nil),NSLocalizedString(@"PMVC_Title3", nil),NSLocalizedString(@"PMVC_Title4", nil),NSLocalizedString(@"PMVC_Title5", nil),NSLocalizedString(@"PMVC_Title6", nil),NSLocalizedString(@"PMVC_Title7", nil),NSLocalizedString(@"PMVC_Title8", nil),NSLocalizedString(@"PMVC_Title9", nil),NSLocalizedString(@"PMVC_Title10", nil),NSLocalizedString(@"PMVC_Title11", nil)];
    self.infoArray = @[@"",NSLocalizedString(@"PMVC_Info1", nil),NSLocalizedString(@"PMVC_Info2", nil),NSLocalizedString(@"PMVC_Info3", nil),NSLocalizedString(@"PMVC_Info4", nil),NSLocalizedString(@"PMVC_Info5", nil),NSLocalizedString(@"PMVC_Info6", nil),NSLocalizedString(@"PMVC_Info7", nil),NSLocalizedString(@"PMVC_Info8", nil),NSLocalizedString(@"PMVC_Info9", nil),NSLocalizedString(@"PMVC_Info10", nil)];
    [self setUI];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.isInfo = YES;
    cell.lineView.hidden = NO;
    [cell setType:CellType_Arrows];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationViewController *info = [[InformationViewController alloc]init];
    info.navTitleStr = NSLocalizedString(@"PMVC_CommonProblemTitle", nil);
    info.titleStr = self.titleArray[indexPath.row];

    if (indexPath.row == 0) {
        info.isOperationGuide = YES;
    }else{
        info.valueStr = self.infoArray[indexPath.row];
    }
    [self.navigationController pushViewController:info animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}
-(void)setUI{
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
    titleLabel.text = NSLocalizedString(@"PMVC_HelpTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
//    UILabel *titleTableLabel = [[UILabel alloc]init];
//    [self.view addSubview:titleTableLabel];
//    titleTableLabel.font = [UIFont systemFontOfSize:14];
//    titleTableLabel.textColor = kControllerTitleColor;
//    titleTableLabel.textAlignment = NSTextAlignmentLeft;
//    titleTableLabel.text = NSLocalizedString(@"PMVC_CommonProblemTitle", nil);
//    [titleTableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight + 44);
//        make.left.mas_equalTo(weakSelf.view.mas_left).offset(kMargin);
//        make.height.equalTo(@28);
//        make.width.equalTo(@200);
//    }];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-110);
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
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
