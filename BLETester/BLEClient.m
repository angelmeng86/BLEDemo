//
//  BLEClient.m
//  BLETester
//
//  Created by Mapple on 2016/11/13.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "BLEClient.h"
#import "BLESearchDevice.h"
#import "BLEInitDevice.h"
#import "BLEScanDevice.h"
#import "Fun.h"


@interface BLEClient ()
{
    BLESearchDevice *searchDevice;
    BLEInitDevice *initDevice;
    BLEScanDevice *scanDevice;
}

@property (nonatomic, strong) CBCentralManager *manager;

@property (nonatomic, copy) SwingBluetoothInitDeviceBlock blockOnInitDevice;
@property (nonatomic, copy) SwingBluetoothScanDeviceBlock blockOnScanDevice;
@property (nonatomic, copy) SwingBluetoothSearchDeviceBlock blockOnSearchDevice;
@property (nonatomic, copy) SwingBluetoothSyncDeviceBlock blockOnSyncDevice;

@end

@implementation BLEClient

- (id)init {
    if (self = [super init]) {
        static CBCentralManager *manager = nil;
        if (manager == nil) {
            manager = [[CBCentralManager alloc] init];
        }
        self.manager = manager;
        searchDevice = [[BLESearchDevice alloc] init];
        initDevice = [[BLEInitDevice alloc] init];
        scanDevice = [[BLEScanDevice alloc] init];
        
        searchDevice.delegate = self;
        initDevice.delegate = self;
        scanDevice.delegate = self;
    }
    return self;
}

- (void)scanDeviceWithCompletion:(SwingBluetoothScanDeviceBlock)completion {
    self.blockOnScanDevice = completion;
    _manager.delegate = scanDevice;
    [scanDevice scanDevice:_manager];
}

- (void)reportScanDeviceResult:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData error:(NSError*)error {
    if (self.blockOnScanDevice) {
        self.blockOnScanDevice(peripheral, advertisementData, error);
        if (error) {
            self.blockOnInitDevice = nil;
            [_manager stopScan];
        }
    }
}

- (void)stopScan {
    [_manager stopScan];
}

- (void)initDevice:(CBPeripheral*)peripheral completion:(SwingBluetoothInitDeviceBlock)completion {
    self.blockOnInitDevice = completion;
    _manager.delegate = initDevice;
    [initDevice initDevice:peripheral centralManager:_manager];
}

- (void)reportInitDeviceResult:(NSData*)data error:(NSError*)error {
    if (self.blockOnInitDevice) {
        self.blockOnInitDevice(data, error);
        self.blockOnInitDevice = nil;
    }
}

- (void)searchDevice:(NSData*)macAddress completion:(SwingBluetoothSearchDeviceBlock)completion {
    self.blockOnSearchDevice = completion;
    _manager.delegate = searchDevice;
    [searchDevice searchDevice:macAddress centralManager:_manager];
}

- (void)reportSearchDeviceResult:(CBPeripheral*)peripheral error:(NSError*)error {
    if (self.blockOnSearchDevice) {
        self.blockOnSearchDevice(peripheral, error);
        self.blockOnSearchDevice = nil;
        self.manager.delegate = nil;
    }
    [_manager stopScan];
}

- (void)syncDevice:(CBPeripheral*)peripheral event:(NSArray*)events completion:(SwingBluetoothSyncDeviceBlock)completion {
    
}

- (void)cannelAll {
    [_manager stopScan];
    [initDevice cannel];
    [searchDevice cannel];
}

@end
