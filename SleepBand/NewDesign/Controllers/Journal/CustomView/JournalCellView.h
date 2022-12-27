//
//  JournalCellView.h
//  SleepBand
//
//  Created by Mac on 27/12/22.
//  Copyright © 2022 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JournalCellView : UIView

@property (nonatomic, strong) NSString * iconStr;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * time;
@property (nonatomic, assign) NSInteger index;

- (instancetype)initWithIconStr:(NSString*)iconStr
                          title:(NSString*)title
                           time:(NSString*)time
                          index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
