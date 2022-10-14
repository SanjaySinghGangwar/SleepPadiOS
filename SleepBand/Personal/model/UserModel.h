//
//  UserModel.h
//  SleepBand
//
//  Created by admin on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (copy,nonatomic)NSString *token;
//@property (assign,nonatomic)int userId;
//@property (copy,nonatomic)NSString *name;
@property (assign,nonatomic)int units;
@property (copy,nonatomic)NSString *project;
//@property (copy,nonatomic)NSString *bluetooth;


@property (copy,nonatomic)NSString *areaCode; //手机号码所在的区号
@property (copy,nonatomic)NSString *phoneNumber;//用户手机号码
@property (copy,nonatomic)NSString *email;//用户邮箱
@property (copy,nonatomic)NSString *userName;//用户名
@property (copy,nonatomic)NSString *lastName;//姓氏
@property (copy,nonatomic)NSString *firstName;//名字
@property (copy,nonatomic)NSString *avatar;//头像
@property (assign,nonatomic)int sex;//性别，1 男，2 女
@property (copy,nonatomic)NSString *birthday;//生日，格式：yyyy-MM-dd
@property (copy,nonatomic)NSString *nation;//国家
@property (copy,nonatomic)NSString *unit;//单位
@property (copy,nonatomic)NSString *height;//身高，单位厘米
@property (copy,nonatomic)NSString *weight;//体重，单位kg
@property (copy,nonatomic)NSString *blood;//血型
@property (copy,nonatomic)NSString *deviceCode;//当前绑定的睡眠带的MAC地址
@property (copy,nonatomic)NSString *createTime;//注册时间，格式：yyyy-MM-dd HH:mm:ss
@property (copy,nonatomic)NSString *updateTime;//个人信息更新时间，格式：yyyy-MM-dd HH:mm:ss

@end
