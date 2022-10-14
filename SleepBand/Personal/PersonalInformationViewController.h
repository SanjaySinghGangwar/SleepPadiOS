//
//  PersonalInformationViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/13.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PersonalInformationNameBlock)(NSString *string);

@interface PersonalInformationViewController : UIViewController
@property (copy,nonatomic)PersonalInformationNameBlock personalInformationNameBlock;

@end
