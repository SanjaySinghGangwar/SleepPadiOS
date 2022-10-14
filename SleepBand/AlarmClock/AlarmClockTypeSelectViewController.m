//
//  AlarmClockTypeSelectViewController.m
//  SleepBand
//
//  Created by admin on 2018/8/30.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AlarmClockTypeSelectViewController.h"
#import "UniversalTableViewCell.h"

@interface AlarmClockTypeSelectViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *selectTableView;
@property (nonatomic,strong)NSArray *menuNameArray;
@end

@implementation AlarmClockTypeSelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuNameArray = @[NSLocalizedString(@"ACMVC_General", nil),
                           NSLocalizedString(@"ACMVC_Nurse", nil),
                           NSLocalizedString(@"ACMVC_GetUp", nil),
                           NSLocalizedString(@"ACMVC_GoToBedEarly", nil)];
    [self setUI];
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuNameArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setType:CellType_Button];
    cell.buttonView.image = [UIImage imageNamed:@"alarm_icon_choose"];
    if (self.type == indexPath.row)
    {
        cell.buttonView.hidden = NO;
        
    }else
    {
        cell.buttonView.hidden = YES;
    }
    cell.titleLabel.text = self.menuNameArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type != indexPath.row) {
        self.selectBlock((int)indexPath.row);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
    titleLabel.text = NSLocalizedString(@"ACEVC_TypeTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.selectTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.selectTableView];
    self.selectTableView.backgroundColor = [UIColor clearColor];
    self.selectTableView.showsVerticalScrollIndicator = NO;
    self.selectTableView.delegate = self;
    self.selectTableView.dataSource = self;
    self.selectTableView.bounces = NO;
    [self.selectTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-110-kTabbarSafeHeight);
    }];
    self.selectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.selectTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.selectTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
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

- (void)didReceiveMemoryWarning
{
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
