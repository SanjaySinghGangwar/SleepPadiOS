//
//  BlueToothManager.m
//  QLife
//
//  Created by admin on 2018/4/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "BlueToothManager.h"
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>


#define Service_UUID          @"00001523-1212-EFDE-1523-785FEABCD125"
#define Write_Characteristic  @"00001524-1212-EFDE-1523-785FEABCD125"  //写
#define Response_Characteristic  @"00001525-1212-EFDE-1523-785FEABCD125"  //响应
#define HR_RR_Characteristic  @"00001526-1212-EFDE-1523-785FEABCD125"  //心率_呼吸值
#define HR_RR_Sample_Characteristic  @"00001527-1212-EFDE-1523-785FEABCD125"  //心率_呼吸率采样值 或 翻身历史数据，心率_呼吸率历史数据
#define Service_DFU_UUID  @"FE59"  //
#define DFU_Characteristic  @"8EC90003-F315-4F60-9FB8-838830DAEA50"
#define DFU_Characteristic1  @"8EC90001-F315-4F60-9FB8-838830DAEA50"
#define DFU_Characteristic2  @"8EC90002-F315-4F60-9FB8-838830DAEA50"//
//F0050000-AC46-485F-87B6-F111112F2042

@interface BlueToothManager() <NSCopying,NSMutableCopying>

@end
static BlueToothManager * _manager = nil;
@implementation BlueToothManager
-(MSCoreManager *)coreManager
{
    if (_coreManager == nil) {
        
        _coreManager = [MSCoreManager sharedManager];
    }
    return _coreManager;
}

-(NSMutableArray *)clockMutableArray
{
    if (_clockMutableArray == nil) {
        
        _clockMutableArray = [[NSMutableArray alloc]init];
    }
    return _clockMutableArray;
}

-(NSMutableArray *)scanPeripheralArray
{
    if (_scanPeripheralArray == nil) {
        
        _scanPeripheralArray = [[NSMutableArray alloc]init];
    }
    return _scanPeripheralArray;
}

-(NSMutableData *)mutableData
{
    if (_mutableData == nil) {
        
        _mutableData = [[NSMutableData alloc]init];
    }
    return _mutableData;
}
-(NSMutableArray *)SQMutableArray
{
    if (_SQMutableArray == nil) {
        
        _SQMutableArray = [[NSMutableArray alloc]init];
    }
    return _SQMutableArray;
}
-(NSMutableArray *)RrMutableArray
{
    if (_RrMutableArray == nil) {
        
        _RrMutableArray = [[NSMutableArray alloc]init];
    }
    return _RrMutableArray;
}

-(NSMutableArray *)HrMutableArray
{
    if (_HrMutableArray == nil) {
        
        _HrMutableArray = [[NSMutableArray alloc]init];
    }
    return _HrMutableArray;
    
}
-(NSMutableArray *)TurnMutableArray
{
    if (_TurnMutableArray == nil) {
        
        _TurnMutableArray = [[NSMutableArray alloc]init];
    }
    return _TurnMutableArray;
    
}

//-(NSMutableArray *)dataArray{
//    if (_dataArray) {
//        _dataArray = [[NSMutableArray alloc]init];
//    }
//    return _dataArray;
//}

#pragma mark - 创建蓝牙类单例

//+(instancetype)shareIsnstance
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken , ^{
//
//        if (manager == nil) {
//            manager = [[self alloc] init];
//            [manager createCentralManager];
//        }
//
//
//    });
//    return manager;
//
//}

+ (instancetype)shareIsnstance {
//    [_manager createCentralManager];
            return [[self alloc] init];
        }
        
+ (id)allocWithZone:(struct _NSZone *)zone {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [super allocWithZone:zone];
            [_manager createCentralManager];
            }
        });
        return _manager;
    }
    
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
            return _manager;
        }
        
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
            return _manager;
}

#pragma mark - 懒加载
-(void)createCentralManager
{
    if(self.centralManager)
    {
        self.centralManager = nil;
    }
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    //    NSLog(@"createCentralManager:%ld",(long)self.centralManager.state);
    
}

#pragma mark - 创建中心管理类
//-(CBCentralManager *)centralManager{
//    if (_centralManager == nil) {
//        dispatch_queue_t queue = dispatch_queue_create("bluetooth", DISPATCH_QUEUE_SERIAL);
//        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
//    }
//    return _centralManager;
//}

#pragma mark - CBCentralManagerDelegate
// 检查系统蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //    NSLog(@"centralManagerDidUpdateState:%ld",(long)self.centralManager.state);
    self.centralManagerState = central.state;
    NSLog(@"zp蓝牙状态=%ld",(long)self.centralManager.state);
    switch (central.state)
    {
        case CBManagerStatePoweredOff:
            
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothClose", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            
            if (self.isConnect)
            {
                self.isConnect = NO;
                self.connectPeripheralBlock(NO);
            }
            break;
        case CBManagerStateUnauthorized:
            //            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothNoAuthorization", nil)];
            //            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            break;
        case CBManagerStatePoweredOn:
            
            if(!self.isScan && !self.isConnect){
                
                [self scanAllPeripheral];
            }
            
            break;
        default:
            break;
    }
}

// 搜索所有蓝牙外设
-(void)scanAllPeripheral
{
    [self stopScan];
    self.centralManagerState = self.centralManager.state;
    if (self.centralManager.state == 5)
    {
        
        
        [self.scanPeripheralArray removeAllObjects];
        
        if (self.coreManager.userModel.deviceCode.length > 1)
        {
            self.deviceName = self.coreManager.userModel.deviceCode;
            //蓝牙连接中...
            [SVProgressHUD showWithStatus:NSLocalizedString(@"BTM_DeviceMonitoring", nil)];
            [SVProgressHUD dismissWithDelay:8.0 completion:^{
                if (!self.isConnect) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BTM_DeviceOutTime", nil)];
                    [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
                    [self stopScan];
                }
            }];
        }else
        {
            self.deviceName = @"";
        }
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        if ([defaults stringForKey:@"lastConnectDevice"].length > 1) {
//            self.deviceName = [defaults stringForKey:@"lastConnectDevice"];
//        }else{
//            self.deviceName = @"";
//        }
//        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerRestoredStateScanOptionsKey:@(YES)}];
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        self.isScan = YES;
        
    }else if (self.centralManagerState == 4)
    {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothClose", nil)];
        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
        
    }else
    {
        //        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothNoAuthorization", nil)];
        //        [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    }
    //    self.centralManagerState = self.centralManager.state;
    //    switch (self.centralManager.state) {
    //        case CBManagerStatePoweredOff:
    //            if (![SVProgressHUD isVisible] ) {
    //                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothClose", nil)];
    //                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    //                [self stopScan];
    //                self.isScan = NO;
    //            }
    //            break;
    //        case CBManagerStateUnauthorized:
    //            if (![SVProgressHUD isVisible] ) {
    //                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_BlueToothNoAuthorization", nil)];
    //                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
    //                [self stopScan];
    //                self.isScan = NO;
    //            }
    //            break;
    //        case CBManagerStatePoweredOn:
    //            [self.scanPeripheralArray removeAllObjects];
    //            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    //            self.isScan = YES;
    //            break;
    //        default:
    //            [self stopScan];
    //            self.isScan = NO;
    //            break;
    //    }
}

#pragma mark --2搜索扫描到外设
// 执行扫描的动作之后，如果扫描到外设了，就会自动回调下面的协议方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI
{
    NSLog(@"[%d]设备名:%@",self.testInt,peripheral.name);
//    self.testInt++;
    
    if ([peripheral.name rangeOfString:@"Dfu"].length > 0 && self.isUpdateManualCancelConnect) {
        [self connectPeripheral:peripheral];
        return;
    }
    
    if (self.isUpdateManualCancelConnect) return;
    
//    NSRange range = [peripheral.name rangeOfString:@"iSmarport_LE"];
    NSRange range = [peripheral.name rangeOfString:@"sleep"];
    NSString *value;
    if (range.length > 0)
    {
        NSLog(@"advertisementData = %@",advertisementData);
        if([[advertisementData allKeys] containsObject:@"kCBAdvDataManufacturerData"]){
            
            value = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
            
        }
        if (self.deviceName.length > 0 )
        {
            if (value && value.length > 0)
            {
                if ([[self getMacAddress:value] isEqualToString:self.deviceName])
                {
                    [self connectPeripheral:peripheral];
                }
            }
            
        }else
        {
            [self.scanPeripheralArray addObject:peripheral];
            PeripheralModel *model = [[PeripheralModel alloc]init];
            model.peripheral = peripheral;
            if (value && value.length > 0) {
                
                model.macAddress = [self getMacAddress:value];
            }
            [self scanBlock:model];
        }
        
    }
    
//    if (self.deviceName.length > 0) {
//        if ([peripheral.name isEqualToString:self.deviceName]) {
//            [self connectPeripheral:peripheral];
//        }
//    }else{
//        NSRange range = [peripheral.name rangeOfString:@"sleep"];
//        if (range.length > 0)
//        {
//            [self.scanPeripheralArray addObject:peripheral];
//            [self scanBlock:peripheral];
//        }
//    }
    
}

-(NSString *)getMacAddress:(NSString *)value{
    
    NSMutableString *macString = [[NSMutableString alloc] init];
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 13.0) {
        // 针对 13.0 以上的iOS系统进行处理
        // 实例 ---  {length = 8, bytes = 0x0000c759c5d71992}
        value = [value substringWithRange:NSMakeRange(value.length - 18, 18)];
        [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(7, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(9, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(11, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(13, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(15, 2)] uppercaseString]];
    } else {
        // 针对 13.0 以下的iOS系统进行处理
        // 实例 ---  <0000c759 c5d71992>
        [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(7, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(10, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
    }
    
    
    
    
    return macString;
}

-(void)connectPeripheral:(CBPeripheral *)peripheral
{
    self.currentPeripheral = peripheral;
    self.currentPeripheral.delegate = self;
    [self.centralManager connectPeripheral:self.currentPeripheral options:nil];
    [self stopScan];
    self.isScan = NO;
}

-(void)manualCancelConnect
{
    self.isManualCancelConnect = YES;
    [self cancelConnect];
}

-(void)connectCurrentPeripheral
{
    self.currentPeripheral.delegate = self;
    [self.centralManager connectPeripheral:self.currentPeripheral options:nil];
    //蓝牙连接中...
    [SVProgressHUD showWithStatus:NSLocalizedString(@"BTM_DeviceMonitoring", nil)];
    [SVProgressHUD dismissWithDelay:8.0 completion:^{
        if (!self.isConnect) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BTM_DeviceOutTime", nil)];
            [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
            [self stopScan];
        }
    }];
    
//    [self stopScan];
//    self.isScan = NO;
    
}

-(void)cancelConnect
{
    [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
}

-(void)scanBlock:(PeripheralModel *)model
{
    self.scanPeripheralBlock(model);
}

#pragma mark --连接外设-成功
// 如果连接成功，就会回调下面的协议方法了
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功");
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"BTM_SuccessToConnectPeripheral", nil)];
    [SVProgressHUD dismissWithDelay:1.0f];
    [peripheral discoverServices:nil];
    
    if (self.manualCancelConnectBlock && self.isUpdateManualCancelConnect) {
        self.manualCancelConnectBlock();
    }
    
}

// 连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
    {
        NSLog(@"连接失败,%@",error);
        self.connectPeripheralBlock(NO);
        self.isConnect = NO;
    }
}

// 外设断开连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.isConnect = NO;
    NSLog(@"设备断开连接,%@",error);
    if (!self.isManualCancelConnect)
    {
        self.connectPeripheralBlock(NO);
        if (!self.isUpdateManualCancelConnect) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BTM_DeviceFailToConnect", nil)];
            [SVProgressHUD dismissWithDelay:1.0f];
        }
        
    }else
    {
        self.isManualCancelConnect = NO;
    }
    
}

// 停止搜索
-(void)stopScan
{
    self.isScan = NO;
    [self.centralManager stopScan];
}

#pragma mark - CBPeripheralDelegate
// 读取到外设的相关服务就会回调下面的方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServicesError:%@",error);
        [self cancelConnect];
        
    }else
    {
        for (CBService *service in peripheral.services) {
            if([[service.UUID UUIDString] isEqualToString:Service_UUID])
            {
                [peripheral discoverCharacteristics:nil forService:service];
            }
            if([[service.UUID UUIDString] isEqualToString:Service_DFU_UUID])
            {
                [peripheral discoverCharacteristics:nil forService:service];
            }
            
        }
    }
}


#pragma mark --获取到服务的特证
// 订阅, 实时接收
// 遍历特征值
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverCharacteristicsForService:%@",error);
        
        [self cancelConnect];
        
    }else
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([[characteristic.UUID UUIDString] isEqualToString:Write_Characteristic])
            {
                self.writeCharacteristic = characteristic;
            }
            if ([[characteristic.UUID UUIDString] isEqualToString:Response_Characteristic])
            {
                self.responseCharacteristic = characteristic;
                [self.currentPeripheral setNotifyValue:YES forCharacteristic:self.responseCharacteristic];
                
            }
            if ([[characteristic.UUID UUIDString] isEqualToString:HR_RR_Characteristic])
            {
                self.HrRrCharacteristic = characteristic;
                [self.currentPeripheral setNotifyValue:YES forCharacteristic:self.HrRrCharacteristic];
                
            }
            if ([[characteristic.UUID UUIDString] isEqualToString:HR_RR_Sample_Characteristic])
            {
                self.HrRrSampleCharacteristic = characteristic;
                [self.currentPeripheral setNotifyValue:YES forCharacteristic:self.HrRrSampleCharacteristic];
                
            }
            if ([[characteristic.UUID UUIDString] isEqualToString:DFU_Characteristic]){
                self.DFUCharacteristic = characteristic;
                [self.currentPeripheral setNotifyValue:YES forCharacteristic:self.DFUCharacteristic];
            }
        }
        //设置设备时间
//        NSLog(@"测试需要，屏蔽设置睡眠带时间");
        
        if (self.currentPeripheral && self.DFUCharacteristic && !self.isConnect) {
            [self setDeviceTime];
            self.isConnect = YES;
        }
        
        
    }

}

#pragma mark--向peripheral中写入数据后的回调函数
//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"写入失败 -> error : %@", error);
        return;
    }
    
    if (characteristic.value && characteristic.value.length > 0) {
        Byte *byte = (Byte*)[characteristic.value bytes];
        NSLog(@">>>>>>>>>>>>>>写入成功 : %@",characteristic.value);
        NSLog(@"包头 = %x,长度 = %x,命令 = %x",byte[0],byte[1],byte[2]);
    }else{
        NSLog(@">>>>>>>>>>>>>>写入成功");
    }
    
}
#pragma mark --向外围设备发送数据
/*发送数据*/
- (void)sendCommandWithData:(NSData*)data{
    Byte *byte = (Byte*)[data bytes];
    NSLog(@">>>>>>>>>>>>>>(包头 = %x,长度 = %x,命令 = %x)发送数据 = %@",byte[0],byte[1],byte[2],data);
    [self.currentPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark --从外围设备读取数据
/*获取数据*/
//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) return;
    
    /* 校验数据 */
    //1.将NSData转化为Byte数组
    Byte *byte = (Byte*)[characteristic.value bytes];
    NSLog(@">>>>>>>>>>>>>>(包头 = %x,长度 = %x,命令 = %x)接收数据 = %@",byte[0],byte[1],byte[2],characteristic.value);
    //2.判断指令是否为空
    if (characteristic.value.length == 0) {
        NSLog(@"指令为空或没有数据");
        return;
    }
    //3.判断是否包含指令头
    if (byte[0] != 0x5A) {
        NSLog(@"指令不包含指令头");
        return;
    }
    //4.校验数据长度
    if (byte[1] != characteristic.value.length) {
        NSLog(@"指令长度不匹配");
        return;
    }
    //5.CRC校验
    //...
    
    //6.根据相应指令进行数据保存操作
    if (characteristic == self.responseCharacteristic)
    {
        //回复特征
        //命令： 00 02 03 06 54
        NSLog(@"特征：responseCharacteristic");
        //获取当前日期前N天的日期
        NSDate * date = [UIFactory returnCurrentDayBefore:-self.currentSynchronizationCount];
        //返回该时区时间
        NSDate * date1 = [UIFactory NSDateForNoUTC:date];
        //date转不带“-”的字符串
        self.synchronizationDate = [UIFactory dateForNumString:date1];
        
        switch (byte[2]) {
            case 0x00:
                //读取设备版本
                [self getDeviceVersions:byte];
                break;
                
            case 0x02:
                //读取设备 电量
                [self getDeviceBatterys:byte];
                break;
                
            case 0x03:
                //设备时间数据
                if (byte[1] == 0x06){
                    if (byte[4] == 0x01){
                        //时间设置成功，发送读取设备时间指令
//                        [self readDeviceTime];
                        self.connectPeripheralBlock(YES);
                    }
                }else if (byte[1] == 0x0B){
                    //byte[8],byte[9] 为时区
                    int test;
                    test = (int) ((byte[4] & 0xff) | ((byte[5] & 0xff)<<8) | ((byte[6] & 0xff)<<16) | ((byte[7] & 0xff)<<24));
                    
                    // 格式化时间
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    int h = byte[8];
                    int m = byte[9];
                    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:h*3600+m*60];
                    [formatter setDateStyle:NSDateFormatterMediumStyle];
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
                    
                    NSDate* date = [NSDate dateWithTimeIntervalSince1970:test];
                    NSString* dateString = [formatter stringFromDate:date];
                    
                    NSLog(@"设备时间: date = %@ ,dateString = %@",date,dateString);
                    
                }
                break;
                
            case 0x06:
                if (byte[1] == 0x07) {
                    //闹钟增、删、改结果回调
                    NSLog(@"设备闹钟<增、删、改>结果回调");
                    if(byte[3]  != 4){
                        self.clockOperationBlock(byte[3], byte[4], byte[5]);
                    }
                }
                break;
            
            case 0x55:
                //删除睡眠带历史数据 byte[4]、 0x01成功、 0x00失败
                NSLog(@"删除睡眠带历史数据:%@", (byte[3] == 0x01) ? @"成功": @"失败");
                break;
                
            default:
                break;
        }
        
    }
    else if (characteristic == self.HrRrCharacteristic)
    {
        //心率-呼吸值特征(实时数据通道)
        //命令： 50
        NSLog(@"特征：HrRrCharacteristic");
        if (byte[2] == 0x50){
            //心率呼吸率实时数值
            [self UpdateValueForHrRrCharacteristic:self.HrRrCharacteristic];
            
        }
        return;
    }
    else if (characteristic == self.HrRrSampleCharacteristic)
    {
        //心率-呼吸率采样值特征(历史数据通道)
        //命令： 51 52 53 54
        NSLog(@"特征：HrRrSampleCharacteristic");
        
        switch (byte[2]) {
            case 0x06:
            {
                NSLog(@"设备闹钟<查询>结果回调  0x0F");
                ////闹钟查结果回调  0x0F
                NSData * data = characteristic.value;
                NSData * newData = [data subdataWithRange:NSMakeRange(4, data.length-5)];
                [self getDeviceClockForResponseSubpackage:newData];
            }
                break;
                
            case 0x0a:
                if (byte[1] == 0x07) {
                    //设备->app，心率&呼吸预警
                    int alertStyle = byte[3];//心率预警:0    呼吸预警1
                    int alert_hr = byte[4];//心率值
                    int alert_rr = byte[5];//呼吸值
                    NSLog(@"预警类型:%d（心率预警-0、呼吸预警-1） ， 预警当前值：心率-%d，呼吸-%d",alertStyle,alert_hr,alert_rr);
                    
                    for (AlarmClockModel * model in [AlarmClockModel GetAllAlarmClockEvent]) {
                        NSLog(@"model.clockTimer = %@",model.clockTimer);
                        if (model.clockId == 99999) {
                            [AlarmClockModel RemoveAlarmClockWithTimer:model.clockTimer];
                        }
                        
                    }
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString * timeString = [formatter stringFromDate:[NSDate date]];//当天日期
                    // 获取今日星期
                    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];// 指定日历的算法
                    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
                    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour |  NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
                    NSDateComponents *comps = [calendar components:unitFlags fromDate:[NSDate date]];// 1是周日，2是周一 3.以此类推
                    NSNumber * weekNumber = @([comps weekday]);
                    NSLog(@"今日星期:%@(1是周日，2是周一 3.以此类推)",weekNumber);
                    //我们星期选择的控件返还的星期，0是周日，1是周一 2以此类推，所以要-1，再去校验；
                    NSString * weekString = [NSString stringWithFormat:@"%d",[weekNumber intValue] - 1];
                    
                    NSString * selectClockTimer = [NSString stringWithFormat:@"%02d:%02d:00",(int)comps.hour,(int)comps.minute];
                    
                    AlarmClockModel * model = [[AlarmClockModel alloc]init];
                    model.isPhone = YES;
                    model.isOn = YES;
                    model.isIntelligentWake = NO;
                    model.clockId = 99999;
                    model.hour = (int)comps.hour;
                    model.minute = (int)comps.minute;
                    model.type = 1;
                    model.index = -1;
                    model.remark = [NSString stringWithFormat:@"%@ = %d ;\n %@ = %d ;",NSLocalizedString(@"RTVC_HeartRateTitle", nil),alert_hr,NSLocalizedString(@"RTVC_RespiratoryRateTitle", nil),alert_rr];
                    model.repeat = @[weekString];
                    model.clockTitle = NSLocalizedString(@"ACMVC_Tips", nil);
                    model.clockDescribe = model.remark;
                    model.clockMusic = @"bell_ring.m4a";
                    NSString *clockTimer = [timeString stringByReplacingOccurrencesOfString:[[formatter stringFromDate:[NSDate date]] substringFromIndex:timeString.length-8] withString:selectClockTimer];
                    NSLog(@"APP内响铃闹钟 响铃时间 : %@",clockTimer);
                    model.clockTimer = clockTimer;
                    [AlarmClockModel SaveAlarmClockWithModel:model];
                    
                }
                break;
                
            case 0x51:
                NSLog(@"心率-呼吸率绘图数据");
                [self UpdateValueForHrRrSampleCharacteristic:self.HrRrSampleCharacteristic];
                break;
            case 0x52://睡眠质量
            {
                [self.SQMutableArray addObject:characteristic.value];
                
                if (characteristic.value.length == 5) {//设备无任何睡眠质量数据
                    self.isSyncSQ = YES;
                    [self readHrBrDataNotifyWithAll:YES];//部分
                    break;
                }
//                if (byte[3] == 1) {//最后一条数据
//                    self.bagIndex = byte[4];
//                    if (self.bagIndex + 1 != self.SQMutableArray.count) {
//                        break;
//                    }else{
//                        self.bagIndex = -1;
//                    }
//                }else{
//                    break;
//                }
                
                if (byte[3] == 1) {//最后一条数据
                    self.bagIndex = byte[4];
                    self.getLastBag = YES;
                }
                if (self.getLastBag) {//已接受过最后一个包
                    if (self.bagIndex + 1 != self.SQMutableArray.count) {//校验当前包是否是最后一个包
                        break;
                    }else{
                        self.bagIndex = -1;//恢复默认值
                        self.getLastBag = NO;//恢复默认值
                    }
                }else{//还未接受过最后一个包
                    break;
                }
                
                NSLog(@"开始解析睡眠质量历史数据");
                [SVProgressHUD dismissWithDelay:kDismissWithDelayTime];
//                if (byte[3] == 1) {//最后一条数据
                
                    //存放时间戳的数组
                    NSMutableArray * timeStringArr = [NSMutableArray array];
                    //拼接蓝牙数据
                    NSMutableData * allData = [self addDataWithSubDataArr:self.SQMutableArray];
                    //按时间戳拆分数据
                    NSMutableArray * subDataArr = [self getSubDataArrWithAllData:allData subLength:3];
                    for (int i = 0; i<subDataArr.count; i++) {
                        //单段数据（数据h格式：时间戳+数据个数+有效数据）
                        NSData * data = subDataArr[i];
                        Byte *subByte = (Byte*)[data bytes];
                        //时间戳
                        int timeString = (int)((subByte[0] & 0xff) | ((subByte[1] & 0xff)<<8) | ((subByte[2] & 0xff)<<16) | ((subByte[3] & 0xff)<<24));
                        //数据个数
                        int stateNum = (int)((subByte[4] & 0xff) | ((subByte[5] & 0xff)<<8));
                        
                        //存放有效数据的数组
                        NSMutableArray * stateArr = [NSMutableArray array];
                        int allStateTime = 0;
                        for (int j = 0; j<stateNum; j++) {
                            //状态时长 单位：分钟
                            int stateTime = (int)((subByte[6+3*j] & 0xff) | ((subByte[7+3*j] & 0xff)<<8));
                            //状态 0-64-128-192-256
                            int state = subByte[8+3*j];
                            NSDictionary * dict = @{@"stateTime":[NSString stringWithFormat:@"%d",stateTime],
                                                    @"state":[NSString stringWithFormat:@"%d",state]};
                            allStateTime = allStateTime + stateTime;
                            [stateArr addObject:dict];
                        }
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSLog(@"时间戳：%@ , 数据个数：%d",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeString]],stateNum);
                        //数据模型
                        SleepQualityModel * model = [[SleepQualityModel alloc]init];
//                        model.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
                        model.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
                        model.dataDate = [NSString stringWithFormat:@"%d",timeString];
                        model.dataArray = stateArr;
                        NSLog(@"dataDate = %@;deviceName = %@",model.dataDate,[MSCoreManager sharedManager].userModel.deviceCode);
                        if (allStateTime >= 30) {
                            //数据库存储v数据模型
                            if ([[SleepQualityModel searchWithWhere:@{@"dataDate":model.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}] count] == 0){
                                [model saveToDB];
                                [timeStringArr addObject:model.dataDate];
                                //NSLog(@"睡眠质量-数据保存");
                                //发送睡眠质量数据更新通知 xu
                                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                                [defaults setBool:YES forKey:@"isHaveNewDataForPushToReport"];
                                [defaults synchronize];
                                
                            }else{
                                [SleepQualityModel updateToDB:model where:@{@"dataDate":model.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
                                //NSLog(@"睡眠质量-数据更新");
                            }
                        }else{
                            NSLog(@"过滤不足30分钟的<睡眠质量>数据，不进行数据库的存储更新");
                        }
                        
                    }
                NSLog(@"解析睡眠质量历史数据成功");
                    [self.SQMutableArray removeAllObjects];
                    self.isSyncSQ = YES;
//                    self.syncFinishedBlock([[NSArray alloc]initWithArray:timeStringArr], self.isSyncSQ && self.isSyncHrRr && self.isSyncTurn);
                    [self readHrBrDataNotifyWithAll:YES];//部分
//                }
                
            }
                break;
            case 0x53://呼吸心率
            {
                
                [self.HrMutableArray addObject:characteristic.value];
                
                if (characteristic.value.length == 5) {//设备无任何呼吸心率数据
                    self.isSyncHrRr = YES;
                    [self readTurnOverDataNotifyWithAll:YES];//部分
                    break;
                }
                
                if (byte[3] == 1) {//最后一条数据
                    self.bagIndex = byte[4];
                    self.getLastBag = YES;
                }
                if (self.getLastBag) {//已接受过最后一个包
                    if (self.bagIndex + 1 != self.HrMutableArray.count) {//校验当前包是否是最后一个包
                        break;
                    }else{
                        self.bagIndex = -1;//恢复默认值
                        self.getLastBag = NO;//恢复默认值
                    }
                }else{//还未接受过最后一个包
                    break;
                }
                NSLog(@"开始解析呼吸心率历史数据");
//                if (byte[3] == 1) {//最后一条数据
                    //存放时间戳的数组
                    NSMutableArray * timeStringArr = [NSMutableArray array];
                    //拼接蓝牙数据
                    NSMutableData * allData = [self addDataWithSubDataArr:self.HrMutableArray];
                    //按时间戳拆分数据
                    NSMutableArray * subDataArr = [self getSubDataArrWithAllData:allData subLength:2];
                    for (int i = 0; i<subDataArr.count; i++) {
                        
                        //单段数据（数据h格式：时间戳+数据个数+有效数据）
                        NSData * data = subDataArr[i];
                        Byte *subByte = (Byte*)[data bytes];
                        //时间戳
                        int timeString = (int)((subByte[0] & 0xff) | ((subByte[1] & 0xff)<<8) | ((subByte[2] & 0xff)<<16) | ((subByte[3] & 0xff)<<24));
                        //数据个数
                        int stateNum = (int)((subByte[4] & 0xff) | ((subByte[5] & 0xff)<<8));
                        //存放有效数据的数组
                        NSMutableArray * hrArr = [NSMutableArray array];
                        NSMutableArray * rrArr = [NSMutableArray array];
                        for (int j = 0; j<stateNum; j++) {
                            int hr = subByte[6+2*j];//心率
                            int rr = subByte[7+2*j];//呼吸率
                            NSDictionary * dictHr = @{@"value":[NSString stringWithFormat:@"%d",hr]};
                            NSDictionary * dictRr = @{@"value":[NSString stringWithFormat:@"%d",rr]};
                            [hrArr addObject:dictHr];
                            [rrArr addObject:dictRr];
                        }
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSLog(@"时间戳：%@ , 数据个数：%d ",[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeString]],stateNum);
                        //数据模型
                        HeartRateModel * heartRateModel = [[HeartRateModel alloc]init];
//                        heartRateModel.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
                        heartRateModel.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
                        heartRateModel.dataDate = [NSString stringWithFormat:@"%d",timeString];
                        heartRateModel.dataArray = hrArr;
                        RespiratoryRateModel * respiratoryRateModel = [[RespiratoryRateModel alloc]init];
//                        respiratoryRateModel.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
                        respiratoryRateModel.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
                        respiratoryRateModel.dataDate = [NSString stringWithFormat:@"%d",timeString];
                        respiratoryRateModel.dataArray = rrArr;
                        
                        if (heartRateModel.dataArray.count >= 6) {
                            //数据库存储v数据模型
                            if ([[HeartRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":heartRateModel.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}] count] == 0){
                                [heartRateModel saveToDB];
                                //NSLog(@"心率-数据保存");
                                [timeStringArr addObject:heartRateModel.dataDate];
                                //发送心率数据更新通知 xu
                            }else{
                                [HeartRateModel updateToDB:heartRateModel where:@{@"dataDate":heartRateModel.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
                                //NSLog(@"心率-数据更新");
                            }
                            if ([[RespiratoryRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":respiratoryRateModel.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}] count] == 0){
                                [respiratoryRateModel saveToDB];
                                //NSLog(@"呼吸率-数据保存");
                                [timeStringArr addObject:heartRateModel.dataDate];
                                //发送呼吸率数据更新通知 xu
                            }else{
                                [RespiratoryRateModel updateToDB:respiratoryRateModel where:@{@"dataDate":respiratoryRateModel.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
                                //NSLog(@"呼吸率-数据更新");
                            }
                        }else{
                            NSLog(@"过滤不足30分钟的<心率/呼吸率>数据，不进行数据库的存储更新");
                        }
                        
                    }
                NSLog(@"解析呼吸心率历史数据成功");
                    [self.HrMutableArray removeAllObjects];
                    self.isSyncHrRr = YES;
//                    self.syncFinishedBlock([timeStringArr valueForKeyPath:@"@distinctUnionOfObjects.self"], self.isSyncSQ && self.isSyncHrRr && self.isSyncTurn);
                    [self readTurnOverDataNotifyWithAll:YES];//部分
//                }
                
            }
            
                break;
            case 0x54://翻身
            {
                [self.TurnMutableArray addObject:characteristic.value];
                
                if (characteristic.value.length == 5) {//设备无任何翻身数据
                    self.isSyncTurn = YES;
                    self.syncFinishedBlock(@[], self.isSyncSQ && self.isSyncHrRr && self.isSyncTurn);
                    break;
                }
                
                if (byte[3] == 1) {//最后一条数据
                    self.bagIndex = byte[4];
                    self.getLastBag = YES;
                }
                if (self.getLastBag) {//已接受过最后一个包
                    if (self.bagIndex + 1 != self.TurnMutableArray.count) {//校验当前包是否是最后一个包
                        break;
                    }else{
                        self.bagIndex = -1;//恢复默认值
                        self.getLastBag = NO;//恢复默认值
                    }
                }else{//还未接受过最后一个包
                    break;
                }
                
                
                NSLog(@"开始解析翻身历史数据");
//                if (byte[3] == 1) {//最后一条数据
                    //存放时间戳的数组
                    NSMutableArray * timeStringArr = [NSMutableArray array];
                    //拼接蓝牙数据
                    NSMutableData * allData = [self addDataWithSubDataArr:self.TurnMutableArray];
                    //按时间戳拆分数据
                    NSMutableArray * subDataArr = [self getSubDataArrWithAllData:allData subLength:1];
                    for (int i = 0; i<subDataArr.count; i++) {
                        //单段数据（数据h格式：时间戳+数据个数+有效数据）
                        NSData * data = subDataArr[i];
                        Byte *subByte = (Byte*)[data bytes];
                        //时间戳
                        int timeString = (int)((subByte[0] & 0xff) | ((subByte[1] & 0xff)<<8) | ((subByte[2] & 0xff)<<16) | ((subByte[3] & 0xff)<<24));
                        //数据个数
                        int stateNum = (int)((subByte[4] & 0xff) | ((subByte[5] & 0xff)<<8));
                        
                        //存放有效数据的数组
                        NSMutableArray * stateArr = [NSMutableArray array];
                        for (int j = 0; j<stateNum; j++) {
                            //翻身次数 高四位为翻身状态 低四位为翻身次数数
//                            int turnNum = subByte[6+j] & 0x0f; //取低四位
                            int turnNum = subByte[6+j];
                            NSDictionary * dict = @{@"value":[NSString stringWithFormat:@"%d",turnNum]};
                            [stateArr addObject:dict];
                        }
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSLog(@"时间戳：%d<%@> , 数据个数：%d",timeString,[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeString]],stateNum);
                        //数据模型
                        TurnOverModel * model = [[TurnOverModel alloc]init];
//                        model.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
                        model.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
                        model.dataDate = [NSString stringWithFormat:@"%d",timeString];
                        model.dataArray = stateArr;
                        
                        if (model.dataArray.count >= 10) {
                            //数据库存储v数据模型
                            if ([[TurnOverModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":model.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}] count] == 0){
                                [model saveToDB];
                                [timeStringArr addObject:model.dataDate];
                                //NSLog(@"翻身-数据保存");
                                //发送翻身数据更新通知 xu
                            }else{
                                [TurnOverModel updateToDB:model where:@{@"dataDate":model.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}];
                                //NSLog(@"翻身-数据更新");
                            }
                        }else{
                            NSLog(@"过滤不足30分钟的<翻身>数据，不进行数据库的存储更新");
                        }
                        
                    }
                NSLog(@"解析翻身历史数据成功");
                    [self.TurnMutableArray removeAllObjects];
                    self.isSyncTurn = YES;
                    self.syncFinishedBlock([[NSArray alloc]initWithArray:timeStringArr], self.isSyncSQ && self.isSyncHrRr && self.isSyncTurn);
//                }
                
            }
                break;
                
            default:
                break;
        }
        
    }
    
    if (characteristic == self.HrRrSampleCharacteristic)
    {
        
        //闹钟智能唤醒推送
        if (byte[1] == 0x06 && byte[2] == 0x06 && byte[3] == 0x05)
        {
            if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                
                [self deviceClockForIntelligentWake];
            }
            return;
        }
        
    }
    
}

#pragma mark --蓝牙历史数据处理-拼包、拆包
//拼接蓝牙数据
- (NSMutableData *)addDataWithSubDataArr:(NSMutableArray*)subDataArr{
    
    //根据分包序号，进行插入排序
    NSMutableArray * allArr = [NSMutableArray arrayWithArray:subDataArr];
    for (NSData * subData in subDataArr) {
        Byte *subByte = (Byte*)[subData bytes];
        NSInteger index = subByte[4];
        
        if (index < subDataArr.count) {
            //替换元素
            [allArr replaceObjectAtIndex:index withObject:subData];
        }
    }
    
    NSMutableData * allData = [NSMutableData data];
    for (int i = 0; i < allArr.count; i++) {
        NSData * data = allArr[i];
        
        if (data.length>6) {
            NSData * newData = [data subdataWithRange:NSMakeRange(5, data.length-6)];
            [allData appendData:newData];
        }
    }
    
    return allData;
}
/*拆分数据
 allData        所有数据
 subLength      一组有效数据的byte长度
 <一组睡眠质量数据的有效数据为“状态时长-2byte + 状态-1byte”，则长度为3>
 <一组心率呼吸率数据的有效数据为“心率-1byte + 呼吸率-1byte”，则长度为2>
 <一组翻身数据的有效数据为“翻身次数-1byte”，则长度为1>
 */
- (NSMutableArray *)getSubDataArrWithAllData:(NSMutableData*)allData subLength:(int)subLength{
    
    NSMutableArray * subDataArr = [NSMutableArray array];
    Byte *byte = (Byte*)[allData bytes];
    int stateNum = 0;
    int j = 0;
    for (int i = 0; i<allData.length; i++) {
        if (i == j) {
            stateNum = (int)((byte[i+4] & 0xff) | ((byte[i+5] & 0xff)<<8));
            int dataLength = 6 + stateNum * subLength;
            if (i+dataLength <= allData.length) {
                NSData * data = [allData subdataWithRange:NSMakeRange(i, dataLength)];
                j = i + dataLength;
                [subDataArr addObject:data];
            }else{
                i = (int)allData.length;
            }
            
        }
    }
    return subDataArr;
}

#pragma mark --写指令to蓝牙--
-(int)byteWithInt:(nullable const void  *)bytes
{
    Byte *byte = (Byte *)bytes;
    int returnValue = 0;
    int byteCount = sizeof(byte)/2;
    for (int i=0; i<byteCount; i++) {
        if (i == 0) {
            returnValue = byte[byteCount -1];
        }else{
            returnValue += pow(256, i) * byte[byteCount-i-1];
        }
    }
    return returnValue;
}
#pragma mark --开实时心率/呼吸率开关
//打开实时心率/呼吸率开关
-(void)openRealTimeHrRrNotify
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x50;
    CRCArr[3] = 0x01;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x50;
    dataArr[3] = 0x01;
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
}

//关闭实时心率/呼吸率开关
-(void)closeRealTimeHrRrNotify
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x50;
    CRCArr[3] = 0x00;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x50;
    dataArr[3] = 0x00;
    dataArr[4] = crc_check(CRCArr, 4);
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.mainTabBar.tabBarView.hidden = NO;
    
//    if(delegate.mainTabBar.index && delegate.mainTabBar.index == 0)
//    {
        [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
//    }
}
#pragma mark -- 推送心率/呼吸率绘图开关 zp
//打开实时心率/呼吸率采样值开关 (推送心率/呼吸率采样数据 <新协议0x51>)
-(void)openRealTimeHrRrSampleNotify
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x51;
    CRCArr[3] = 0x01;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x51;
    dataArr[3] = 0x01;
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];// 将指令写入蓝牙
    
}

//关闭实时心率/呼吸率采样值开关 (推送心率/呼吸率采样数据 <新协议0x53>)
-(void)closeRealTimeHrRrSampleNotify
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x51;
    CRCArr[3] = 0x00;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x51;
    dataArr[3] = 0x00;
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
    
}
#pragma mark -- 清理睡眠历史数据(本地数据库)
-(void)deleteSleepAllDataNotify{
    
    [LKDBHelper clearTableData:[SleepQualityModel class]];
    [LKDBHelper clearTableData:[HeartRateModel class]];
    [LKDBHelper clearTableData:[RespiratoryRateModel class]];
    [LKDBHelper clearTableData:[TurnOverModel class]];
    
}
#pragma mark -- 读取睡眠历史数据
-(void)readSleepAllDataNotifyWithAll:(BOOL)isAll{
    self.isSyncSQ = NO;
    self.isSyncHrRr = NO;
    self.isSyncTurn = NO;
    
    [self.SQMutableArray removeAllObjects];
    [self.RrMutableArray removeAllObjects];
    [self.HrMutableArray removeAllObjects];
    [self.TurnMutableArray removeAllObjects];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self readSleepQuDataNotifyWithAll:isAll];//部分
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self readHrBrDataNotifyWithAll:isAll];//部分
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self readTurnOverDataNotifyWithAll:isAll];//部分
//            });
//        });
    });
    
   
}

#pragma mark -- 清理睡眠历史数据(睡眠带)
-(void)deleteSleepBandDataNotify{
    
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x04;
    CRCArr[2] = 0x55;
    CRCArr[3] = 0x01;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x04;
    dataArr[2] = 0x55;
    dataArr[3] = crc_check(CRCArr, 3);
//    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:4]];
    
}

#pragma mark --读取睡眠质量数据zp
- (void)readSleepQuDataNotifyWithAll:(BOOL)isAll
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x52;
    CRCArr[3] = 0x01;
    CRCArr[3] = isAll ? 0x01 : 0x00;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x52;
    dataArr[3] = isAll ? 0x01 : 0x00;
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
}

#pragma mark --读取呼吸心率数据
- (void)readHrBrDataNotifyWithAll:(BOOL)isAll
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x53;
    CRCArr[3] = isAll ? 0x01 : 0x00;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x53;
    dataArr[3] = isAll ? 0x01 : 0x00;
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
}

#pragma mark --读取翻身数据
- (void)readTurnOverDataNotifyWithAll:(BOOL)isAll
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x54;
    CRCArr[3] = isAll ? 0x01 : 0x00;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x54;
    dataArr[3] = isAll ? 0x01 : 0x00;
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
}

#pragma mark --翻身或HRRR历史数据
-(void)historicalData:(Byte *)byte
{
    //包序号
    int packetsNum = byte[5];
        NSLog(@"当前包:%d",packetsNum);
    //翻身或心率呼吸率历史数据
    if(byte[3] == 0x01) // 1-结束 0-未结束
    {
        [self.mutableData replaceBytesInRange:NSMakeRange(0, self.mutableData.length) withBytes:NULL length:0];
    }
    
    if(!self.turnOverOrHrRr)
    {
        if(byte[3] == 0x01)// 1-结束 0-未结束
        {
            self.turnOverModel = nil;
            self.turnOverModel = [[TurnOverModel alloc]init];
//            self.turnOverModel.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
            self.turnOverModel.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
            self.turnOverModel.dataDate = self.synchronizationDate;
        }
        
        Byte newByte[18] = {};
        for(int i = 1 ; i < 19 ; i++)
        {
            if (i == 0 || i == 19)
            {
                continue;
            }
            if (packetsNum == 27)
            {
                if (i == 13) {
                    break;
                }
            }
            newByte[i-1] = byte[i];
            //                        NSLog(@"%d",byte[i]);
            //                        NSLog(@"翻身数据：%hhu",newByte[i-1]);
        }
        if (packetsNum == 27)
        {
            [self.mutableData appendBytes:newByte length:12];
            
        }else
        {
            [self.mutableData appendBytes:newByte length:18];
        }
        
        //如果最后一个包等于总包数
        if(packetsNum == self.turnOverPackets)
        {
            //存数据库
            self.turnOverModel.data = self.mutableData;
            [self.turnOverModel saveToDB];
            //已传天数++
            self.currentSynchronizationCount++;
            if (self.synchronizationBlock) {
                self.synchronizationBlock(1);
            }
            
            //如果已传天数等于总天数
            if(self.currentSynchronizationCount == self.synchronizationCount)
            {
                //代表翻身历史已经获取完成，现在获取HRRR历史数据
                [self getHrRrHistoricalData];
            }
            
        }
        
    }
    else
    {
        if(byte[0] == 0x01)
        {
            self.heartRateModel = nil;
            self.heartRateModel = [[HeartRateModel alloc]init];
//            self.heartRateModel.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
            self.heartRateModel.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
            self.heartRateModel.dataDate = self.synchronizationDate;
            [self.HrMutableArray removeAllObjects];
            
            self.respiratoryRateModel = nil;
            self.respiratoryRateModel = [[RespiratoryRateModel alloc]init];
//            self.respiratoryRateModel.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
            self.respiratoryRateModel.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
            self.respiratoryRateModel.dataDate = self.synchronizationDate;
            [self.RrMutableArray removeAllObjects];
        }
        //        Byte hrNewByte[9] = {};
        //        Byte rrNewByte[9] = {};
        //        int num = 0 ;
        for(int i = 1 ; i < 19 ; i++)
        {
            if (i == 0 || i == 19)
            {
                continue;
            }
            
            //            NSLog(@"%d,%d",(int)byte[i],(int)byte[i+1]);
            [self.HrMutableArray addObject: [NSString stringWithFormat:@"%d",(int)byte[i]]];
            [self.RrMutableArray addObject: [NSString stringWithFormat:@"%d",(int)byte[i+1]]];
            i++;
            //            num++;
        }
        
        if(packetsNum == self.HrRrPackets)
        {
            //存数据库
            self.heartRateModel.dataArray = self.HrMutableArray;
            [self.heartRateModel saveToDB];
            self.respiratoryRateModel.dataArray = self.RrMutableArray;
            [self.respiratoryRateModel saveToDB];
            
            //已传天数++
            self.currentSynchronizationCount++;
            if (self.synchronizationBlock) {
                self.synchronizationBlock(1);
            }
        }
        
    }
    
}

//-(void)updateDataForType:(int)type{
//    [self.coreManager postDataFromParams:@{} WithResponse:^(ResponseInfo *info) {
//
//    }];
//}

//心率呼吸率总包数 5分钟一个格子
-(void)HrRrTotalPackets:(Byte *)byte
{
    self.HrRrPackets = byte[4];
        NSLog(@"心率呼吸率总包数:%ld",(long)self.HrRrPackets);
    if(self.HrRrPackets == 0)
    {
        HeartRateModel *heartRateModel = [[HeartRateModel alloc]init];
        RespiratoryRateModel *respiratoryRateModel = [[RespiratoryRateModel alloc]init];
        
//        heartRateModel.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
//        respiratoryRateModel.uesrId = [NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId];
        
        heartRateModel.dataDate = self.synchronizationDate;
        respiratoryRateModel.dataDate = self.synchronizationDate;
        
        heartRateModel.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
        respiratoryRateModel.deviceName = [MSCoreManager sharedManager].userModel.deviceCode;
        
        [self.HrMutableArray removeAllObjects];
        [self.RrMutableArray removeAllObjects];
        //保存数据库
        //        uint8_t *newByte = malloc(sizeof(*newByte) *288);
        //        Byte newByte[288] = {};
        
        for(int i = 0 ; i < 288 ; i ++)
        {
            //            newByte[i] = 0x00;
            [self.HrMutableArray addObject:@"0"];
            [self.RrMutableArray addObject:@"0"];
        }
        //        NSLog(@"心率呼吸率空数据：%s",newByte);
        //        [self.mutableData appendBytes:newByte length:288];
        heartRateModel.dataArray = self.HrMutableArray;
        respiratoryRateModel.dataArray = self.RrMutableArray;
        if ([[HeartRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":heartRateModel.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}] count] == 0)
        {
            [heartRateModel saveToDB];
        }
        
        if ([[RespiratoryRateModel searchWithWhere:@{/*@"uesrId":[NSString stringWithFormat:@"%d",[MSCoreManager sharedManager].userModel.userId],*/@"dataDate":respiratoryRateModel.dataDate,@"deviceName":[MSCoreManager sharedManager].userModel.deviceCode}] count] == 0)
        {
            [respiratoryRateModel saveToDB];
        }
        
        //已传天数++
        self.currentSynchronizationCount++;
        if (self.synchronizationBlock) {
            self.synchronizationBlock(1);
        }
    }
}

//心率,呼吸率历史数据分布
-(void)heartRateOrRespiratoryRateHistoryDistribution:(Byte *)byte
{
    NSLog(@"心率,呼吸率历史数据分布");
#if 0
//    Byte numByte[] = {0x01,0x02,0x04,0x08,0x10,0x20,0x40};
//    if (numByte)
//    {
//
//    }
    NSLog(@"心率,呼吸率历史数据:%d,%d,%d",byte[4],byte[5],byte[6]);
   
    //Byte 转化 16进制字符串
    NSLog(@"16进制字符串=: %@",[self hexStringFromString:byte]);
    //16进制字符串=: 01001a15101202000000f00f00f0b8b7
    
    //16进制字符串 转化 NSData
    NSString *str = [self hexStringFromString:byte];
    NSLog(@"nsdata str= %@", [self convertHexStrToData:str]);
    //nsdata str=<01001a15 10120200 0000f00f 00f0b8b7>
    
    NSData *data = [self convertHexStrToData:str];
    
    // 从第0位开始，截取2个字节，所以location是0，offset是2
    UInt16 result = [self unsignedDataTointWithData:data Location:0 Offset:2];
    NSLog(@"result=%d",result);
    
    // 0x000f == 0000 0000 0000 1111
    // 按位与上result之后，得到的number == 0000 0000 0000 0110 就是低4位的数据0110
    int number99 = result & 0x000f;
    NSLog(@"number99=%d",number99);
#endif
    
    [self logotodata51:byte];
}

//to
- (void)logotodata51:(Byte *) byte
{
    
    
}


//呼吸率心率采样数据zp
- (void)updateValueForHr:(Byte *) byte
{
//    NSString *s34 = [NSString stringWithFormat:@"%hhu%hhu",byte[3],byte[4]];
//    NSString *s56 = [NSString stringWithFormat:@"%hhu%hhu",byte[5],byte[6]];
//    NSString *s78 = [NSString stringWithFormat:@"%hhu%hhu",byte[7],byte[8]];
//    NSString *s910 = [NSString stringWithFormat:@"%hhu%hhu",byte[9],byte[10]];
////    NSString *s1112 = [NSString stringWithFormat:@"%hhu%hhu",byte[11],byte[12]];
////    NSString *s1314 = [NSString stringWithFormat:@"%hhu%hhu",byte[13],byte[14]];
////    NSString *s1516 = [NSString stringWithFormat:@"%hhu%hhu",byte[15],byte[16]];
////    NSString *s1719 = [NSString stringWithFormat:@"%hhu%hhu",byte[17],byte[18]];
//
//    NSLog(@"心率滤呼吸滤:%@-%@-%@-%@",s34,s56,s78,s910);
//
//    Byte numByte[] ={0x03,0x04,0x5,0x6,0x07,0x08};
//    uint32_t num;
//    memcpy((uint8_t *)&num, numByte, 2);
//    printf("egeg:%d", num);
    
    NSLog(@"心率滤呼吸滤: %@",[self hexStringFromString:byte]);
    //0004ff030004ff030004fe03ff03fd03
    
    NSString *str = [self hexStringFromString:byte];
    NSLog(@"nsdata str=%@", [self convertHexStrToData:str]);
    
}


//Byte转换为十六进制字符串
//- (NSString *)hexStringFromString:(NSString *)string
- (NSString *)hexStringFromString:(Byte *) byte
{
    //NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)byte;
    //下面是Byte转换为16进制。
    NSString *hexStr = @"";
    for(int i = 3; i < 19; i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i] & 0xff];///16进制数
        if([newHexStr length] ==1 )
        {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            
        }else
        {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
    
}


//将16进制的字符串转换成NSData
- (NSMutableData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0)
    {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        
        range = NSMakeRange(0,2);
        
    } else
    {
        range = NSMakeRange(0,1);
    }
    
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
        
    }
    return hexData;
}


//心率呼吸率实时数值
-(void)UpdateValueForHrRrCharacteristic:(CBCharacteristic *)characteristic
{
    Byte *byte = (Byte*)[characteristic.value bytes];
    self.HrRrBlock([NSString stringWithFormat:@"%hhu",byte[3]], [NSString stringWithFormat:@"%hhu",byte[4]]);
    
    //zp
    NSString *strxx = [NSString stringWithFormat:@"%hhu",byte[3]];
    NSString *stryy = [NSString stringWithFormat:@"%hhu",byte[4]];
    NSLog(@"心率实时数值=%@,呼吸率实时数值=%@",strxx,stryy);
    
}

#pragma mark --心率呼吸率采样值
//心率呼吸率采样值
-(void)UpdateValueForHrRrSampleCharacteristic:(CBCharacteristic *)characteristic
{
    NSMutableArray *hrSampleArray = [[NSMutableArray alloc]init];
    NSMutableArray *rrSampleArray = [[NSMutableArray alloc]init];
    Byte *byte = (Byte*)[characteristic.value bytes];
    
    for (int i = 3; i < 19; i++)
    {
        unsigned short buf[1];
//        NSLog(@"心率滤波值:%d,i=%d",buf[0],i);
        memcpy((unsigned char *)&buf[0], (unsigned char *)&byte[i], 2);
        [hrSampleArray addObject:[NSString stringWithFormat:@"%d",buf[0]]];
        
        if (i+4 < 19)
        {
            i = i+3;
            
        }else
        {
            break;
        }
    }
//    NSLog(@"心率000 hrSampleArray=%@",hrSampleArray);
    
    
    for (int i = 5; i < 19; i++)
    {
        unsigned short rrBuf[1];
        memcpy((unsigned char *)&rrBuf[0], (unsigned char *)&byte[i], 2);
//                NSLog(@"呼吸率滤波值:%d",rrBuf[0]);
        [rrSampleArray addObject:[NSString stringWithFormat:@"%d",rrBuf[0]]];
        if (i+4 < 19)
        {
            i = i+3;
            
        }else
        {
            break;
        }
        
    }
//    NSLog(@"呼吸率000 hrSampleArray=%@",hrSampleArray);
    
    //获取心率和呼吸率值
    self.HrRrSampleBlock(hrSampleArray, rrSampleArray);
    [hrSampleArray removeAllObjects];
    hrSampleArray = nil;
    [rrSampleArray removeAllObjects];
    rrSampleArray = nil;
    
}

//读取心率呼吸率历史数据
-(void)getHrRrHistoricalData
{
    self.turnOverOrHrRr = YES;
    self.currentSynchronizationCount = 0;
    Byte numByte[1];
    switch (self.numByte) {
        case 1:
            numByte[0] = 0x01;
            break;
        case 2:
            numByte[0] = 0x03;
            break;
        case 3:
            numByte[0] = 0x07;
            break;
        case 4:
            numByte[0] = 0x0F;
            break;
        case 5:
            numByte[0] = 0x1F;
            break;
        case 6:
            numByte[0] = 0x3F;
            break;
        default:
            numByte[0] = 0x7F;
            break;
    }
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x52;
    CRCArr[3] = numByte[0];
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x52;
    dataArr[3] = numByte[0];
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
    
}

//读取翻身历史数据
-(void)getTurnOverHistoricalData:(int)num
{
    self.numByte  = num;
    self.turnOverOrHrRr = NO;
    self.synchronizationCount = num;
    self.currentSynchronizationCount = 0;
    Byte numByte[1];
    switch (num) {
        case 1:
            numByte[0] = 0x01;
            break;
        case 2:
            numByte[0] = 0x03;
            break;
        case 3:
            numByte[0] = 0x07;
            break;
        case 4:
            numByte[0] = 0x0F;
            break;
        case 5:
            numByte[0] = 0x1F;
            break;
        case 6:
            numByte[0] = 0x3F;
            break;
        default:
            numByte[0] = 0x7F;
            break;
    }
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x56;
    CRCArr[3] = numByte[0];
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x56;
    dataArr[3] = numByte[0];
    dataArr[4] = crc_check(CRCArr, 4);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
    
}

#pragma mark --报告
//回复睡眠质量数据
- (void)reportSleepQualitydata:(Byte *)byte
{
    NSLog(@"byte=%hhu",byte);
    NSMutableArray *sreportSleepArray = [[NSMutableArray alloc]init];
    uint8_t pn;
    uint16_t statusNum;
    uint16_t timelong;
    uint8_t status;
    uint32_t tick;
    
    pn = byte[4];//包序号
    [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",pn]];
    
    memcpy((uint8_t *)&tick, (uint8_t *)&byte[5], 4);//时间戳
    [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",tick]];
   
    memcpy((uint8_t *)&statusNum, (uint8_t *)&byte[9], 2);//状态个数
    [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",statusNum]];
    
    memcpy((uint8_t *)&timelong, (uint8_t *)&byte[11], 2);//状态时间长度
    [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",timelong]];
    
    status = byte[13];//状态
    [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",status]];
    
    NSLog(@"回复睡眠质量数据sreportSleepArray=%@",sreportSleepArray);
    
//    self.reportSampleBlock(sreportSleepArray);//发data
//    [sreportSleepArray removeAllObjects];
//    sreportSleepArray = nil;
    
    
#if 0
    NSMutableArray *sreportSleepArray = [[NSMutableArray alloc]init];
    for (int i = 4; i < 19; i++)
    {
        unsigned short buf[1];
        unsigned short buf2[3];
        
        if (i == 4 )//1位 （包序号）
        {
            [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",byte[4]]];
        }
        if ( i > 4 && i < 9)//4位 （时间）
        {
            memcpy((unsigned char *)&buf2[0], (unsigned char *)&byte[i], 4);
            [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",buf2[0]]];
        }
        if (  i > 8 && i < 11 )//2位 (状态个数)
        {
            memcpy((unsigned char *)&buf[0], (unsigned char *)&byte[i], 2);
            [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",buf[0]]];
        }
        if ( i > 11 && i < 13)// 2位 (状态时间长度)
        {
            memcpy((unsigned char *) &buf, (unsigned char *)&byte[i], 2);
            [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",buf[0]]];
        }
        if (i == 13) //1位 (状态)
        {
            [sreportSleepArray addObject:[NSString stringWithFormat:@"%d",byte[13]]];
        }
        
    }
    
    self.reportSampleBlock(sreportSleepArray);//发data
    [sreportSleepArray removeAllObjects];
    sreportSleepArray = nil;
    
#endif
    
}

//回复读取呼吸心率数据
- (void)readBrHrData:(Byte *)byte
{

    NSMutableArray *hrReArray = [[NSMutableArray alloc]init];
    NSMutableArray *brReArray = [[NSMutableArray alloc]init];
    uint8_t pn;
    uint16_t dnum;
    //uint16_t hr_data[64];
    uint32_t tick;

    pn = byte[4];//包序号
    
    memcpy((uint8_t *)&tick, (uint8_t *)&byte[5], 4);//时间戳
    
    memcpy((uint8_t *)&dnum, (uint8_t *)&byte[9], 2);//数据个数
    
    for (int i = 0; i < dnum; i++)//心率
    {
        uint8_t byte_cnt = 0;
        unsigned short hr;
        memcpy((unsigned char *)&hr, (unsigned char *)&byte[i*byte_cnt], 2);
        byte_cnt += 4;
        [hrReArray addObject:[NSString stringWithFormat:@"%d",hr]];
    }
    NSLog(@"回复读取呼吸心率数据 心率hrReArray=%@",hrReArray);
    
    
    for (int i = 0;  i < dnum; i++)//呼吸率
    {
        uint8_t byte_cnt = 2;
        unsigned short buf[1];
        memcpy((unsigned char *)&buf[0], (unsigned char *)&byte[i*byte_cnt], 2);
        byte_cnt+=4;
        [brReArray addObject:[NSString stringWithFormat:@"%d",buf[0]]];
    }
    NSLog(@"回复读取呼吸心率数据 呼吸率hrReArray=%@",brReArray);
    
    //NSLog(@"%hhu,%d,%d,%@",pn,tick,dnum,hrReArray,brReArray);
    
    //self.BrhrBlock(hrReArray,brReArray);//发data
   
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:hrReArray,@"hrReArray", brReArray,@"brReArray", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"egeg" object:dic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"egeg" object:hrReArray];
    [hrReArray removeAllObjects];
    [brReArray removeAllObjects];
    hrReArray = nil;
    brReArray = nil;
    
    
#if 0
    eg
    for(int i = 0; i < dnum; i+=2)//copy
    {
        memcpy((uint8_t *)&hr_data[i], (uint8_t *)&byte[11+i], 2);
        //memcpy((uint8_t *)&br_data[i+1], (uint8_t *)&byte[11+i+2], 2);
    }
    
    for(int i = 0; i < dnum; i++)
    {
        NSLog(@"hr_data[%d]=%d", i, hr_data[i]);
        [hrReArray addObject:[NSString stringWithFormat:@"%d",hr_data[i]]];
        //[brReArray addObject:[NSString stringWithFormat:@"%d",br_data[i]]];
    }

    memcpy((unsigned char *)&buff[0], (unsigned char *)&byte[11], 2);
    [BHeportSleepArray addObject:[NSString stringWithFormat:@"%d",buff[0]]];
   
    memcpy((unsigned char *)&buff[0], (unsigned char *)&byte[13], 2);
    [BHeportSleepArray addObject:[NSString stringWithFormat:@"%d",byte[0]]];
    
#endif
    

#if 0
    uint8_t pn;
    uint32_t tick;
    uint16_t dnum;
    uint16_t hr_data[64];
    uint16_t br_data[64];
    
    //    unsigned int  pn;
    //    unsigned int  tick;
    //    int  dnum;
    //    int  hr_data[64];
    //    int  br_data[64];
    
    memcpy((uint8_t *)&pn, (uint8_t *)&byte[4], 1);
    memcpy((uint8_t *)&tick, (uint8_t *)&byte[5], 4);
    memcpy((uint8_t *)&dnum, (uint8_t *)&byte[9], 2);
    
    for(int i = 0; i < dnum; i+=2)
    {
        memcpy((uint8_t *)&hr_data[i], (uint8_t *)&byte[11+i], 2);
        memcpy((uint8_t *)&br_data[i+1], (uint8_t *)&byte[11+i+2], 2);
        // dnum=5, hr_data=1860740152,br_data=1860740024
        //6ee8a438        //6ee8a3b8
    }
    
    for(uint8_t i = 0; i < 5; i++)
        //for(int i = 0 ; i < 5 ; i++)
    {
        NSLog(@"hr_data[%d]=%d, br_data[%d]=%d,", i, hr_data[i], i, br_data[i]);
        [hrReArray addObject:[NSString stringWithFormat:@"%d",hr_data[i]]];
        [brReArray addObject:[NSString stringWithFormat:@"%d",br_data[i]]];
    }
    self.BrhrBlock(hrReArray,brReArray);//发data
    [BHeportSleepArray removeAllObjects];
    BHeportSleepArray = nil;
#endif

}

#pragma mark --闹钟
// 单个字节 转 周数组
- (NSMutableArray *)byteToWeekArrWithByte:(int8_t)byte{
    
    NSMutableArray *repeatArray = [[NSMutableArray alloc]init];
    int8_t temp = 0x01;
    for (int i = 0; i < 7; i++) {
        if ((byte & temp)<<(7-i) == 128) {
            [repeatArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        temp <<= 1;
    }
    return repeatArray;
}
// 周数组 转 单个字节
- (uint8_t)weekArrToByteWithWeekArr:(NSArray*)arr{
    
    uint8_t week = 0x00;
    if (arr && arr.count > 0) {
        for (int i = 0; i<arr.count; i++) {
            week |= (0x01 << [arr[i] intValue]);
        }
    }
    return week;
    
}

//智能闹钟本地推送
-(void)deviceClockForIntelligentWake
{
    NSLog(@"智能闹钟本地推送");
    // 使用 UNUserNotificationCenter 来管理通知
        if (@available(iOS 10.0, *))
        {
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
            UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
            content.title = [NSString localizedUserNotificationStringForKey:NSLocalizedString(@"ACMVC_IntelligentClock", nil) arguments:nil];
            content.body = [NSString localizedUserNotificationStringForKey:NSLocalizedString(@"ACMVC_GetUpClock", nil)
                                                                 arguments:nil];
            content.sound = [UNNotificationSound defaultSound];
            UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                          triggerWithTimeInterval:1 repeats:NO];
            
            UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"IntelligentClock"
                                                                                  content:content trigger:trigger];
            [center setNotificationCategories:[NSSet setWithObject:request]];
            
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
                NSLog(@"本地推送 :( 报错 %@",error);
                
            }];
            
    }else
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        notification.fireDate = fireDate;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = kCFCalendarUnitSecond;
        notification.alertBody =  NSLocalizedString(@"ACMVC_GetUpClock", nil);
        notification.soundName = UILocalNotificationDefaultSoundName;
        // ios8后，需要添加这个注册，才能得到授权
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            // 通知重复提示的单位，可以是天、周、月
            notification.repeatInterval = 0;
            
        } else
        {
            // 通知重复提示的单位，可以是天、周、月
            notification.repeatInterval = 0;
        }
        // 执行通知注册
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
}

//闹钟分包数
-(void)getDeviceClockForResponseSubpackage:(NSData *)data
{
    if (data.length<10) {
        self.clockBlock(@[]);
        NSLog(@"设备没有闹钟");
        return;
    }
    int clockNum = (int)data.length / 10;;
    Byte *byte = (Byte*)[data bytes];
    for (int i = 0; i<clockNum; i++) {
        int index = i*10;
        AlarmClockModel *model = [[AlarmClockModel alloc]init];
        model.index = byte[0 + index];
        model.isPhone = byte[1 + index] ? NO:YES;
        model.isOn = byte[2 + index];
        model.repeat = [self byteToWeekArrWithByte:byte[5 + index]];
        model.hour = byte[6 + index];
        model.minute = byte[7 + index];
        model.isIntelligentWake = byte[8 + index];
        model.type = byte[9 + index];
        [self.clockMutableArray addObject:model];
    }
    
    self.clockBlock(self.clockMutableArray);

}

#pragma mark -- 闹钟（查）
//获取闹钟
-(void)getDeviceClock
{
    [self.clockMutableArray removeAllObjects];
    Byte CRCArr[5];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x06;
    CRCArr[2] = 0x06;
    CRCArr[3] = 0x04;
    CRCArr[4] = 0xFF;
    
    Byte dataArr[6];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x06;
    dataArr[2] = 0x06;
    dataArr[3] = 0x04;
    dataArr[4] = 0xFF;
    dataArr[5] = crc_check(CRCArr, 5);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:6]];
}
#pragma mark -- 闹钟（增）
//新增闹钟
-(void)addClock:(AlarmClockModel *)model
{
    NSLog(@"设备新增闹钟");
    Byte CRCArr[14];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x0F;
    CRCArr[2] = 0x06;
    CRCArr[3] = 0x01;
    CRCArr[4] = 0xFF;
    CRCArr[5] = model.isPhone ? 0x00:0x01;
    CRCArr[6] = model.isOn ? 0x01:0x00;
    CRCArr[7] = 0x00;
    CRCArr[8] = 0x00;
    CRCArr[9] = [self weekArrToByteWithWeekArr:model.repeat];
    CRCArr[10] = (Byte)model.hour & 0xFF;
    CRCArr[11] = (Byte)model.minute & 0xFF;
    CRCArr[12] = model.isIntelligentWake;
    CRCArr[13] = model.type;
    
    Byte dataArr[15];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x0F;
    dataArr[2] = 0x06;
    dataArr[3] = 0x01;
    dataArr[4] = 0xFF;
    dataArr[5] = model.isPhone ? 0x00:0x01;
    dataArr[6] = model.isOn ? 0x01:0x00;
    dataArr[7] = 0x00;
    dataArr[8] = 0x00;
    dataArr[9] = [self weekArrToByteWithWeekArr:model.repeat];
    dataArr[10] = (Byte)model.hour & 0xFF;
    dataArr[11] = (Byte)model.minute & 0xFF;
    dataArr[12] = model.isIntelligentWake;
    dataArr[13] = model.type;
    dataArr[14] = crc_check(CRCArr, 14);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:15]];
    
}
#pragma mark -- 闹钟（删）
//删除闹钟
-(void)deleteClock:(AlarmClockModel *)model
{
    Byte CRCArr[14];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x0F;
    CRCArr[2] = 0x06;
    CRCArr[3] = 0x02;
    CRCArr[4] = model.index;
    CRCArr[5] = model.isPhone ? 0x00:0x01;
    CRCArr[6] = model.isOn;
    CRCArr[7] = 0x00;
    CRCArr[8] = 0x00;
    CRCArr[9] = [self weekArrToByteWithWeekArr:model.repeat];
    CRCArr[10] = (Byte)model.hour & 0xFF;
    CRCArr[11] = (Byte)model.minute & 0xFF;
    CRCArr[12] = model.isIntelligentWake;
    CRCArr[13] = model.type;
    
    Byte dataArr[15];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x0F;
    dataArr[2] = 0x06;
    dataArr[3] = 0x02;
    dataArr[4] = model.index;
    dataArr[5] =  model.isPhone ? 0x00:0x01;
    dataArr[6] = model.isOn;
    dataArr[7] = 0x00;
    dataArr[8] = 0x00;
    dataArr[9] = [self weekArrToByteWithWeekArr:model.repeat];
    dataArr[10] = (Byte)model.hour & 0xFF;
    dataArr[11] = (Byte)model.minute & 0xFF;
    dataArr[12] = model.isIntelligentWake;
    dataArr[13] = model.type;
    dataArr[14] = crc_check(CRCArr, 14);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:15]];
}
#pragma mark -- 闹钟（改）
//编辑闹钟
-(void)editClock:(AlarmClockModel *)model
{
    Byte CRCArr[14];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x0F;
    CRCArr[2] = 0x06;
    CRCArr[3] = 0x03;
    CRCArr[4] = model.index;
    CRCArr[5] = model.isPhone ? 0x00:0x01;
    CRCArr[6] = model.isOn;
    CRCArr[7] = 0x00;
    CRCArr[8] = 0x00;
    CRCArr[9] = [self weekArrToByteWithWeekArr:model.repeat];
    CRCArr[10] = (Byte)model.hour & 0xFF;
    CRCArr[11] = (Byte)model.minute & 0xFF;
    CRCArr[12] = model.isIntelligentWake;
    CRCArr[13] = model.type;
    
    Byte dataArr[15];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x0F;
    dataArr[2] = 0x06;
    dataArr[3] = 0x03;
    dataArr[4] = model.index;
    dataArr[5] = model.isPhone ? 0x00:0x01;
    dataArr[6] = model.isOn;
    dataArr[7] = 0x00;
    dataArr[8] = 0x00;
    dataArr[9] = [self weekArrToByteWithWeekArr:model.repeat];
    dataArr[10] = (Byte)model.hour & 0xFF;
    dataArr[11] = (Byte)model.minute & 0xFF;
    dataArr[12] = model.isIntelligentWake;
    dataArr[13] = model.type;
    dataArr[14] = crc_check(CRCArr, 14);
    NSLog(@"选中的日期 = %@",model.repeat);
    NSLog(@"发送修改闹钟命令 = %@",[NSData dataWithBytes:dataArr length:15]);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:15]];
    
}

//读取设备版本
-(void)getDeviceVersions
{
    Byte CRCArr[3];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x04;
    CRCArr[2] = 0x00;
    
    Byte dataArr[4];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x04;
    dataArr[2] = 0x00;
    dataArr[3] = crc_check(CRCArr, 3);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:4]];
    
}

//读取设备版本响应
-(void)getDeviceVersions:(Byte *)byte
{
    NSString * hardwareVersion = [NSString stringWithFormat:@"%d.%d",byte[11],byte[12]];
    
    NSString * softwareVersion = [NSString stringWithFormat:@"%d.%d",byte[13],byte[14]];
    NSLog(@"zp睡眠带硬件版本:%@,软件版本:%@",hardwareVersion,softwareVersion);
    
    self.versionBlock(hardwareVersion, softwareVersion);
    
    [self getDeviceBatterys];
    
}

//设备固件升级-（唤醒DFU模式）
-(void)upDataDeviceVersions{
    
    Byte dataArr[1];
    dataArr[0] = 0x01;
    [self.currentPeripheral writeValue:[NSData dataWithBytes:dataArr length:1] forCharacteristic:self.DFUCharacteristic type:CBCharacteristicWriteWithResponse];
    //发送DFU唤醒指令后会断开连接，所以这里需要手动开启扫描
    [self scanAllPeripheral];
}

//读取设备电量
-(void)getDeviceBatterys
{
    Byte CRCArr[3];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x04;
    CRCArr[2] = 0x02;
    
    Byte dataArr[4];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x04;
    dataArr[2] = 0x02;
    dataArr[3] = crc_check(CRCArr, 3);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:4]];
    
}

//读取设备电量响应
-(void)getDeviceBatterys:(Byte *)byte
{
    int batterys = byte[3];
    NSLog(@"读取设备电量:%d",batterys);
    int batState = byte[4];
    
    NSLog(@"读取设备充电状态:%d(0-未充电,1-充电中)",batState);
    if (self.batteryBlock) {
        self.batteryBlock(batterys,batState == 1);
    }
    
}

//读设备时间
-(void)readDeviceTime
{
    Byte CRCArr[4];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x05;
    CRCArr[2] = 0x03;
    CRCArr[3] = 0x00;
    
    Byte dataArr[5];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x05;
    dataArr[2] = 0x03;
    dataArr[3] = 0x00;
    dataArr[4] = crc_check(CRCArr, 4);
//    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:5]];
    
}

//设置设备时间
-(void)setDeviceTime{
    //设置本地时区
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSInteger seconds = [timeZone secondsFromGMT];
    NSInteger hour = floorf(seconds/3600);//取整
    NSInteger minute = floorf(seconds % 3600/60);//取整

    // 当前时间
    NSDate* date = [NSDate date];
    NSLog(@"date = %@",date);
    NSTimeInterval a =[date timeIntervalSince1970]; // *1000 是精确到毫秒，不乘就是精确到秒
    NSInteger time = (NSInteger)a;
    
//    uint32_t time1;
//    Byte buf[20];
//    memcpy((uint8_t *)&time1, (uint8_t *)&buf[6], 4);
    
    Byte CRCArr[10];
    CRCArr[0] = 0xAB;
    CRCArr[1] = 0x0B;
    CRCArr[2] = 0x03;
    CRCArr[3] = 0x01;
    CRCArr[4] = (Byte)((time & 0xff) & 0xff);
    CRCArr[5] = (Byte)((time >> 8) & 0xff);
    CRCArr[6] = (Byte)((time >> 16) & 0xff);
    CRCArr[7] = (Byte)(time >> 24);
    CRCArr[8]  = hour;
    CRCArr[9]  = minute;
    
    Byte dataArr[11];
    dataArr[0] = 0xAB;
    dataArr[1] = 0x0B;
    dataArr[2] = 0x03;
    dataArr[3] = 0x01;
    dataArr[4] = (Byte)((time & 0xff) & 0xff);
    dataArr[5] = (Byte)((time >> 8) & 0xff);
    dataArr[6] = (Byte)((time >> 16) & 0xff);
    dataArr[7] = (Byte)(time >> 24);
    dataArr[8]  = hour;
    dataArr[9]  = minute;
    dataArr[10] = crc_check(CRCArr, 10);
    [self sendCommandWithData:[NSData dataWithBytes:dataArr length:11]];
}

//CRC校验函数
uint8_t crc_check(const uint8_t *fp_CRC, uint8_t len)
{
    uint8_t CRC_8=0;
    uint8_t CRC_count,i;
    uint8_t cmd_buf[len];
    memcpy(cmd_buf,fp_CRC,len);
    for(CRC_count=0;CRC_count < len;CRC_count++){
        for(i=0;i<8;i++){
            if(((CRC_8 ^ cmd_buf[CRC_count])&0x01)){
                CRC_8 ^= 0x18;
                CRC_8 >>= 1;
                CRC_8 |= 0x80;
            }
            else{
                CRC_8 >>= 1;
            }
            cmd_buf[CRC_count] >>= 1;
        }
    }
    return CRC_8;
}


#pragma mark --小端大端模式
//大小eg
//short int number = 0x8866;
//NSLog(@"%@",[NSString stringWithFormat:@"%x",((char *)&number)[0]].intValue == 66 ? @"小端模式" : @"大端模式");


// 转为本地大小端模式 返回Signed类型的数据
- (signed int)signedDataTointWithData:(NSData *)data Location:(NSInteger)location Offset:(NSInteger)offset
{
    signed int value=0;
    NSData *intdata= [data subdataWithRange:NSMakeRange(location, offset)];
    if (offset==2)
    {
        value = CFSwapInt16BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==4)
    {
        value = CFSwapInt32BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==1)
    {
        signed char *bs = (signed char *)[[data subdataWithRange:NSMakeRange(location, 1) ] bytes];
        value = *bs;
    }
    return value;
}

// 转为本地大小端模式 返回Unsigned类型的数据
- (unsigned int)unsignedDataTointWithData:(NSData *)data Location:(NSInteger)location Offset:(NSInteger)offset
{
    unsigned int value=0;
    NSData *intdata= [data subdataWithRange:NSMakeRange(location, offset)];
    
    if (offset==2)
    {
        value=CFSwapInt16BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==4)
    {
        value = CFSwapInt32BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==1)
    {
        unsigned char *bs = (unsigned char *)[[data subdataWithRange:NSMakeRange(location, 1) ] bytes];
        value = *bs;
    }
    return value;
}

/**
 十六进制转换为二进制
 
 @param hex 十六进制数
 @return 二进制数
 */
-(NSString *)getBinaryByHex:(NSString *)hex
{
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}

/**
 十进制转换为二进制
 
 @param decimal 十进制数
 @return 二进制数
 */
-(NSString *)getBinaryByDecimal:(NSInteger)decimal
{
    
    NSString *binary = @"";
    while (decimal) {
        
        binary = [[NSString stringWithFormat:@"%ld", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}

//获取当前视图的活动页面
- (UIViewController *)getCurrentViewController {
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self GetNextVC:root];
    
    return currentVC;
}

//使用的递归方法
- (UIViewController *)GetNextVC:(UIViewController *)rootVC{
    
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    
    //    UITabBarController
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self GetNextVC:[(UITabBarController *)rootVC selectedViewController]];
    }
    //    UINavigationController
    else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self GetNextVC:[(UINavigationController *)rootVC visibleViewController]];
    }
    //    普通的ViewController
    else {
        currentVC = rootVC;
    }
    return currentVC;
    
}


@end
