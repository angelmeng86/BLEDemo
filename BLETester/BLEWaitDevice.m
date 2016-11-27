//
//  BLEWaitDevice.m
//  Swing
//
//  Created by Mapple on 2016/11/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BLEWaitDevice.h"
#import "Fun.h"

@interface BLEWaitDevice ()
{
    NSTimer *waitTimer;
    int waitTimes;
}

@end

@implementation BLEWaitDevice

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            LOG_D(@"蓝牙已打开,请扫描外设");
            break;
        case CBManagerStatePoweredOff:
            LOG_D(@"蓝牙没有打开,请先打开蓝牙");
            break;
        default:
            break;
    }
}

- (void)cannel {
    if (waitTimer) {
        [waitTimer invalidate];
        waitTimer = nil;
    }
}

- (void)checkBleStatus {
    if (waitTimer) {
        [waitTimer invalidate];
        waitTimer = nil;
    }
    
    if (_manager.state == CBManagerStatePoweredOn) {
        [self fire];
        return;
    }
    
    waitTimes = 5;
    waitTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTick:) userInfo:nil repeats:YES];
}

- (void)timeTick:(NSTimer*)timer {
    LOG_D(@"等待蓝牙启动");
    if (_manager.state == CBManagerStatePoweredOn) {
        [self cannel];
        [self fire];
    }
    else if (--waitTimes <= 0) {
        [self cannel];
        [self bleTimeout];
    }
}

- (void)bleTimeout {
    
}

- (void)fire {
    
}

@end
