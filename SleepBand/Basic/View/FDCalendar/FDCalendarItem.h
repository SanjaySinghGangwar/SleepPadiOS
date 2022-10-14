//
//  FDCalendarItem.h
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DeviceWidth [UIScreen mainScreen].bounds.size.width

@protocol FDCalendarItemDelegate;
typedef void(^block)(NSString *selectedDate);
@interface FDCalendarItem : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSDate *selectDate;
@property (strong, nonatomic) NSDate *date;
@property (weak, nonatomic) id<FDCalendarItemDelegate> delegate;
@property (copy, nonatomic) block selectedDateBlock;
- (NSDate *)nextMonthDate;
- (NSDate *)previousMonthDate;

@end

@protocol FDCalendarItemDelegate <NSObject>

- (void)calendarItem:(FDCalendarItem *)item didSelectedDate:(NSDate *)date;

@end
