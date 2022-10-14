//
//  SleepQualityModel.m
//  SleepBand
//
//  Created by admin on 2018/8/14.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SleepQualityModel.h"

@implementation SleepQualityModel
+(NSArray *)getPrimaryKeyUnionArray {
    return @[@"uesrId",@"dataDate",@"deviceName"];
}
@end
