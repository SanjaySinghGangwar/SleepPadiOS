//
//  BCCKeychain.h
//  QLife
//
//  Created by admin on 2018/5/25.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCCKeychain : NSObject
+ (NSString *)getPasswordStringForUsername:(NSString *)username andServiceName:(NSString *)serviceName error:(NSError **)error;
+ (NSData *)getPasswordDataForUsername:(NSString *)username andServiceName:(NSString *)serviceName error:(NSError **)error;

+ (BOOL)storeUsername:(NSString *)username andPasswordString:(NSString *)password forServiceName:(NSString *)serviceName updateExisting:(BOOL)updateExisting error:(NSError **)error;
+ (BOOL)storeUsername:(NSString *)username andPasswordData:(NSData *)passwordData forServiceName:(NSString *)serviceName updateExisting:(BOOL)updateExisting error:(NSError **)error;

+ (BOOL)deleteItemForUsername:(NSString *)username andServiceName:(NSString *)serviceName error:(NSError **)error;
@end
