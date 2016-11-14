//
//  BLEInitDevice.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEInitDeviceDelegate <NSObject>

- (void)reportInitDeviceResult:(NSData*)data error:(NSError*)error;

@end

@interface BLEInitDevice : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id delegate;

- (void)initDevice:(CBPeripheral*)peripheral  centralManager:(CBCentralManager *)central;

- (void)cannel;

@end
