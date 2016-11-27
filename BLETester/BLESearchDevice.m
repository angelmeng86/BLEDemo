//
//  BLESearchDevice.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "BLESearchDevice.h"
#import "Fun.h"

@interface BLESearchDevice ()

@property (nonatomic, strong) NSMutableArray *connectingDevices;
@property (nonatomic, strong) NSData *macAddress;

@end

@implementation BLESearchDevice

- (id)init {
    if (self = [super init]) {
        self.connectingDevices = [NSMutableArray array];
    }
    return self;
}

- (void)cannel {
    [super cannel];
    for (CBPeripheral *peripheral in _connectingDevices) {
        [self.manager cancelPeripheralConnection:peripheral];
    }
    [_connectingDevices removeAllObjects];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    LOG_D(@"didDiscoverPeripheral:%@ advertisementData:%@ RSSI:%@", peripheral, advertisementData, RSSI);
    if ([peripheral.name.uppercaseString hasPrefix:@"SWING"]) {
        if (![self.connectingDevices containsObject:peripheral]) {
            [self.connectingDevices addObject:peripheral];
        }
        
        LOG_D(@"connectPeripheral:%@", peripheral);
        [central connectPeripheral:peripheral options:nil];
        
//        LOG_D(@"connectPeripheral:%@", peripheral);
//        [central connectPeripheral:peripheral options:nil];
//        if (peripheral.state != CBPeripheralStateConnecting &&
//            peripheral.state != CBPeripheralStateConnected) {
//            LOG_D(@"connectPeripheral:%@", peripheral);
//            [central connectPeripheral:peripheral options:nil];
//        }
        
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    LOG_D(@"didConnectPeripheral:%@", peripheral);
    [peripheral setDelegate:self];
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    LOG_D(@"didFailToConnectPeripheral:%@ error:%@", peripheral, error);
    [self.connectingDevices removeObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    LOG_D(@"didDisconnectPeripheral:%@ error:%@", peripheral, error);
    if (error) {
        LOG_D(@"reconnectPeripheral:%@", peripheral);
        [central connectPeripheral:peripheral options:nil];
        return;
    }
    [self.connectingDevices removeObject:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    LOG_D(@"didDiscoverServices:%@ error:%@", peripheral, error);
    if (error) {
        return;
    }
    for (CBService *s in peripheral.services) {
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
            NSArray *characters = @[[CBUUID UUIDWithString:@"FFA1"], [CBUUID UUIDWithString:@"FFA3"], [CBUUID UUIDWithString:@"FFA6"]];
            [peripheral discoverCharacteristics:characters forService:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    LOG_D(@"didDiscoverCharacteristicsForService:%@ error:%@", peripheral, error);
    if (error) {
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
        for (CBCharacteristic *character in service.characteristics) {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
                [peripheral writeValue:[NSData dataWithBytes:"\x01" length:1] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                LOG_D(@"Write FFA1");
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    LOG_D(@"didWriteValueForCharacteristic:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    if (error) {
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        for (CBCharacteristic *character in characteristic.service.characteristics) {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFA3"]]) {
                NSData *time = [Fun longToByteArray:TIME_STAMP];
                LOG_D(@"write FFA3 %@", time);
                [peripheral writeValue:time forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA3"]]) {
        for (CBCharacteristic *character in characteristic.service.characteristics) {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:@"FFA6"]]) {
                LOG_D(@"read FFA6");
                [characteristic.service.peripheral readValueForCharacteristic:character];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    LOG_D(@"didUpdateValueForCharacteristic:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    if (error) {
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA6"]]) {
        LOG_D(@"FFA6 Value:%@", characteristic.value);
        
        if (self.macAddress == nil || [self.macAddress isEqual:characteristic.value]) {
            [self reportSearchDeviceResult:peripheral error:nil];
        }
    }
}

- (void)searchDevice:(NSData*)macAddress centralManager:(CBCentralManager *)central {
    self.macAddress = macAddress;
    self.manager = central;
    LOG_D(@"searchDevice:%@", macAddress);
    [self checkBleStatus];
}

- (void)bleTimeout {
    [self reportSearchDeviceResult:nil error:[NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"蓝牙开关未打开" forKey:NSLocalizedDescriptionKey]]];
}

- (void)fire {
    [self performSelector:@selector(operationTimeout) withObject:nil afterDelay:30];
//    [self.manager scanForPeripheralsWithServices:nil options:nil];
    [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)operationTimeout {
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Can not find device, operation timeout." forKey:NSLocalizedDescriptionKey]];
    [self reportSearchDeviceResult:nil error:err];
}

- (void)reportSearchDeviceResult:(CBPeripheral*)peripheral error:(NSError*)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(operationTimeout) object:nil];
    if ([self.delegate respondsToSelector:@selector(reportSearchDeviceResult:error:)]) {
        [self.delegate reportSearchDeviceResult:peripheral error:error];
    }
    [self cannel];
}

@end
