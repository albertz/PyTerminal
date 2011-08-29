//
//  NTKeyEventMonitor.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTKeyEventMonitor.h"
#import "NTKeyEventMonitorToken.h"
#import "NSThread-NTExtensions.h"

@interface NTKeyEventMonitor ()
@property (nonatomic, retain) NSMutableDictionary *hotKeyMap;
@property (nonatomic, retain) id eventMonitor;
@end

@interface NTKeyEventMonitor (Private)
- (void)installMonitor;
- (void)sendNotification:(NTKeyEventMonitorToken*)theToken;
- (NSString*)keyForHotKey:(unichar)hotKey
			modifierFlags:(NSUInteger)modifierFlags;

- (void)removeTokenFromMap:(NTKeyEventMonitorToken*)theToken;
- (void)addTokenToMap:(NTKeyEventMonitorToken*)theToken;
@end

@implementation NTKeyEventMonitor

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

@synthesize hotKeyMap;
@synthesize eventMonitor;

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.hotKeyMap = nil;
    self.eventMonitor = nil;
    [super dealloc];
}

- (void)removeHotKey:(id)keyToken;
{
	[self removeTokenFromMap:keyToken];
}

- (id)setHotKey:(unichar)hotKey 
	 identifier:(NSInteger)identifier 
  modifierFlags:(NSUInteger)modifierFlags;
{	
	NTKeyEventMonitorToken* result = nil;
	
    if (hotKey)
    {		
		result = [NTKeyEventMonitorToken token:hotKey
									identifier:identifier
								 modifierFlags:modifierFlags];
		
		[self addTokenToMap:result];
	}
	
	return result;
}

@end

@implementation NTKeyEventMonitor (Private)

- (void)removeTokenFromMap:(NTKeyEventMonitorToken*)theToken;
{
	if (![NSThread isMainThread])
		NSLog(@"-[%@ %@] not thread safe", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

	NSString* theKey = [self keyForHotKey:theToken.hotKey modifierFlags:theToken.modifierFlags];
	
	NSMutableDictionary* subDict = [self.hotKeyMap objectForKey:theKey];
	if (subDict)
		[subDict removeObjectForKey:[NSNumber numberWithUnsignedInteger:theToken.identifier]];
}

- (void)addTokenToMap:(NTKeyEventMonitorToken*)theToken;
{
	if (![NSThread isMainThread])
		NSLog(@"-[%@ %@] not thread safe", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

	[self installMonitor];
	
	NSString* theKey = [self keyForHotKey:theToken.hotKey modifierFlags:theToken.modifierFlags];
	if (theKey)
	{
		NSMutableDictionary* subDict = [self.hotKeyMap objectForKey:theKey];
		
		if (!subDict)
		{
			subDict = [NSMutableDictionary dictionary];
			[self.hotKeyMap setObject:subDict forKey:theKey];
		}
		
		[subDict setObject:theToken forKey:[NSNumber numberWithUnsignedInteger:theToken.identifier]];
	}
}

- (NSString*)keyForHotKey:(unichar)hotKey
		 modifierFlags:(NSUInteger)modifierFlags;
{
	modifierFlags &= (NSShiftKeyMask | 
					  NSControlKeyMask |
					  NSAlternateKeyMask |
					  NSCommandKeyMask |
					  NSFunctionKeyMask);
		
	NSString* result = [NSString stringWithFormat:@"%lu:%lu", hotKey, modifierFlags];
	
	return result;
}

- (void)sendNotification:(NTKeyEventMonitorToken*)theToken;
{
	if ([NSThread isMainThread])
		[[NSNotificationCenter defaultCenter] postNotificationName:kNTKeyEventMonitorNotification object:[NTKeyEventMonitor sharedInstance] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:theToken.identifier], @"identifier", nil]];
	else
		[self performSelectorOnMainThread:@selector(sendNotification) withObject:theToken];
}

- (void)installMonitor;
{
	if (!self.eventMonitor)
	{
		self.eventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:
							 ^(NSEvent *incomingEvent) 
							 {
								 if (![NSThread isMainThread])
									 NSLog(@"-[%@ %@] not thread safe", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
								 								 
								 if ([incomingEvent type] == NSKeyDown)
								 {
									 NSString* characters = [incomingEvent characters];
									 
									 if ([characters length])
									 {
										 NSString* theKey = [self keyForHotKey:[characters characterAtIndex:0] modifierFlags:[incomingEvent modifierFlags]];
										 
										 if (theKey)
										 {
											 NSMutableDictionary* subDict = [self.hotKeyMap objectForKey:theKey];
											 
											 if (subDict)
											 {
												 for (NTKeyEventMonitorToken* theToken in [subDict allValues])
													 [self sendNotification:theToken];
											 }
										 }
									 }
								 }
							 }];
	}
}
	
@end

