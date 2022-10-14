//
//  BlueToothManager.h
//  QLife
//
//  Created by admin on 2018/4/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmClockModel.h"
#import "PeripheralModel.h"
#import "MSCoreManager.h"

typedef void(^ManualCancelConnectBlock)(void);
typedef void(^ScanPeripheralBlock)(PeripheralModel* model);
typedef void(^ConnectPeripheralBlock)(BOOL isSuccess);
typedef void(^HrRrBlock)(NSString *HR,NSString *RR);
typedef void(^HrRrSampleBlock)(NSArray *HRSample,NSArray *RRSample);
typedef void(^synchronizationBlock)(int successCount);
typedef void(^syncFinishedBlock)(NSArray * timeStringArr, BOOL isFinished);
typedef void(^ClockOperationBlock)(int operation,int index,int isSuccess);
typedef void(^ClockBlock)(NSArray *clockArray);
typedef void(^VersionBlock)(NSString * hardwareVersion,NSString * softwareVersion);
typedef void(^BatteryBlock)(int battery, BOOL isCharge);
//
//eg report
typedef void(^reportSampleBlock)(NSArray *reportSample);
typedef void(^BrHrBlock)(NSArray *Hrreport, NSArray *Brreport);


@interface BlueToothManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong)MSCoreManager *coreManager;
@property (nonatomic,strong)CBCentralManager *centralManager;
@property (nonatomic,strong)CBPeripheral *currentPeripheral;
@property (nonatomic,assign)NSInteger centralManagerState;
@property (nonatomic,assign)BOOL isConnect;
@property (nonatomic,assign)BOOL isScan;
@property (nonatomic,strong)NSString *deviceName;
@property (nonatomic,copy)ScanPeripheralBlock scanPeripheralBlock;
@property (nonatomic,copy)ConnectPeripheralBlock connectPeripheralBlock;
@property (nonatomic,copy)ManualCancelConnectBlock manualCancelConnectBlock;
@property (nonatomic,copy)HrRrBlock HrRrBlock;  //心率/呼吸率推送
@property (nonatomic,copy)synchronizationBlock synchronizationBlock;  //同步结果
@property (nonatomic,copy)syncFinishedBlock syncFinishedBlock; //同步设备睡眠数据回调
@property (nonatomic,assign)BOOL isSyncSQ;
@property (nonatomic,assign)BOOL isSyncHrRr;
@property (nonatomic,assign)BOOL isSyncTurn;

@property (nonatomic,copy)HrRrSampleBlock HrRrSampleBlock;  //心率/呼吸率采样值推送
@property (nonatomic,strong)NSMutableArray *scanPeripheralArray;
@property (nonatomic,strong) CBCharacteristic *writeCharacteristic;//发送特征
@property (nonatomic,strong) CBCharacteristic *responseCharacteristic;//回复特征
@property (nonatomic,strong) CBCharacteristic *HrRrCharacteristic; //心率-呼吸值特征(实时数据通道)
@property (nonatomic,strong) CBCharacteristic *HrRrSampleCharacteristic;//心率-呼吸率采样值特征(历史数据通道)
@property (nonatomic,strong) CBCharacteristic *DFUCharacteristic;//DFU升级
@property (nonatomic,assign)BOOL isDUFModel; //升级模式
@property (nonatomic,assign)BOOL isManualCancelConnect; //手动取消连接
@property (nonatomic,assign)BOOL turnOverOrHrRr; //当前接收的是翻身还是HrRr
@property (nonatomic,assign)NSInteger turnOverPackets; //翻身总包数
@property (nonatomic,assign)NSInteger HrRrPackets; //心率呼吸率总包数
//@property (nonatomic,strong) NSMutableArray *dataArray;//收到的数据数组
@property (nonatomic,assign)NSInteger bagIndex; //包序号
@property (nonatomic,assign)BOOL getLastBag;
@property (nonatomic,strong) NSMutableData *mutableData;//收到的数据
@property (nonatomic,strong) NSMutableArray *SQMutableArray;//睡眠质量收到的数据
@property (nonatomic,strong) NSMutableArray *HrMutableArray;//呼吸率收到的数据
@property (nonatomic,strong) NSMutableArray *RrMutableArray;//呼吸率收到的数据
@property (nonatomic,strong) NSMutableArray *TurnMutableArray;//翻身收到的数据
@property (nonatomic,assign)int synchronizationCount; //需要同步的总天数
@property (nonatomic,assign)int currentSynchronizationCount; //当前已同步的天数
@property (nonatomic,assign)int numByte; //需要获取数据的日期
@property (nonatomic,copy)NSString *synchronizationDate; //数据的日期 
@property (nonatomic,strong) SleepQualityModel *sleepQualityModel;//
@property (nonatomic,strong) TurnOverModel *turnOverModel;//
@property (nonatomic,strong) HeartRateModel *heartRateModel;//
@property (nonatomic,strong) RespiratoryRateModel *respiratoryRateModel;
@property (nonatomic,assign)int clockSynchronizationCount; //需要同步的总闹钟
@property (nonatomic,assign)int clockCurrentSynchronizationCount; //当前已同步的闹钟
@property (nonatomic,copy)ClockOperationBlock clockOperationBlock; //闹钟操作回调
@property (nonatomic,copy)VersionBlock versionBlock; //版本号回调
@property (nonatomic,copy)BatteryBlock batteryBlock; //电量回调
@property (nonatomic,assign)BOOL isUpdateManualCancelConnect; //升级手动取消连接;
@property (nonatomic,strong) NSMutableArray *clockMutableArray;//闹钟收到的数据
@property (nonatomic,copy)ClockBlock clockBlock; //闹钟查询全部操作回调

//eg report
@property (nonatomic,copy)reportSampleBlock reportSampleBlock;
@property (nonatomic,copy)BrHrBlock BrhrBlock;//呼吸率心率

@property (nonatomic,assign)int testInt;//测试


//创建蓝牙类单例
+(instancetype)shareIsnstance;
-(void)createCentralManager;
//搜索所有蓝牙外设
-(void)scanAllPeripheral;
-(void)connectPeripheral:(CBPeripheral *)peripheral;

//关闭实时心率/呼吸率开关
-(void)closeRealTimeHrRrNotify;
//打开实时心率/呼吸率开关
-(void)openRealTimeHrRrNotify;

//打开实时心率/呼吸率采样值开关
-(void)openRealTimeHrRrSampleNotify;
//关闭实时心率/呼吸率采样值开关
-(void)closeRealTimeHrRrSampleNotify;

//停止搜索
-(void)stopScan;
//断开连接
-(void)cancelConnect;

//手动断开连接
-(void)manualCancelConnect;
//读取翻身历史数据
-(void)getTurnOverHistoricalData:(int)num;
//设置设备时间
-(void)setDeviceTime;
-(void)connectCurrentPeripheral;
//设备固件升级-（唤醒DFU模式）
-(void)upDataDeviceVersions;
//读取设备版本
-(void)getDeviceVersions;
//获取闹钟
-(void)getDeviceClock;
//新增闹钟
-(void)addClock:(AlarmClockModel *)model;
//删除闹钟
-(void)deleteClock:(AlarmClockModel *)model;
//编辑闹钟
-(void)editClock:(AlarmClockModel *)model;

//读取睡眠历史数据
-(void)readSleepAllDataNotifyWithAll:(BOOL)isAll;
////读取睡眠质量数据
//-(void)readSleepQuDataNotifyWithAll:(BOOL)isAll;
////读取睡呼吸心率数据
//-(void)readHrBrDataNotifyWithAll:(BOOL)isAll;
////读取翻身数据
//-(void)readTurnOverDataNotifyWithAll:(BOOL)isAll;

//清理睡眠历史数据（本地数据库）
-(void)deleteSleepAllDataNotify;

//清理睡眠历史数据 (睡眠带)
-(void)deleteSleepBandDataNotify;


@end
