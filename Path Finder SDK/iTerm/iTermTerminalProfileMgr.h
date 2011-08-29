/*
 **  iTermTerminalProfileMgr.h
 **
 **  Copyright (c) 2002, 2003, 2004
 **
 **  Author: Tianming Yang
 **
 **  Project: iTerm
 **
 **  Description: header file for terminal profile manager.
 **
 */

#import <Foundation/Foundation.h>


@interface iTermTerminalProfileMgr : NSObject {

	NSMutableDictionary *profiles;
}

// Class methods
+ (id)singleInstance;

	// Instance methods
- (id)init;
- (void)dealloc;

- (NSDictionary *) profiles;
- (void)setProfiles: (NSMutableDictionary *) aDict;
- (void)addProfileWithName: (NSString *) newProfile copyProfile: (NSString *) sourceProfile;
- (void)deleteProfileWithName: (NSString *) profileName;
- (BOOL) isDefaultProfile: (NSString *) profileName;
- (NSString *) defaultProfileName;


- (NSString *) typeForProfile:(NSString *) profileName;
- (void)setType: (NSString *) type forProfile:(NSString *) profileName;
- (NSStringEncoding) encodingForProfile:(NSString *) profileName;
- (void)setEncoding: (NSStringEncoding) encoding forProfile:(NSString *) profileName;
- (int) scrollbackLinesForProfile:(NSString *) profileName;
- (void)setScrollbackLines: (int) lines forProfile:(NSString *) profileName;
- (BOOL) silenceBellForProfile:(NSString *) profileName;
- (void)setSilenceBell: (BOOL) silent forProfile:(NSString *) profileName;
- (BOOL) showBellForProfile:(NSString *) profileName;
- (void)setShowBell: (BOOL) showBell forProfile:(NSString *) profileName;
- (BOOL) blinkCursorForProfile:(NSString *) profileName;
- (void)setBlinkCursor: (BOOL) blink forProfile:(NSString *) profileName;
- (BOOL) closeOnSessionEndForProfile:(NSString *) profileName;
- (void)setCloseOnSessionEnd: (BOOL) close forProfile:(NSString *) profileName;
- (BOOL) doubleWidthForProfile:(NSString *) profileName;
- (void)setDoubleWidth: (BOOL) doubleWidth forProfile:(NSString *) profileName;
- (BOOL) sendIdleCharForProfile:(NSString *) profileName;
- (void)setSendIdleChar: (BOOL) sent forProfile:(NSString *) profileName;
- (char) idleCharForProfile:(NSString *) profileName;
- (void)setIdleChar: (char) idle forProfile:(NSString *) profileName;
- (BOOL) xtermMouseReportingForProfile:(NSString *) profileName;
- (void)setXtermMouseReporting: (BOOL) xtermMouseReporting forProfile:(NSString *) profileName;
- (BOOL) appendTitleForProfile:(NSString *) profileName;
- (void)setAppendTitle: (BOOL) appendTitle forProfile:(NSString *) profileName;

@end

@interface iTermTerminalProfileMgr (Private)

- (float) _floatValueForKey: (NSString *) key inProfile: (NSString *) profileName;
- (void)_setFloatValue: (float) fval forKey: (NSString *) key inProfile: (NSString *) profileName;
- (int) _intValueForKey: (NSString *) key inProfile: (NSString *) profileName;
- (void)_setIntValue: (int) ival forKey: (NSString *) key inProfile: (NSString *) profileName;

@end
