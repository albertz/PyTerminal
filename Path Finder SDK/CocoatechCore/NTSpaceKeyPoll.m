//
//  NTSpaceKeyPoll.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/18/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTSpaceKeyPoll.h"
#import "NSEvent-Utilities.h"

@interface NTSpaceKeyPoll (Protocols) <NTSimpleTimerProtocol>
@end

@interface NTSpaceKeyPoll (Private)
- (void)doTest;
@end

@implementation NTSpaceKeyPoll

@synthesize delegate;
@synthesize spaceDown, timer, startDate, timerCount;

+ (NTSpaceKeyPoll*)poll:(id<NTSpaceKeyPollDelegate>)theDelegate;
{
	NTSpaceKeyPoll* result = [[NTSpaceKeyPoll alloc] init];
	
	result.delegate = theDelegate;
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    if (self.delegate)
		[NSException raise:@"must call setDelegate:nil" format:@"%@", NSStringFromClass([self class])];

	[self.timer clearDelegate];
	self.timer = nil;
	self.startDate = nil;
	
    [super dealloc];
}

- (void)start;
{
	self.spaceDown = NO;
	
	// test before starting the timer, maybe the space is already down?
	[self doTest];

	if (!self.spaceDown)
	{
		self.timerCount = 0;
		self.startDate = [NSDate date];

		self.timer = [NTSimpleTimer timer:0.01 message:@"" delegate:self repeats:YES];
		[self.timer start];
	}
}

- (void)stop;
{
	[self.timer clearDelegate];
	self.timer = nil;
	
	// get rid of any space key events so quicklook won't trigger after drop
	[NSApp discardEventsMatchingMask:NSKeyDownMask|NSKeyUpMask beforeEvent:nil];
}

@end

@implementation NTSpaceKeyPoll (Private)

- (void)doTest;
{
	if (!self.spaceDown)
	{
		self.spaceDown = [NSEvent spaceKeyDownNow];
		if (self.spaceDown)
		{
			[self.delegate spaceKeyDown:self];
			
			[self stop];
		}
	}	
}

@end

@implementation NTSpaceKeyPoll (Protocols) 

// <NTSimpleTimerProtocol>

- (void)delegate_simpleTimerNotification:(NSString*)message;
{
	self.timerCount++;
	
	// just trying to use as little cpu as possible.  limit to every 100 fires
	if ((self.timerCount % 100) == 0)
	{
		if (-[self.startDate timeIntervalSinceNow] > 10)
			[self stop];
	}
	
	[self doTest];
}

@end

