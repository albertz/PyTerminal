//
//  NTAppearanceMgr.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/3/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTAppearanceMgr.h"
#import "NTKVObserverProxy.h"

@interface NTAppearanceMgr (Private)
- (void)reset:(BOOL)sendNotifcation;
@end

@interface NTAppearanceMgr (Protocols) <NTKVObserverProxyDelegateProtocol>
@end

@interface NTAppearanceMgr (KVO) 
- (void)addKVObserver; 
- (void)removeKVObserver; 
@end

@implementation NTAppearanceMgr

@synthesize sizeMode;
@synthesize buttonFont;
@synthesize barHeight;
@synthesize headerFont, headerHeight;
@synthesize statusFont, observerProxy, buildNumber;

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

- (id)init;
{
	self = [super init];
	
	[self addKVObserver];
	
	[self reset:NO];
	
	return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
	[self removeKVObserver];
	
	self.buttonFont = nil;
	self.statusFont = nil;
	self.headerFont = nil;
	
	[super dealloc];
}

@end

@implementation NTAppearanceMgr (Private)

- (void)reset:(BOOL)sendNotifcation;
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useLargeAppearanceMode"])
	{
		self.buttonFont = [NSFont boldSystemFontOfSize:13];
		self.sizeMode = NTAppearance_Large;
		self.barHeight = 23;
		
		self.headerFont = [NSFont systemFontOfSize:12];
		self.headerHeight = 17;
		
		self.statusFont = [NSFont boldSystemFontOfSize:12];
	}
	else
	{
		self.buttonFont = [NSFont boldSystemFontOfSize:11];
		self.sizeMode = NTAppearance_Regular;
		self.barHeight = 21;
		
		self.headerFont = [NSFont systemFontOfSize:11];
		self.headerHeight = 15;
		
		self.statusFont = [NSFont boldSystemFontOfSize:11];
	}
	
	self.buildNumber++;
	
	if (sendNotifcation)
		[[NSNotificationCenter defaultCenter] postNotificationName:kNTAppearanceMgrNotification object:self];
}

@end

@implementation NTAppearanceMgr (Protocols)

// NTKVObserverProxyDelegateProtocol 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context; 
{ 
	if (object == [NSUserDefaults standardUserDefaults]) 
	{ 
		if ([keyPath isEqualToString:@"useLargeAppearanceMode"]) 
			[self reset:YES]; 
	} 
} 

@end 

@implementation NTAppearanceMgr (KVO) 

- (void)addKVObserver; 
{ 
	self.observerProxy = [NTKVObserverProxy proxy:self]; 
	
	[[NSUserDefaults standardUserDefaults] addObserver:self.observerProxy 
											forKeyPath:@"useLargeAppearanceMode" 
											   options:NSKeyValueObservingOptionOld 
											   context:NULL]; 
} 

- (void)removeKVObserver; 
{ 
	[[NSUserDefaults standardUserDefaults] removeObserver:self.observerProxy forKeyPath:@"useLargeAppearanceMode"]; 
	
	self.observerProxy.delegate = nil; 
	self.observerProxy = nil; 
} 

@end 

