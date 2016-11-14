//
//  BLEClient.h
//  BLETester
//
//  Created by Mapple on 2016/11/13.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^SwingBluetoothInitDeviceBlock)(NSData *macAddress, NSError *error);
typedef void (^SwingBluetoothScanDeviceBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSError *error);

typedef void (^SwingBluetoothSearchDeviceBlock)(CBPeripheral *peripheral, NSError *error);
typedef void (^SwingBluetoothSyncDeviceBlock)(NSMutableArray *activities, NSError *error);

@interface BLEClient : NSObject

- (void)scanDeviceWithCompletion:(SwingBluetoothScanDeviceBlock)completion;

- (void)stopScan;

- (void)initDevice:(CBPeripheral*)peripheral completion:(SwingBluetoothInitDeviceBlock)completion;

- (void)searchDevice:(NSData*)macAddress completion:(SwingBluetoothSearchDeviceBlock)completion;

- (void)syncDevice:(CBPeripheral*)peripheral event:(NSArray*)events completion:(SwingBluetoothSyncDeviceBlock)completion;

- (void)cannelAll;

@end
