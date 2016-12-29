//
//  SGPlatform.m
//
/*  Created by Daniel Loughney, spookygroup.com on 9/17/13 with significant sourcing from:
    http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk

    And tremendous thanks to:
    http://en.wikipedia.org/wiki/List_of_iOS_devices
    http://theiphonewiki.com/wiki/Models

    Feel free to copy, modify, and distribute as needed
*/
#include <sys/types.h>
#include <sys/sysctl.h>
#import "SGPlatform.h"

@implementation SGDeviceInfo

+ (id) info:(NSString*)deviceType bits:(unsigned long long)bits size:(CGSize)size physicalScreenSize:(CGSize)physicalScreenSize physicalDeviceSize:(CGPhysicalSize)physicalDeviceSize {
    
    SGDeviceInfo *di = [[SGDeviceInfo alloc]init:deviceType bits:bits size:size physicalScreenSize:physicalScreenSize physicalDeviceSize:physicalDeviceSize];
    
    return di;
}

- (id) init:(NSString*)deviceType bits:(unsigned long long)bits size:(CGSize)screenSize physicalScreenSize:(CGSize)physicalScreenSize physicalDeviceSize:(CGPhysicalSize)physicalDeviceSize {
    self = [super init];
    if (self) {
        _deviceType = deviceType;
        _bits = bits;
        _size = screenSize;
        _physicalScreenSize = physicalScreenSize;
        _physicalDeviceSize = physicalDeviceSize;
    }
    return self;
}

@end

// static SGPlatform *thePlatform;

// private interface definition
@interface SGPlatform ()
@property (readonly, strong) NSDictionary *deviceInformation;
@property (readonly, assign, getter = getBits) unsigned long long bits;
@property (readonly, assign, getter = getScreenSize) CGSize screenSize;
@property (readonly, assign, getter = getPhysicalScreenSize) CGSize physicalScreenSize;
@property (readonly, assign, getter = getPhysicalDeviceSize) CGPhysicalSize physicalDeviceSize;
@property (readonly, strong, getter = getDeviceType) NSString *deviceType;


@end

#define DEVICE_UNKNOWN         (0)
#define DEVICE_IPHONE          (1 << 0)
#define DEVICE_IPAD            (1 << 1)
#define DEVICE_IPAD_MINI       (1 << 2)
#define DEVICE_IPAD_PRO        (1 << 3)
#define DEVICE_IPOD            (1 << 4)
#define DEVICE_IPHONE_C        (1 << 5)
#define DEVICE_SIZE_PLUS       (1 << 6)
#define DEVICE_SIMULATOR       (1 << 7)

#define DEVICE_MASK            (DEVICE_IPOD | DEVICE_IPHONE | DEVICE_IPAD | DEVICE_IPAD_MINI | DEVICE_SIMULATOR)

#define DEVICE_GENERATION_BASE ( 7 )
#define DEVICE_GENERATION1     (1 << (DEVICE_GENERATION_BASE + 1))
#define DEVICE_GENERATION2     (1 << (DEVICE_GENERATION_BASE + 2))
#define DEVICE_GENERATION3     (1 << (DEVICE_GENERATION_BASE + 3))
#define DEVICE_GENERATION4     (1 << (DEVICE_GENERATION_BASE + 4))
#define DEVICE_GENERATION5     (1 << (DEVICE_GENERATION_BASE + 5))
#define DEVICE_GENERATION6     (1 << (DEVICE_GENERATION_BASE + 6))
#define DEVICE_GENERATION7     (1 << (DEVICE_GENERATION_BASE + 7))
#define DEVICE_GENERATION8     (1 << (DEVICE_GENERATION_BASE + 8))
#define DEVICE_GENERATION9     (1 << (DEVICE_GENERATION_BASE + 9))
#define DEVICE_GENERATION10    (1 << (DEVICE_GENERATION_BASE + 10))
#define DEVICE_GENERATION_MASK (0xf << DEVICE_GENERATION_BASE)
#define DEVICE_GENERATION_MAX  (DEVICE_GENERATION10)

#define DEVICE_IPHONE3GS        (DEVICE_IPHONE | DEVICE_GENERATION2)
#define DEVICE_IPHONE4          (DEVICE_IPHONE | DEVICE_GENERATION3)
#define DEVICE_IPHONE4S         (DEVICE_IPHONE | DEVICE_GENERATION4)
#define DEVICE_IPHONE5          (DEVICE_IPHONE | DEVICE_GENERATION5)
#define DEVICE_IPHONE5S         (DEVICE_IPHONE | DEVICE_GENERATION6)
#define DEVICE_IPHONE6          (DEVICE_IPHONE | DEVICE_GENERATION7)
#define DEVICE_IPHONE6PLUS      (DEVICE_IPHONE | DEVICE_GENERATION7 | DEVICE_SIZE_PLUS)

#define DEVICE_SUBGEN_BASE     ( 15 )
#define DEVICE_SUBGEN1         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN2         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN3         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN4         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN5         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN6         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN7         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN8         ( 0 << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN9         ( 0 << DEVICE_SUBGEN_BASE)

#define DEVICE_SUBGEN_MASK     (0xf << DEVICE_SUBGEN_BASE)
#define DEVICE_SUBGEN_MAX      (DEVICE_SUBGEN7)


@implementation SGPlatform

#pragma public interface

+ (unsigned long long) bitMask {
    return [SGPlatform currentPlatform].bits;
}
+ (unsigned long long) deviceMask {
    return [SGPlatform currentPlatform].bits & DEVICE_MASK;
}
+ (unsigned long long) generation {
    return ([SGPlatform currentPlatform].bits & DEVICE_GENERATION_MASK) >> DEVICE_GENERATION_BASE;
}
+ (unsigned long long) subGeneration {
    return ([SGPlatform currentPlatform].bits & DEVICE_SUBGEN_MASK) >> DEVICE_SUBGEN_BASE;
}
+ (BOOL) iPad {
    return ([SGPlatform currentPlatform].bits & DEVICE_IPAD) == DEVICE_IPAD;
}
+ (BOOL) iPadPro {
    return ([SGPlatform currentPlatform].bits & DEVICE_IPAD_PRO) == DEVICE_IPAD_PRO;
}
+ (BOOL) iPadMini {
    return ([SGPlatform currentPlatform].bits & DEVICE_IPAD_MINI) == DEVICE_IPAD_MINI;
}
+ (BOOL) iPhone {
    return ([SGPlatform currentPlatform].bits & DEVICE_IPHONE) == DEVICE_IPHONE;
}
+ (BOOL) iPod {
    return ([SGPlatform currentPlatform].bits & DEVICE_IPOD) == DEVICE_IPOD;
}
+ (CGSize) screenSize {
    return [SGPlatform currentPlatform].screenSize;
}
+ (CGSize) physicalScreenSize {
    return [SGPlatform currentPlatform].physicalScreenSize;
}
+ (CGPhysicalSize) physicalDeviceSize {
    return [SGPlatform currentPlatform].physicalDeviceSize;
}
+ (NSString*)deviceType {
    return [SGPlatform currentPlatform].deviceType;
}

+ (NSString *) description {
    return [NSString stringWithFormat:@"%@ bits(0x%08llx) device(0x%04llx) generation(%llu) subGen(%llu)", [SGPlatform deviceType],[SGPlatform bitMask], [SGPlatform deviceMask], [SGPlatform generation], [SGPlatform subGeneration]];
}

#pragma - private class implementation

#pragma mark - singleton
static SGPlatform *__platform = nil;

+ (SGPlatform *)currentPlatform {
    if (!__platform) {
        __platform = [[SGPlatform alloc]init:nil];
    }
    return __platform;
}

#pragma mark - init
- (id) init:(NSString*)mock {
    self = [super init];

    if (self) {
        CGSize iPhone3inchScreenSize = CGSizeMake(89.0, 49);
        CGSize iPhone4inchScreenSize = CGSizeMake(100.0, 49);
        CGSize iPhone5inchScreenSize = CGSizeMake(0, 0);
        CGSize iPhone5point5inchScreenSize = CGSizeMake(0, 0);
        
        CGSize iPhone3inchDisplaySize = CGSizeMake(320, 480);
        CGSize iPhone4inchDisplaySize = CGSizeMake(320, 568);
        CGSize iPhone5inchDisplaySize = CGSizeMake(0, 0);
        CGSize iPhone5point5inchDisplaySize = CGSizeMake(0, 0);
        
        CGSize iPadDisplaySize = CGSizeMake(1024, 768);
        
        _deviceInformation = @{
                               // iPhone 2G";
                               @"iPhone1,1" : [SGDeviceInfo info:@"iPhone 2G"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION1 | DEVICE_SUBGEN1)
                                                            size:iPhone3inchDisplaySize
                                              physicalScreenSize:iPhone3inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(115.2, 62.1, 12.3)],

                               // iPhone 3G"
                               @"iPhone1,2" : [SGDeviceInfo info:@"iPhone 3G"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION1 | DEVICE_SUBGEN2)
                                                            size:iPhone3inchDisplaySize
                                              physicalScreenSize:iPhone3inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(115.2, 62.1, 12.3)],
                               
                               // iPhone 3GS";
                               @"iPhone2,1" : [SGDeviceInfo info:@"iPhone 3GS"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION2 | DEVICE_SUBGEN1)
                                                            size:iPhone3inchDisplaySize
                                              physicalScreenSize:iPhone3inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(115.2, 62.1, 12.3)],
                               
                               // iPhone 4";
                               @"iPhone3,1" : [SGDeviceInfo info:@"iPhone 4"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION3 | DEVICE_SUBGEN1)
                                                            size:iPhone3inchDisplaySize
                                              physicalScreenSize:iPhone3inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(115.2, 58.6, 9.3)],
                               
                               // iPhone 4";
                               @"iPhone3,2" : [SGDeviceInfo info:@"iPhone 4"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION3 | DEVICE_SUBGEN2)
                                                            size:iPhone3inchDisplaySize
                                              physicalScreenSize:iPhone3inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(115.2, 58.6, 9.3)],
                               
                               // iPhone 4 (CDMA)"
                               @"iPhone3,3" : [SGDeviceInfo info:@"iPhone 4 (CDMA)"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION3 | DEVICE_SUBGEN3)
                                                            size:iPhone3inchDisplaySize
                                              physicalScreenSize:iPhone3inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(115.2, 58.6, 9.3)],
                               
                               // iPhone 4S";
                               @"iPhone4,1" : [SGDeviceInfo info:@"iPhone 4S"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION4 | DEVICE_SUBGEN1)
                                                            size:iPhone3inchDisplaySize
                                              physicalScreenSize:iPhone3inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(115.2, 58.6, 9.3)],
                               

                               // iPhone 5";
                               @"iPhone5,1" : [SGDeviceInfo info:@"iPhone 5"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION5 | DEVICE_SUBGEN1)
                                                            size:iPhone4inchDisplaySize
                                              physicalScreenSize:iPhone4inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(123.8, 58.6, 7.6)],
                               
                               // iPhone 5 (GSM+CDMA)
                               @"iPhone5,2" : [SGDeviceInfo info:@"iPhone 5 (CSM+CDMA)"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION5 | DEVICE_SUBGEN2)
                                                            size:iPhone4inchDisplaySize
                                              physicalScreenSize:iPhone4inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(123.8, 58.6, 7.6)],
                               
                               // iPhone 5C
                               @"iPhone5,3" : [SGDeviceInfo info:@"iPhone 5C"
                                                            bits:(DEVICE_IPHONE | DEVICE_IPHONE_C | DEVICE_GENERATION5 | DEVICE_SUBGEN3)
                                                            size:iPhone4inchDisplaySize
                                              physicalScreenSize:iPhone4inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(124.4, 59.2, 8.97)],
                               
                               // iPhone 5C
                               @"iPhone5,4" : [SGDeviceInfo info:@"iPhone 5C"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION5 | DEVICE_SUBGEN4)
                                                            size:iPhone4inchDisplaySize
                                              physicalScreenSize:iPhone4inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(124.4, 59.2, 8.97)],
                               

                               // iPhone 5S";
                               @"iPhone6,1" : [SGDeviceInfo info:@"iPhone 5S"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION6 | DEVICE_SUBGEN1)
                                                            size:iPhone4inchDisplaySize
                                              physicalScreenSize:iPhone4inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(123.8, 58.6, 7.6)],
                               
                               // iPhone 5S";
                               @"iPhone6,2" : [SGDeviceInfo info:@"iPhone 5S"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION6 | DEVICE_SUBGEN2)
                                                            size:iPhone4inchDisplaySize
                                              physicalScreenSize:iPhone4inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(123.8, 58.6, 7.6)],
                               
                               // iPhone 5SE";
                               @"iPhone8,4" : [SGDeviceInfo info:@"iPhone SE"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION8 | DEVICE_SUBGEN4)
                                                            size:iPhone4inchDisplaySize
                                              physicalScreenSize:iPhone4inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(123.8, 58.6, 7.6)],
                               

                               // iPhone 6 Plus";
                               @"iPhone7,1" : [SGDeviceInfo info:@"iPhone 6 Plus"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION7 | DEVICE_SUBGEN1 | DEVICE_SIZE_PLUS)
                                                            size:iPhone5point5inchDisplaySize
                                              physicalScreenSize:iPhone5point5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],

                               // iPhone 6";
                               @"iPhone7,2" : [SGDeviceInfo info:@"iPhone 6"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION7 | DEVICE_SUBGEN2)
                                                            size:iPhone5inchDisplaySize
                                              physicalScreenSize:iPhone5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               // iPhone 6S";
                               @"iPhone8,1" : [SGDeviceInfo info:@"iPhone 6S"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION8 | DEVICE_SUBGEN1)
                                                            size:iPhone5inchDisplaySize
                                              physicalScreenSize:iPhone5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],

                               // iPhone 6S Plus";
                               @"iPhone8,2" : [SGDeviceInfo info:@"iPhone 6S Plus"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION8 | DEVICE_SUBGEN1 | DEVICE_SIZE_PLUS)
                                                            size:iPhone5point5inchDisplaySize
                                              physicalScreenSize:iPhone5point5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],

                               // iPhone 7";
                               @"iPhone9,1" : [SGDeviceInfo info:@"iPhone 7"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION9 | DEVICE_SUBGEN1)
                                                            size:iPhone5inchDisplaySize
                                              physicalScreenSize:iPhone5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               @"iPhone9,3" : [SGDeviceInfo info:@"iPhone 7"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION9 | DEVICE_SUBGEN3)
                                                            size:iPhone5inchDisplaySize
                                              physicalScreenSize:iPhone5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],

                               // iPhone 7 Plus";
                               @"iPhone9,2" : [SGDeviceInfo info:@"iPhone 7 Plus"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION9 | DEVICE_SUBGEN2 | DEVICE_SIZE_PLUS)
                                                            size:iPhone5point5inchDisplaySize
                                              physicalScreenSize:iPhone5point5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               // iPhone 7 Plus";
                               @"iPhone9,4" : [SGDeviceInfo info:@"iPhone 7 Plus"
                                                            bits:(DEVICE_IPHONE | DEVICE_GENERATION9 | DEVICE_SUBGEN4 | DEVICE_SIZE_PLUS)
                                                            size:iPhone5point5inchDisplaySize
                                              physicalScreenSize:iPhone5point5inchScreenSize
                                              physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               
                               // IPADS/////////////////////////////////////////////////////////////////////
                               @"iPad1,1" : [SGDeviceInfo info:@"iPad 1"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION1 | DEVICE_SUBGEN1)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(242.8, 189.7, 13.4)],
                               
                               @"iPad1,2" : [SGDeviceInfo info:@"iPad 1 (3G)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION1 | DEVICE_SUBGEN2)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(242.8, 189.7, 13.4)],
                               
                               @"iPad2,1" : [SGDeviceInfo info:@"iPad 2 (WiFi)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION2 | DEVICE_SUBGEN1)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241.2, 185.7, 8.8)],
                
                               @"iPad2,2" : [SGDeviceInfo info:@"iPad 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION2 | DEVICE_SUBGEN2)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241.2, 185.7, 8.8)],
                               
                               @"iPad2,3" : [SGDeviceInfo info:@"iPad2 (CDMA)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION2 | DEVICE_SUBGEN3)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241.2, 185.7, 8.8)],
                               
                               @"iPad2,4" : [SGDeviceInfo info:@"iPad 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION2 | DEVICE_SUBGEN4)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241.2, 185.7, 8.8)],
                               
                               @"iPad3,1" : [SGDeviceInfo info:@"iPad 3 (WiFi)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION3 | DEVICE_SUBGEN1)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241, 186, 9.4)],
                               
                               @"iPad3,2" : [SGDeviceInfo info:@"iPad 3 (CSM+CDMA)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION3 | DEVICE_SUBGEN2)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241, 186, 9.4)],
                               
                               @"iPad3,3" : [SGDeviceInfo info:@"iPad 3"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION3 | DEVICE_SUBGEN3)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241, 186, 9.4)],

                               @"iPad3,4" : [SGDeviceInfo info:@"iPad 4 (WiFi)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN4)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241, 186, 9.4)],
                               
                               @"iPad3,5" : [SGDeviceInfo info:@"iPad 4"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN5)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(241, 186, 9.4)],
                               
                               @"iPad3,6" : [SGDeviceInfo info:@"iPad 4 (GSM+CDMA)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN6)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(100, 200)
                                            physicalDeviceSize:CGPhysicalSizeMake(241, 186, 9.4)],
                               
                               @"iPad4,1" : [SGDeviceInfo info:@"iPad Air"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION5 | DEVICE_SUBGEN1)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(240, 169.5, 7.5)],
                               
                               @"iPad4,2" : [SGDeviceInfo info:@"iPad Air"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION5 | DEVICE_SUBGEN2)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(240, 169.5, 7.5)],
                               
                               @"iPad4,3" : [SGDeviceInfo info:@"iPad Air"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION5 | DEVICE_SUBGEN3)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(240, 169.5, 7.5)],

                               @"iPad5,3" : [SGDeviceInfo info:@"iPad Air 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION5 | DEVICE_SUBGEN1)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(240, 169.5, 7.5)],
                               
                               @"iPad5,4" : [SGDeviceInfo info:@"iPad Air 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION5 | DEVICE_SUBGEN1)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(240, 169.5, 7.5)],
                               
                               
                               // iPad MINI /////////////////////////////////////////////////////////////////////////////
                               @"iPad2,5" : [SGDeviceInfo info:@"iPad Mini (WiFi)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION2 | DEVICE_SUBGEN5 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.2)],

                               @"iPad2,6" : [SGDeviceInfo info:@"iPad Mini"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION2 | DEVICE_SUBGEN6 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.2)],
                               
                               @"iPad2,7" : [SGDeviceInfo info:@"iPad Mini (GSM+CDMA)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION2 | DEVICE_SUBGEN7 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.2)],

                               @"iPad4,4" : [SGDeviceInfo info:@"iPad Mini 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN4 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],
                               
                               @"iPad4,5" : [SGDeviceInfo info:@"iPad Mini 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN5 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],

                               @"iPad4,6" : [SGDeviceInfo info:@"iPad Mini 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN6 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],
                               
                               @"iPad4,7" : [SGDeviceInfo info:@"iPad Mini 2"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN7 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],
                               
                               @"iPad4,8" : [SGDeviceInfo info:@"iPad Mini 3"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN8 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],
                               
                               @"iPad4,9" : [SGDeviceInfo info:@"iPad Mini 3"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION4 | DEVICE_SUBGEN9 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],

                               @"iPad5,1" : [SGDeviceInfo info:@"iPad Mini 4"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION5 | DEVICE_SUBGEN1 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],

                               @"iPad5,2" : [SGDeviceInfo info:@"iPad Mini 4"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION5 | DEVICE_SUBGEN2 | DEVICE_IPAD_MINI)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(200, 134.7, 7.5)],

                               // iPad Pro /////////////////////////////////////////////////////////////////////////////
                               @"iPad6,7" : [SGDeviceInfo info:@"iPad Pro 12.9\" (Wi-Fi)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION6 | DEVICE_SUBGEN7 | DEVICE_IPAD_PRO)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(305.7, 220.6, 6.9)], // ?

                               @"iPad6,8" : [SGDeviceInfo info:@"iPad Pro 12.9\" (Cellular)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION6 | DEVICE_SUBGEN8 | DEVICE_IPAD_PRO)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(305.7, 220.6, 6.9)], // ?
                               
                               
                               @"iPad6,3" : [SGDeviceInfo info:@"iPad Pro 9.7\" (Wi-Fi)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION6 | DEVICE_SUBGEN3 | DEVICE_IPAD_PRO)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(305.7, 220.6, 6.9)], // ?

                               @"iPad6,4" : [SGDeviceInfo info:@"iPad Pro 9.7\" (Cellular)"
                                                          bits:(DEVICE_IPAD | DEVICE_GENERATION6 | DEVICE_SUBGEN4 | DEVICE_IPAD_PRO)
                                                          size:iPadDisplaySize
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(305.7, 220.6, 6.9)], // ?

                               
                               // IPOD //////////////////////////////////////////////////////////////////////////////////
                               @"iPod1,1" : [SGDeviceInfo info:@"iPod Touch (Gen 1)"
                                                          bits:(DEVICE_IPOD | DEVICE_GENERATION1 | DEVICE_SUBGEN1)
                                                          size:iPhone3inchDisplaySize
                                            physicalScreenSize:iPhone3inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               @"iPod2,1" : [SGDeviceInfo info:@"iPod Touch (Gen 2)"
                                                          bits:(DEVICE_IPOD | DEVICE_GENERATION2 | DEVICE_SUBGEN1)
                                                          size:iPhone3inchDisplaySize
                                            physicalScreenSize:iPhone3inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               @"iPod3,1" : [SGDeviceInfo info:@"iPod Touch (Gen 3)"
                                                          bits:(DEVICE_IPOD | DEVICE_GENERATION3 | DEVICE_SUBGEN1)
                                                          size:iPhone3inchDisplaySize
                                            physicalScreenSize:iPhone3inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               @"iPod4,1" : [SGDeviceInfo info:@"iPod Touch (Gen 4)"
                                                          bits:(DEVICE_IPOD | DEVICE_GENERATION4 | DEVICE_SUBGEN1)
                                                          size:iPhone3inchDisplaySize
                                            physicalScreenSize:iPhone3inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               @"iPod5,1" : [SGDeviceInfo info:@"iPod Touch (Gen 5)"
                                                          bits:(DEVICE_IPOD | DEVICE_GENERATION5 | DEVICE_SUBGEN1)
                                                          size:iPhone4inchDisplaySize
                                            physicalScreenSize:iPhone4inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
   
                               // there are two entries for 6Gen iPod as there is some ambiguity on the device code
                               @"iPod6,1" : [SGDeviceInfo info:@"iPod Touch (Gen 6)"
                                                          bits:(DEVICE_IPOD | DEVICE_GENERATION7 | DEVICE_SUBGEN1)
                                                          size:iPhone4inchDisplaySize
                                            physicalScreenSize:iPhone4inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
                               
                               @"iPod7,1" : [SGDeviceInfo info:@"iPod Touch (Gen 6)"
                                                          bits:(DEVICE_IPOD | DEVICE_GENERATION7 | DEVICE_SUBGEN1)
                                                          size:iPhone4inchDisplaySize
                                            physicalScreenSize:iPhone4inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],
    
                               
                               // SIMULATORS //////////////////////////////////////////////////////////////////////////////////
                               
                               @"x86_64" : [SGDeviceInfo info:@"iOS Simulator x86_64"
                                                          bits:(DEVICE_SIMULATOR)
                                                          size:iPhone4inchDisplaySize
                                            physicalScreenSize:iPhone4inchScreenSize
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],

                               @"i386" : [SGDeviceInfo info:@"iOS Simulator i386"
                                                         bits:(DEVICE_SIMULATOR)
                                                         size:iPhone4inchDisplaySize
                                           physicalScreenSize:iPhone4inchScreenSize
                                           physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)],

                               // DEFAULT ////////////////////////////////////////////////////////////////////////////////////
                               
                               @"UNKNOWN" : [SGDeviceInfo info:@"UNKNOWN DEVICE"
                                                          bits:0
                                                          size:CGSizeMake(0, 0)
                                            physicalScreenSize:CGSizeMake(0, 0)
                                            physicalDeviceSize:CGPhysicalSizeMake(0, 0, 0)]
                               };
        
#if 0
        if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
        if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
        if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
        if ([platform isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";
        if ([platform isEqualToString:@"Watch1,1"])     return @"Apple Watch Series 1 (38mm, S1)";
        if ([platform isEqualToString:@"Watch1,2"])     return @"Apple Watch Series 1 (42mm, S1)";
        if ([platform isEqualToString:@"Watch2,6"])     return @"Apple Watch Series 1 (38mm, S1P)";
        if ([platform isEqualToString:@"Watch2,7"])     return @"Apple Watch Series 1 (42mm, S1P)";
        if ([platform isEqualToString:@"Watch2,3"])     return @"Apple Watch Series 2 (38mm, S2)";
        if ([platform isEqualToString:@"Watch2,4"])     return @"Apple Watch Series 2 (42mm, S2)";
#endif
        _hardwareString = [SGPlatform retrieveHardwareString];
        if (mock && ([_hardwareString isEqualToString:@"x86_64"] || [_hardwareString isEqualToString:@"i386"])) {
            _hardwareString = mock;
        }
        
        // get the device info for this device and if not found/valid, return the UNKNOWN device
        SGDeviceInfo *di = _deviceInformation[_hardwareString];
        if (!di) {
            di = _deviceInformation[@"UNKNOWN"];
            
            // check the strings to see if we can find out which device it is, at least.  Make the generation the maximum that it could be just in case the caller is doing comparisons.  The device must be later than any other device we know about.
            NSRange range = [_hardwareString rangeOfString:@"iPhone"];
            if (range.location != NSNotFound) {
                di.bits = DEVICE_IPHONE | DEVICE_GENERATION_MAX;
            } else {
                range = [_hardwareString rangeOfString:@"iPad"];
                if (range.location == NSNotFound) {
                    di.bits = DEVICE_IPAD | DEVICE_GENERATION_MAX | DEVICE_SUBGEN_MAX;
                } else {
                    range = [_hardwareString rangeOfString:@"iPod"];
                    if (range.location == NSNotFound) {
                        di.bits = DEVICE_IPOD | DEVICE_GENERATION_MAX | DEVICE_SUBGEN_MAX;
                    }
                }
            }
        }
        
        _currentDeviceInfo = di;
    }
    return self;
}

+ (void) mockWithHardwareString:(NSString*)hardwareString {
#ifdef DEBUG
    // only allow mocking if we are in debug mode
    __platform = [[SGPlatform alloc]init:hardwareString];
#endif
}

+ (void) mockiPad {
    [SGPlatform mockWithHardwareString:@"iPad5,4"];
}
+ (void) mockiPadPro {
    [SGPlatform mockWithHardwareString:@"iPad6,7"];
}
+ (void) mockiPhone5 {
    [SGPlatform mockWithHardwareString:@"iPhone6,2"];
}
+ (void) mockiPhone6 {
    [SGPlatform mockWithHardwareString:@"iPhone7,2"];
}
+ (void) mockiPhone6Plus {
    [SGPlatform mockWithHardwareString:@"iPhone7,1"];
}

+ (NSString*) retrieveHardwareString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

+ (NSString*)getDeviceType {
    return [self currentPlatform].deviceType;
}

- (unsigned long long) getBits {
    return self.currentDeviceInfo.bits;
}

- (CGSize) getScreenSize {
    return self.currentDeviceInfo.size;
}

- (CGSize) getPhysicalScreenSize {
    return self.currentDeviceInfo.physicalScreenSize;
}

- (CGPhysicalSize) getPhysicalDeviceSize {
    return self.currentDeviceInfo.physicalDeviceSize;
}

@end
