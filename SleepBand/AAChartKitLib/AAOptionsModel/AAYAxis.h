//
//  AAYAxis.h
//  AAChartKit
//
//  Created by An An on 17/1/5.
//  Copyright ยฉ 2017ๅนด An An. All rights reserved.
//*************** ...... SOURCE CODE ...... ***************
//***...................................................***
//*** https://github.com/AAChartModel/AAChartKit        ***
//*** https://github.com/AAChartModel/AAChartKit-Swift  ***
//***...................................................***
//*************** ...... SOURCE CODE ...... ***************

/*
 
 * -------------------------------------------------------------------------------
 *
 * ๐ ๐ ๐ ๐  โโโ   WARM TIPS!!!   โโโ ๐ ๐ ๐ ๐
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

#import <Foundation/Foundation.h>

@class AATitle,AALabels,AACrosshair;

typedef NSString *AAYAxisGridLineInterpolation;
static AAYAxisGridLineInterpolation const AAYAxisGridLineInterpolationCircle  = @"circle";//ๅๅฝข
static AAYAxisGridLineInterpolation const AAYAxisGridLineInterpolationPolygon = @"polygon";//ๅค่พนๅฝข

@interface AAYAxis : NSObject

//AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, BOOL,       min) 
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, AATitle  *, title)
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSArray  *, plotBands)
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSArray  *, plotLines)
AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, BOOL,       reversed)
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSNumber *, gridLineWidth) // y ่ฝด็ฝๆ?ผ็บฟๅฎฝๅบฆ
AAPropStatementAndPropSetFuncStatement(copy,   AAYAxis, NSString *, gridLineColor) // y ่ฝด็ฝๆ?ผ็บฟ้ข่ฒ
AAPropStatementAndPropSetFuncStatement(copy,   AAYAxis, NSString *, gridLineDashStyle) //็ฝๆ?ผ็บฟ็บฟๆกๆ?ทๅผ๏ผๆๆๅฏ็จ็็บฟๆกๆ?ทๅผๅ่๏ผHighcharts็บฟๆกๆ?ทๅผ
AAPropStatementAndPropSetFuncStatement(copy,   AAYAxis, NSString *, alternateGridColor) //backcolor of every other grid line area
AAPropStatementAndPropSetFuncStatement(copy,   AAYAxis, AAYAxisGridLineInterpolation, gridLineInterpolation) //Polar charts only. Whether the grid lines should draw as a polygon with straight lines between categories, or as circles. Can be either circle or polygon. ้ป่ฎคๆฏ๏ผnull.
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, AALabels *, labels) //็จไบ่ฎพ็ฝฎ y ่ฝดๆๅญ็ธๅณ็
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSNumber *, lineWidth) // y ่ฝด็บฟๅฎฝๅบฆ
AAPropStatementAndPropSetFuncStatement(copy,   AAYAxis, NSString *, lineColor) // y ่ฝด็บฟ้ข่ฒ
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSNumber *, offset) // y ่ฝด็บฟๆฐดๅนณๅ็งป

AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, BOOL,       allowDecimals)  //y่ฝดๆฏๅฆๅ่ฎธๆพ็คบๅฐๆฐ
AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, NSNumber *, max)  //y่ฝดๆๅคงๅผ
AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, NSNumber *, min)  //y่ฝดๆๅฐๅผ๏ผ่ฎพ็ฝฎไธบ0ๅฐฑไธไผๆ่ดๆฐ๏ผ
//AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, NSNumber *, minPadding)  //Padding of the min value relative to the length of the axis. A padding of 0.05 will make a 100px axis 5px longer. This is useful when you don't want the lowest data value to appear on the edge of the plot area. ้ป่ฎคๆฏ๏ผ0.05.
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSArray  *, tickPositions) //่ชๅฎไนY่ฝดๅๆ?๏ผๅฆ๏ผ[@(0), @(25), @(50), @(75) , (100)]๏ผ
AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, BOOL,       visible)  //y่ฝดๆฏๅฆๅ่ฎธๆพ็คบ
AAPropStatementAndPropSetFuncStatement(assign, AAYAxis, BOOL,       opposite) //ๆฏๅฆๅฐๅๆ?่ฝดๆพ็คบๅจๅฏน็ซ้ข๏ผ้ป่ฎคๆๅตไธ x ่ฝดๆฏๅจๅพ่กจ็ไธๆนๆพ็คบ๏ผy ่ฝดๆฏๅจๅทฆๆน๏ผๅๆ?่ฝดๆพ็คบๅจๅฏน็ซ้ขๅ๏ผx ่ฝดๆฏๅจไธๆนๆพ็คบ๏ผy ่ฝดๆฏๅจๅณๆนๆพ็คบ๏ผๅณๅๆ?่ฝดไผๆพ็คบๅจๅฏน็ซ้ข๏ผใ่ฏฅ้็ฝฎไธ่ฌๆฏ็จไบๅคๅๆ?่ฝดๅบๅๅฑ็คบ๏ผๅฆๅคๅจ Highstock ไธญ๏ผy ่ฝด้ป่ฎคๆฏๅจๅฏน็ซ้ขๆพ็คบ็ใ ้ป่ฎคๆฏ๏ผfalse.
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSNumber *, tickInterval) 
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, AACrosshair*, crosshair)  //ๅๆ็บฟๆ?ทๅผ่ฎพ็ฝฎ
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, AALabels *, stackLabels) 
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSNumber *, tickWidth) //ๅๆ?่ฝดๅปๅบฆ็บฟ็ๅฎฝๅบฆ๏ผ่ฎพ็ฝฎไธบ 0 ๆถๅไธๆพ็คบๅปๅบฆ็บฟ
AAPropStatementAndPropSetFuncStatement(strong, AAYAxis, NSNumber *, tickLength)//ๅๆ?่ฝดๅปๅบฆ็บฟ็้ฟๅบฆใ ้ป่ฎคๆฏ๏ผ10.
AAPropStatementAndPropSetFuncStatement(copy,   AAYAxis, NSString *, tickPosition) //ๅปๅบฆ็บฟ็ธๅฏนไบ่ฝด็บฟ็ไฝ็ฝฎ๏ผๅฏ็จ็ๅผๆ inside ๅ outside๏ผๅๅซ่กจ็คบๅจ่ฝด็บฟ็ๅ้จๅๅค้จใ ้ป่ฎคๆฏ๏ผoutside.
@end
