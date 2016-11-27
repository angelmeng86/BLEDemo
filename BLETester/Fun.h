//
//  Fun.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EventModel.h"
#import "ActivityModel.h"

#define LOG_D(format, ...) NSLog(format, ##__VA_ARGS__)

#define  TIME_ADJUST        [NSTimeZone localTimeZone].secondsFromGMT
#define  TIME_STAMP         [[NSDate date] timeIntervalSince1970] + TIME_ADJUST

#define SWING_WATCH_BATTERY_NOTIFY  @"SWING_WATCH_BATTERY_NOTIFY"

@interface Fun : NSObject

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg;

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg delegate:(id)delegate;

+ (void)showMessageBox:(NSString*)title andFormat:(NSString*)format, ...;

+ (void)log:(NSString*)info;

+ (void)logInfo:(NSString *)format, ...;

+ (NSString*)getLogInfo;

+ (void)showLog;

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email;

+ (NSString*)getTimeString:(NSDate*)updatedAt;

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage maxWidth:(CGFloat)maxWidth;

+ (NSDate*)dateFromString:(NSString*)str;
+ (NSString*)dateToString:(NSDate*)date;

+ (UIColor*)colorFromNSString:(NSString *)string;
+ (NSString*)stringFromColor:(UIColor*)color;

+ (NSData*)longToByteArray:(long)data;
+ (long)byteArrayToLong:(NSData*)data;
+ (long)byteArrayToLong:(NSData*)data length:(int)len;
+ (long)byteArrayToLong:(NSData*)data pos:(int)pos length:(int)len;

+ (NSString*)dataToHex:(NSData*)data;
+ (NSData*)hexToData:(NSString*)data;

@end
