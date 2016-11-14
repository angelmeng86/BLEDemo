//
//  BLEScanDevice.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEScanDeviceDelegate <NSObject>

- (void)reportScanDeviceResult:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData error:(NSError*)error;

@end

@interface BLEScanDevice : NSObject<CBCentralManagerDelegate>

@property (nonatomic, weak) id delegate;

- (void)scanDevice:(CBCentralManager *)central;

@end
