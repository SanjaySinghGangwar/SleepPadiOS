//
//  ResetPasswordViewController.h
//  QLife
//
//  Created by admin on 2018/5/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ResetPasswordType){
    ResetPasswordType_Register,
    ResetPasswordType_ForgotPassword,
    ResetPasswordType_ChangePassword
};


@interface ResetPasswordViewController : UIViewController
@property (nonatomic,strong)NSDictionary *accountDict;
@property (nonatomic,assign)NSInteger resetPasswordType;
@end
