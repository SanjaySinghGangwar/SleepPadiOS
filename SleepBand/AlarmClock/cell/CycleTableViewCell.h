//
//  CycleTableViewCell.h
//  SleepBand
//
//  Created by admin on 2018/7/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^repeatBlock)(NSString *value);

@interface CycleTableViewCell : UITableViewCell
@property (strong,nonatomic) UILabel *titleLabel;
@property (copy,nonatomic) repeatBlock repeatBlock;
@property (strong,nonatomic) NSArray *titleArray;
-(void)setRepeat:(NSArray *)array;  //设置重复
@end
