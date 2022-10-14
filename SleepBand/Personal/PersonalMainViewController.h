//
//  PersonalMainViewController.h
//  SleepBand
//
//  Created by admin on 2018/7/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PersonalType) {
    PersonalType_SynchronousData,
    PersonalType_MyDevice,
    PersonalType_Account,
    PersonalType_PersonalInformation,
    PersonalType_Help,
    PersonalType_SleepAdvice,
    PersonalType_Feedback,
    PersonalType_About
};


@interface PersonalMainViewController : UIViewController

@end
