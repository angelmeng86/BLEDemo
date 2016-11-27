//
//  ActivityModel.m
//  Swing
//
//  Created by Mapple on 16/8/16.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ActivityModel.h"
#import "Fun.h"

@implementation ActivityModel
/*
indoorActivity:  1471185427,1,232,0,0,2,0,0,0,3,0,0,0,4,0,0,0,0
outdoorActivity: 1471185427,0,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
time:            1470885849
macId:           tester1
*/

/*
indoorActivity:  1471185427,1,Dec,Dec,Dec,Dec
outdoorActivity: 1471185427,0,Dec,Dec,Dec,Dec
time:            1470885849
macId:           tester1
*/
/*
- (void)reset {
    self.time = [[NSDate date] timeIntervalSince1970];
//    self.indoorActivity = [NSString stringWithFormat:@"%ld,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", _time];
//    self.outdoorActivity = [NSString stringWithFormat:@"%ld,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", _time];
    self.indoorActivity = [NSString stringWithFormat:@"%ld,0,0,0,0,0", _time];
    self.outdoorActivity = [NSString stringWithFormat:@"%ld,1,0,0,0,0", _time];
}
*/
- (NSString*)indoorActivity {
    if (_indoorActivity.length == 0) {
        _indoorActivity = [NSString stringWithFormat:@"%ld,0,%ld,%ld,%ld,%ld",
                           _time == 0 ? (long)[[NSDate date] timeIntervalSince1970] : _time,
                           _inData1, _inData2, _inData3, _inData4];
    }
    return _indoorActivity;
}

- (NSString*)outdoorActivity {
    if (_outdoorActivity.length == 0) {
        _outdoorActivity = [NSString stringWithFormat:@"%ld,1,%ld,%ld,%ld,%ld",
                            _time == 0 ? (long)[[NSDate date] timeIntervalSince1970] : _time,
                            _outData1, _outData2, _outData3, _outData4];
    }
    return _outdoorActivity;
}

- (long)time {
    if (_time == 0) {
        _time = [[NSDate date] timeIntervalSince1970];
    }
    return _time;
}

- (void)parseData:(NSData*)data {
//    [info appendFormat:@"%ld,", [Fun byteArrayToLong:data length:4]];
    const Byte* ptr = data.bytes;
    if(ptr[4] == 1) {
        for (int i = 5, index = 0; i < data.length; i+=4, index++) {
            switch(index) {
                case 0:
                    _outData1 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
                case 1:
                    _outData2 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
                case 2:
                    _outData3 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
                case 3:
                    _outData4 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
            }
        }
    }
    else {
        for (int i = 5, index = 0; i < data.length; i+=4, index++) {
            switch(index) {
                case 0:
                    _inData1 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
                case 1:
                    _inData2 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
                case 2:
                    _inData3 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
                case 3:
                    _inData4 = [Fun byteArrayToLong:data pos:i length:4];
                    break;
            }
        }
    }
    
//    for (int i = 4; i < data.length; i++) {
//        if (i + 1 == data.length) {
//            [info appendFormat:@"%d", ptr[i]];
//        }
//        else {
//            [info appendFormat:@"%d,", ptr[i]];
//        }
//    }
}

- (void)setIndoorData:(NSData*)data {
    if (data.length == 21) {
        [self parseData:data];
    }
}

- (void)setOutdoorData:(NSData*)data {
    if (data.length == 21) {
        [self parseData:data];
    }
}

- (void)add:(ActivityModel*)model {
    _inData1 += model.inData1;
    _inData2 += model.inData2;
    _inData3 += model.inData3;
    _inData4 += model.inData4;
    _outData1 += model.outData1;
    _outData2 += model.outData2;
    _outData3 += model.outData3;
    _outData4 += model.outData4;
}

- (void)reload {
    _indoorActivity = [NSString stringWithFormat:@"%ld,0,%ld,%ld,%ld,%ld",
                       _time == 0 ? (long)[[NSDate date] timeIntervalSince1970] : _time,
                       _inData1, _inData2, _inData3, _inData4];
    _outdoorActivity = [NSString stringWithFormat:@"%ld,1,%ld,%ld,%ld,%ld",
                        _time == 0 ? (long)[[NSDate date] timeIntervalSince1970] : _time,
                        _outData1, _outData2, _outData3, _outData4];
}

@end
