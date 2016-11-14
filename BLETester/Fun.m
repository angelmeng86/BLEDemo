//
//  Fun.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "Fun.h"

@implementation Fun

+ (NSData*)longToByteArray:(long)data {
    
    unsigned char byteArray[4] = { 0 };
    for (int index = 0; index < 4; index++) {
        unsigned char byte = data & 0xff;
        byteArray[index] = byte;
        data = (data - byte) / 256;
    }
    return [NSData dataWithBytes:byteArray length:4];
}

@end
