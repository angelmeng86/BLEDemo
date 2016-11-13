//
//  ViewController.m
//  BLETester
//
//  Created by Mapple on 2016/11/13.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "ViewController.h"
#import "BLEClient.h"

@interface ViewController ()
{
    BLEClient *client;
}

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)searchAction:(id)sender {
    //要搜索的蓝牙地址，请使用十六进制不带空格
    NSString *mac = @"87432b199e68";
    NSData *macAddress = [ViewController hexToData:mac];
    self.statusLabel.text = [NSString stringWithFormat:@"正在搜索...%@", macAddress];
    self.searchBtn.enabled = NO;
    [client searchDevice:macAddress completion:^(CBPeripheral *peripheral, NSError *error) {
        if (error) {
            self.statusLabel.text = [error localizedDescription];
        }
        else {
            self.statusLabel.text = [NSString stringWithFormat:@"找到设备:%@", peripheral];
        }
        self.searchBtn.enabled = YES;
    }];
}

- (IBAction)cancelAction:(id)sender {
    [client cannelAll];
    self.searchBtn.enabled = YES;
    self.statusLabel.text = nil;
}

@end
