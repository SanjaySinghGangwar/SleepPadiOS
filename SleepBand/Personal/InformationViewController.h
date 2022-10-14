//
//  InformationViewController.h
//  SleepBand
//
//  Created by admin on 2018/12/12.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InformationViewController : UIViewController
@property (copy,nonatomic)NSString *navTitleStr;
@property (copy,nonatomic)NSString *titleStr;
@property (copy,nonatomic)NSString *valueStr;
@property (assign,nonatomic)BOOL isOperationGuide;
@property (assign,nonatomic)BOOL isFeedback;
@end

NS_ASSUME_NONNULL_END
