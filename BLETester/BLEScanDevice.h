//
//  BLEScanDevice.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEWaitDevice.h"

@protocol BLEScanDeviceDelegate <NSObject>

- (void)reportScanDeviceResult:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData error:(NSError*)error;

@end

@interface BLEScanDevice : BLEWaitDevice

- (void)scanDevice:(CBCentralManager *)central;

@end
