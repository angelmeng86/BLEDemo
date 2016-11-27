//
//  BLEWaitDevice.h
//  Swing
//
//  Created by Mapple on 2016/11/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEWaitDevice : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id delegate;

@property (nonatomic, weak) CBCentralManager *manager;

- (void)checkBleStatus;

- (void)bleTimeout;

- (void)fire;

- (void)cannel;

@end
