//
//  SGPlatform.m
//
//  Created by Daniel Loughney, spookygroup.com on 9/17/13 with significant sourcing from:
//  http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
//
//  return the color of the device face.
//  http://osxdaily.com/2012/01/26/reading-iphone-serial-number/
//
//  Apple Device reference for models and dimensions
//  https://en.wikipedia.org/wiki/List_of_iOS_devices
//
//  https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
//

@import Foundation;
@import CoreGraphics;

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



