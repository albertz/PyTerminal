//
//  NTPrefNotification.h
//  CocoaTechBase
//
//  Created by Steve Gehrman on Fri Aug 30 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// app notifications
#define kNTPreferencesModifiedNotification @"kNTPreferencesModifiedNotification"
#define kNTObjectPreferencesModifiedNotification @"kNTObjectPreferencesModifiedNotification"

@interface NTPrefNotification : NSObject
{
    NSMutableSet* nameSet;
}

- (void)sendNotification;  // used for global preferences
- (void)sendNotificationWithDocument:(id)document;   // used for document preferences (message only sent to objects registerted with object)

+ (NTPrefNotification*)notification;
+ (NTPrefNotification*)notificationWithPreference:(NSString*)preference;
+ (NTPrefNotification*)notificationWithPreferences:(NSArray*)preferences;

// extracts the NTPrefNotification from a notification, returns nil if not found
+ (NTPrefNotification*)extractFromNotification:(NSNotification*)notification;

- (BOOL)isPreferenceChanged:(NSString*)preference;
- (BOOL)isAnyPreferenceChanged:(NSArray*)preferences;

- (void)addPreference:(NSString*)preference;
- (void)addPreferences:(NSArray*)preferences;

- (NSInteger)numPreferences;

@end
