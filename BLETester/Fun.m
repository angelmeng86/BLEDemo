//
//  Fun.m
//  BLETester
//
//  Created by Mapple on 2016/11/14.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import "Fun.h"

@implementation Fun

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:msg
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)showMessageBoxWithTitle:(NSString*)title andMessage:(NSString*)msg delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:msg
                              delegate:delegate
                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)showMessageBox:(NSString*)title andFormat:(NSString*)format, ...
{
    va_list argList;
    if(format)
    {
        va_start(argList, format);
        NSString *content = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:content
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

+ (void)log:(NSString*)info
{
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    NSString *logName = [documentsDirectory stringByAppendingPathComponent:@"log.txt"];
    NSError *err;
    NSMutableString *text = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:logName])
    {
        NSStringEncoding enc = NSUTF8StringEncoding;
        text = [NSMutableString stringWithContentsOfFile:logName usedEncoding:&enc error:&err];
    }
    else {
        text = [NSMutableString stringWithCapacity:256];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
    [text appendFormat:@"Log:%@\n%@\n", [formatter stringFromDate:[NSDate date]], info];
    [text writeToFile:logName atomically:YES encoding:NSUTF8StringEncoding error:&err];
}

+ (void)logInfo:(NSString *)format, ...
{
    va_list argList;
    if(format)
    {
        va_start(argList, format);
        NSString *info = [[NSString alloc] initWithFormat:format arguments:argList];
        va_end(argList);
        [Fun log:info];
    }
    
}

+ (NSString*)getLogInfo
{
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    NSString *logName = [documentsDirectory stringByAppendingPathComponent:@"log.txt"];
    NSError *err;
    NSStringEncoding enc = NSUTF8StringEncoding;
    return [NSString stringWithContentsOfFile:logName usedEncoding:&enc error:&err];
}

+ (void)showLog
{
    [Fun showMessageBoxWithTitle:@"日志" andMessage:[Fun getLogInfo]];
}

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString*)getTimeString:(NSDate*)updatedAt
{
    //    NSTimeInterval aTimer = [[NSDate date] timeIntervalSinceDate:updatedAt];
    //    int days = (int)aTimer/(3600*24);
    //    int hour = (int)(aTimer/3600);
    //    int minute = (int)(aTimer - hour*3600)/60;
    //    if (updatedAt == nil) {
    //        LOG_D(@"updatedAt is nil");
    //        updatedAt = [NSDate date];
    //    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:updatedAt toDate:[NSDate date] options:NSCalendarWrapComponents];
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld year ago", (long)components.year];
    }
    else if(components.month > 0) {
        return [NSString stringWithFormat:@"%ld month ago", (long)components.month];
    }
    else if(components.day > 0) {
        return [NSString stringWithFormat:@"%ld day ago", (long)components.day];
    }
    else if(components.hour > 0) {
        return [NSString stringWithFormat:@"%ld hour ago", (long)components.hour];
    }
    else {
        return [NSString stringWithFormat:@"%ld min ago", components.minute == 0 ? 1 : (long)components.minute];
    }
}

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage maxWidth:(CGFloat)maxWidth {
    if (sourceImage.size.width < maxWidth) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = maxWidth;
        btWidth = sourceImage.size.width * (maxWidth / sourceImage.size.height);
    } else {
        btWidth = maxWidth;
        btHeight = sourceImage.size.height * (maxWidth / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [Fun imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) LOG_D(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSDate*)dateFromString:(NSString*)str {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    }
    return [df dateFromString:str];
}

+ (NSString*)dateToString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    }
    return [df stringFromDate:date];
}

+ (UIColor*)colorFromNSString:(NSString *)string
{
    //
    // http://stackoverflow.com/a/13648705
    //
    
    NSString *noHashString = [string stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

+ (NSString*)stringFromColor:(UIColor*)color
{
    //
    // http://softteco.blogspot.de/2011/06/extract-hex-rgb-color-from-uicolor.mtml
    //
    
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0), (int)((CGColorGetComponents(color.CGColor))[1]*255.0), (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

+ (NSData*)longToByteArray:(long)data {
    
    unsigned char byteArray[4] = { 0 };
    for (int index = 0; index < 4; index++) {
        unsigned char byte = data & 0xff;
        byteArray[index] = byte;
        data = (data - byte) / 256;
    }
    return [NSData dataWithBytes:byteArray length:4];
}

+ (long)byteArrayToLong:(NSData*)data {
    
    long value = 0;
    const unsigned char* byte = (const unsigned char*)data.bytes;
    for (int i = (int)data.length ; --i >= 0; ) {
        value = (value * 256) + byte[i];
    }
    return value;
}

+ (long)byteArrayToLong:(NSData*)data length:(int)len {
    
    long value = 0;
    const unsigned char* byte = (const unsigned char*)data.bytes;
    for (int i = len ; --i >= 0; ) {
        value = (value * 256) + byte[i];
    }
    return value;
}

+ (long)byteArrayToLong:(NSData*)data pos:(int)pos length:(int)len {
    
    long value = 0;
    const unsigned char* byte = (const unsigned char*)data.bytes + pos;
    for (int i = len ; --i >= 0; ) {
        value = (value * 256) + byte[i];
    }
    return value;
}

+ (NSString*)dataToHex:(NSData*)data {
    NSMutableString *str = [NSMutableString string];
    const Byte* ptr = data.bytes;
    for (int i = 0; i < data.length; i++) {
        [str appendFormat:@"%02X", ptr[i]];
    }
    return str;
}

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

@end
