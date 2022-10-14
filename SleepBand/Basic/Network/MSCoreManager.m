//
//  MSCoreManager.m
//  Kingdom
//
//  Created by 何助金 on 2017/7/17.
//  Copyright © 2017年 MissionSky. All rights reserved.
//



#import "MSCoreManager.h"
#import "AppDelegate.h"

// For keys
NSString * const kResultKey = @"response";
NSString * const kPageKey = @"page";
NSString * const kDidLoginSuccessNotification = @"DidLoginSuccessNotification";
NSString * const kUnauthorizedNotification = @"UnauthorizedNotification";
NSString * const kUpdateUserInfo = @"UpdateUserInfo";
NSString * const kCurrentToken = @"access-token";
NSString * const kCurrentAuthModel = @"currentAuthModel";
NSString * const kCurrentChannelCN = @"CurrentChannelCN";

/*
 user
 用户账户操作接口
 */
static NSString *LoginPost = @"/user/login"; //登录
static NSString *RegisterPost = @"/user/signUp"; //注册
static NSString *UnregisterPost = @"/user/unregister"; //注销
static NSString *VerificationCodeGet = @"/user/sendVerifyCode"; //获取验证码
static NSString *BindPhone = @"/user/bindPhoneNumber"; //绑定手机
static NSString *unBindPhone = @"/user/unbindPhoneNumber";//解绑手机
static NSString *BindEmail = @"/user/bindEmail"; //绑定邮箱
static NSString *unBindEmail = @"/user/unbindEmail";//解绑邮箱
static NSString *EditPasswordPost = @"/user/changePassword"; //修改密码
static NSString *SetPasswordPost = @"/user/retrievePassword"; //设置密码
//设置头像 /user/setProfilePicture
static NSString *EditUserInfo = @"/user/updateUserInfo"; //编辑用户信息
//获取用户信息 /user/getUserInfo

/*
 device
 睡眠带设备相关操作接口
 */
static NSString *BindDevice = @"/device/bindDevice"; //绑定设备
static NSString *UnBindDevice = @"/device/unbindDevice"; //解绑设备
static NSString *PutSleepData = @"/device/uploadSleepData"; //上传睡眠数据
static NSString *GetSleepData = @"/device/getSleepData"; //获取睡眠数据

/*
 alarmClock
 睡眠带闹钟相关接口
 */

static NSString *AddAlarmClock = @"/alarmClock/add"; //添加闹钟
static NSString *UpdateAlarmClock = @"/alarmClock/edit"; //修改闹钟
static NSString *DeleteAlarmClock = @"/alarmClock/delete"; //删除闹钟
static NSString *GetAlarmClock = @"/alarmClock/getList"; //获取闹钟

/* comm
 通用接口
 */
//跳转到“使用条款和隐私政策”web页面,该接口在 webview中使用 /comm/statement
static NSString *DeviceUpdate = @"/comm/upgrade"; //固件升级
static NSString *Feedback = @"/comm/feedback";//提交意见反馈


//未使用
static NSString *GetTokenPost = @"/oauth/token"; //获取token
static NSString *VerificationCodePost = @"/user/verifiCode"; //验证验证码

@implementation ResponseInfo

- (NSString *)description
{
    NSMutableString *strDESC = [NSMutableString string];
    [strDESC appendString:@"Response Info : { \n"];
    [strDESC appendFormat:@"Result : %@ \n", _response];
    if ([_response objectForKey:@"code"] &&
        [_response objectForKey:@"message"] &&
        [_response objectForKey:@"data"]) {
        
        [strDESC appendFormat:@"Code : %@ Message:%@\n", [_response objectForKey:@"code"],[_response objectForKey:@"message"]];
        NSInteger code = [[[_response objectForKey:@"data"] objectForKey: @"status"] intValue ];
        if (code) {
            [strDESC appendFormat:@"Status : %@ \n", @(code)];
        }
    }
    
    [strDESC appendString:@"} \n"];
    
    return [strDESC copy];
}//

@end

#pragma mark -

// 转换error为相应的string描述
NSString * errorString(NSError *error, NSString *origin)
{
    return error ? (error.localizedDescription) : origin;
}//

void showErrorTip(NSError *error, NSString *origin)
{
    [SVProgressHUD showErrorWithStatus:errorString(error, origin)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];

}//

#pragma mark -

#pragma mark -

@interface MSCoreManager ()

@end


@implementation MSCoreManager
//-(UserModel *)userModel{
//    if (_userModel == nil) {
//        _userModel = [[UserModel alloc] init];
//    }
//    return _userModel;
//}
-(NSMutableArray *)clockArray{
    if (_clockArray == nil) {
        _clockArray = [[NSMutableArray alloc]init];
    }
    return _clockArray;
}
+ (MSCoreManager *)sharedManager
{
    static MSCoreManager *__sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedManager = [[MSCoreManager alloc] init];
    });
    
    return __sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _httpManager = [ZJHTTPManager manager];
        [self setHTTPHeaderWithDefaults];
    }
    return self;
}
//获取验证码
-(void)getVerificationCodeForData:(NSDictionary *)dictionary WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",VerificationCodeGet];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:dictionary withResponse:blockResponse];
}
//验证验证码
-(void)postVerificationCodeForData:(NSDictionary *)dictionary WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",VerificationCodePost];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:dictionary withResponse:blockResponse];

}
//注册
-(void)postRegisterForData:(NSDictionary *)registerData WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",RegisterPost];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:registerData withResponse:blockResponse];
}
//注销
-(void)postUnregisterForData:(NSDictionary *)registerData WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",UnregisterPost];
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:registerData withResponse:blockResponse];
}
//登录
-(void)postLoginForData:(NSDictionary *)loginData WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",LoginPost];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:loginData withResponse:blockResponse];
}
//设置密码
-(void)postSetPasswordForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",SetPasswordPost];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:data withResponse:blockResponse];
}
//修改密码
-(void)postEditPasswordForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",EditPasswordPost];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:data withResponse:blockResponse];
}
//绑定邮箱/手机号码
-(void)postBindEmailOrPhoneForAccount:(NSString *)account WithCode:(NSString *)code areaCode:(NSString*)areaCode isPhone:(BOOL)isPhone WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url ;
    NSDictionary *dict;
    if (isPhone) {
        url = [NSString stringWithFormat:@"%@",BindPhone];
        dict = @{@"areaCode":areaCode,@"phoneNumber":account,@"verifyCode":code};
    }else{
        url = [NSString stringWithFormat:@"%@",BindEmail];
        dict = @{@"email":account,@"verifyCode":code};
    }
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:dict withResponse:blockResponse];

}
//解绑邮箱/手机号码
-(void)postBindEmailOrPhoneWithIsPhone:(BOOL)isPhone WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url ;
    if (isPhone) {
        url = [NSString stringWithFormat:@"%@",unBindPhone];
    }else{
        url = [NSString stringWithFormat:@"%@",unBindEmail];
    }
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:nil withResponse:blockResponse];
}
//解绑邮箱/手机号码 （旧接口）
-(void)postBindEmailOrPhoneForCode:(NSString *)code WithIsCancelBind:(BOOL)isCancelBind WIsPhone:(BOOL)isPhone WithAccount:(NSString *)account WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url ;
    NSDictionary *dict;
    if(isPhone){
        url = [NSString stringWithFormat:@"%@",BindPhone];
        dict = @{@"flag":@(isCancelBind),@"phoneNumber":account,@"verifyCode":code};
    }else{
        url = [NSString stringWithFormat:@"%@",BindEmail];
                dict = @{@"email":account,@"verifyCode":code};
    }
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:dict withResponse:blockResponse];
}
//绑定设备
-(void)postBindDeviceForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",BindDevice];
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:data withResponse:blockResponse];
}
//解绑设备
-(void)postUnBindDeviceForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",UnBindDevice];
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:data withResponse:blockResponse];
}
//获取设备升级信息
-(void)getDeviceUpdateForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",DeviceUpdate];
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:data withResponse:blockResponse];
}
//下载固件
-(void)updateDeviceForUrl:(NSString *)url{
    [_httpManager dowloadFileWithURL:url progress:^(NSProgress * _Nullable downloadProgress) {
        self.downloadProgressBlock(downloadProgress.totalUnitCount, downloadProgress.completedUnitCount);
    } completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        self.downloadBlock(filePath, error);
    }];
}
//编辑用户信息
-(void)postEditUserInfoForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",EditUserInfo];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:data withResponse:blockResponse];
}
//增加闹钟
-(void)postAddAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",AddAlarmClock];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:data withResponse:blockResponse];
}
//修改闹钟
-(void)postUpdateAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",UpdateAlarmClock];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:data withResponse:blockResponse];
}
//删除闹钟
-(void)getDeleteAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",DeleteAlarmClock];
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:data withResponse:blockResponse];
}
//获取全部闹钟
-(void)getGetAlarmClockForData:(NSDictionary *)data WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",GetAlarmClock];
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:data withResponse:blockResponse];
}
//上传睡眠心率呼吸率数据
-(void)postSleepDataFromParams:(NSDictionary *)params WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",PutSleepData];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:params withResponse:blockResponse];
}
//获取睡眠心率呼吸率数据
-(void)getSleepDataFromParams:(NSDictionary *)params WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",GetSleepData];
    [self sendRequestType:HTTPRequestType_GET withURL:url withParams:params withResponse:blockResponse];
}
//意见反馈
-(void)getFeedbackForData:(NSDictionary *)dictionary WithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",Feedback];
    
//    [_httpManager uploadWithDictData:dictionary withURL:url withParams:nil progress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
//        ResponseInfo *responseInfo = [self convertData:responseObject];
//        blockResponse(responseInfo);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
//        ResponseInfo *responseInfo = [self convertWithError:error withErrorData:task.response];
//        blockResponse(responseInfo);
//        NSLog(@"请求URL：%@",task.originalRequest.URL);
//        NSLog(@"请求方式：%@",task.originalRequest.HTTPMethod);
//        NSLog(@"请求头信息：%@",task.originalRequest.allHTTPHeaderFields);
//        NSLog(@"请求正文信息：%@",[[NSString alloc]initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]);
//    }];
    
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:dictionary withResponse:blockResponse];
}
//获取Token
- (void)getTokenWithResponse:(void (^)(ResponseInfo *))blockResponse{
    NSString *url = [NSString stringWithFormat:@"%@",GetTokenPost];
    [_httpManager setRequestHeader:@{
                                     @"Authorization":@"basic MTYwMTA5ZjY3ZDZhNjI1MTc4NjQ2YzYxYjI1MDRlNzE0YTUyZWRjMTpmbUhTSlNOS2FqOWZUZkVuTHNFYU5qSk9lSHVWa1NXUlNDT0d0U0xzelRnWWRvTUFacm54Y3BkandNQ25IclRvclZvK2UwcUZ4dDNmRGp5NVV1MW00WTFWZWhwM3EvS0k2OHh0MVlJOHhkYUNBZ0lBeXlTV200ckJ6R3ZhYzBBRQ==",
                                     @"Content-Type":@"application/x-www-form-urlencoded"
                                     }
     ];
    [self sendRequestType:HTTPRequestType_POST withURL:url withParams:@{
                                                                        @"grant_type":@"client_credentials",
                                                                        @"scope":@"upload",@"token_type":@"bearer"
                                                                        } withResponse:blockResponse];
}

#pragma mark - 获取钥匙串
-(NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}
//获取钥匙串
-(id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            //            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}
- (void)setHTTPHeaderWithDefaults
{
    //    在app启动前就执行了
//    [_httpManager setRequestHeader:@{@"Authorization":@"1"}];
//    [_httpManager setRequestHeader:@{@"Project":projectName}];
//    [_httpManager setRequestHeader:@{@"accept":@"application/json"}];
//    [_httpManager setRequestHeader:@{@"Content-Type":@"application/json"}];
    
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if([[appLanguages objectAtIndex:0] rangeOfString:@"zh-Han"].length > 0){
        [_httpManager setRequestHeader:@{@"Accept-Language":AppleLanguages_zh_CN}];
    }else{
        [_httpManager setRequestHeader:@{@"Accept-Language":AppleLanguages_en_US}];
    }

}

- (void)sendRequestType:(HTTPRequestType)HTTPType
                withURL:(NSString *)strURL
             withParams:(nullable id)dicParams
           withResponse:(void (^)(ResponseInfo *))blockRespone
{
    strURL = [NSString stringWithFormat:@"%@%@",GET_NetWork_URL_Head,strURL];
    [_httpManager resquestWith:HTTPType withURL:strURL withParams:dicParams success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"请求URL：%@",task.originalRequest.URL);
        NSLog(@"请求方式：%@",task.originalRequest.HTTPMethod);
        NSLog(@"请求头信息：%@",task.originalRequest.allHTTPHeaderFields);
//        NSLog(@"请求正文信息：%@",[[NSString alloc]initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]);
//        NSLog(@"responseObject = %@",responseObject);
        ResponseInfo *responseInfo = [self convertData:responseObject];
        blockRespone(responseInfo);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        ResponseInfo *responseInfo = [self convertWithError:error withErrorData:task.response];
        blockRespone(responseInfo);
    }];
}

- (ResponseInfo *)convertData:(id)responseObject
{
    NSDictionary *dicRes = @{};
    if (![responseObject isKindOfClass:[NSHTTPURLResponse class]]) {
//        dicRes = [NSJSONSerialization JSONObjectWithData:responseObject
//                                                 options:NSJSONReadingMutableContainers
//                                                   error:&error];
        dicRes = [NSDictionary dictionaryWithDictionary:responseObject];
    }
    
    ResponseInfo *res = [[ResponseInfo alloc] init];
    if ([dicRes isKindOfClass:[NSDictionary class]]) {
        if ([dicRes objectForKey:@"code"] &&
            [dicRes objectForKey:@"msg"] ) {
            //&&
//            [dicRes objectForKey:@"data"]
            res.code = [NSString stringWithFormat:@"%@",[dicRes objectForKey:@"code"]];
            res.message = [NSString stringWithFormat:@"%@",[dicRes objectForKey:@"msg"]];
            if ([res.code isEqualToString:@"401"]) {
                AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [delegate setRootViewControllerForLogin];
                if ([BlueToothManager shareIsnstance].isConnect) {
                    [[BlueToothManager shareIsnstance] cancelConnect];//断开连接
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"0" forKey:@"isLogin"];
                [defaults synchronize];
            }
            NSLog(@"res.code = %@,res.message = %@",res.code,res.message);
//            if([res.code isEqualToString:@"101"]){
//                res.message = NSLocalizedString(@"ErrorTokenPastDue", nil);
//            }else if([res.code isEqualToString:@"105"]){
//                res.message = NSLocalizedString(@"ErrorEmailUsed", nil);
//            }else if([res.code isEqualToString:@"106"]){
//                res.message = NSLocalizedString(@"ErrorPhoneUsed", nil);
//            }else if([res.code isEqualToString:@"204"]){
//                res.message = NSLocalizedString(@"LVC_AlertAccountPasswordError", nil);
//            }else if([res.code isEqualToString:@"205"]){
//                res.message = NSLocalizedString(@"RVC_AlertCodeError", nil);
//            }else if([res.code isEqualToString:@"206"]){
//                res.message = NSLocalizedString(@"RVC_AlertCodePastDue", nil);
//            }else if([res.code isEqualToString:@"207"]){
//                res.message = NSLocalizedString(@"ErrorEmailFail", nil);
//            }else if([res.code isEqualToString:@"208"]){
//                res.message = NSLocalizedString(@"LVC_AlertAccountUnregistered", nil);
//            }else if([res.code isEqualToString:@"209"]){
//                res.message = NSLocalizedString(@"RVC_AlertCodeFrequently", nil);
//            }else if([res.code isEqualToString:@"300"]){
//                res.message = NSLocalizedString(@"ErrorUserExist", nil);
//            }else if([res.code isEqualToString:@"305"]){
//                res.message = NSLocalizedString(@"ErrorFileUploadFail", nil);
//            }else{
//                res.message = NSLocalizedString(@"ErrorNetworkRequestFail", nil);
//            }
            
            if ([dicRes objectForKey:@"data"] == [NSNull null]) {
                res.data = @{};
            }else{
                res.data = [dicRes objectForKey:@"data"];
            }
            if ([dicRes objectForKey:@"array"] == [NSNull null]) {
                res.list = @[];
            }else{
                res.list = [dicRes objectForKey:@"list"];
            }
        }
    }
    return res;
}//
- (ResponseInfo *)convertWithError:(NSError *)error withErrorData:(id)failData
{
    NSString * str  =[[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    ResponseInfo *responseInfo = [[ResponseInfo alloc] init];
    if ([failData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicRes = (NSDictionary *)failData;
        if ([dicRes objectForKey:@"code"] &&
            [dicRes objectForKey:@"msg"] &&
            [dicRes objectForKey:@"data"]) {
            responseInfo.code = [dicRes objectForKey:@"code"];
            responseInfo.message = NSLocalizedString(@"ErrorNetworkRequestFail", nil);
            responseInfo.data = [dicRes objectForKey:@"data"];
            responseInfo.list = [dicRes objectForKey:@"list"];
        }
    }else{
        responseInfo.code = [NSString stringWithFormat:@"%ld",(long)error.code];
        responseInfo.message = NSLocalizedString(@"ErrorNetworkRequestFail", nil);
        responseInfo.data = @{};
        responseInfo.list = @[];
    }
    return responseInfo;
}//

@end

