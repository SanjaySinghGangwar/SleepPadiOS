//
//  AALegend.h
//  AAChartKit
//
//  Created by An An on 17/1/6.
//  Copyright ยฉ 2017ๅนด An An. All rights reserved.
//
//*************** ...... SOURCE CODE ...... ***************
//***...................................................***
//***    https://github.com/AAChartModel/AAChartKit     ***
//***...................................................***
//*************** ...... SOURCE CODE ...... ***************
//

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
@class AAItemStyle;

typedef NSString *AALegendLayoutType;
typedef NSString *AALegendAlignType;
typedef NSString *AALegendVerticalAlignType;

extern AALegendLayoutType const AALegendLayoutTypeHorizontal;
extern AALegendLayoutType const AALegendLayoutTypeVertical;

extern AALegendAlignType const AALegendAlignTypeLeft;
extern AALegendAlignType const AALegendAlignTypeCenter;
extern AALegendAlignType const AALegendAlignTypeRight;

extern AALegendVerticalAlignType const AALegendVerticalAlignTypeTop;
extern AALegendVerticalAlignType const AALegendVerticalAlignTypeMiddle;
extern AALegendVerticalAlignType const AALegendVerticalAlignTypeBottom;

@interface AALegend : NSObject

AAPropStatementAndPropSetFuncStatement(copy,   AALegend, AALegendLayoutType,        layout) //ๅพไพๆฐๆฎ้กน็ๅธๅฑใๅธๅฑ็ฑปๅ๏ผ "horizontal" ๆ "vertical" ๅณๆฐดๅนณๅธๅฑๅๅ็ดๅธๅฑ ้ป่ฎคๆฏ๏ผhorizontal.
AAPropStatementAndPropSetFuncStatement(copy,   AALegend, AALegendAlignType,         align) //่ฎพๅฎๅพไพๅจๅพ่กจๅบไธญ็ๆฐดๅนณๅฏน้ฝๆนๅผ๏ผๅๆณๅผๆleft๏ผcenter ๅ rightใ
AAPropStatementAndPropSetFuncStatement(copy,   AALegend, AALegendVerticalAlignType, verticalAlign) //่ฎพๅฎๅพไพๅจๅพ่กจๅบไธญ็ๅ็ดๅฏน้ฝๆนๅผ๏ผๅๆณๅผๆ top๏ผmiddle ๅ bottomใๅ็ดไฝ็ฝฎๅฏไปฅ้่ฟ y ้้กนๅ่ฟไธๆญฅ่ฎพๅฎใ
AAPropStatementAndPropSetFuncStatement(assign, AALegend, BOOL,          enabled) 
AAPropStatementAndPropSetFuncStatement(copy,   AALegend, NSString    *, borderColor) 
AAPropStatementAndPropSetFuncStatement(strong, AALegend, NSNumber    *, borderWidth) 
AAPropStatementAndPropSetFuncStatement(strong, AALegend, NSNumber    *, itemMarginTop) //ๅพไพ็ๆฏไธ้กน็้กถ้จๅค่พน่ท๏ผๅไฝpxใ ้ป่ฎคๆฏ๏ผ0.
AAPropStatementAndPropSetFuncStatement(strong, AALegend, AAItemStyle *, itemStyle) 
AAPropStatementAndPropSetFuncStatement(strong, AALegend, NSNumber    *, x) 
AAPropStatementAndPropSetFuncStatement(strong, AALegend, NSNumber    *, y) 

@end



@interface AAItemStyle : NSObject

AAPropStatementAndPropSetFuncStatement(copy, AAItemStyle, NSString *, color)
AAPropStatementAndPropSetFuncStatement(copy, AAItemStyle, NSString *, cursor)
AAPropStatementAndPropSetFuncStatement(copy, AAItemStyle, NSString *, pointer)
AAPropStatementAndPropSetFuncStatement(copy, AAItemStyle, NSString *, fontSize)
AAPropStatementAndPropSetFuncStatement(copy, AAItemStyle, NSString *, fontWeight)

@end
