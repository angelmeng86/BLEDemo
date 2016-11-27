//
//  BLESyncDevice.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "BLESyncDevice.h"
#import "CBService+LMMethod.h"
#import "Fun.h"

typedef enum : NSUInteger {
    SwingSyncNone,
    SwingSyncBegin,
    SwingSyncTimeWrited,
    SwingSyncMacReaded,
    SwingSyncAlertNumberWrited,
    SwingSyncAlertTimeWrited,
    SwingSyncHeaderReaded,
    SwingSyncTimeReaded,
    SwingSyncData1Readed,
    SwingSyncData2Readed,
    SwingSyncChecksumWrited,
} SwingSyncState;

@interface BLESyncDevice ()
{
    SwingSyncState syncState;
}

@property (nonatomic, strong) NSMutableArray *eventArray;
@property (nonatomic, strong) NSMutableArray *activityArray;
@property (nonatomic, strong) NSMutableDictionary *activityDict;
@property (nonatomic) long timeStamp;
@property (nonatomic, strong) NSData *ffa4Data1;
@property (nonatomic, strong) NSData *ffa4Data2;
@property (nonatomic, strong) NSData *macAddress;
@property (nonatomic, strong) NSMutableIndexSet *timeSet;

@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation BLESyncDevice

- (BOOL)writeAlertNumber:(CBService*)service {
    CBCharacteristic *characteristic = [service findCharacteristic:@"FFA7"];
    Byte array[1];
    array[0] = 0x00;
    if (_eventArray.count > 0) {
        //往FFA7里面写
        EventModel *model = [_eventArray firstObject];
        array[0] = model.alert;
        LOG_D(@"lwz alert:%d", model.alert);
    }
    NSData *data = [NSData dataWithBytes:array length:1];
    [service.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    return array[0] == 0x00 ? NO : YES;
}

- (BOOL)writeAlertTimestmp:(CBService*)service {
    if (_eventArray.count > 0) {
        // 往FFA8里面放未来的时间戳
        EventModel *model = [_eventArray firstObject];
        [_eventArray removeObjectAtIndex:0];
        long date = [model.startDate timeIntervalSince1970] + TIME_ADJUST;
        NSData *timedata = [Fun longToByteArray:date];
        LOG_D(@"date %@, timestamp:%@", model.startDate, timedata);
        CBCharacteristic *characteristic = [service findCharacteristic:@"FFA8"];
        [service.peripheral writeValue:timedata forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    return NO;
}

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

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    LOG_D(@"didConnectPeripheral:%@", peripheral);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(operationTimeout) object:nil];
    [peripheral setDelegate:self];
    NSArray *services = @[[CBUUID UUIDWithString:@"FFA0"], [CBUUID UUIDWithString:@"180F"]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    LOG_D(@"didFailToConnectPeripheral:%@ error:%@", peripheral, error);
    if ([peripheral isEqual:_peripheral]) {
        [self reportSyncDeviceResult:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    LOG_D(@"didDisconnectPeripheral:%@ error:%@", peripheral, error);
    if ([peripheral isEqual:_peripheral]) {
        [self reportSyncDeviceResult:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    LOG_D(@"didDiscoverServices:%@ error:%@", peripheral, error);
    if (error) {
        [self reportSyncDeviceResult:error];
        return;
    }
    for (CBService *s in peripheral.services) {
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
            [peripheral discoverCharacteristics:nil forService:s];
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
        [self reportSyncDeviceResult:error];
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFA0"]]) {
        CBCharacteristic *character = [service findCharacteristic:@"FFA1"];
        [peripheral writeValue:[NSData dataWithBytes:"\x01" length:1] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
        LOG_D(@"Write FFA1");
        syncState = SwingSyncBegin;
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
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFA8"]) {
        LOG_D(@"FFA8 err:%@", error);
        [self writeAlertNumber:characteristic.service];
        LOG_D(@"write FFA7");
//        [rhythm beats];
        return;
    }
    if (error) {
        [self reportSyncDeviceResult:error];
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA3"];
        NSData *time = [Fun longToByteArray:TIME_STAMP];
        LOG_D(@"write FFA3 %@", time);
        [peripheral writeValue:time forCharacteristic:character type:CBCharacteristicWriteWithResponse];
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA3"]) {
        LOG_D(@"read FFA6");
        CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA6"];
        [characteristic.service.peripheral readValueForCharacteristic:character];
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA7"]) {
        
        if ([self writeAlertTimestmp:characteristic.service]) {
            LOG_D(@"write FFA8");
            syncState = SwingSyncTimeWrited;
        }
        else {
            LOG_D(@"read FFA9");
            syncState = SwingSyncHeaderReaded;
            CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA9"];
            [characteristic.service.peripheral readValueForCharacteristic:character];
        }
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA5"]) {
        if (self.ffa4Data2) {
            //判断是否存在重复数据
            if (![self.timeSet containsIndex:self.timeStamp]) {
                [self.timeSet addIndex:self.timeStamp];
                //处理Activity数据
                static NSDateFormatter *df = nil;
                if (df == nil) {
                    df = [[NSDateFormatter alloc] init];
                    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [df setDateFormat:@"yyyy-MM-dd"];
                }
                NSString *key = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.timeStamp]];
                ActivityModel *model = [ActivityModel new];
                model.time = self.timeStamp;
                model.macId = [Fun dataToHex:self.macAddress];
                [model setIndoorData:self.ffa4Data1];
                [model setOutdoorData:self.ffa4Data2];
                [self.activityArray addObject:model];
//                [DBHelper addActivity:model];
                
//                NSString *local = [GlobalCache shareInstance].local.date;
//                if (local && [local isEqualToString:key]) {
//                    //累加当天的步数
//                    [GlobalCache shareInstance].local.indoorSteps += model.inData1;
//                    [GlobalCache shareInstance].local.outdoorSteps += model.outData1;
//                    [[GlobalCache shareInstance] saveInfo];
//                }
                /*
                 if (weakSelf.activityDict[key]) {
                 ActivityModel *m = weakSelf.activityDict[key];
                 [m add:model];
                 [m reload];
                 }
                 else {
                 weakSelf.activityDict[key] = model;
                 }
                 */
                LOG_D(@"activity: time:%ld indoor:%@ outdoor:%@ date:%@", model.time, model.indoorActivity, model.outdoorActivity, key);
            }
            else {
                LOG_D(@"activity: time:%@ is repeat.", [NSDate dateWithTimeIntervalSince1970:self.timeStamp]);
            }
        }
        
        LOG_D(@"read FFA9");
        syncState = SwingSyncHeaderReaded;
        CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA9"];
        [characteristic.service.peripheral readValueForCharacteristic:character];
    }
//    [rhythm beats];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    LOG_D(@"didUpdateValueForCharacteristic:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    if (error) {
        [self reportSyncDeviceResult:error];
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA6"]]) {
        LOG_D(@"FFA6 Value:%@", characteristic.value);
        self.macAddress = characteristic.value;
        LOG_D(@"write FFA7");
        [self writeAlertNumber:characteristic.service];
        syncState = SwingSyncAlertNumberWrited;
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        const Byte* ptr = characteristic.value.bytes;
        LOG_D(@"Read Battery:%d%%", ptr[0]);
//        [GlobalCache shareInstance].local.battery = ptr[0];
//        [[GlobalCache shareInstance] saveInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:SWING_WATCH_BATTERY_NOTIFY object:[NSNumber numberWithInt:ptr[0]]];
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA9"]) {
        const Byte *ptr = characteristic.value.bytes;
        LOG_D(@"HeaderReaded len %d %02x%02x", (int)[characteristic.value length], ptr[0], ptr[1]);
        if (ptr[0] == 0x01 && ptr[1] == 0x00) {
            LOG_D(@"Have Data!");
            //FFA3
            CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA3"];
            [characteristic.service.peripheral readValueForCharacteristic:character];
//            [rhythm beats];
            LOG_D(@"Read FFA3");
            syncState = SwingSyncTimeReaded;
        }
        else {
            LOG_D(@"No Data!");
            syncState = SwingSyncNone;
            //断开连接
//            [rhythm beatsOver];
            [self reportSyncDeviceResult:nil];
        }
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA3"]) {
        long value = [Fun byteArrayToLong:characteristic.value];
        self.timeStamp = value;
        LOG_D(@"SwingSyncTimeReaded:%@", [NSDate dateWithTimeIntervalSince1970:value]);
        
        syncState = SwingSyncData1Readed;
        LOG_D(@"Read FFA4");
        CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA4"];
        [characteristic.service.peripheral readValueForCharacteristic:character];
//        [rhythm beats];
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFA4"]) {
        if (syncState == SwingSyncData1Readed) {
            self.ffa4Data1 = characteristic.value;
            syncState = SwingSyncData2Readed;
            LOG_D(@"Read FFA4");
            CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA4"];
            [characteristic.service.peripheral readValueForCharacteristic:character];
            
        }
        else {
            LOG_D(@"SwingSyncData2Readed:%d", (int)characteristic.value.length);
            
            Byte array[1];
            if ([self.ffa4Data1 isEqualToData:characteristic.value]) {
                //数据有误
                array[0] = 0x00;
                self.ffa4Data2 = nil;
                LOG_D(@"FFA4DATA1 isEqualto FFA4DATA2!");
            }
            else {
                array[0] = 0x01;
                self.ffa4Data2 = characteristic.value;
            }
            LOG_D(@"Write FFA5 %d", array[0]);
            NSData *data = [NSData dataWithBytes:array length:1];
            CBCharacteristic *character = [characteristic.service findCharacteristic:@"FFA5"];
            [characteristic.service.peripheral writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            syncState = SwingSyncChecksumWrited;
        }
    }
}

- (void)syncDevice:(CBPeripheral*)peripheral centralManager:(CBCentralManager *)central event:(NSArray*)events {
    syncState = SwingSyncNone;
    self.eventArray = [NSMutableArray arrayWithArray:events];
//    NSDate *date = [NSDate date];
//    for (int i = (int)_eventArray.count; --i >= 0;) {
//        EventModel *obj = _eventArray[i];
//        if (obj.alert < 34) {
//            [_eventArray removeObjectAtIndex:i];
//        }
//        else if(NSOrderedDescending != [obj.startDate compare:date]) {
//            [_eventArray removeObjectAtIndex:i];
//        }
//    }
    self.activityArray = [NSMutableArray array];
    self.activityDict = [NSMutableDictionary dictionary];
    self.timeSet = [NSMutableIndexSet new];
    
    self.peripheral = peripheral;
    self.manager = central;
    
    LOG_D(@"syncDevice:%@", peripheral);
    [self checkBleStatus];
}

- (void)bleTimeout {
    [self reportSyncDeviceResult:[NSError errorWithDomain:@"SwingBluetooth" code:-2 userInfo:[NSDictionary dictionaryWithObject:@"蓝牙开关未打开" forKey:NSLocalizedDescriptionKey]]];
}

- (void)fire {
    [self performSelector:@selector(operationTimeout) withObject:nil afterDelay:30];
    [self.manager connectPeripheral:self.peripheral options:nil];
}

- (void)operationTimeout {
    NSError *err = [NSError errorWithDomain:@"SwingBluetooth" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"connectPeripheral timeout." forKey:NSLocalizedDescriptionKey]];
    [self reportSyncDeviceResult:err];
}

- (void)cannel {
    [super cannel];
    
    if (_peripheral) {
        [self.manager cancelPeripheralConnection:_peripheral];
    }
    self.peripheral = nil;
    
    self.eventArray = nil;
    self.activityArray = nil;
    self.activityDict = nil;
    self.timeSet = nil;
    
    self.ffa4Data1 = nil;
    self.ffa4Data2 = nil;
    self.macAddress = nil;
}

- (void)reportSyncDeviceResult:(NSError*)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(operationTimeout) object:nil];
    if ([self.delegate respondsToSelector:@selector(reportSyncDeviceResult:error:)]) {
        [self.delegate reportSyncDeviceResult:_activityArray error:error];
    }
    [self cannel];
}


@end
