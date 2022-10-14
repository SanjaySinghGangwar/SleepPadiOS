//
//  SleepCurveTool.m
//  SleepBand
//
//  Created by admin on 2018/8/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "SleepCurveTool.h"
#include "SleepCurve.h"

@implementation SleepCurveTool

/**
 @param newSelectDate byte数组
 @param length byte长度
 @param index 用户设置的睡眠时间在数组的下标
 */
+(NSDictionary *)sleepCurve:(Byte *)newSelectDate WithDataByteLength:(int)length WithIndex:(int)index
{
    SleepQualityTime sqTime;
    CSleepCurve cSleepCurve;
//    for(int i = 0 ; i < 480 ; i++){
//        NSLog(@"%d",newSelectDate[i]);
//    }
    
    //曲线数组
    int curveLength = length*18;
    double curveArray[curveLength];
    //上床和离床的标记数组
    int tagLength = 360;
    int tagArray[tagLength];
    cSleepCurve.CalcSleepCurve(newSelectDate, length, curveArray, curveLength, index, tagArray,tagLength,sqTime);
//    [NSThread sleepForTimeInterval:2.0];

    NSMutableArray *sleepCurveArray = [[NSMutableArray alloc]init];
    NSMutableArray *tagIndexArray = [[NSMutableArray alloc]init];
    
    for(int i =  0; i < curveLength;i++)
    {
        double num = curveArray[i];
        [sleepCurveArray addObject:[NSNumber numberWithDouble:num]];
    }
    
    for(int i =  0; i < tagLength; i++)
    {
        int num = tagArray[i];
        [tagIndexArray addObject:[NSNumber numberWithInt:num]];
    }
    
    NSString *awake =  [NSString stringWithFormat:@"%d",sqTime.awake];
    NSString *lightSleep = [NSString stringWithFormat:@"%d",sqTime.lightSleep];
    NSString *midSleep = [NSString stringWithFormat:@"%d",sqTime.midSleep];
    NSString *deepSleep = [NSString stringWithFormat:@"%d",sqTime.deepSleep];
    
    NSDictionary *dict = @{@"SleepCurve":sleepCurveArray,@"AwakeTime":awake,@"LightSleepTime":lightSleep,@"MidSleepTime":midSleep,@"DeepSleepTime":deepSleep,@"tagArray":tagIndexArray};
    
//    [sleepCurveArray removeAllObjects];
//    sleepCurveArray = nil;
    return dict;
    
}

@end
