//
//  TurnOverModel.m
//  SleepBand
//
//  Created by admin on 2018/8/9.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "TurnOverModel.h"

@implementation TurnOverModel
//+(NSString *)getPrimaryKey{
//    return @"dataDate";
//}
+(NSArray *)getPrimaryKeyUnionArray {
    return @[@"uesrId",@"dataDate",@"deviceName"];
}
//+(NSString *)getTableName
//{
//    return @"TurnOverTable";
//}
@end
