//
//  P3XPeripheralModel.h
//  QLife
//
//  Created by admin on 2018/11/23.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralModel : NSObject
@property (strong,nonatomic)CBPeripheral *peripheral;
@property (copy,nonatomic)NSString *macAddress;
@end

NS_ASSUME_NONNULL_END
