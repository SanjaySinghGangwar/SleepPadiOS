//
//  JournalVC.m
//  SleepBand
//
//  Created by Mac on 27/12/22.
//  Copyright © 2022 admin. All rights reserved.
//

#import "JournalVC.h"

@interface JournalVC ()

@property (nonatomic, strong) NSArray<JournalCellView *> * progressArr;

@end

@implementation JournalVC
@synthesize progressBar, cellViewContainer;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialConfiguration];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}


-(void)initialConfiguration {
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"#120B29"]];
    [self configureProgressBar];
    [self drawJournalVCellViews];
}

-(void)configureProgressBar {
    WS(weakSelf);
    progressBar = [[MBCircularProgressBarView alloc] init];
    progressBar.backgroundColor = [UIColor clearColor];
    
    progressBar.fontColor = [UIColor whiteColor];
    progressBar.valueFontName = @"HelveticaNeue-Medium";
    
    progressBar.showUnitString = NO;
    progressBar.unitString = @"";

    progressBar.emptyLineColor = [UIColor whiteColor];
    progressBar.emptyLineStrokeColor = [UIColor whiteColor];
    progressBar.emptyLineWidth = 10;
    
    progressBar.progressColor = [UIColor colorWithHexString:@"#7000A1"];
    progressBar.progressStrokeColor = [UIColor colorWithHexString:@"#7000A1"];
    progressBar.progressLineWidth = 10;
    progressBar.progressAngle = 100;
    progressBar.progressRotationAngle = 49;
    progressBar.progressCapType = kCGLineCapRound;
    
    progressBar.valueFontSize = 60;
    progressBar.maxValue = 100;
    progressBar.value = 1;
    
    [self.view addSubview: progressBar];
    [progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.centerY.equalTo(weakSelf.view).offset(-60);
        make.width.height.equalTo(@(kSCREEN_WIDTH*0.64103));
    }];
}

- (void)drawJournalVCellViews {
    WS(weakSelf);

    NSArray *titleArray = @[NSLocalizedString(@"JVC_InBed", nil),
                            NSLocalizedString(@"JVC_Awake", nil),
                            NSLocalizedString(@"JVC_HeartRate", nil),
                            NSLocalizedString(@"JVC_RespirationRate", nil)];
    NSArray *iconArray  =  @[@"report_icon_deep",@"report_icon_wakeup",
                             @"report_icon_heartrate",@"report_icon_breath"];
    
    NSMutableArray * progressCellViewsArr = [NSMutableArray array];
    
   
    cellViewContainer = [[UIView alloc] init];
    cellViewContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cellViewContainer];
    [cellViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottomMargin).offset(-24);
        make.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@140);
    }];
    
    for (int i = 0; i < titleArray.count; i++) {
        JournalCellView * progressCellView = [[JournalCellView alloc]initWithIconStr:iconArray[i] title:titleArray[i] time:@"0" index:i];
        [cellViewContainer addSubview:progressCellView];
        [progressCellViewsArr addObject:progressCellView];
    }
    
    self.progressArr = [NSArray arrayWithArray:progressCellViewsArr];
    [self layoutCellViews];

}

- (void)layoutCellViews {
    WS(weakSelf);
    
    __block CGFloat spaceWidth = 18;
    __block CGFloat spaceheight = 22;
    __block CGFloat width = (kSCREEN_WIDTH - 52)/2;
    __block CGFloat height = 48;
    __block NSInteger i = 0;
    __block NSInteger j = 0;
    
    for (JournalCellView * progressCellView in self.progressArr) {
        i = progressCellView.index;
        j = i < 2 ? 0 : 1;
        i = i < 2 ? i : (i-2);
        [progressCellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.cellViewContainer.mas_top).offset((spaceheight + height)*j);
            make.left.mas_equalTo(weakSelf.cellViewContainer.mas_left).offset(16+i*(width+spaceWidth));
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
