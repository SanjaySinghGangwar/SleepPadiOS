//
//  PersonalInformationViewController.m
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "PersonalInformationViewController.h"
#import "UniversalTableViewCell.h"
#import "UserModel.h"

@interface PersonalInformationViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong,nonatomic)UITableView *informationTableView;
@property (strong,nonatomic)NSArray *menuArray;
@property (assign,nonatomic)NSInteger selectIndex;
@property (strong,nonatomic)UIView *universalPickerView; //身高体重
@property (strong,nonatomic)UIPickerView *universalPicker;
@property (strong,nonatomic)UIView *datePickerView;//生日
@property (nonatomic,strong)UIDatePicker *datePicker;
@property (strong,nonatomic)NSMutableArray *cmArray; //厘米数组
@property (strong,nonatomic)NSMutableArray *lbArray; //磅数组
@property (strong,nonatomic)NSMutableArray *inArray; //英寸数组
@property (strong,nonatomic)NSMutableArray *ftArray; //英尺数组
@property (strong,nonatomic)NSMutableArray *kgArray; //公斤数组
@property (assign,nonatomic)BOOL isHeight;
@property (copy,nonatomic)NSString *userName;
@property (assign,nonatomic)int sex;
@property (copy,nonatomic)NSString *birthday;
@property (assign,nonatomic)int units;
@property (copy,nonatomic)NSString *height;
@property (copy,nonatomic)NSString *weight;
@property (strong,nonatomic)AlertView *alertView;
@property (strong,nonatomic)NSMutableDictionary * userInfoDict;
@end

@implementation PersonalInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userInfoDict = [NSMutableDictionary dictionary];
    
    
    self.menuArray = @[NSLocalizedString(@"PIVC_NameTitle", nil),NSLocalizedString(@"PIVC_GenderTitle", nil),NSLocalizedString(@"PIVC_AgeTitle", nil),NSLocalizedString(@"PIVC_Unit", nil),NSLocalizedString(@"PIVC_HeightTitle", nil),NSLocalizedString(@"PIVC_WeightTitle", nil)];
    self.userName = [MSCoreManager sharedManager].userModel.userName;
    self.sex = [MSCoreManager sharedManager].userModel.sex;
    self.birthday = [MSCoreManager sharedManager].userModel.birthday;
    self.units = [MSCoreManager sharedManager].userModel.units;
    self.height = [MSCoreManager sharedManager].userModel.height;
    self.weight = [MSCoreManager sharedManager].userModel.weight;
    
    [self setUnitArrayData];
    [self setUI];
}
-(void)setUnitArrayData{
    self.cmArray = [[NSMutableArray alloc]init];
    self.lbArray = [[NSMutableArray alloc]init];
    self.inArray = [[NSMutableArray alloc]init];
    self.ftArray = [[NSMutableArray alloc]init];
    self.kgArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < 300; i++){
        if (i < 9) {
            [self.ftArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (i < 12) {
            [self.inArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (i < 137) {
            [self.kgArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        if (i < 251) {
            [self.cmArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.lbArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIndentifier = @"userInfocell";
    UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.menuArray[indexPath.row];
    cell.valueLabel.text = @"";
    [cell setType:CellType_VauleArrows];
    cell.lineView.hidden = NO;
    switch (indexPath.row) {
        case InformationType_Name:
            if(self.userName.length > 0){
                cell.valueLabel.text = self.userName;
            }
            break;
        case InformationType_Gender:
            if (self.sex == 1) {
                cell.valueLabel.text = NSLocalizedString(@"PIVC_GenderMale", nil);
            }else if (self.sex == 2){
                cell.valueLabel.text = NSLocalizedString(@"PIVC_GenderFemale", nil);
            }else {
                cell.valueLabel.text = @"";
            }
            break;
        case InformationType_Age:
        {
            if (self.birthday.length > 0) {
                cell.valueLabel.text = self.birthday;
            }
        }
            break;
        case InformationType_Height:
            if(self.height.length > 0){
                cell.valueLabel.text = self.height;
            }
            break;
        case InformationType_Weight:
            if(self.weight.length > 0){
                cell.valueLabel.text = self.weight;
            }
            break;
        case InformationType_Unit:
            if(self.units == 0){
                cell.valueLabel.text = NSLocalizedString(@"PIVC_StandardUnit", nil);
            }else{
                cell.valueLabel.text = NSLocalizedString(@"PIVC_EnglishUnit", nil);
            }
            break;
        default:
            break;
    }
//    NSLog(@"cell.valueLabel.text = %@",cell.valueLabel.text);
//    if (!cell.valueLabel.text) {
//
//    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectIndex = indexPath.row;
    if (indexPath.row == InformationType_Name) {
        [self setUserName];
    }else if (indexPath.row == InformationType_Gender){
        [self setGender];
    }else if (indexPath.row == InformationType_Age){
        [self.alertView showPickerActionSheetWithType:InformationType_Age alertType:AlertType_ActionSheetPicker dataArray:nil value:self.birthday units:0];
    }else if (indexPath.row == InformationType_Height){
        [self.alertView showPickerActionSheetWithType:InformationType_Height alertType:AlertType_ActionSheetPicker dataArray:nil value:self.height units:self.units];
    }else if (indexPath.row == InformationType_Weight){
        [self.alertView showPickerActionSheetWithType:InformationType_Weight alertType:AlertType_ActionSheetPicker dataArray:nil value:self.weight units:self.units];
    }else{
        [self setUnit];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
}
-(void)setUserName{
    WS(weakSelf);
    [self.alertView showAlertWithType:AlertType_TextField title:NSLocalizedString(@"PIVC_NameTitle", nil) menuArray:nil];
    self.alertView.alertTextBlock = ^(AlertType type, NSString *text) {
        if (type == AlertType_TextField) {
            if (text.length > 0 && ![text isEqualToString:weakSelf.userName]) {
                //设置用户名
                weakSelf.userName = text;
                [weakSelf.informationTableView reloadData];
                [weakSelf.userInfoDict setObject:weakSelf.userName forKey:@"userName"];
                
            }
        }
    };
}
-(void)setGender{
    WS(weakSelf);
    [self.alertView showAlertWithType:AlertType_ActionSheet title:nil menuArray:@[NSLocalizedString(@"PIVC_GenderMale", nil),NSLocalizedString(@"PIVC_GenderFemale", nil)]];
    self.alertView.alertActionSheetBlock = ^(AlertType type, int index) {
        if(type == AlertType_ActionSheet){
            if (index+1 != weakSelf.sex) {
                //设置性别
                weakSelf.sex = index+1;
                [weakSelf.informationTableView reloadData];
                [weakSelf.userInfoDict setObject:[NSNumber numberWithInt:weakSelf.sex] forKey:@"sex"];
            }
            
        }
    };
}
-(void)setUnit{
    WS(weakSelf);
    [self.alertView showAlertWithType:AlertType_ActionSheet title:nil menuArray:@[NSLocalizedString(@"PIVC_StandardUnit", nil),NSLocalizedString(@"PIVC_EnglishUnit", nil)]];
    self.alertView.alertActionSheetBlock = ^(AlertType type, int index) {
        if(type == AlertType_ActionSheet){
            if (index != weakSelf.units) {
                weakSelf.units = index;
                
                if ([weakSelf.height rangeOfString:@"null"].length>0 || weakSelf.height.length==0) {
                }else{
                    weakSelf.height = index == 0 ? [UIFactory ftInTransformCm:weakSelf.height] :[UIFactory cmTransformFtIn:weakSelf.height];
                    [weakSelf.userInfoDict setObject:weakSelf.height forKey:@"height"];
                }
                
                if ([weakSelf.weight rangeOfString:@"null"].length>0 || weakSelf.weight.length==0) {
                }else{
                    weakSelf.weight = index == 0 ? [UIFactory lbTransformKg:weakSelf.weight] :[UIFactory kgTransformLb:weakSelf.weight];
                    [weakSelf.userInfoDict setObject:weakSelf.weight forKey:@"weight"];
                }
                [weakSelf.userInfoDict setObject:weakSelf.units==0 ?NSLocalizedString(@"PIVC_StandardUnit", nil):NSLocalizedString(@"PIVC_EnglishUnit", nil) forKey:@"unit"];
                
                [weakSelf.informationTableView reloadData];
            }
        }
    };
}

-(void)setUI{
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
    titleLabel.text = NSLocalizedString(@"PMVC_PersonalInformationTitle", nil);
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
        make.centerX.equalTo(weakSelf.view);
        make.height.equalTo(@44);
        make.width.equalTo(@200);
    }];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor colorWithHexString:@"#575756"] forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    [self.view addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make){
         make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight);
         make.right.mas_equalTo(weakSelf.view.mas_right).offset(-10);
         make.height.equalTo(@44);
         make.width.equalTo(@54);
         
     }];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.informationTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.informationTableView];
    self.informationTableView.backgroundColor = [UIColor clearColor];
    self.informationTableView.showsVerticalScrollIndicator = NO;
    self.informationTableView.delegate = self;
    self.informationTableView.dataSource = self;
    self.informationTableView.bounces = NO;
    [self.informationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(34);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-34);
        make.top.mas_equalTo(weakSelf.view.mas_top).offset(kStatusBarHeight+44);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight-101);
    }];
    
    UIView *footerView = [[UIView alloc]init];
    self.informationTableView.tableFooterView = footerView;
    self.informationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.informationTableView registerClass:[UniversalTableViewCell class] forCellReuseIdentifier:@"userInfocell"];
    
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
//        make.top.mas_equalTo(weakSelf.view.mas_top).offset(0);
//        make.left.right.bottom.equalTo(weakSelf.view);
//    }];
    
    self.alertView.alertPickerBlock = ^(InformationType type, NSString *valueStr) {
        if (type == InformationType_Age) {
            if (![valueStr isEqualToString:weakSelf.birthday]) {
                weakSelf.birthday = valueStr;
                [weakSelf.userInfoDict setObject:valueStr forKey:@"birthday"];
            }
        }else if (type == InformationType_Weight || type == InformationType_Height){
            
            if (type == InformationType_Height) {
                if (![valueStr isEqualToString:weakSelf.height]) {
                    weakSelf.height = valueStr;
                    [weakSelf.userInfoDict setObject:valueStr forKey:@"height"];
                }
            }else{
                if (![valueStr isEqualToString:weakSelf.weight]) {
                    weakSelf.weight = valueStr;
                    [weakSelf.userInfoDict setObject:valueStr forKey:@"weight"];
                }
            }
        }else{}
        [weakSelf.informationTableView reloadData];
    };
    
}
//out
-(void)setDatePickerViewUI{
    WS(weakSelf);
    self.datePickerView = [[UIView alloc]init];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.datePickerView];
    self.datePickerView.hidden = YES;
    [self.datePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.height.equalTo(@(250));
    }];
    
    UIView *toolbar = [[UIView alloc]init];
    [self.datePickerView addSubview:toolbar];
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.datePickerView);
        make.height.equalTo(@50);
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#45addd"] forState:UIControlStateNormal];
    [toolbar addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(datePickCancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(toolbar);
        make.width.equalTo(@100);
        make.height.equalTo(@50);
    }];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor colorWithHexString:@"#45addd"] forState:UIControlStateNormal];
    [toolbar addSubview:okBtn];
    [okBtn addTarget:self action:@selector(datePickOK) forControlEvents:UIControlEventTouchUpInside];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(toolbar);
        make.width.equalTo(@100);
        make.height.equalTo(@50);
    }];
    
    self.datePicker = [[UIDatePicker alloc] init];
    //    //设置地区: zh-中国
    //    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    if (self.birthday.length > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *birthday = [formatter dateFromString:self.birthday];
        [self.datePicker setDate:birthday animated:YES];
    }else{
        [self.datePicker setDate:[NSDate date] animated:YES];
    }
    [self.datePickerView addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.datePickerView);
        make.bottom.mas_equalTo(weakSelf.datePickerView.mas_bottom).offset(0);
        make.height.equalTo(@200);
    }];
}
-(void)datePickCancel{
    self.datePickerView.hidden = YES;
}
-(void)datePickOK{
    WS(weakSelf);
    self.datePickerView.hidden = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置时间格式
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [formatter  stringFromDate:self.datePicker.date];
    if (![dateStr isEqualToString:self.birthday]) {
        weakSelf.birthday = dateStr;
        [weakSelf.informationTableView reloadData];
    }
    NSLog(@"dateStr = %@",dateStr);
}
//计算年龄
- (NSInteger)ageWithDateOfBirth:(NSDate *)date;
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    
    return iAge;
}
-(void)setPickerViewUI{
    WS(weakSelf);
    self.universalPickerView = [[UIView alloc]init];
    self.universalPickerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.universalPickerView];
    self.universalPickerView.hidden = YES;
    [self.universalPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-kTabbarSafeHeight);
        make.height.equalTo(@(250));
    }];
    
    UIView *toolbar = [[UIView alloc]init];
    [self.universalPickerView addSubview:toolbar];
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.universalPickerView);
        make.height.equalTo(@50);
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#45addd"] forState:UIControlStateNormal];
    [toolbar addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(universalPickCancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(toolbar);
        make.width.equalTo(@100);
        make.height.equalTo(@50);
    }];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor colorWithHexString:@"#45addd"] forState:UIControlStateNormal];
    [toolbar addSubview:okBtn];
    [okBtn addTarget:self action:@selector(universalPickOK) forControlEvents:UIControlEventTouchUpInside];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(toolbar);
        make.width.equalTo(@100);
        make.height.equalTo(@50);
    }];
    
    self.universalPicker = [[UIPickerView alloc] init];
    [self.universalPickerView addSubview:self.universalPicker];
    self.universalPicker.dataSource = self;
    self.universalPicker.delegate = self;
    self.universalPicker.showsSelectionIndicator = YES;
    [self.universalPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.universalPickerView);
        make.bottom.mas_equalTo(weakSelf.universalPickerView.mas_bottom).offset(0);
        make.height.equalTo(@200);
    }];
}
-(void)universalPickCancel{
    self.universalPickerView.hidden = YES;
}
-(void)universalPickOK{
    
    self.universalPickerView.hidden = YES;
    NSInteger row = [self.universalPicker selectedRowInComponent:0];
    NSInteger row2 = [self.universalPicker selectedRowInComponent:1];
    if (self.units == 0) {
        if (self.isHeight) {
            self.height = [NSString stringWithFormat:@"%@cm",self.cmArray[row]];
        }else{
            self.weight = [NSString stringWithFormat:@"%@kg",self.kgArray[row]];
        }
    }else{
        if (self.isHeight) {
            self.height = [NSString stringWithFormat:@"%@ft%@in",self.ftArray[row],self.inArray[row2]];
        }else{
            self.weight = [NSString stringWithFormat:@"%@lb",self.lbArray[row]];
        }
    }
    [self.informationTableView reloadData];
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    //    if (self.model.units == 1) {
    //        if (self.isHeight) {
    //            return 2;
    //        }
    //    }
    return 2;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.units == 0) {
        if (component == 0) {
            if (self.isHeight) {
                return self.cmArray.count;
            }else{
                return self.kgArray.count;
            }
        }else{
            return 1;
        }
    }else{
        if (self.isHeight) {
            if (component == 0) {
                return self.ftArray.count;
            }
            return self.inArray.count;
        }else{
            if (component == 0) {
                return self.lbArray.count;
            }else{
                return 1;
            }
        }
    }
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *str;
    if (self.units == 0) {
        if (component == 0) {
            if (self.isHeight) {
                str = self.cmArray[row];
            }else{
                str = self.kgArray[row];
            }
        }else{
            if (self.isHeight) {
                str = @"cm";
            }else{
                str = @"kg";
            }
        }
        
    }else{
        if (self.isHeight) {
            if (component == 0) {
                str = self.ftArray[row];
            }else{
                str = self.inArray[row];
            }
        }else{
            if (component == 0) {
                str = self.lbArray[row];
            }else{
                str = @"lb";
            }
        }
    }
    return str;
    
}

- (void)saveButtonClick:(UIButton*)sender{
    
    NSMutableDictionary * testDict = [NSMutableDictionary dictionary];
    [testDict setObject:[NSNull null] forKey:@"lastName"];
    [testDict setObject:[NSNull null] forKey:@"firstName"];
    [testDict setObject:[NSNull null] forKey:@"nation"];
    [testDict setObject:[NSNull null] forKey:@"blood"];
    [testDict setObject:[NSNumber numberWithInt:self.sex] forKey:@"sex"];
    [testDict setObject:self.units == 0 ?@"Metric":@"Inch" forKey:@"unit"];
    if (self.userName) {
        [testDict setObject:[NSString stringWithFormat:@"%@",self.userName] forKey:@"userName"];
    }else{
        [testDict setObject:[NSNull null] forKey:@"userName"];
    }
    if (self.birthday) {
        [testDict setObject:[NSString stringWithFormat:@"%@",self.birthday] forKey:@"birthday"];//
    }else{
        [testDict setObject:[NSNull null] forKey:@"birthday"];
    }
    if (self.height) {
        [testDict setObject:[NSString stringWithFormat:@"%@",self.height] forKey:@"height"];//
        
    }else{
//        [testDict setObject:[NSNull null] forKey:@"height"];
        [testDict setObject:@"" forKey:@"height"];
    }
    if (self.weight) {
        [testDict setObject:[NSString stringWithFormat:@"%@",self.weight] forKey:@"weight"];//
        
    }else{
//        [testDict setObject:[NSNull null] forKey:@"weight"];
        [testDict setObject:@"" forKey:@"weight"];
    }
    NSLog(@"个人信息保存按钮被点击了.上传信息：%@",testDict);
    WS(weakSelf);
    [[MSCoreManager sharedManager] postEditUserInfoForData:testDict WithResponse:^(ResponseInfo *info) {
        if ([info.code isEqualToString:@"200"]) {
            [MSCoreManager sharedManager].userModel.userName = self.userName?self.userName:nil;
            [MSCoreManager sharedManager].userModel.sex = self.sex;
            [MSCoreManager sharedManager].userModel.birthday = self.birthday?self.birthday:nil;
            [MSCoreManager sharedManager].userModel.units = self.units;
            [MSCoreManager sharedManager].userModel.height = self.height?self.height:nil;
            [MSCoreManager sharedManager].userModel.weight = self.weight?self.weight:nil;
            if (self.userName) weakSelf.personalInformationNameBlock(self.userName);
            [self back];
            [SVProgressHUD showSuccessWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }else{
            [SVProgressHUD showErrorWithStatus:info.message];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        }
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
