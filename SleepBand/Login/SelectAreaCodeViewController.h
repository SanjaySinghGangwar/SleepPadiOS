//
//  SelectAreaCodeViewController.h
//  QLife
//
//  Created by admin on 2018/5/28.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectAreaCodeBlock)(NSString *area,NSString *language,NSString *code);

@interface SelectAreaCodeViewController : UIViewController
@property (copy,nonatomic)selectAreaCodeBlock selectAreaCodeBlock;
@property (assign,nonatomic)BOOL isPersonal;
@end
