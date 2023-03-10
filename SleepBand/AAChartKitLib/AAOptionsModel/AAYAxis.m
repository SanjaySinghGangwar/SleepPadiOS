//
//  AAYAxis.m
//  AAChartKit
//
//  Created by An An on 17/1/5.
//  Copyright Â© 2017å¹´ An An. All rights reserved.
//*************** ...... SOURCE CODE ...... ***************
//***...................................................***
//*** https://github.com/AAChartModel/AAChartKit        ***
//*** https://github.com/AAChartModel/AAChartKit-Swift  ***
//***...................................................***
//*************** ...... SOURCE CODE ...... ***************

/*
 
 * -------------------------------------------------------------------------------
 *
 * ð ð ð ð  âââ   WARM TIPS!!!   âââ ð ð ð ð
 *
 * Please contact me on GitHub,if there are any problems encountered in use.
 * GitHub Issues : https://github.com/AAChartModel/AAChartKit/issues
 * -------------------------------------------------------------------------------
 * And if you want to contribute for this project, please contact me as well
 * GitHub        : https://github.com/AAChartModel
 * StackOverflow : https://stackoverflow.com/users/7842508/codeforu
 * JianShu       : https://www.jianshu.com/u/f1e6753d4254
 * SegmentFault  : https://segmentfault.com/u/huanghunbieguan
 *
 * -------------------------------------------------------------------------------
 
 */

#import "AAYAxis.h"

@implementation AAYAxis

//AAPropSetFuncImplementation(AAYAxis, BOOL,       min) tickWidth
AAPropSetFuncImplementation(AAYAxis, AATitle  *, title)
AAPropSetFuncImplementation(AAYAxis, NSArray  *, plotBands)
AAPropSetFuncImplementation(AAYAxis, NSArray  *, plotLines) 
AAPropSetFuncImplementation(AAYAxis, BOOL,       reversed) 
AAPropSetFuncImplementation(AAYAxis, NSNumber *, gridLineWidth) 
AAPropSetFuncImplementation(AAYAxis, NSString *, gridLineColor)
AAPropSetFuncImplementation(AAYAxis, NSString *, gridLineDashStyle) //ç½æ ¼çº¿çº¿æ¡æ ·å¼ï¼ææå¯ç¨ççº¿æ¡æ ·å¼åèï¼Highchartsçº¿æ¡æ ·å¼
AAPropSetFuncImplementation(AAYAxis, NSString *, alternateGridColor) 
AAPropSetFuncImplementation(AAYAxis, AAYAxisGridLineInterpolation, gridLineInterpolation) 
AAPropSetFuncImplementation(AAYAxis, AALabels *, labels) 
AAPropSetFuncImplementation(AAYAxis, NSNumber *, lineWidth) //yè½´çº¿å®½åº¦
AAPropSetFuncImplementation(AAYAxis, NSString *, lineColor) // y è½´çº¿é¢è²
AAPropSetFuncImplementation(AAYAxis, NSNumber *, offset) // y è½´çº¿æ°´å¹³åç§»

AAPropSetFuncImplementation(AAYAxis, BOOL,       allowDecimals)  //yè½´æ¯å¦åè®¸æ¾ç¤ºå°æ°
AAPropSetFuncImplementation(AAYAxis, NSNumber *, max)  //yè½´æå¤§å¼
AAPropSetFuncImplementation(AAYAxis, NSNumber *, min)  //yè½´æå°å¼ï¼è®¾ç½®ä¸º0å°±ä¸ä¼æè´æ°ï¼
//AAPropSetFuncImplementation(AAYAxis, NSNumber *, minPadding)  //Padding of the min value relative to the length of the axis. A padding of 0.05 will make a 100px axis 5px longer. This is useful when you don't want the lowest data value to appear on the edge of the plot area. é»è®¤æ¯ï¼0.05.
AAPropSetFuncImplementation(AAYAxis, NSArray  *, tickPositions) //èªå®ä¹Yè½´åæ ï¼å¦ï¼[@(0), @(25), @(50), @(75) , (100)]ï¼
AAPropSetFuncImplementation(AAYAxis, BOOL,       visible)  //yè½´æ¯å¦åè®¸æ¾ç¤º
AAPropSetFuncImplementation(AAYAxis, BOOL,       opposite) //æ¯å¦å°åæ è½´æ¾ç¤ºå¨å¯¹ç«é¢ï¼é»è®¤æåµä¸ x è½´æ¯å¨å¾è¡¨çä¸æ¹æ¾ç¤ºï¼y è½´æ¯å¨å·¦æ¹ï¼åæ è½´æ¾ç¤ºå¨å¯¹ç«é¢åï¼x è½´æ¯å¨ä¸æ¹æ¾ç¤ºï¼y è½´æ¯å¨å³æ¹æ¾ç¤ºï¼å³åæ è½´ä¼æ¾ç¤ºå¨å¯¹ç«é¢ï¼ãè¯¥éç½®ä¸è¬æ¯ç¨äºå¤åæ è½´åºåå±ç¤ºï¼å¦å¤å¨ Highstock ä¸­ï¼y è½´é»è®¤æ¯å¨å¯¹ç«é¢æ¾ç¤ºçã é»è®¤æ¯ï¼false.
AAPropSetFuncImplementation(AAYAxis, NSNumber *, tickInterval) 
AAPropSetFuncImplementation(AAYAxis, AACrosshair*, crosshair)  //åæçº¿æ ·å¼è®¾ç½®
AAPropSetFuncImplementation(AAYAxis, AALabels *, stackLabels)
AAPropSetFuncImplementation(AAYAxis, NSNumber *, tickWidth) //åæ è½´å»åº¦çº¿çå®½åº¦ï¼è®¾ç½®ä¸º 0 æ¶åä¸æ¾ç¤ºå»åº¦çº¿
AAPropSetFuncImplementation(AAYAxis, NSNumber *, tickLength)//åæ è½´å»åº¦çº¿çé¿åº¦ã é»è®¤æ¯ï¼10.
AAPropSetFuncImplementation(AAYAxis, NSString *, tickPosition) //å»åº¦çº¿ç¸å¯¹äºè½´çº¿çä½ç½®ï¼å¯ç¨çå¼æ inside å outsideï¼åå«è¡¨ç¤ºå¨è½´çº¿çåé¨åå¤é¨ã é»è®¤æ¯ï¼outside.



@end
