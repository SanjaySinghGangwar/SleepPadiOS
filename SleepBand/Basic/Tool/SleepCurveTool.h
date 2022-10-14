//
//  SleepCurveTool.h
//  SleepBand
//
//  Created by admin on 2018/8/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepCurveTool : NSObject

/**
 @param newSelectDate byte数组
 @param length byte长度
 @param index 用户设置的睡眠时间在数组的下标
 */
+(NSDictionary *)sleepCurve:(Byte *)newSelectDate WithDataByteLength:(int)length WithIndex:(int)index;


@end
