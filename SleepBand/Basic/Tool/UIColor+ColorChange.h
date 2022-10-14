//
//  UIColor+ColorChange.h
//  QLife
//
//  Created by admin on 2018/5/16.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorChange)
// 颜色转换：iOS中（以#开头）十六进制的颜色转换为UIColor(RGB)
+ (UIColor *) colorWithHexString: (NSString *)color;
@end
