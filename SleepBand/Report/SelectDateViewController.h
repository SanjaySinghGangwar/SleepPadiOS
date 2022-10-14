//
//  SelectDateViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/23.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dateblock)(NSString *date);

@interface SelectDateViewController : UIViewController

@property (copy,nonatomic)NSDate *pushDate;
@property (copy,nonatomic)NSString *date;
@property (copy, nonatomic)dateblock dateBlock;

@end
