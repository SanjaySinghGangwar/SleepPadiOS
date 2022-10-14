//
//  LeftView.h
//  SleepBand
//
//  Created by admin on 2019/2/12.
//  Copyright © 2019年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LeftMenuType){
    
    LeftMenuType_Sleep,//睡眠
    LeftMenuType_Report,//报告
    LeftMenuType_Clock,//时钟
    LeftMenuType_Me //我
};

typedef void(^SelectControllerBlock)(LeftMenuType type);

@interface LeftView : UIView

@property (strong,nonatomic)UIView *menuView;
@property (assign,nonatomic)BOOL leftMenuBool;
@property (copy,nonatomic)SelectControllerBlock selectControllerBlock;
-(void)showView;
-(void)hiddenView;

@end


