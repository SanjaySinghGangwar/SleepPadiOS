//
//  BoundViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BindBlock)(BOOL isPhone,BOOL isBound,NSString *account);

@interface BoundViewController : UIViewController
@property (assign,nonatomic)BOOL isPhone;
@property (assign,nonatomic)BOOL isBound; //是否绑定
@property (copy,nonatomic)BindBlock bindBlock; 
@end
