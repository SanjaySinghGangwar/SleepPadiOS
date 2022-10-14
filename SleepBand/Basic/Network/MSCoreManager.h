//
//  MSCoreManager.h
//  Kingdom
//
//  Created by 何助金 on 2017/7/17.
//  Copyright © 2017年 MissionSky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJHTTPManager.h"


static NSInteger kPageSize = 15;

@interface ResponseInfo : NSObject

@property (nonatomic, strong) id                response;
@property (nonatomic, assign) NSInteger         totalPages;
@property (nonatomic, strong) NSString          *code;
@property (nonatomic, strong) NSString          *message;
@property (nonatomic, strong) NSDictionary      *data;
@property (nonatomic, strong) NSArray           *list;
@property (nonatomic, assign) NSString          *location;
@end

#pragma mark - 转换error为相应的string描述
NSString * errorString(NSError *error, NSString *origin);
void showErrorTip(NSError *error, NSString *origin);


typedef void(^downloadProgressBlock)(long totalCount,long completedCount);
typedef void(^downloadBlock)(NSURL *filePath,NSError * error);

@interface MSCoreManager : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, strong) ZJHTTPManager *httpManager;
@property (nonatomic, strong) UserModel *userModel;
@property (nonatomic, strong) NSMutableArray *clockArray;
@property (nonatomic, copy) downloadProgressBlock downloadProgressBlock;
@property (nonatomic, copy) downloadBlock downloadBlock;

+ (MSCoreManager *)sharedManager;
- (void)setHTTPHeaderWithDefaults;
//获取验证码
-(void)getVerificationCodeForData:(NSDictionary *)dictionary WithResponse:(void (^)(ResponseInfo *))blockResponse;
//验证验证码
-(void)postVerificationCodeForData:(NSDictionary *)dictionary WithResponse:(void (^)(ResponseInfo *))blockResponse;
//注册
-(void)postRegisterForData:(NSDictionary *)registerData WithResponse:(void (^)(ResponseInfo *))blockResponse;
//注销
-(void)postUnregisterForData:(NSDictionary *)registerData WithResponse:(void (^)(ResponseInfo *))blockResponse;
//登录
-(void)postLoginForData:(NSDictionary *)loginData WithResponse:(void (^)(ResponseInfo *))blockResponse;
//设置密码
-(void)postSetPasswordForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//修改密码
-(void)postEditPasswordForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//绑定设备
-(void)postBindDeviceForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//解除绑定
-(void)postUnBindDeviceForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//绑定邮箱/手机号码
-(void)postBindEmailOrPhoneForAccount:(NSString *)account WithCode:(NSString *)code areaCode:(NSString*)areaCode isPhone:(BOOL)isPhone WithResponse:(void (^)(ResponseInfo *))blockResponse;
//解绑邮箱/手机号码
-(void)postBindEmailOrPhoneWithIsPhone:(BOOL)isPhone WithResponse:(void (^)(ResponseInfo *))blockResponse;
//解绑邮箱/手机号码（旧接口）
-(void)postBindEmailOrPhoneForCode:(NSString *)code WithIsCancelBind:(BOOL)isCancelBind WIsPhone:(BOOL)isPhone WithAccount:(NSString *)account WithResponse:(void (^)(ResponseInfo *))blockResponse;
//获取设备升级信息
-(void)getDeviceUpdateForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//下载固件
-(void)updateDeviceForUrl:(NSString *)url;
//编辑用户信息
-(void)postEditUserInfoForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//增加闹钟
-(void)postAddAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//修改闹钟
-(void)postUpdateAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//删除闹钟
-(void)getDeleteAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;
//获取全部闹钟
-(void)getGetAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse;

//上传睡眠心率呼吸率数据
-(void)postSleepDataFromParams:(NSDictionary *)params WithResponse:(void (^)(ResponseInfo *))blockResponse;
//获取睡眠心率呼吸率数据
-(void)getSleepDataFromParams:(NSDictionary *)params WithResponse:(void (^)(ResponseInfo *))blockResponse;

//意见反馈
-(void)getFeedbackForData:(NSDictionary *)dictionary WithResponse:(void (^)(ResponseInfo *))blockResponse;

#pragma mark - 数据库


@end

