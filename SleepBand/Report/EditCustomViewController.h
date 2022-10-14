//
//  EditCustomViewController.h
//  SleepBand
//
//  Created by admin on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^editCustomBlock) (NSArray *customArray);

@interface EditCustomViewController : UIViewController

@property (copy,nonatomic)editCustomBlock editCustomBlock;

@end
