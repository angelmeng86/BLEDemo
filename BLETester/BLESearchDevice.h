//
//  BLESearchDevice.h
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLESearchDeviceDelegate <NSObject>

- (void)reportSearchDeviceResult:(CBPeripheral*)peripheral error:(NSError*)error;

@end

@interface BLESearchDevice : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id delegate;

- (void)searchDevice:(NSData*)macAddress centralManager:(CBCentralManager *)central;

- (void)cannel;

@end
