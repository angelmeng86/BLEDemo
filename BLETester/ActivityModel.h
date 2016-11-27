//
//  ActivityModel.h
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject

@property (nonatomic, strong) NSString *indoorActivity;
@property (nonatomic, strong) NSString *outdoorActivity;
@property (nonatomic) long time;
@property (nonatomic, strong) NSString *macId;

@property (nonatomic) long inData1;
@property (nonatomic) long inData2;
@property (nonatomic) long inData3;
@property (nonatomic) long inData4;

@property (nonatomic) long outData1;
@property (nonatomic) long outData2;
@property (nonatomic) long outData3;
@property (nonatomic) long outData4;

- (void)setIndoorData:(NSData*)data;
- (void)setOutdoorData:(NSData*)data;

- (void)add:(ActivityModel*)model;

- (void)reload;
//- (void)reset;

@end
