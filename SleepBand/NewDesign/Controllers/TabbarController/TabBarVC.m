//
//  TabBarVC.m
//  SleepBand
//
//  Created by Mac on 27/12/22.
//  Copyright © 2022 admin. All rights reserved.
//

#import "TabBarVC.h"

@interface TabBarVC()

@end

@implementation TabBarVC
@synthesize normalImages, selectedImages, tabBarView, homeVC, homeNVC, journalVC, journalNVC, dashboardVC, dashboardNVC, settingsVC, settingsNVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildControllers];

}

#pragma mark -

- (void)setupChildControllers
{
    WS(weakSelf);
    
    NSArray *titleArray = @[NSLocalizedString(@"HTVC_Title", nil),NSLocalizedString(@"JTVC_Title", nil),NSLocalizedString(@"DTVC_Title", nil),NSLocalizedString(@"STVC_Title", nil)];
    self.normalImages = @[@"t1",@"t2",@"t3",@"t4"];
    self.selectedImages = @[@"t1",@"t2",@"t3",@"t4",];
    
    homeVC = [[HomeVC alloc] init];
    homeNVC = [[UINavigationController alloc] initWithRootViewController: homeVC];
    homeNVC.view.backgroundColor = [UIColor whiteColor];
    homeNVC.tabBarItem.title = NSLocalizedString(@"HTVC_Title", nil);
    homeNVC.tabBarItem.image = [UIImage imageNamed:@"tab_buddy_nor"];
    homeNVC.navigationBar.hidden = YES;
    
    journalVC = [[JournalVC alloc] init];
    journalNVC = [[UINavigationController alloc] initWithRootViewController: journalVC];
    journalNVC.view.backgroundColor = [UIColor whiteColor];
    journalNVC.tabBarItem.title = NSLocalizedString(@"JTVC_Title", nil);
    journalNVC.tabBarItem.image = [UIImage imageNamed:@"tab_buddy_nor"];
    
    dashboardVC = [[DashboardVC alloc] init];
    dashboardNVC = [[UINavigationController alloc] initWithRootViewController: dashboardVC];
    dashboardNVC.view.backgroundColor = [UIColor whiteColor];
    dashboardNVC.tabBarItem.title = NSLocalizedString(@"DTVC_Title", nil);
    dashboardNVC.tabBarItem.image = [UIImage imageNamed:@"tab_buddy_nor"];
    
    settingsVC = [[SettingsVC alloc] init];
    settingsNVC = [[UINavigationController alloc] initWithRootViewController: settingsVC];
    settingsNVC.view.backgroundColor = [UIColor whiteColor];
    settingsNVC.tabBarItem.title = NSLocalizedString(@"STVC_Title", nil);
    settingsNVC.tabBarItem.image = [UIImage imageNamed:@"tab_buddy_nor"];

    self.viewControllers = @[homeNVC, journalNVC, dashboardNVC, settingsNVC];
    
    
    tabBarView = [[UIView alloc] init];
    tabBarView.backgroundColor = [UIColor colorWithHexString:@"#7000A1"];
    [self.view addSubview: tabBarView];
    [tabBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(weakSelf.view);
        make.height.equalTo(@(kTabbarHeight+kTabbarSafeHeight));
        
    }];
    
    for(int i = 0; i < titleArray.count; i++) {
        UIView *item = [[UIView alloc] init];
        item.tag = 10000 + i;
        [tabBarView addSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.tabBarView);
            make.width.equalTo(@(kSCREEN_WIDTH/titleArray.count));
            make.left.mas_equalTo(weakSelf.tabBarView.mas_left).offset(i*(kSCREEN_WIDTH/4));
            make.height.equalTo(@49);

        }];

        [item addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget: self action: @selector(click:)]];

        UIImageView *icon = [[UIImageView alloc] init];
        icon.tag = 20000 + i;
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.image = [UIImage imageNamed: normalImages[i]];
        [item addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@3);
            make.centerX.equalTo(item);
            make.width.equalTo(@20);
            make.height.equalTo(@20);

        }];

        UILabel *title = [[UILabel alloc]init];
        title.tag = 30000 + i;
        title.text = [titleArray[i] uppercaseString];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:12];
        [item addSubview: title];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(icon.mas_bottom).offset(0);
            make.left.right.equalTo(item);
        }];
        
        UIView *indicator = [[UIView alloc] init];
        indicator.tag = 40000 + i;
        [item addSubview: indicator];
        [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(title.mas_bottom).offset(1);
            make.left.right.bottom.equalTo(item);
            make.height.equalTo(@4);

        }];
        
        if (i == 1) {
            [self manageTabItemSelection: YES for: i];
        } else {
            [self manageTabItemSelection: NO for: i];
        }
    }
}

//TabBar
- (void)click: (UITapGestureRecognizer *)sender {
    NSInteger tag = sender.view.tag - 10000;
    
    if (tag != self.index) {
        [self manageTabItemSelection: NO for: self.index];
        [self manageTabItemSelection: YES for: tag];
    }
}

-(void)manageTabItemSelection:(BOOL)isSelected for:(NSInteger)tag {
    UIImageView *iconSelect = (UIImageView *)[self.view viewWithTag: tag + 20000];
    UILabel *titleSelect = (UILabel *)[self.view viewWithTag: tag + 30000];
    UIView *indicator = (UIView *)[self.view viewWithTag: tag + 40000];

    UIColor *color = [UIColor whiteColor];
    
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        iconSelect.tintColor = color;
        titleSelect.textColor = color;
        
        if (isSelected) {
            iconSelect.image = [UIImage imageNamed: weakSelf.selectedImages[tag]];
            indicator.backgroundColor = color;
            
            weakSelf.index = tag;
            weakSelf.selectedIndex = weakSelf.index;
        } else {
            iconSelect.image = [UIImage imageNamed: weakSelf.normalImages[tag]];
            indicator.backgroundColor = [UIColor clearColor];
        }
    });
    
    
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
