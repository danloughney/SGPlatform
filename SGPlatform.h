//
//  SGPlatform.m
//
//  Created by Daniel Loughney, spookygroup.com on 9/17/13 with significant sourcing from http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
//  Feel free to copy, modify, and distribute as needed
//
// return the color of the device face.
// add this: http://osxdaily.com/2012/01/26/reading-iphone-serial-number/
//
// Apple Device reference for models and dimensions
// https://en.wikipedia.org/wiki/List_of_iOS_devices
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

// 0x0000000000100701
// 0b000000000000000000000000000000000 00000000 0010000 00000111 00000001

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

struct CGPhysicalSize {
    CGFloat width;
    CGFloat height;
    CGFloat depth;
};
typedef struct CGPhysicalSize CGPhysicalSize;

CG_INLINE CGPhysicalSize
CGPhysicalSizeMake(CGFloat width, CGFloat height, CGFloat depth)
{
    CGPhysicalSize size; size.width = width; size.height = height; size.depth = depth; return size;
}

@interface SGDeviceInfo : NSObject
@property (readwrite, strong) NSString *deviceType;
@property (readwrite, assign) unsigned long long bits;
@property (readwrite, assign) CGSize size;
@property (readwrite, assign) CGSize physicalScreenSize;
@property (readwrite, assign) CGPhysicalSize physicalDeviceSize;

@end

@interface SGPlatform : NSObject
@property (readonly, strong) NSString *hardwareString;
@property (readonly, strong) SGDeviceInfo *currentDeviceInfo;

+ (unsigned long long) bitMask;           // complete bitmask
+ (unsigned long long) deviceMask;        // device type bitmask
+ (unsigned long long) generation;        // generation value
+ (unsigned long long) subGeneration;     // subgeneration value

+ (CGSize) screenSize;
+ (CGSize) physicalScreenSize;
+ (CGPhysicalSize) physicalDeviceSize;
+ (NSString*)deviceType;

+ (BOOL) iPad;                      // is an iPad
+ (BOOL) iPadPro;                   // is an iPadPro
+ (BOOL) iPadMini;                  // is an iPad Mini
+ (BOOL) iPhone;                    // is an iPhone
+ (BOOL) iPod;                      // is an iPod

+ (void) mockiPad;
+ (void) mockiPadPro;
+ (void) mockiPhone5;
+ (void) mockiPhone6;
+ (void) mockiPhone6Plus;

@end

#define IS_IPHONE_6_PLUS (([SGPlatform bitMask] & DEVICE_IPHONE6PLUS) == DEVICE_IPHONE6PLUS)

#define IS_IPHONE_6      ((([SGPlatform bitMask] & DEVICE_IPHONE6) == DEVICE_IPHONE6) && \
                         !(([SGPlatform bitMask] & DEVICE_SIZE_PLUS)))

#define IS_IPHONE_5      (([SGPlatform bitMask] & DEVICE_IPHONE5) == DEVICE_IPHONE5)

#define IS_IPHONE_4INCH  ((([SGPlatform bitMask] & DEVICE_IPHONE5) == DEVICE_IPHONE5) || \
                          (([SGPlatform bitMask] & DEVICE_IPHONE5S) == DEVICE_IPHONE5S))

#define IS_IPHONE_3INCH  ((([SGPlatform bitMask] & DEVICE_IPHONE4) == DEVICE_IPHONE4) || \
                          (([SGPlatform bitMask] & DEVICE_IPHONE4S) == DEVICE_IPHONE4S) || \
                          (([SGPlatform bitMask] & DEVICE_IPHONE3GS) == DEVICE_IPHONE3GS))

#define IOS_VERSION         ([[UIDevice currentDevice].systemVersion intValue])
#define IOS_FLOAT_VERSION   ([[UIDevice currentDevice].systemVersion floatValue])

#define IS_IPAD ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
#define IS_IPAD_PRO ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && [SGPlatform iPadPro])
#define IS_IPHONE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )



