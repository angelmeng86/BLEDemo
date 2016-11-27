//
//  BLEScanDevice.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "BLEScanDevice.h"
#import "Fun.h"

@implementation BLEScanDevice

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    LOG_D(@"didDiscoverPeripheral:%@ advertisementData:%@ RSSI:%@", peripheral, advertisementData, RSSI);
    if ([peripheral.name.uppercaseString hasPrefix:@"SWING"]) {
        [self reportScanDeviceResult:peripheral advertisementData:advertisementData error:nil];
    }
}

- (void)scanDevice:(CBCentralManager *)central {
    LOG_D(@"scanDevice");
    self.manager = central;
    [self checkBleStatus];
}

- (void)bleTimeout {
    [self reportScanDeviceResult:nil advertisementData:nil error:[NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"蓝牙开关未打开" forKey:NSLocalizedDescriptionKey]]];
}

- (void)fire {
    [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)reportScanDeviceResult:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData error:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(reportScanDeviceResult:advertisementData:error:)]) {
        [self.delegate reportScanDeviceResult:peripheral advertisementData:advertisementData error:error];
    }
}

@end
