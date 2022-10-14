//
//  AlarmClockModel.m
//  SleepBand
//
//  Created by admin on 2018/7/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AlarmClockModel.h"
//@class AppDelegate;
#import "AppDelegate.h"

@implementation AlarmClockModel

#pragma mark - 实现NSCoding的代理方法

/**
 *  归档
 *
 *  @param aCoder
 */
//@property (nonatomic,assign) int clockId;
//@property (nonatomic,assign) int hour;
//@property (nonatomic,assign) int minute;
//@property (nonatomic,assign) BOOL isPhone;
//@property (nonatomic,copy) NSString *remark;  //标签
//@property (nonatomic,strong) NSArray *repeat;
//@property (nonatomic,strong) NSString * repeatStr;
//@property (nonatomic,assign) BOOL isOn;  //是否开启
//@property (nonatomic,copy)   NSString *music;  //音乐
//@property (nonatomic,assign) BOOL isIntelligentWake;  //智能唤醒
//@property (nonatomic,assign) int type;  //闹钟类型
//@property (nonatomic,assign) int index;  //设备闹钟下标
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSNumber numberWithInt:self.clockId] forKey:@"clockId"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.hour] forKey:@"hour"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.minute] forKey:@"minute"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isPhone] forKey:@"isPhone"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isIntelligentWake] forKey:@"isIntelligentWake"];
    [aCoder encodeObject:self.repeat forKey:@"repeat"];
    
    [aCoder encodeObject:self.clockTitle forKey:@"clockTitle"];
    [aCoder encodeObject:self.clockTimer forKey:@"clockTimer"];
    [aCoder encodeObject:self.clockDescribe forKey:@"clockDescribe"];
    [aCoder encodeObject:self.clockMusic forKey:@"clockMusic"];
}

/**
 *  解归档
 *
 *  @param aDecoder
 *
 *  @return
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self == [super init]) {
        self.clockId = [[aDecoder decodeObjectForKey:@"clockId"] intValue];
        self.hour = [[aDecoder decodeObjectForKey:@"hour"] intValue];
        self.minute = [[aDecoder decodeObjectForKey:@"minute"] intValue];
        self.isPhone = [[aDecoder decodeObjectForKey:@"isPhone"] boolValue];
        self.isIntelligentWake = [[aDecoder decodeObjectForKey:@"isIntelligentWake"] boolValue];
        self.repeat = [aDecoder decodeObjectForKey:@"repeat"];
        
        self.clockTitle = [aDecoder decodeObjectForKey:@"clockTitle"];
        self.clockTimer = [aDecoder decodeObjectForKey:@"clockTimer"];
        self.clockDescribe = [aDecoder decodeObjectForKey:@"clockDescribe"];
        self.clockMusic = [aDecoder decodeObjectForKey:@"clockMusic"];
    }
    return self;
}

/**
 *  存储闹钟事件
 *
 *  @param clockModel 传入对象
 */
+ (void)SaveAlarmClockWithModel:(AlarmClockModel*)clockModel{
    //存储的话，这边就是归档到本地文件中
    [NSKeyedArchiver archiveRootObject:clockModel toFile:[NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],clockModel.clockTimer]];
    //这边添加一个闹钟的时候需要动态的给闹钟工具类中的数组进行赋值
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!delegate.alarmClockTool) {
        delegate.alarmClockTool = [AlarmClockTool sharedAlarmClockTool];
    }
    //对于单例的闹钟工具进行赋值
    delegate.alarmClockTool.alarmClockArray = [AlarmClockModel GetAllAlarmClockEvent];
}
/**
 *  移除闹钟事件
 *
 *  @param timer 事件值类型为 .h定义的  dateformater
 */
+ (void)RemoveAlarmClockWithTimer:(NSString *)timer{
    //文件路径
    NSString * path = [NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],timer];
    //判断文件是否存在 存在将文件删除
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
        if ([AlarmClockModel GetAllAlarmClockEvent].count > 0) {
            if (!delegate.alarmClockTool) {
                delegate.alarmClockTool = [AlarmClockTool sharedAlarmClockTool];
            }
            //对于单例的闹钟工具进行赋值
            delegate.alarmClockTool.alarmClockArray = [AlarmClockModel GetAllAlarmClockEvent];
        }else{
            //将appleDelegate的对象释放掉
            delegate.alarmClockTool.alarmClockArray = nil;
            delegate.alarmClockTool = nil;
        }

    }
    
}

/**
 *  获取所有的闹钟事件
 *
 *  @return 返回所有闹钟事件的数组
 */
+ (NSArray*)GetAllAlarmClockEvent{
    //获取闹钟目录下的所有文件名
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[AlarmClockModel GetLocalPath] error:nil];
    NSMutableArray * clockArray = [NSMutableArray array];
    //这边文件名存储的时候存入的是时间值 所以需要将过期的闹钟事件移除掉
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = ClockDateFormatter;
    for (NSString * string in files) {
        //比较闹钟的时间跟当前时间的差值
        NSDate* inputDate = [dateFormatter dateFromString:string];
        int number =  [inputDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
        //闹钟任务还没有开始
        //if (number > 0) {
        if (number > -59) {
            AlarmClockModel * model = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],string]];
            [clockArray addObject:model];
        }else{
            //已经开始过了的闹钟任务这里需要将其移除掉
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[AlarmClockModel GetLocalPath],string] error:nil];
        }
    }
    return clockArray;
}

/**
 *  获取本地的闹钟事件存储地址
 *
 *  @return
 */
+ (NSString *)GetLocalPath{
    
    NSFileManager * manger = [NSFileManager defaultManager];
    NSString *localPath = [NSString stringWithFormat:@"%@/Documents/AlarmClock", NSHomeDirectory()];
    //这边判断文件夹是否创建，如果文件夹不存在则创建
    if(![manger fileExistsAtPath:localPath]){
        [manger createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return localPath;
}

- (id)copyWithZone:(NSZone *)zone{
    
    AlarmClockModel * model = [[AlarmClockModel allocWithZone:zone] init];
    model.clockId = self.clockId;
    model.hour = self.hour;
    model.minute = self.minute;
    model.isPhone = self.isPhone;
    model.remark = self.remark;
    model.repeat = self.repeat;
    model.isOn = self.isOn;
    model.music = self.music;
    model.isIntelligentWake = self.isIntelligentWake;
    model.type = self.type;
    model.index = self.index;
    return model;
    
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    
    AlarmClockModel * model = [[AlarmClockModel allocWithZone:zone] init];
    model.hour = self.hour;
    model.minute = self.minute;
    model.isPhone = self.isPhone;
    model.remark = self.remark;
    model.repeat = self.repeat;
    model.isOn = self.isOn;
    model.music = self.music;
    model.isIntelligentWake = self.isIntelligentWake;
    model.type = self.type;
    model.index = self.index;
    model.clockId = self.clockId;
    return model;
    
}
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"clockId":@"id"};
}
@end

