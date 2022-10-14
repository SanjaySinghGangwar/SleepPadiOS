//
//  FDCalendar.h
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^block)(NSString *date);

@interface FDCalendar : UIView
@property (copy, nonatomic) block selectedDateBlock;
@property (strong, nonatomic) UIView *datePickerView;
@property (strong, nonatomic) UIDatePicker *datePicker;

- (instancetype)initWithCurrentDate:(NSDate *)date;
- (void)setCurrentDate:(NSDate *)date;
@end
