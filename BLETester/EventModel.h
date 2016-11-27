//
//  EventModel.h
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor;
@interface EventModel : NSObject

@property (nonatomic) int objId;
@property (strong, nonatomic) NSString* eventName;
@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSDate* endDate;

@property (nonatomic) int alert;

@end
