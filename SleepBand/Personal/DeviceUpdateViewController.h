//
//  DeviceUpdateViewController.h
//  SleepBand
//
//  Created by admin on 2018/8/23.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateBlock)(NSString *updateVersion);

@interface DeviceUpdateViewController : UIViewController
@property (copy,nonatomic)NSString *hardwareVersion;
@property (copy,nonatomic)NSString *softwareVersion;
@property (copy,nonatomic)UpdateBlock updateBlock;
@end
