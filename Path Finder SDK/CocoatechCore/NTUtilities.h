//
//  NTUtilities.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Mon Dec 17 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define LEAKOK(x) [[x autorelease] hold]

@interface NTUtilities : NSObject {

}

+ (NSString*)OSVersionString;
+ (NSString*)OSVersionDescription;

+ (unsigned)versionStringToInt:(NSString*)version;

+ (NSString*)applicationVersion;
+ (NSString*)applicationBuild;

+ (NSNumber*)applicationVersionAsNumber;  // 4.6.2 = 462
+ (NSString*)applicationName;
+ (NSString*)applicationBundleIdentifier;
+ (NSString*)applicationCreatorCode;
+ (NSString*)usersEmailAddress;
+ (NSString *)computerName;
+ (NSString*)ipAddress:(NSString**)outInterface;

+ (BOOL)runningOnTiger;
+ (BOOL)runningOnLeopard;
+ (BOOL)runningOnSnowLeopard;

	// 0x1047 == 10.4.7
+ (BOOL)osVersionIsAtLeast:(unsigned)osVersion;

    // OSType code conversion
+ (unsigned int)stringToInt:(NSString*)stringValue;
+ (NSString*)intToString:(unsigned int)intValue;
+ (NSString*)MACAddress;

+ (BOOL)compatibleWithLayerBackedViews;
+ (BOOL)machineIdleForMinutes:(int)inMinutes;

// uses NSWorkspace to trash
+ (void)moveToTrash:(NSString*)path;
+ (void)moveContentsToTrash:(NSString*)folder;

@end

void NSLogRect(NSString* title, NSRect rect);
void NSLogErr(NSString* title, int err);
NSString* NSErrorString(OSStatus error);
void NSLogNULL(NSString *format, ...);  // Use this to easily disable an NSLog

@interface NSObject (LEAKOK)

- (id)hold;  // used by LEAKOK, don't use on it's own, just a [self retain]

@end
