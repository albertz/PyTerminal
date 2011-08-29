//
//  NTSCPrefsListener.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/15/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTSCPrefsListener.h"
#import "NTUtilities.h"

static void allPreferencesCallBack(SCPreferencesRef prefs,
								   SCPreferencesNotification notificationType,
								   void *info);

static void ipPreferenceCallBack(SCDynamicStoreRef store,
								 CFArrayRef changedKeys,
								 void *context);

@interface NTSCPrefsListener ()
@property (nonatomic, assign) SCPreferencesRef prefsRef;
@property (nonatomic, retain) NSString* computerName;
@property (nonatomic, retain) NSString* networkState;
@end

@interface NTSCPrefsListener (Private)
- (void)setupAllPrefsNotification;
- (void)setupIPPrefNotification;
- (void)sendNotification:(NSString*)notificationName;
@end

@implementation NTSCPrefsListener

@synthesize prefsRef, computerName, networkState, networkStateID;

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

- (id)init;
{
	self = [super init];
	
	self.computerName = [NTUtilities computerName];
	
	[self setupAllPrefsNotification];
	[self setupIPPrefNotification];
	
	return self;
}

- (void)dealloc;
{
	if (self.prefsRef)
	{
		SCPreferencesUnscheduleFromRunLoop(self.prefsRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
		CFRelease(self.prefsRef);
	}

	self.computerName = nil;
	self.networkState = nil;

	[super dealloc];
}

@end

@implementation NTSCPrefsListener (Private)

- (void)setupIPPrefNotification;
{
	SCDynamicStoreContext context = { 0, self, NULL, NULL, NULL };
	SCDynamicStoreRef store = SCDynamicStoreCreate(NULL, CFSTR("com.cocoatech.pathfinder"), ipPreferenceCallBack, &context);
	if (store)
	{
		CFMutableArrayRef patterns = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
		if (patterns)
		{
			// Create a pattern list containing just one pattern,
			// then tell SCF that we want to watch changes in keys
			// that match that pattern list, then create our run loop
			// source.
			// The pattern is "State:/Network/Service/[^/]+/IPv4".
			CFStringRef pattern = SCDynamicStoreKeyCreateNetworkServiceEntity(NULL,
																			  kSCDynamicStoreDomainState,
																			  kSCCompAnyRegex,
																			  kSCEntNetIPv4);
			
			if (pattern)
			{
				CFArrayAppendValue(patterns, pattern);
				CFRelease(pattern);
			}
			
			SCDynamicStoreSetNotificationKeys(store, NULL, patterns);
			
			CFRunLoopSourceRef rls = SCDynamicStoreCreateRunLoopSource(NULL, store, 0);
			if (rls)
			{
				CFRunLoopAddSource(CFRunLoopGetMain(), rls, kCFRunLoopCommonModes);
				
				CFRelease(rls);
			}
			
			CFRelease(patterns);
		}
		CFRelease(store);
	}
}

- (void)setupAllPrefsNotification;
{
	self.prefsRef = SCPreferencesCreate(NULL, CFSTR("com.cocoatech.pathfinder"), NULL);
	
	SCPreferencesContext prefcontext;
	bzero(&prefcontext,sizeof(SCPreferencesContext));
	prefcontext.info = self;
	
	SCPreferencesSetCallback(self.prefsRef,allPreferencesCallBack,&prefcontext);
	
	SCPreferencesScheduleWithRunLoop(self.prefsRef, CFRunLoopGetMain(),kCFRunLoopDefaultMode);
}

- (void)sendNotification:(NSString*)notificationName;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

@end

static void allPreferencesCallBack(SCPreferencesRef prefs,
								   SCPreferencesNotification notificationType,
								   void *info)
{
	NTSCPrefsListener* listener = (NTSCPrefsListener*)info;
	
	if ([listener isKindOfClass:[NTSCPrefsListener class]])
	{	
		if ((notificationType & kSCPreferencesNotificationCommit) == kSCPreferencesNotificationCommit)
		{
			NSString* newComputerName = [NTUtilities computerName];
			if (![newComputerName isEqualToString:listener.computerName])
			{
				listener.computerName = newComputerName;
				
				[listener sendNotification:kNTComputerNamedChangedNotification];
			}
		}
	}
}

static void ipPreferenceCallBack(SCDynamicStoreRef store, CFArrayRef changedKeys, void *context)
{
	NTSCPrefsListener* listener = (NTSCPrefsListener*)context;
	
	if ([listener isKindOfClass:[NTSCPrefsListener class]])
	{		
		BOOL notify = NO;
		NSString* interface;
		NSString* ipAddress = [NTUtilities ipAddress:&interface];
		NSString* newNetworkState = [NSString stringWithFormat:@"%@:%@", interface, ipAddress];
				
		if (listener.networkState)
			notify = ![listener.networkState isEqualToString:newNetworkState];
		else
			notify = YES;
				
		if (notify)
		{
			listener.networkStateID += 1;
			listener.networkState = newNetworkState;
	
			[listener sendNotification:kNTIPAddressChangedNotification];
		}
	}
}
