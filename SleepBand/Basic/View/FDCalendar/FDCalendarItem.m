//
//  FDCalendarItem.m
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "FDCalendarItem.h"

@interface FDCalendarCell : UICollectionViewCell

- (UILabel *)dayLabel;
- (UILabel *)chineseDayLabel;

@end

@implementation FDCalendarCell {
    UILabel *_dayLabel;
    UILabel *_chineseDayLabel;
}

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.font = [UIFont systemFontOfSize:15];
        _dayLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 3);
        [self addSubview:_dayLabel];
    }
    return _dayLabel;
}

- (UILabel *)chineseDayLabel {
    if (!_chineseDayLabel) {
        _chineseDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
        _chineseDayLabel.textAlignment = NSTextAlignmentCenter;
        _chineseDayLabel.font = [UIFont boldSystemFontOfSize:9];
        
        CGPoint point = _dayLabel.center;
        point.y += 15;
        _chineseDayLabel.center = point;
        [self addSubview:_chineseDayLabel];
    }
    return _chineseDayLabel;
}

@end

#define CollectionViewHorizonMargin 5
#define CollectionViewVerticalMargin 5

typedef NS_ENUM(NSUInteger, FDCalendarMonth) {
    FDCalendarMonthPrevious = 0,
    FDCalendarMonthCurrent = 1,
    FDCalendarMonthNext = 2,
};

@interface FDCalendarItem () <UICollectionViewDataSource, UICollectionViewDelegate>



@end

@implementation FDCalendarItem

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupCollectionView];
        [self setFrame:CGRectMake(0, 0, DeviceWidth, self.collectionView.frame.size.height + CollectionViewVerticalMargin * 2)];
    }
    return self;
}

#pragma mark - Custom Accessors

- (void)setDate:(NSDate *)date {
    _date = date;
    [self.collectionView reloadData];
}

#pragma mark - Public 

// 获取date的下个月日期
- (NSDate *)nextMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    NSDate *nextMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    return nextMonthDate;
}

// 获取date的上个月日期
- (NSDate *)previousMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *newPreviousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    return newPreviousMonthDate;
}

#pragma mark - Private

// collectionView显示日期单元，设置其属性
- (void)setupCollectionView {
    CGFloat itemWidth = (DeviceWidth - CollectionViewHorizonMargin * 2) / 7;
    CGFloat itemHeight = itemWidth;
    
    UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
    flowLayot.sectionInset = UIEdgeInsetsZero;
    flowLayot.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayot.minimumLineSpacing = 0;
    flowLayot.minimumInteritemSpacing = 0;
    
    CGRect collectionViewFrame = CGRectMake(CollectionViewHorizonMargin, CollectionViewVerticalMargin, DeviceWidth - CollectionViewHorizonMargin * 2, itemHeight * 6);
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayot];
    [self addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[FDCalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
}

// 获取date当前月的第一天是星期几
- (NSInteger)weekdayOfFirstDayInDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstDate];
    return firstComponents.weekday - 1;
}

// 获取date当前月的总天数
- (NSInteger)totalDaysInMonthOfDate:(NSDate *)date {
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

// 获取某月day的日期
- (NSDate *)dateOfMonth:(FDCalendarMonth)calendarMonth WithDay:(NSInteger)day {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date;
    
    switch (calendarMonth) {
        case FDCalendarMonthPrevious:
            date = [self previousMonthDate];
            break;
            
        case FDCalendarMonthCurrent:
            date = self.date;
            break;
            
        case FDCalendarMonthNext:
            date = [self nextMonthDate];
            break;
        default:
            break;
    }
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [components setDay:day];
    NSDate *dateOfDay = [calendar dateFromComponents:components];
    return dateOfDay;
}


#pragma mark - UICollectionDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CalendarCell";
    FDCalendarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.dayLabel.textColor = [UIColor blackColor];
    cell.chineseDayLabel.textColor = [UIColor blackColor];
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];
    
    NSInteger totalDaysOfLastMonth = [self totalDaysInMonthOfDate:[self previousMonthDate]];
    
    if (indexPath.row < firstWeekday) {    // 小于这个月的第一天
        NSInteger day = totalDaysOfLastMonth - firstWeekday + indexPath.row + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%zd", day];
        cell.dayLabel.textColor = [UIColor colorWithHexString:@"#c1c1c1"];
    } else if (indexPath.row >= totalDaysOfMonth + firstWeekday) {    // 大于这个月的最后一天
        NSInteger day = indexPath.row - totalDaysOfMonth - firstWeekday + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%zd", day];
        cell.dayLabel.textColor = [UIColor colorWithHexString:@"#c1c1c1"];
    } else {    // 属于这个月
        NSInteger day = indexPath.row - firstWeekday + 1;
        cell.dayLabel.text= [NSString stringWithFormat:@"%zd", day];
        int dayDate = [[[[[NSString stringWithFormat:@"%@",self.date] substringWithRange:NSMakeRange(0, 10)]stringByReplacingOccurrencesOfString:@"-" withString:@""] substringWithRange:NSMakeRange(6, 2)] intValue];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *selectDateStr = [format stringFromDate:self.selectDate];
        NSString *selectMonthDate = [selectDateStr substringWithRange:NSMakeRange(0, 7)];
        NSString *lastMonthDateStr = [[NSString stringWithFormat:@"%@",self.date] substringWithRange:NSMakeRange(0, 7)];
        if (day == dayDate){
            if([selectMonthDate isEqualToString: lastMonthDateStr]) {
                cell.backgroundColor = [UIColor blackColor];
                cell.layer.cornerRadius = cell.frame.size.height / 2;
                cell.dayLabel.textColor = [UIColor whiteColor];
//                cell.dayLabel.textColor = [UIColor colorWithHexString:@"#666666"];
                cell.chineseDayLabel.textColor = [UIColor blackColor];
            }
        }
        
        NSInteger currentDate = [[[format stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(8, 2)] integerValue];
        NSString *currentMonthDate = [[format stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, 7)];
        NSString *lastMonthStr = [[format stringFromDate:self.date] substringWithRange:NSMakeRange(0, 7)];
        if (day == currentDate && [lastMonthStr isEqualToString:currentMonthDate]) {
            cell.dayLabel.textColor = [UIColor redColor];
        }
        
        // 如果日期和当期日期同年同月不同天, 注：第一个判断中的方法是iOS8的新API, 会比较传入单元以及比传入单元大得单元上数据是否相等，亲测同时传入Year和Month结果错误
        //        if ([[NSCalendar currentCalendar] isDate:[NSDate date] equalToDate:self.date toUnitGranularity:NSCalendarUnitMonth] && ![[NSCalendar currentCalendar] isDateInToday:self.date]) {
        //
        //            // 将当前日期的那天高亮显示
        //            if (day == [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:[NSDate date]]) {
        //                cell.dayLabel.textColor = [UIColor redColor];
        //            }
        //
        //        }
    }
    
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    [components setDay:indexPath.row - firstWeekday +1];
    NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setDay:1];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *datenow = [calendar dateByAddingComponents:adcomps toDate:selectedDate options:0];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSString *selectString = [NSString stringWithFormat:@"%@",[currentTimeString substringWithRange:NSMakeRange(0, 10)]];
    NSDate *newDate =  [formatter dateFromString:selectString];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarItem:didSelectedDate:)]) {
        [self.delegate calendarItem:self didSelectedDate:newDate];
        self.selectDate = newDate ;
        self.selectedDateBlock([[NSString stringWithFormat:@"%@",newDate] substringWithRange:NSMakeRange(0, 10)]);
    }
}

@end
