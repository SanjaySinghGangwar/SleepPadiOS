//
//  UserModel.m
//  SleepBand
//
//  Created by admin on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if ([property.name isEqualToString:@"email"] || [property.name isEqualToString:@"phoneNumber"] || [property.name isEqualToString:@"birthday"]) {
        if (oldValue == [NSNull null]) {
            return @"";
        }
    }
    return oldValue;
}

- (void)setUnit:(NSString *)unit{
    if (_unit != unit) {
        _unit = unit;
        //公制0，英制1
        _units = [unit isEqualToString:@"Metric"] || [unit isEqualToString:@"公制"] ? 0 : 1;
    }
}

@end
