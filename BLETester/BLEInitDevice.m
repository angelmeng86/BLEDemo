//
//  BLEInitDevice.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "BLEInitDevice.h"
#import "Fun.h"

@interface BLEInitDevice ()

@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation BLEInitDevice

- (void)cannel {
    [super cannel];
    if (_peripheral) {
        [self.manager cancelPeripheralConnection:_peripheral];
    }
    self.peripheral = nil;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    LOG_D(@"didConnectPeripheral:%@", peripheral);
    [peripheral setDelegate:self];
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"], [CBUUID UUIDWithString:@"180F"]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    LOG_D(@"didFailToConnectPeripheral:%@ error:%@", peripheral, error);
    [self reportInitDeviceResult:nil error:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    LOG_D(@"didDisconnectPeripheral:%@ error:%@", peripheral, error);
    [self reportInitDeviceResult:nil error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    LOG_D(@"didDiscoverServices:%@ error:%@", peripheral, error);
    if (error) {
        [self reportInitDeviceResult:nil error:error];
        return;
    }
    for (CBService *s in peripheral.services) {
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
            NSArray *characters = @[[CBUUID UUIDWithString:@"FFA1"], [CBUUID UUIDWithString:@"FFA3"], [CBUUID UUIDWithString:@"FFA6"]];
            [peripheral discoverCharacteristics:characters forService:s];
        }
        else if ([s.UUID isEqual:[CBUUID UUIDWithString:@"180F"]]) {
            NSArray *characters = @[[CBUUID UUIDWithString:@"2A19"]];
            [peripheral discoverCharacteristics:characters forService:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    LOG_D(@"didDiscoverCharacteristicsForService:%@ error:%@", peripheral, error);
    if (error) {
        [self reportInitDeviceResult:nil error:error];
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
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180F"]]) {
        for (CBCharacteristic *character in service.characteristics) {
            if ([character.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
                [peripheral readValueForCharacteristic:character];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    LOG_D(@"didWriteValueForCharacteristic:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    if (error) {
        [self reportInitDeviceResult:nil error:error];
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
        [self reportInitDeviceResult:nil error:error];
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA6"]]) {
        LOG_D(@"FFA6 Value:%@", characteristic.value);
        [self reportInitDeviceResult:characteristic.value error:nil];
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        const Byte* ptr = characteristic.value.bytes;
        LOG_D(@"Read Battery:%d%%", ptr[0]);
//        [GlobalCache shareInstance].local.battery = ptr[0];
//        [[GlobalCache shareInstance] saveInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:SWING_WATCH_BATTERY_NOTIFY object:[NSNumber numberWithInt:ptr[0]]];
    }
}

- (void)initDevice:(CBPeripheral*)peripheral centralManager:(CBCentralManager *)central {
    self.peripheral = peripheral;
    self.manager = central;
    LOG_D(@"initDevice:%@", self.peripheral);
    [self checkBleStatus];
}

- (void)bleTimeout {
    [self reportInitDeviceResult:nil error:[NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"蓝牙开关未打开" forKey:NSLocalizedDescriptionKey]]];
}

- (void)fire {
    [self performSelector:@selector(operationTimeout) withObject:nil afterDelay:30];
    [self.manager connectPeripheral:self.peripheral options:nil];
}

- (void)operationTimeout {
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"connectPeripheral timeout." forKey:NSLocalizedDescriptionKey]];
    [self reportInitDeviceResult:nil error:err];
}

- (void)reportInitDeviceResult:(NSData*)data error:(NSError*)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(operationTimeout) object:nil];
    if ([self.delegate respondsToSelector:@selector(reportInitDeviceResult:error:)]) {
        [self.delegate reportInitDeviceResult:data error:error];
    }
    [self cannel];
}

@end
