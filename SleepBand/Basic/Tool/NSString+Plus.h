//
// Created by HH on 2017/6/27.
// Copyright (c) 2017 李晓博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Plus)
- (NSString *)stringWithFormat:(NSString *)format andArguments:(NSArray *)arguments;
//十进制转16进制
+(NSString *)ToHex:(int)tmpid;
@end
