//
//  DeviceModel.h
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject
@property (nonatomic,assign)int userId;
@property (nonatomic,copy)NSString *firmware;
@property (nonatomic,copy)NSString *battery;
@end
