//
//  TurnOverModel.h
//  SleepBand
//
//  Created by admin on 2018/8/9.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TurnOverModel : NSObject
@property (copy,nonatomic)NSString *uesrId; //用户ID
@property (copy,nonatomic)NSString *deviceName; //设备名字
@property (copy,nonatomic)NSString *dataDate; //数据日期
@property (strong,nonatomic)NSData *data; //数据

@property (strong,nonatomic)NSArray *dataArray; //数据
@end
