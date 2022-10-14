//
//  AlertView.h
//  SleepBand
//
//  Created by admin on 2019/2/15.
//  Copyright © 2019年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AlertType){
    AlertType_UnBind,//解绑设备
    AlertType_Logout,//退出登录
    AlertType_TextField,
    AlertType_ActionSheet,
    AlertType_ActionSheetPicker,
    AlertType_ResetPassword,
    AlertType_UpData,//固件升级
    AlertType_Disconnect //断开蓝牙
};

typedef NS_ENUM(NSInteger,InformationType) {
    InformationType_Name,
    InformationType_Gender,
    InformationType_Age,
    InformationType_Unit,
    InformationType_Height,
    InformationType_Weight
};

typedef void(^AlertOkBlock)(AlertType type);
typedef void(^AlertCancelBlock)(AlertType type);
typedef void(^AlertTextBlock)(AlertType type,NSString *text);
typedef void(^AlertActionSheetBlock)(AlertType type,int index);
typedef void(^AlertPickerBlock)(InformationType type,NSString *value);

@interface AlertView : UIView <UIPickerViewDataSource,UIPickerViewDelegate>

@property (assign,nonatomic)AlertType alertType;
@property (assign,nonatomic)InformationType informationType;
@property (copy,nonatomic)AlertCancelBlock alertCancelBlock;
@property (copy,nonatomic)AlertOkBlock alertOkBlock;
@property (copy,nonatomic)AlertTextBlock alertTextBlock;
@property (copy,nonatomic)AlertPickerBlock alertPickerBlock;
@property (copy,nonatomic)AlertActionSheetBlock alertActionSheetBlock;

@property (strong,nonatomic)UILabel *alertTitleL;
@property (strong,nonatomic)UITextField *textField ;
@property (strong,nonatomic)UIImageView *alertBgIV;
@property (nonatomic,strong)UIDatePicker *datePicker;
@property (strong,nonatomic)UIPickerView *universalPicker;
@property (assign,nonatomic)int units;
@property (strong,nonatomic)NSMutableArray *cmArray; //厘米数组
@property (strong,nonatomic)NSMutableArray *lbArray; //磅数组
@property (strong,nonatomic)NSMutableArray *inArray; //英寸数组
@property (strong,nonatomic)NSMutableArray *ftArray; //英尺数组
@property (strong,nonatomic)NSMutableArray *kgArray; //公斤数组

-(instancetype)init;
//只有OK按钮的提示框
-(instancetype)initWithAlertWithoutCancel;
-(void)showAlertWithoutCancelWithTitle:(NSString *)title type:(AlertType)type;

-(void)showAlertWithType:(AlertType)type title:(NSString *)title menuArray:(NSArray *)menuArray;
-(void)showPickerActionSheetWithType:(InformationType)informationType alertType:(AlertType)alertType dataArray:(NSArray *)dataArray value:(NSString *)value units:(int)units;
@end


