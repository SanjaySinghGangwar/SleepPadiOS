//
//  FDCalendar.m
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "FDCalendar.h"
#import "FDCalendarItem.h"

#define Weekdays @[@"ACMVC_Sunday",@"ACMVC_Monday",@"ACMVC_Tuesday",@"ACMVC_Wednesday",@"ACMVC_Thursday",@"ACMVC_Friday",@"ACMVC_Saturday"]

//static NSDateFormatter *dateFormattor;

@interface FDCalendar () <UIScrollViewDelegate, FDCalendarItemDelegate>
@property (strong, nonatomic) NSDate *selectDate;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIButton *titleButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) FDCalendarItem *leftCalendarItem;
@property (strong, nonatomic) FDCalendarItem *centerCalendarItem;
@property (strong, nonatomic) FDCalendarItem *rightCalendarItem;
@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSTimeZone *zone;

@end

@implementation FDCalendar

- (instancetype)initWithCurrentDate:(NSDate *)date {
    if (self = [super init]) {
        //        self.backgroundColor = [UIColor colorWithRed:236 / 255.0 green:236 / 255.0 blue:236 / 255.0 alpha:1.0];
        self.date = date;
        self.selectDate = date;
        [self setupTitleBar];
        [self setupWeekHeader];
        [self setupCalendarItems];
        [self setupScrollView];
        [self setFrame:CGRectMake(0, 0, DeviceWidth, CGRectGetMaxY(self.scrollView.frame))];
        self.dateFormatter = [[NSDateFormatter alloc]init];
        self.zone = [NSTimeZone systemTimeZone];
        self.dateFormatter.dateFormat=@"yyyy-MM-dd";
        [self.dateFormatter setTimeZone:self.zone];
        [self setCurrentDate:self.date];
    }
    return self;
}

#pragma mark - Custom Accessors

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame: self.bounds];
        _backgroundView.backgroundColor = [UIColor lightGrayColor];
        _backgroundView.alpha = 0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDatePickerView)];
        [_backgroundView addGestureRecognizer:tapGesture];
    }
    
    [self addSubview:_backgroundView];
    return _backgroundView;
}

- (UIView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kSCREEN_WIDTH, 0)];
        _datePickerView.backgroundColor = [UIColor whiteColor];
        _datePickerView.clipsToBounds = YES;
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 70, 20)];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelSelectCurrentDate) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerView addSubview:cancelButton];
        
        UIButton *okButton = [[UIButton alloc] init];
        okButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        if (NSLocalizedString(@"Submit", nil).length == 6) {
            okButton.frame = CGRectMake(kSCREEN_WIDTH - 105, 10, 90, 20);
        }else{
            okButton.frame = CGRectMake(kSCREEN_WIDTH - 85, 10, 70, 20);
        }
        [okButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
        okButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(selectCurrentDate) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerView addSubview:okButton];
        [_datePickerView addSubview:self.datePicker];
    }
    [self addSubview:_datePickerView];
    
    return _datePickerView;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 32, kSCREEN_WIDTH, 250)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        //        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"Chinese"];
    }
    
    return _datePicker;
}

#pragma mark - Private

- (NSString *)stringFromDate:(NSDate *)date {
    return [[NSString stringWithFormat:@"%@",date] substringWithRange:NSMakeRange(0, 7)];
}

// 设置上层的titleBar
- (void)setupTitleBar {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    [self addSubview:titleView];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 6, 40, 32)];
    [leftButton setImage:[UIImage imageNamed:@"signup_icon_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(setPreviousMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:leftButton];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(titleView.frame.size.width - 41, 0, 26, 44)];
    [rightButton setImage:[UIImage imageNamed:@"me_arrow_right"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(setNextMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:rightButton];
    
    UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleButton.titleLabel.textColor = [UIColor blackColor];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleButton.center = titleView.center;
    [titleButton addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:titleButton];
    
    self.titleButton = titleButton;
}

// 设置星期文字的显示
- (void)setupWeekHeader {
    NSInteger count = [Weekdays count];
    CGFloat offsetX = 5;
    for (int i = 0; i < count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 50, (DeviceWidth - 10) / count, 20)];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.text = NSLocalizedString(Weekdays[i], nil);
        weekdayLabel.font = [UIFont systemFontOfSize:15];
        //        if (i == 0 || i == count - 1) {
                    weekdayLabel.textColor = [UIColor redColor];
        //        } else {
//        weekdayLabel.textColor = [UIColor whiteColor];
        //        }
        
        [self addSubview:weekdayLabel];
        offsetX += weekdayLabel.frame.size.width;
    }
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 74, DeviceWidth - 30, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:lineView];
}

// 设置包含日历的item的scrollView
- (void)setupScrollView {
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView setFrame:CGRectMake(0, 75, DeviceWidth, self.centerCalendarItem.frame.size.height)];
    self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    [self addSubview:self.scrollView];
    
}

// 设置3个日历的item
- (void)setupCalendarItems {
    __weak FDCalendar *fd = self;
    self.scrollView = [[UIScrollView alloc] init];
    
    self.leftCalendarItem = [[FDCalendarItem alloc] init];
    self.leftCalendarItem.selectDate = self.selectDate;
    self.leftCalendarItem.selectedDateBlock = ^(NSString *date){
        NSDate *selectDate = [fd.dateFormatter dateFromString:date];
        NSInteger interval = [fd.zone secondsFromGMTForDate:selectDate];
        fd.selectDate = [selectDate  dateByAddingTimeInterval:interval];
        fd.selectedDateBlock(date);
    };
    [self.scrollView addSubview:self.leftCalendarItem];
    
    CGRect itemFrame = self.leftCalendarItem.frame;
    
    itemFrame.origin.x = DeviceWidth;
    self.centerCalendarItem = [[FDCalendarItem alloc] init];
    self.centerCalendarItem.selectDate = self.selectDate;
    self.centerCalendarItem.selectedDateBlock = ^(NSString *date){
        NSDate *selectDate = [fd.dateFormatter dateFromString:date];
        NSInteger interval = [fd.zone secondsFromGMTForDate:selectDate];
        fd.selectDate = [selectDate  dateByAddingTimeInterval:interval];
        fd.selectedDateBlock(date);
    };
    self.centerCalendarItem.frame = itemFrame;
    self.centerCalendarItem.delegate = self;
    [self.scrollView addSubview:self.centerCalendarItem];
    
    itemFrame.origin.x = DeviceWidth * 2;
    self.rightCalendarItem = [[FDCalendarItem alloc] init];
    self.rightCalendarItem.selectDate = self.selectDate;
    self.rightCalendarItem.selectedDateBlock = ^(NSString *date){
        NSDate *selectDate = [fd.dateFormatter dateFromString:date];
        NSInteger interval = [fd.zone secondsFromGMTForDate:selectDate];
        fd.selectDate = [selectDate  dateByAddingTimeInterval:interval];
        fd.selectedDateBlock(date);
    };
    self.rightCalendarItem.frame = itemFrame;
    [self.scrollView addSubview:self.rightCalendarItem];
    
}

// 设置当前日期，初始化
- (void)setCurrentDate:(NSDate *)date {
    
    //    NSInteger interval = [self.zone secondsFromGMTForDate:date];
    //    self.selectDate = [date  dateByAddingTimeInterval:interval];
    
    self.centerCalendarItem.date = date;
    //    self.centerCalendarItem.selectDate = self.selectDate;
    //    [self.centerCalendarItem.collectionView reloadData];
    
    self.leftCalendarItem.date = [self.centerCalendarItem previousMonthDate];
    //    self.leftCalendarItem.selectDate = self.selectDate;
    //    [self.leftCalendarItem.collectionView reloadData];
    
    self.rightCalendarItem.date = [self.centerCalendarItem nextMonthDate];
    //    self.rightCalendarItem.selectDate = self.selectDate;
    //    [self.rightCalendarItem.collectionView reloadData];
    
    [self.titleButton setTitle:[self stringFromDate:self.centerCalendarItem.date] forState:UIControlStateNormal];
}

// 重新加载日历items的数据
- (void)reloadCalendarItems {
    CGPoint offset = self.scrollView.contentOffset;
    
    if (offset.x > self.scrollView.frame.size.width) {
        [self setNextMonthDate];
    } else {
        [self setPreviousMonthDate];
    }
    
}

- (void)showDatePickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0.4;
        self.datePickerView.frame = CGRectMake(0, 44, kSCREEN_WIDTH, 250);
    }];
    
}

- (void)hideDatePickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0;
        self.datePickerView.frame = CGRectMake(0, 44, kSCREEN_WIDTH, 0);
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self.datePickerView removeFromSuperview];
    }];
    
}

#pragma mark - SEL

// 跳到上一个月
- (void)setPreviousMonthDate {
    [self setCurrentDate:[self.centerCalendarItem previousMonthDate]];
    
}

// 跳到下一个月
- (void)setNextMonthDate {
    [self setCurrentDate:[self.centerCalendarItem nextMonthDate]];
    
}

- (void)showDatePicker {
    //    [self.datePicker setDate:self.selectDate];
    [self showDatePickerView];
    
}

// 选择当前日期
- (void)selectCurrentDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
//    [adcomps setDay:1];
    NSDate *date = [UIFactory NSDateForUTC:[calendar dateByAddingComponents:adcomps toDate:self.datePicker.date options:0]];
    self.date = date;
    self.selectDate = date;
    self.centerCalendarItem.selectDate = self.selectDate;
    self.leftCalendarItem.selectDate = self.selectDate;
    self.rightCalendarItem.selectDate = self.selectDate;
    [self setCurrentDate:self.date];
    //    self.selectedDateBlock([[NSString stringWithFormat:@"%@",[calendar dateByAddingComponents:adcomps toDate:self.datePicker.date options:1]] substringWithRange:NSMakeRange(0, 10)]);
    self.selectedDateBlock([UIFactory dateForString:date]);
    [self hideDatePickerView];
    
}

- (void)cancelSelectCurrentDate {
    [self hideDatePickerView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadCalendarItems];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
}

#pragma mark - FDCalendarItemDelegate

- (void)calendarItem:(FDCalendarItem *)item didSelectedDate:(NSDate *)date {
    self.date = date;
    [self setCurrentDate:self.date];
}

@end
