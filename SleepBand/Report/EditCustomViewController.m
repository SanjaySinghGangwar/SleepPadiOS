//
//  EditCustomViewController.m
//  SleepBand
//
//  Created by admin on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "EditCustomViewController.h"
#import "CustomEditTableViewCell.h"

@interface EditCustomViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic)NSMutableArray *selectArray;
@property (strong,nonatomic)NSMutableArray *unSelectArray;
@property (strong,nonatomic)UITableView *editTableView;
@property (strong,nonatomic)NSArray *nameArray;

@end

@implementation EditCustomViewController

-(NSMutableArray *)selectArray
{
    if (_selectArray == nil) {
        _selectArray = [[NSMutableArray alloc]init];
    }
    return _selectArray;
}

-(NSMutableArray *)unSelectArray
{
    if (_unSelectArray == nil) {
        _unSelectArray = [[NSMutableArray alloc]init];
    }
    return _unSelectArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.selectArray = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"weekMonthCustom"]];
    
    self.nameArray = @[NSLocalizedString(@"RMVC_AverageHeartRate", nil),NSLocalizedString(@"RMVC_AverageRespiratoryRate", nil),NSLocalizedString(@"RMVC_AverageLengthOfSleepStages", nil),NSLocalizedString(@"RMVC_SleepLatency", nil),NSLocalizedString(@"RMVC_GetUpTime", nil),NSLocalizedString(@"RMVC_FrequencyOfWakeUp", nil),NSLocalizedString(@"RMVC_FrequencyOfBedAway", nil)];
    
    [self setUI];
    
    [self unSelectArrayData];
    
}

-(void)unSelectArrayData
{
    self.unSelectArray = [NSMutableArray arrayWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6"]];
    for (int i = 0 ; i < self.selectArray.count; i++)
    {
        for (int j = 0 ; j < self.unSelectArray.count; j++)
        {
            if ([self.selectArray[i] isEqualToString:self.unSelectArray[j]])
            {
                [self.unSelectArray removeObjectAtIndex:j];
                break;
            }
        }
    }
    [self.editTableView reloadData];
}

-(void)back
{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:self.selectArray forKey:@"weekMonthCustom"];
//    [defaults synchronize];
//    self.editCustomBlock(self.selectArray);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUI
{
    WS(weakSelf);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    titleLabel.text = NSLocalizedString(@"ECVC_EditTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
        
    }];
    
    self.editTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.editTableView];
    self.editTableView.backgroundColor = [UIColor clearColor];
    self.editTableView.showsVerticalScrollIndicator = NO;
    self.editTableView.delegate = self;
    self.editTableView.dataSource = self;
    self.editTableView.bounces = NO;
    [self.editTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-kTabbarHeight);
        
    }];
    
    UIView *footerView = [[UIView alloc]init];
    self.editTableView.tableFooterView = footerView;
    self.editTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.editTableView registerClass:[CustomEditTableViewCell class] forCellReuseIdentifier:@"cell"];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.selectArray.count;
    }
    return self.unSelectArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array = indexPath.section == 0 ? self.selectArray : self.unSelectArray;
    if (indexPath.section == 0)
    {
        cell.selectBtn.selected = YES;
        
    }else
    {
        cell.selectBtn.selected = NO;
    }
    cell.titleLabel.text = self.nameArray[[array[indexPath.row] intValue]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        [self.selectArray removeObjectAtIndex:indexPath.row];
        [self unSelectArrayData];
        
    }else
    {
        [self.selectArray addObject:self.unSelectArray[indexPath.row]];
        NSArray *result = [self.selectArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2]; //升序
        }];
        [self.selectArray removeAllObjects];
        [self.selectArray addObjectsFromArray:result];
        [self unSelectArrayData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 38)];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kMargin, 0, 200-kMargin, 38)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    if (section == 0)
    {
        titleLabel.text = NSLocalizedString(@"ECVC_Show", nil);
        
    }else
    {
        titleLabel.text = NSLocalizedString(@"ECVC_UnShow", nil);
    }
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 38;
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
