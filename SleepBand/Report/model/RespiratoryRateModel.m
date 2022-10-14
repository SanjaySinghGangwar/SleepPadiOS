//
//  RespiratoryRateModel.m
//  SleepBand
//
//  Created by admin on 2018/8/9.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "RespiratoryRateModel.h"

@implementation RespiratoryRateModel
+(NSArray *)getPrimaryKeyUnionArray {
    return @[@"uesrId",@"dataDate",@"deviceName"];
}
//+(NSString *)getPrimaryKey{
//    return @"dataDate";
//}
//+(NSString *)getTableName
//{
//    return @"RespiratoryRateTable";
//}
@end
