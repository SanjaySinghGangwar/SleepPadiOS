//
//  AATitle.m
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

#import "AATitle.h"

AAChartTitleAlignType const AAChartTitleAlignTypeLeft   = @"left";
AAChartTitleAlignType const AAChartTitleAlignTypeCenter = @"center";
AAChartTitleAlignType const AAChartTitleAlignTypeRight  = @"right";

AAChartTitleVerticalAlignType const AAChartTitleVerticalAlignTypeTop    = @"top";
AAChartTitleVerticalAlignType const AAChartTitleVerticalAlignTypeMiddle = @"middle";
AAChartTitleVerticalAlignType const AAChartTitleVerticalAlignTypeBottom = @"bottom";

@implementation AATitle

AAPropSetFuncImplementation(AATitle, NSString *, text) 
AAPropSetFuncImplementation(AATitle, AAStyle  *, style) 
AAPropSetFuncImplementation(AATitle, AAChartTitleAlignType, align) 
AAPropSetFuncImplementation(AATitle, AAChartTitleVerticalAlignType, verticalAlign) 
AAPropSetFuncImplementation(AATitle, NSNumber *, y) //ๆ?้ข็ธๅฏนไบๅ็ดๅฏน้ฝ็ๅ็งป้๏ผๅๅผ่ๅด๏ผๅพ่กจ็ไธ่พน่ท๏ผchart.spacingTop ๏ผๅฐๅพ่กจ็ไธ่พน่ท๏ผchart.spacingBottom๏ผ๏ผๅฏไปฅๆฏ่ดๅผ๏ผๅไฝๆฏpxใ้ป่ฎคๅผๅๅญไฝๅคงๅฐๆๅณใ
AAPropSetFuncImplementation(AATitle, BOOL          , useHTML) //ๆฏๅฆ ไฝฟ็จHTMLๆธฒๆๆ?้ขใ ้ป่ฎคๆฏ๏ผfalse.

@end



@implementation AASubtitle

AAPropSetFuncImplementation(AASubtitle, NSString *, text)
AAPropSetFuncImplementation(AASubtitle, NSString *, align)
AAPropSetFuncImplementation(AASubtitle, AAStyle  *, style)

@end
