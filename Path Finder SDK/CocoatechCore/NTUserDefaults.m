//
//  NTUserDefaults.m
//  CocoaTechBase
//
//  Created by Steve Gehrman on 9/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NTUserDefaults.h"
#import "NTPrefNotification.h"
#import "NSUserDefaults-NTExtensions.h"

@interface NTUserDefaults ()
@property (nonatomic, retain) NSMutableArray *keysObserving;
@end

@interface NTUserDefaults (Private)
- (void)sendPrefChangedNotification:(NSString*)prefKey;
@end

@interface NTUserDefaults (KVO)
- (void)addKVObserver:(NSString*)keyPath;
- (void)removeKVObserver;
@end

@implementation NTUserDefaults

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

@synthesize keysObserving;

- (id)init;
{
	self = [super init];
	
    self.keysObserving = [NSMutableArray array];

	// we set the default ones here	
	[self notifyForDefault:@"kDrawLabelColorOnName"];
	[self notifyForDefault:@"kDrawLabelColorOnIcon"];
		
	return self;
}

- (void)dealloc;
{
	[self removeKVObserver];
    self.keysObserving = nil;
	
	[super dealloc];
}

- (void)notifyForDefault:(NSString*)theDefaultName;
{
	[self addKVObserver:theDefaultName];
}

// =============================================================================================
// Setters

- (void)setBool:(BOOL)set forKey:key;
{
    [[NSUserDefaults standardUserDefaults] setBool:set forKey:key];
	
    [self sendPrefChangedNotification:key];
}

- (void)setString:(NSString*)set forKey:key;
{
    [[NSUserDefaults standardUserDefaults] setObject:set forKey:key];
	
    [self sendPrefChangedNotification:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key;
{
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
    
    [self sendPrefChangedNotification:key];    
}

- (void)setInt:(NSInteger)integer forKey:key;
{
    [[NSUserDefaults standardUserDefaults] setInteger:integer forKey:key];
	
    [self sendPrefChangedNotification:key];
}

- (void)setUnsigned:(NSUInteger)value forKey:key;
{
    [[NSUserDefaults standardUserDefaults] setUnsignedInt:value forKey:key];
	
    [self sendPrefChangedNotification:key];
}

- (void)setObject:(id)obj forKey:key;
{
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
	
    [self sendPrefChangedNotification:key];
}

@end

@implementation NTUserDefaults (Private)

- (void)sendPrefChangedNotification:(NSString*)prefKey;
{
    NTPrefNotification* notif = [NTPrefNotification notificationWithPreference:prefKey];
	
    [notif sendNotification];
}

@end

@implementation NTUserDefaults (KVO)

- (void)addKVObserver:(NSString*)keyPath;
{
	if ([keyPath length])
	{
		[[self keysObserving] addObject:keyPath];
		[[NSUserDefaults standardUserDefaults] addObserver:self
												forKeyPath:keyPath
												   options:NSKeyValueObservingOptionOld
												   context:NULL];
	}
}

- (void)removeKVObserver;
{	
	for (NSString* keyPath in [self keysObserving])
		[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	if (object == [NSUserDefaults standardUserDefaults])
		[self sendPrefChangedNotification:keyPath];
}

@end

