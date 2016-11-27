//
//  ViewController.m
//  BLETester
//
//  Created by Mapple on 2016/11/13.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "ViewController.h"
#import "BLEClient.h"
#import "EventModel.h"

@interface ViewController ()
{
    BLEClient *client;
    NSString *mac;
}

@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation ViewController

+ (NSData *)hexToData:(NSString *)hexString {
    const char *chars = [hexString UTF8String];
    int i = 0;
    int len = (int)hexString.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len/2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i<len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    client = [[BLEClient alloc] init];
    
    //要搜索的蓝牙地址，请使用十六进制不带空格
    mac = @"87432b199e68";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)searchAction:(id)sender {
    NSData *macAddress = [ViewController hexToData:mac];
    self.statusLabel.text = [NSString stringWithFormat:@"正在搜索...%@", macAddress];
    self.searchBtn.enabled = NO;
    [client searchDevice:macAddress completion:^(CBPeripheral *peripheral, NSError *error) {
        if (error) {
            self.statusLabel.text = [error localizedDescription];
        }
        else {
            self.statusLabel.text = [NSString stringWithFormat:@"找到设备:%@", peripheral];
            self.peripheral = peripheral;
        }
        self.searchBtn.enabled = YES;
    }];
}

- (IBAction)cancelAction:(id)sender {
    [client cannelAll];
    self.searchBtn.enabled = YES;
    self.statusLabel.text = nil;
}

- (IBAction)initAction:(id)sender {
    self.statusLabel.text = nil;
    [client initDevice:_peripheral completion:^(NSData *macAddress, NSError *error) {
        if (error) {
            self.statusLabel.text = [error localizedDescription];
        }
        else {
            self.statusLabel.text = [NSString stringWithFormat:@"初始化设备:%@", macAddress];
        }
    }];
}

- (IBAction)scanAction:(id)sender {
    self.statusLabel.text = nil;
    [client scanDeviceWithCompletion:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSError *error) {
        if (error) {
            self.statusLabel.text = [error localizedDescription];
        }
        else {
            self.statusLabel.text = [NSString stringWithFormat:@"scanAction:%@", peripheral];
        }
    }];
}

- (IBAction)syncAction:(id)sender {
    if (!self.peripheral) {
        self.statusLabel.text = @"请先进行查找设备操作！";
        return;
    }
    self.statusLabel.text = @"开始同步设备...";
    int start = 30;//30秒后将会陆续播放alert，每隔6秒播放一个
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 36; i < 77; i++) {
        EventModel *model = [[EventModel alloc] init];
        model.alert = i;
        model.startDate = [[NSDate date] dateByAddingTimeInterval:start];
        start += 6;//间隔时间
        [array addObject:model];
    }
    [client syncDevice:self.peripheral event:array completion:^(NSMutableArray *activities, NSError *error) {
        if (error) {
            self.statusLabel.text = [error localizedDescription];
        }
        else {
            self.statusLabel.text = @"同步完成！";
        }
    }];
}

@end
