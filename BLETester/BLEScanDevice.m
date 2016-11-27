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

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    LOG_D(@"didDiscoverPeripheral:%@ advertisementData:%@ RSSI:%@", peripheral, advertisementData, RSSI);
    if ([peripheral.name.uppercaseString hasPrefix:@"SWING"]) {
        [self reportScanDeviceResult:peripheral advertisementData:advertisementData error:nil];
    }
}

- (void)scanDevice:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        LOG_D(@"scanDevice");
        [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    }
    else {
        [self reportScanDeviceResult:nil advertisementData:nil error:[NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"蓝牙开关未打开" forKey:NSLocalizedDescriptionKey]]];
    }
}

- (void)reportScanDeviceResult:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData error:(NSError*)error {
    if ([_delegate respondsToSelector:@selector(reportScanDeviceResult:advertisementData:error:)]) {
        [_delegate reportScanDeviceResult:peripheral advertisementData:advertisementData error:error];
    }
}

@end
