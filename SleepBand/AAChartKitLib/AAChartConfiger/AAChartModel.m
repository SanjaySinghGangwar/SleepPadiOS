
//
//  AAChartModel.m
//  AAChartKit
//
//  Created by An An on 17/1/20.
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

#import "AAChartModel.h"

AAChartType const AAChartTypeColumn          = @"column";
AAChartType const AAChartTypeBar             = @"bar";
AAChartType const AAChartTypeArea            = @"area";
AAChartType const AAChartTypeAreaspline      = @"areaspline";
AAChartType const AAChartTypeLine            = @"line";
AAChartType const AAChartTypeSpline          = @"spline";
AAChartType const AAChartTypeScatter         = @"scatter";
AAChartType const AAChartTypePie             = @"pie";
AAChartType const AAChartTypeBubble          = @"bubble";
AAChartType const AAChartTypePyramid         = @"pyramid";
AAChartType const AAChartTypeFunnel          = @"funnel";
AAChartType const AAChartTypeColumnrange     = @"columnrange";
AAChartType const AAChartTypeArearange       = @"arearange";
AAChartType const AAChartTypeAreasplinerange = @"areasplinerange";
AAChartType const AAChartTypeBoxplot         = @"boxplot";
AAChartType const AAChartTypeWaterfall       = @"waterfall";
AAChartType const AAChartTypePolygon         = @"polygon";

AAChartSubtitleAlignType const AAChartSubtitleAlignTypeLeft   = @"left";
AAChartSubtitleAlignType const AAChartSubtitleAlignTypeCenter = @"center";
AAChartSubtitleAlignType const AAChartSubtitleAlignTypeRight  = @"right";

AAChartZoomType const AAChartZoomTypeNone = @"none";
AAChartZoomType const AAChartZoomTypeX    = @"x";
AAChartZoomType const AAChartZoomTypeY    = @"y";
AAChartZoomType const AAChartZoomTypeXY   = @"xy";

AAChartStackingType const AAChartStackingTypeFalse   = @"";
AAChartStackingType const AAChartStackingTypeNormal  = @"normal";
AAChartStackingType const AAChartStackingTypePercent = @"percent";

AAChartSymbolType const AAChartSymbolTypeCircle        = @"circle";
AAChartSymbolType const AAChartSymbolTypeSquare        = @"square";
AAChartSymbolType const AAChartSymbolTypeDiamond       = @"diamond";
AAChartSymbolType const AAChartSymbolTypeTriangle      = @"triangle";
AAChartSymbolType const AAChartSymbolTypeTriangle_down = @"triangle-down";

AAChartSymbolStyleType const AAChartSymbolStyleTypeDefault     = @"default";
AAChartSymbolStyleType const AAChartSymbolStyleTypeInnerBlank  = @"innerBlank";
AAChartSymbolStyleType const AAChartSymbolStyleTypeBorderBlank = @"borderBlank";

AAChartFontWeightType const AAChartFontWeightTypeThin     = @"thin";
AAChartFontWeightType const AAChartFontWeightTypeRegular  = @"regular";
AAChartFontWeightType const AAChartFontWeightTypeBold     = @"bold";

AALineDashStyleType const AALineDashStyleTypeSolid           = @"Solid";
AALineDashStyleType const AALineDashStyleTypeShortDash       = @"ShortDash";
AALineDashStyleType const AALineDashStyleTypeShortDot        = @"ShortDot";
AALineDashStyleType const AALineDashStyleTypeShortDashDot    = @"ShortDashDot";
AALineDashStyleType const AALineDashStyleTypeShortDashDotDot = @"ShortDashDotDot";
AALineDashStyleType const AALineDashStyleTypeDot             = @"Dot";
AALineDashStyleType const AALineDashStyleTypeDash            = @"Dash";
AALineDashStyleType const AALineDashStyleTypeLongDash        = @"LongDash";
AALineDashStyleType const AALineDashStyleTypeDashDot         = @"DashDot";
AALineDashStyleType const AALineDashStyleTypeLongDashDot     = @"LongDashDot";
AALineDashStyleType const AALineDashStyleTypeLongDashDotDot  = @"LongDashDotDot";

@implementation AAChartModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _chartType             = AAChartTypeColumn;//้ป่ฎคๅพ่กจ็ฑปๅไธบๆฑ็ถๅพ
        _animationType         = AAChartAnimationLinear;//้ป่ฎคไฝฟ็จ้easing.jsไธญ็'linear'็บฟๆงๆธๅๆๆ
        _animationDuration     = @800;//้ป่ฎคๅจ็ปๆถ้ฟไธบ800ๆฏซ็ง
        _subtitleAlign         = AAChartSubtitleAlignTypeLeft;//้ป่ฎคๅพ่กจๅฏๆ?้ขๅฑๅทฆๆพ็คบ
        _stacking              = AAChartStackingTypeFalse;//้ป่ฎคไธๅผๅฏๅพ่กจๆฐๆฎ็ๅ?็งฏๆๆ
        _zoomType              = AAChartZoomTypeNone ;//้ป่ฎค็ฆ็จๅพ่กจ็ๆๅฟ็ผฉๆพๅ่ฝ
        _colorsTheme           = @[@"#1e90ff",@"#ef476f",@"#ffd066",@"#04d69f",@"#25547c",];//้ป่ฎค้ข่ฒไธป้ข
        _tooltipEnabled        = YES;//้ป่ฎคๅฏ็จๆตฎๅจๆ็คบๆก
        //        _tooltipCrosshairs     = YES;//้ป่ฎคๅฏ็จๅๆ็บฟ
        _tooltipShared         = YES;//้ป่ฎคๅค็ปๆฐๆฎๅฑไบซไธไธชๆตฎๅจๆ็คบๆก
        _xAxisLabelsEnabled    = YES;//้ป่ฎคๆพ็คบ X่ฝดๅๆ?็นๆๅญ
        _xAxisGridLineWidth    = @0; //่ฎพ็ฝฎx่ฝดๅๅฒ็บฟๅฎฝๅบฆไธบ0ไธชๅ็ด?,ๅณๆฏ้่ X่ฝดๅๅฒ็บฟ
        _xAxisTickInterval     = @1; //x่ฝดๅๆ?็น้ด้ๆฐ(้ป่ฎคๆฏ1)
        _xAxisVisible          = YES;//x่ฝด้ป่ฎคๅฏ่ง
        _yAxisVisible          = YES;//y่ฝด้ป่ฎคๅฏ่ง
        _yAxisLabelsEnabled    = YES;
        _yAxisLineWidth        = @0.5; //y่ฝด่ฝด็บฟ็ๅฎฝๅบฆไธบ1
        _yAxisGridLineWidth    = @1; //y่ฝดๅๅฒ็บฟ็บฟๅฎฝไธบไธไธชๅ็ด?
        _legendEnabled         = YES;//้ป่ฎคๆพ็คบๅพไพ(ๅพ่กจไธๆนๅฏ็นๅป็ๅธฆๆๆๅญ็ๅฐๅ็น)
        _borderRadius          = @0; //ๆฑ็ถๅพ้ฟๆกๅพๅคด้จๅ่งๅๅพ(ๅฏ็จไบ่ฎพ็ฝฎๅคด้จ็ๅฝข็ถ,ไปๅฏนๆกๅฝขๅพ,ๆฑ็ถๅพๆๆ,่ฎพ็ฝฎไธบ1000ๆถ,ๆฑๅฝขๅพๆ่ๆกๅฝขๅพๅคด้จไธบๆฅๅฝข)
        _markerRadius          = @5; //ๆ็บฟ่ฟๆฅ็น็ๅๅพ้ฟๅบฆ,ๅฆๆๅผ่ฎพ็ฝฎไธบ0,่ฟๆ?ทๅฐฑ็ธๅฝไบไธๆพ็คบไบ
        _yAxisAllowDecimals    = YES;//้ป่ฎคy่ฝดๅ่ฎธๆพ็คบๅฐๆฐ
        _zoomResetButtonText   = @"ๆขๅค็ผฉๆพ";//ๆขๅค็ผฉๆพๆ้ฎ็ๆ?้ขๆๅญ
        
        _titleFontColor        = @"#000000";//ๆ?้ขๅญไฝ้ข่ฒไธบ้ป่ฒ
        _titleFontWeight       = AAChartFontWeightTypeRegular;//ๅธธ่งๅญไฝ
        _titleFontSize         = @11;
        _subtitleFontColor     = @"#000000";//ๅฏๆ?้ขๅญไฝ้ข่ฒไธบ้ป่ฒ
        _subtitleFontWeight    = AAChartFontWeightTypeRegular;//ๅธธ่งๅญไฝ
        _subtitleFontSize      = @9;
        _dataLabelFontColor    = @"#000000";//ๆฐๆฎๆ?็ญพ้ป่ฎค้ข่ฒไธบ้ป่ฒ
        _dataLabelFontWeight   = AAChartFontWeightTypeBold;//ๅพ่กจ็ๆฐๆฎๅญไฝไธบ็ฒไฝ
        _dataLabelFontSize     = @10;
        _xAxisLabelsFontSize   = @11;//x่ฝดๅญไฝๅคงๅฐ
        _xAxisLabelsFontColor  = @"#778899";//ๆต็ณๆฟ็ฐ่ฒๅญไฝ
        _xAxisLabelsFontWeight = AAChartFontWeightTypeThin;//็ปไฝๅญ
        _yAxisLabelsFontSize   = @11;
        _yAxisLabelsFontColor  = @"#778899";//ๆต็ณๆฟ็ฐ่ฒๅญไฝ
//        _gridYLineColor        = @"#778899";//y่ฝด ๅๅฒ็บฟ้ข่ฒ
        _yAxisLabelsFontWeight = AAChartFontWeightTypeThin;//็ปไฝๅญ
    }
    return self;
}

AAPropSetFuncImplementation(AAChartModel, NSString *, title) //ๆ?้ขๅๅฎน
AAPropSetFuncImplementation(AAChartModel, NSNumber *, titleFontSize) //Title label font size
AAPropSetFuncImplementation(AAChartModel, NSString *, titleFontColor) //Title label font color
AAPropSetFuncImplementation(AAChartModel, NSString *, titleFontWeight) //Title label font weight

AAPropSetFuncImplementation(AAChartModel, NSString *, subtitle) //ๅฏๆ?้ขๅๅฎน
AAPropSetFuncImplementation(AAChartModel, NSNumber *, subtitleFontSize) //Subtitle label font size
AAPropSetFuncImplementation(AAChartModel, NSString *, subtitleFontColor) //Subtitle label font color
AAPropSetFuncImplementation(AAChartModel, NSString *, subtitleFontWeight) //Subtitle label font weight

AAPropSetFuncImplementation(AAChartModel, NSString *, backgroundColor) //ๅพ่กจ่ๆฏ่ฒ(ๅฟ้กปไธบๅๅญ่ฟๅถ็้ข่ฒ่ฒๅผๅฆ็บข่ฒ"#FF0000")
AAPropSetFuncImplementation(AAChartModel, NSArray     <NSString *>*, colorsTheme) //ๅพ่กจไธป้ข้ข่ฒๆฐ็ป
AAPropSetFuncImplementation(AAChartModel, NSArray     <NSString *>*, categories) //x่ฝดๅๆ?ๆฏไธช็นๅฏนๅบ็ๅ็งฐ(ๆณจๆ:่ฟไธชไธๆฏ็จๆฅ่ฎพ็ฝฎ X ่ฝด็ๅผ,ไปไปๆฏ็จไบ่ฎพ็ฝฎ X ่ฝดๆๅญๅๅฎน็่ๅทฒ)
AAPropSetFuncImplementation(AAChartModel, NSArray  *, series) //ๅพ่กจ็ๆฐๆฎๅๅๅฎน

AAPropSetFuncImplementation(AAChartModel, AAChartSubtitleAlignType, subtitleAlign) //ๅพ่กจๅฏๆ?้ขๆๆฌๆฐดๅนณๅฏน้ฝๆนๅผใๅฏ้็ๅผๆ โleftโ๏ผโcenterโๅโrightโใ ้ป่ฎคๆฏ๏ผcenter.
AAPropSetFuncImplementation(AAChartModel, AAChartType,              chartType) //ๅพ่กจ็ฑปๅ
AAPropSetFuncImplementation(AAChartModel, AAChartStackingType,      stacking) //ๅ?็งฏๆ?ทๅผ
AAPropSetFuncImplementation(AAChartModel, AAChartSymbolType,        markerSymbol) //ๆ็บฟๆฒ็บฟ่ฟๆฅ็น็็ฑปๅ๏ผ"circle", "square", "diamond", "triangle","triangle-down"๏ผ้ป่ฎคๆฏ"circle"
AAPropSetFuncImplementation(AAChartModel, AAChartSymbolStyleType,   markerSymbolStyle)
AAPropSetFuncImplementation(AAChartModel, AAChartZoomType,          zoomType) //็ผฉๆพ็ฑปๅ AAChartZoomTypeX ่กจ็คบๅฏๆฒฟ็ x ่ฝด่ฟ่กๆๅฟ็ผฉๆพ
AAPropSetFuncImplementation(AAChartModel, AAChartAnimation,         animationType) //่ฎพ็ฝฎๅพ่กจ็ๆธฒๆๅจ็ป็ฑปๅ
AAPropSetFuncImplementation(AAChartModel, NSNumber *, animationDuration) //่ฎพ็ฝฎๅพ่กจ็ๆธฒๆๅจ็ปๆถ้ฟ(ๅจ็ปๅไฝไธบๆฏซ็ง)

AAPropSetFuncImplementation(AAChartModel, BOOL,       inverted) //x ่ฝดๆฏๅฆๅ็ด,้ป่ฎคไธบๅฆ
AAPropSetFuncImplementation(AAChartModel, BOOL,       easyGradientColors) //ๆฏๅฆๆนไพฟๅฟซๆทๅฐๅฐๅธธ่งไธป้ข้ข่ฒๆฐ็ป colorsTheme ่ชๅจ่ฝฌๆขไธบๅ้ๆๆธๅๆๆ็้ข่ฒๆฐ็ป(่ฎพ็ฝฎๅๅฐฑไธ็จ่ชๅทฑๅๆๅจๅปๅๆธๅ่ฒๅญๅธ,็ธๅฝไบๆฏ่ฎพ็ฝฎๆธๅ่ฒ็ไธไธชๅฟซๆทๆนๅผ,ๅฝ็ถไบ,ๅฆๆ้่ฆ็ป่ดๅฐ่ชๅฎไนๆธๅ่ฒๆๆ,่ฟๆฏ้่ฆ่ชๅทฑๆๅจ้็ฝฎๆธๅ้ข่ฒๅญๅธๅๅฎน,ๅทไฝๆนๆณๅ่งๅพ่กจ็คบไพไธญ็`้ข่ฒๆธๅๆกๅฝขๅพ`็คบไพไปฃ็?),้ป่ฎคไธบๅฆ
AAPropSetFuncImplementation(AAChartModel, BOOL,       polar) //ๆฏๅฆๆๅๅพๅฝข(ๅไธบ้ท่พพๅพ),้ป่ฎคไธบๅฆ

AAPropSetFuncImplementation(AAChartModel, BOOL,       dataLabelEnabled) //ๆฏๅฆๆพ็คบๆฐๆฎ,้ป่ฎคไธบๅฆ
AAPropSetFuncImplementation(AAChartModel, NSString *, dataLabelFontColor) //Datalabel font color
AAPropSetFuncImplementation(AAChartModel, NSNumber *, dataLabelFontSize) //Datalabel font size
AAPropSetFuncImplementation(AAChartModel, NSString *, dataLabelFontWeight) //Datalabel font weight


AAPropSetFuncImplementation(AAChartModel, BOOL,       xAxisVisible) //x ่ฝดๆฏๅฆๅฏ่ง(้ป่ฎคๅฏ่ง)
AAPropSetFuncImplementation(AAChartModel, BOOL,       xAxisReversed) // x ่ฝด็ฟป่ฝฌ,้ป่ฎคไธบๅฆ

AAPropSetFuncImplementation(AAChartModel, BOOL,       xAxisLabelsEnabled) //x ่ฝดๆฏๅฆๆพ็คบๆๅญ
AAPropSetFuncImplementation(AAChartModel, NSNumber *, xAxisLabelsFontSize) //x ่ฝดๆๅญๅญไฝๅคงๅฐ
AAPropSetFuncImplementation(AAChartModel, NSString *, xAxisLabelsFontColor) //x ่ฝดๆๅญๅญไฝ้ข่ฒ
AAPropSetFuncImplementation(AAChartModel, AAChartFontWeightType, xAxisLabelsFontWeight) //x ่ฝดๆๅญๅญไฝ็ฒ็ป

AAPropSetFuncImplementation(AAChartModel, NSNumber *, xAxisGridLineWidth) //x ่ฝด็ฝๆ?ผ็บฟ็ๅฎฝๅบฆ
AAPropSetFuncImplementation(AAChartModel, NSNumber *, xAxisTickInterval) //x่ฝดๅปๅบฆ็น้ด้ๆฐ(่ฎพ็ฝฎๆฏ้ๅ?ไธช็นๆพ็คบไธไธช X่ฝด็ๅๅฎน)

AAPropSetFuncImplementation(AAChartModel, NSNumber *, xAxisCrosshairWidth) 
AAPropSetFuncImplementation(AAChartModel, NSString *, xAxisCrosshairColor) 
AAPropSetFuncImplementation(AAChartModel, AALineDashStyleType,   xAxisCrosshairDashStyleType) 


AAPropSetFuncImplementation(AAChartModel, BOOL,       yAxisVisible) //y ่ฝดๆฏๅฆๅฏ่ง(้ป่ฎคๅฏ่ง)
AAPropSetFuncImplementation(AAChartModel, BOOL,       yAxisReversed) //y ่ฝด็ฟป่ฝฌ,้ป่ฎคไธบๅฆ

AAPropSetFuncImplementation(AAChartModel, BOOL,       yAxisLabelsEnabled) //y ่ฝดๆฏๅฆๆพ็คบๆๅญ
AAPropSetFuncImplementation(AAChartModel, NSNumber *, yAxisLabelsFontSize) //y ่ฝดๆๅญๅญไฝๅคงๅฐ
AAPropSetFuncImplementation(AAChartModel, NSString *, yAxisLabelsFontColor) //y ่ฝดๆๅญๅญไฝ้ข่ฒ
AAPropSetFuncImplementation(AAChartModel, NSString *, gridYLineColor) //y ่ฝดๅๅฒ็บฟ้ข่ฒ

AAPropSetFuncImplementation(AAChartModel, AAChartFontWeightType , yAxisLabelsFontWeight) //y ่ฝดๆๅญๅญไฝ็ฒ็ป
AAPropSetFuncImplementation(AAChartModel, NSString *, yAxisTitle) //y ่ฝดๆ?้ข
AAPropSetFuncImplementation(AAChartModel, NSNumber *, yAxisLineWidth) //y y-axis line width
AAPropSetFuncImplementation(AAChartModel, NSNumber *, yAxisGridLineWidth) //y่ฝด็ฝๆ?ผ็บฟ็ๅฎฝๅบฆ
AAPropSetFuncImplementation(AAChartModel, BOOL,       yAxisAllowDecimals) //ๆฏๅฆๅ่ฎธ y ่ฝดๆพ็คบๅฐๆฐ
AAPropSetFuncImplementation(AAChartModel, NSArray  *, yAxisPlotLines) //y ่ฝดๅบ็บฟ็้็ฝฎ
AAPropSetFuncImplementation(AAChartModel, NSNumber *, yAxisMax) //y ่ฝดๆๅคงๅผ
AAPropSetFuncImplementation(AAChartModel, NSNumber *, yAxisMin) //y ่ฝดๆๅฐๅผ๏ผ่ฎพ็ฝฎไธบ0ๅฐฑไธไผๆ่ดๆฐ๏ผ
AAPropSetFuncImplementation(AAChartModel, NSNumber *, yAxisTickInterval) 
AAPropSetFuncImplementation(AAChartModel, NSArray  *, yAxisTickPositions) //่ชๅฎไน y ่ฝดๅๆ?๏ผๅฆ๏ผ[@(0), @(25), @(50), @(75) , (100)]๏ผ

AAPropSetFuncImplementation(AAChartModel, NSNumber *, yAxisCrosshairWidth) 
AAPropSetFuncImplementation(AAChartModel, NSString *, yAxisCrosshairColor) 
AAPropSetFuncImplementation(AAChartModel, AALineDashStyleType,   yAxisCrosshairDashStyleType) 


AAPropSetFuncImplementation(AAChartModel, BOOL,       tooltipEnabled) //ๆฏๅฆๆพ็คบๆตฎๅจๆ็คบๆก(้ป่ฎคๆพ็คบ)
AAPropSetFuncImplementation(AAChartModel, BOOL,       tooltipShared)//ๆฏๅฆๅค็ปๆฐๆฎๅฑไบซไธไธชๆตฎๅจๆ็คบๆก
AAPropSetFuncImplementation(AAChartModel, NSString *, tooltipValueSuffix) //ๆตฎๅจๆ็คบๆกๅไฝๅ็ผ

AAPropSetFuncImplementation(AAChartModel, BOOL,       connectNulls) //่ฎพ็ฝฎๆ็บฟๆฏๅฆๆญ็น้่ฟ(ๆฏๅฆ่ฟๆฅ็ฉบๅผ็น)
AAPropSetFuncImplementation(AAChartModel, BOOL,       legendEnabled) //ๆฏๅฆๆพ็คบๅพไพ lengend(ๅพ่กจๅบ้จๅฏ็นๆ็ๅ็นๅๆๅญ)
AAPropSetFuncImplementation(AAChartModel, NSNumber *, borderRadius) //ๆฑ็ถๅพ้ฟๆกๅพๅคด้จๅ่งๅๅพ(ๅฏ็จไบ่ฎพ็ฝฎๅคด้จ็ๅฝข็ถ,ไปๅฏนๆกๅฝขๅพ,ๆฑ็ถๅพๆๆ)
AAPropSetFuncImplementation(AAChartModel, NSNumber *, markerRadius) //ๆ็บฟ่ฟๆฅ็น็ๅๅพ้ฟๅบฆ
AAPropSetFuncImplementation(AAChartModel, NSString *, zoomResetButtonText)  //String to display in 'zoom reset button"
AAPropSetFuncImplementation(AAChartModel, BOOL      , touchEventEnabled)

@end
