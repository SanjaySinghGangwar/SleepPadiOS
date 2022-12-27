//
//  JournalVC.h
//  SleepBand
//
//  Created by Mac on 27/12/22.
//  Copyright © 2022 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCircularProgressBarView.h"


NS_ASSUME_NONNULL_BEGIN

@interface JournalVC : UIViewController

@property (strong,nonatomic) MBCircularProgressBarView *progressBar;
@property (strong,nonatomic) UIView *cellViewContainer;

@end

NS_ASSUME_NONNULL_END
