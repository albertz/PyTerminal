//
//  NTGlobalPreferences.m
//  CocoatechCore
//
//  Created by sgehrman on Wed Jul 25 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTGlobalPreferences.h"
#import "NSString-Utilities.h"

@implementation NTGlobalPreferences

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

- (id)init;
{
    self = [super init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemColorsChangedNotification:)
                                                 name:NSSystemColorsDidChangeNotification
                                               object:nil];

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timeFormatString release];
    
    [super dealloc];
}

- (void)systemColorsChangedNotification:(NSNotification*)notification;
{
	mSystemColorVersion++;
}

- (UInt32)systemColorVersion;
{
	return mSystemColorVersion;
}

- (BOOL)finderDesktopEnabled;
{
	Boolean exists;
	BOOL result = CFPreferencesGetAppBooleanValue((CFStringRef)@"CreateDesktop", (CFStringRef)@"com.apple.finder", &exists);

	if (!exists)
		result = YES; // by default it's on I assume
	
	return result;
}

- (BOOL)setFinderDesktopEnabled:(BOOL)set;
{
	BOOL result = NO;
	
	if ([[NTGlobalPreferences sharedInstance] finderDesktopEnabled] != set)
	{
		// "defaults write com.apple.finder CreateDesktop 0"	
		CFPreferencesSetAppValue((CFStringRef)@"CreateDesktop", set ? kCFBooleanTrue : kCFBooleanFalse, (CFStringRef)@"com.apple.finder");
		CFPreferencesAppSynchronize((CFStringRef)@"com.apple.finder");
				
		result = YES;
	}
	
	return result;
}


- (NSArray*)finderToolbarItems;
{
	NSArray* result = nil;
	
	CFPreferencesAppSynchronize((CFStringRef)@"com.apple.finder");
	CFArrayRef ref = CFPreferencesCopyAppValue((CFStringRef)@"FXToolbarItems", (CFStringRef)@"com.apple.finder");
	if (ref)
	{
		result = [NSArray arrayWithArray:(NSArray*)ref];
		
		CFRelease(ref);
	}
		
	return result;
}

- (void)setFinderToolbarItems:(NSArray*)items;
{
	CFPreferencesSetAppValue((CFStringRef)@"FXToolbarItems", (CFPropertyListRef)items, (CFStringRef)@"com.apple.finder");
	CFPreferencesAppSynchronize((CFStringRef)@"com.apple.finder");
}

// sets NSFileViewer pref to "com.cocoatech.pathfinder"
- (BOOL)fileViewerPrefForBundleID:(NSString*)bundleID;
{
	BOOL result = NO;
	
	CFStringRef prefResult = CFPreferencesCopyAppValue((CFStringRef)@"NSFileViewer", (CFStringRef)bundleID);
	if (prefResult)
	{
		NSString* str = (NSString*)bundleID;
		
		if ([str isKindOfClass:[NSString class]])
			result = [[str lowercaseString] isEqualToString:@"com.cocoatech.pathfinder"];
		
		CFRelease(prefResult);
	}
	
	return result;
}

- (void)setFileViewerPref:(BOOL)set forBundleID:(NSString*)bundleID;
{	
	if (set)
		CFPreferencesSetAppValue((CFStringRef)@"NSFileViewer", (CFPropertyListRef)@"com.cocoatech.pathfinder", (CFStringRef)bundleID);
	else
		CFPreferencesSetAppValue((CFStringRef)@"NSFileViewer", NULL, (CFStringRef)bundleID);
	
	CFPreferencesAppSynchronize((CFStringRef)bundleID);
}

- (BOOL)useGraphiteAppearance;
{
	return ([NSColor currentControlTint] == NSGraphiteControlTint);
}

- (NSTimeInterval)doubleClickTime;
{
	return [NSEvent doubleClickInterval];
}

@end
