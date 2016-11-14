//
//  Fun.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOG_D(format, ...) NSLog(format, ##__VA_ARGS__)

#define  TIME_ADJUST        [NSTimeZone localTimeZone].secondsFromGMT
#define  TIME_STAMP         [[NSDate date] timeIntervalSince1970] + TIME_ADJUST

#define SWING_WATCH_BATTERY_NOTIFY  @"SWING_WATCH_BATTERY_NOTIFY"

@interface Fun : NSObject

+ (NSData*)longToByteArray:(long)data;

@end
