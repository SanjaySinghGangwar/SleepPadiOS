//
//  HeartRateModel.m
//  SleepBand
//
//  Created by admin on 2018/8/9.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "HeartRateModel.h"

@implementation HeartRateModel
//+(NSString *)getPrimaryKey{
//    return @"dataDate";
//}
+(NSArray *)getPrimaryKeyUnionArray {
    return @[@"uesrId",@"dataDate",@"deviceName"];
}

//+(NSString *)getTableName
//{
//    return @"HeartRateTable";
//}
@end
