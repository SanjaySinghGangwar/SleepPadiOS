//
//  SelectAreaCodeViewController.m
//  QLife
//
//  Created by admin on 2018/5/28.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SelectAreaCodeViewController.h"
#import "SelectAreaCodeTableViewCell.h"
//#import "SearchBar.h"

@interface SelectAreaCodeViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate>
@property (strong,nonatomic)UITableView *areaTableView;
@property (strong,nonatomic)NSDictionary *areaDict;
@property (strong,nonatomic)NSArray *areaDictKey;
@property (strong,nonatomic)UISearchController *searchView;
@property (strong,nonatomic)NSMutableDictionary *resultDict;
@property (strong,nonatomic)NSArray *resultDictKey;
@property (strong,nonatomic)NSMutableArray *resultArray;
@property (copy,nonatomic)NSString *language;
@end

@implementation SelectAreaCodeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

-(NSMutableArray *)resultArray
{
    if (_resultArray == nil) {
        _resultArray = [[NSMutableArray alloc]init];
    }
    return _resultArray;
}
-(NSMutableDictionary *)resultDict{
    if (_resultDict == nil) {
        _resultDict = [[NSMutableDictionary alloc]init];
    }
    return _resultDict;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self getSystemLanguage];
    [self setNavigationUI];
    [self setTableViewUI];
}

#pragma mark - 获取系统语言
-(void)getSystemLanguage
{
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    self.language = [appLanguages objectAtIndex:0];
    NSLog(@"%@",self.language);
    NSString *filePath;
    
    //根据系统当前语言选择不同语言的区号文件
    if([self.language rangeOfString:@"zh-Han"].length > 0){
        
        filePath = [[NSBundle mainBundle] pathForResource:@"TelephoneList" ofType:@"plist"];
        
    }else
    {
        //测试用
        filePath = [[NSBundle mainBundle] pathForResource:@"TelephoneListEN" ofType:@"plist"];
    }
    self.areaDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    self.areaDictKey = [[self.areaDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2){
        
        return [obj1 compare:obj2];
        
    }];
    
}

-(void)back
{
    [self.searchView setActive:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - searchResultsUpdater
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchStr = searchController.searchBar.text;
//    if (searchStr.length > 0) {
        [self.resultDict removeAllObjects];
//    }
    for(NSString *key in self.areaDictKey){
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (NSDictionary *dict in self.areaDict[key]) {
            if ([dict[@"country"] rangeOfString:searchStr].length > 0) {
                [array addObject:dict];
            }
        }
        if (array.count > 0) {
            [self.resultDict setObject:array forKey:key];
        }else{
            array = nil;
        }
    }
    self.resultDictKey = [[self.resultDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    [self.areaTableView reloadData];
}
#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.searchView.active) {
        return [self.resultDictKey count];
    }
    return [self.areaDictKey count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SelectAreaCodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array;
    if (self.searchView.active) {
        array = self.resultDict[self.resultDictKey[indexPath.section]];
    }else{
        array = self.areaDict[self.areaDictKey[indexPath.section]];
    }
    NSDictionary *dict = array[indexPath.row];
    cell.countryLabel.text = dict[@"country"];
    cell.codeLabel.text = [NSString stringWithFormat:@"%d",[dict[@"code"] intValue]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array;
    if (self.searchView.active) {
        array = self.resultDict[self.resultDictKey[indexPath.section]];
    }else{
        array = self.areaDict[self.areaDictKey[indexPath.section]];
    }
    NSDictionary *dict = array[indexPath.row];
    if ([self.language rangeOfString:@"zh-Hant-"].length > 0) {
        if([self.language isEqualToString:@"zh-Hant-TW"]){
            self.language = @"zn-tw";
        }else if([self.language isEqualToString:@"zh-Hant-HK"]){
            self.language = @"zn-hk";
        }else{
            self.language = @"zn-hk";
        }
    }else if([self.language rangeOfString:@"zh-Hans-"].length > 0){
        self.language = @"zh-cn";
    }else if([self.language rangeOfString:@"en-"].length > 0){
        self.language = @"en-us";
    }else if([self.language rangeOfString:@"ja-"].length > 0){
        self.language = @"ja-jp";
    }else{
        
    }
    self.selectAreaCodeBlock(dict[@"country"],self.language, dict[@"code"]);
    self.searchView.active = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchView.active) {
        return  [self.resultDict[self.resultDictKey[section]] count];
    }
    return [self.areaDict[self.areaDictKey[section]] count];
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{

    if (self.searchView.active) {
        return  self.resultDictKey;
    }
    return self.areaDictKey;
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    for (UIView *view in [tableView subviews]) {
        if ([view isKindOfClass:[NSClassFromString(@"UITableViewIndex") class]]) {
            // 设置字体大小
            [view setValue:[UIFont fontWithName:@"AmericanTypewriter" size:11] forKey:@"_font"];
            [view setValue:[UIColor colorWithHexString:@"#a3bbd3"] forKey:@"_indexColor"];
            //设置view的大小
            view.bounds = CGRectMake(0, 0, 25, 15);
            //单单设置其中一个是无效的
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexColor = [UIColor whiteColor];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, 20, 14)];
    if (self.searchView.active) {
        titleLabel.text = self.resultDictKey[section];
    }else{
        titleLabel.text = self.areaDictKey[section];
    }
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textColor = [UIColor colorWithHexString:@"#a3bbd3"];
    [headerView addSubview:titleLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 27.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
//    {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
//    {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}
#pragma mark - 设置列表UI
-(void)setTableViewUI{
    WS(weakSelf);
    
//    UIView *tableBGView = [[UIView alloc] init];
//    tableBGView.backgroundColor = [UIColor whiteColor];
//    tableBGView.alpha = kAlpha;
//    [self.view addSubview:tableBGView];
//    [tableBGView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+57);
//        make.left.right.equalTo(weakSelf.view);
//        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(0);
//    }];
    
    UIView *tableHeaderView = [[UIView alloc]init];
    [self.view addSubview:tableHeaderView];
    [tableHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@30);
    }];
    
    UIView *searchBGView = [[UIView alloc]initWithFrame:CGRectMake(23, 12, kSCREEN_WIDTH-46, 30)];
    searchBGView.layer.cornerRadius = 15;
    searchBGView.alpha = kAlpha;
    searchBGView.backgroundColor = [UIColor colorWithHexString:@"#a3bbd3"];
    [tableHeaderView addSubview:searchBGView];
    
    self.searchView = [[UISearchController alloc]initWithSearchResultsController:nil];
    [tableHeaderView addSubview:self.searchView.searchBar];
    self.searchView.searchResultsUpdater = self;
    for (UIView* subview in [[self.searchView.searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *searchField = (UITextField*)subview;
//            UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"country_search_1"]];
//            imageV.frame = CGRectMake(0, 23/2, 14 , 15);
            UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 18 , 30)];
//            [leftView addSubview:imageV];
            searchField.leftView = leftView;
            searchField.leftViewMode = UITextFieldViewModeAlways;
            searchField.font = [UIFont systemFontOfSize:14];
            searchField.textColor = [UIColor whiteColor];
            [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            [searchField setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
        }
    }

    self.searchView.dimsBackgroundDuringPresentation = NO;
    self.searchView.hidesNavigationBarDuringPresentation = NO;
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:NSLocalizedString(@"Cancel", nil)];
    
    //设置透明背景
    UIImage* searchBarBg = [self GetImageWithColor:[UIColor clearColor] andHeight:30.0f];
    [self.searchView.searchBar setBackgroundImage:searchBarBg];
    [self.searchView.searchBar setBackgroundColor:[UIColor clearColor]];
    [self.searchView.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
    
    
    self.areaTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.areaTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.areaTableView];
    self.areaTableView.delegate = self;
    self.areaTableView.dataSource = self;
    [self.areaTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44+50);
        make.right.equalTo(weakSelf.view);
//        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-23);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(23);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
    }];
    [self.areaTableView registerClass:[SelectAreaCodeTableViewCell class] forCellReuseIdentifier:@"cell"];
    self.areaTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.areaTableView.bounces = NO;
//    self.areaTableView.separatorInset = UIEdgeInsetsMake(0, 27, 0, 0);
    self.areaTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
//    self.areaTableView.tableHeaderView = tableHeaderView;
}
/**
 *  生成图片
 *
 *  @param color  图片颜色
 *  @param height 图片高度
 *
 *  @return 生成的图片
 */
-(UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - 设置导航栏UI
-(void)setNavigationUI
{
    WS(weakSelf);
    
//    UIImageView *bgImageView = [[UIImageView alloc]init];
//    bgImageView.image = [UIImage imageNamed:@"bg"];
//    [self.view addSubview:bgImageView];
//    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.equalTo(weakSelf.view);
//    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = NSLocalizedString(@"SACVC_Title", nil);
    titleLabel.font = kControllerTitleFont;
    titleLabel.textColor = kControllerTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@250);
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
