//
//  AlarmClockMusicViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AlarmClockMusicViewController.h"
#import "UniversalTableViewCell.h"

@interface AlarmClockMusicViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *musicTable;
@property (nonatomic,strong)NSMutableDictionary *musicDict;
@property (nonatomic,strong)NSArray *musicDownloadArray;
@end

@implementation AlarmClockMusicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getMusicData];
    
    [self setUI];
}

-(void)getMusicData
{
    self.musicDict = [NSMutableDictionary dictionaryWithDictionary:@{@"musicVolume":@"50",@"music":@[@"铃声1",@"铃声2",@"铃声3"]}];
    self.musicDownloadArray = @[@"铃声4",@"铃声5",@"铃声6"];
}

-(void)sliderValueChanged:(UISlider *)slider
{
    NSLog(@"slider value%f",slider.value);
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray *array = self.musicDict[@"music"];
        return array.count;
    }
    return self.musicDownloadArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *musicArray = self.musicDict[@"music"];
    [cell setType:CellType_Button];
    if (indexPath.section == 0) {
        cell.titleLabel.text = musicArray[indexPath.row];
        cell.buttonView.image = [UIImage imageNamed:@"clock_music_using"];
        if ([self.selectMusic isEqualToString:musicArray[indexPath.row]]) {
            cell.buttonView.hidden = NO;
        }else{
            cell.buttonView.hidden = YES;
        }
    }else{
        cell.buttonView.image = [UIImage imageNamed:@"clock_music_icon_download"];
        cell.titleLabel.text = self.musicDownloadArray[indexPath.row];
        cell.buttonView.hidden = NO;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]init];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kMargin, 0, kSCREEN_WIDTH, 35)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    if (section == 0) {
        titleLabel.text = NSLocalizedString(@"ACMVC_DownloadedTitle", nil);
    }else{
        titleLabel.text = NSLocalizedString(@"ACMVC_RecommendDownloadedTitle", nil);
    }
    [headerView addSubview:titleLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
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
    titleLabel.text = NSLocalizedString(@"ACMVC_MusicTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    self.musicTable = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.musicTable];
    self.musicTable.backgroundColor = [UIColor clearColor];
    self.musicTable.delegate = self;
    self.musicTable.dataSource = self;
    self.musicTable.bounces = NO;
    [self.musicTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarHeight-kTabbarSafeHeight);
    }];
    self.musicTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.musicTable.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.musicTable registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 44)];
    headerView.backgroundColor = [UIColor clearColor];
    self.musicTable.tableHeaderView = headerView;

    UIView *headerBgView = [[UIView alloc]init];
    [headerView addSubview:headerBgView];
    headerBgView.backgroundColor = [UIColor whiteColor];
    headerBgView.alpha = kAlpha;
    [headerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.equalTo(headerView);
        
    }];
    
    UIImageView *musicVolumeIV = [[UIImageView alloc]init];
    musicVolumeIV.image = [UIImage imageNamed:@"clock_music_icon_vol"];
    [headerView addSubview:musicVolumeIV];
    [musicVolumeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_left).offset(3);
        make.top.equalTo(headerView);
        make.width.height.equalTo(@44);
    }];
    
    UISlider * musicSlider = [[UISlider alloc]init];
    musicSlider.minimumValue = 0.0;
    musicSlider.maximumValue = 100.0;
    [musicSlider  setThumbImage:[UIImage imageNamed:@"clock_music_icon_block"] forState:UIControlStateNormal];
    [musicSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [musicSlider setMaximumTrackTintColor:[UIColor colorWithHexString:@"#cbbfbf"]];
    musicSlider.value = [self.musicDict[@"musicVolume"] integerValue];
    musicSlider.continuous = NO;
    [musicSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:musicSlider];
    [musicSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(musicVolumeIV.mas_right).offset(20);
        make.right.mas_equalTo(headerView.mas_right).offset(-kMargin);
        make.centerY.equalTo(headerView);
        
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
