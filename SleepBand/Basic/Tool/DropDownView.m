//
//  DropDownView.m
//  QLife
//
//  Created by admin on 2018/5/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "DropDownView.h"

@interface DropDownView ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView * tableView;
@end

@implementation DropDownView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

-(void)setTabColor:(UIColor *)tabColor{
    _tabColor = tabColor;
    self.tableView.backgroundColor = tabColor;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initUI];
    }
    return self;
}


-(void)initUI{
    
    UITableView * tableView = [UITableView new];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.frame = self.bounds;
    [self addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    tableView.rowHeight = 30;
    tableView.bounces = NO;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"fmenualert"];
    
}

-(void)setArrMDataSource:(NSMutableArray *)arrMDataSource{
    _arrMDataSource = arrMDataSource;
    [_tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.didSelectedCallback) {
        self.didSelectedCallback(indexPath.row, _arrMDataSource[indexPath.row]);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrMDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fmenualert" forIndexPath:indexPath];
    cell.textLabel.text = _arrMDataSource[indexPath.row];
    cell.textLabel.textColor = _txtColor ? _txtColor : [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.contentView.backgroundColor = self.tabColor;
    cell.textLabel.backgroundColor = self.tabColor;
    cell.textLabel.font = _cusFont ? _cusFont : [UIFont systemFontOfSize:15];
    return cell;
}

// 以下适配iOS11+
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}


@end
