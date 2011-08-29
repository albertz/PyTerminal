//
//  NTThreadHelper.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTThreadHelper.h"

const NSTimeInterval kThreadTimeElapsedInterval = .25;

// NSConditionLock states
typedef enum NTThreadHelperState
{
	kNTRunningThreadState=1,
	kNTPausedThreadState
} NTThreadHelperState;

@interface NTThreadHelper ()
@property (nonatomic, retain) NSConditionLock *conditionLock;
@property (nonatomic, retain) NSDate *lastSentProgressDate;
@property (nonatomic, retain) NSMutableArray *queue;
@end

@implementation NTThreadHelper

@synthesize conditionLock;
@synthesize lastSentProgressDate;
@synthesize queue;

- (void)dealloc;
{
    self.conditionLock = nil;
    self.lastSentProgressDate = nil;
    self.queue = nil;
	
	[super dealloc];
}

+ (NTThreadHelper*)threadHelper;
{
	NTThreadHelper* result = [[NTThreadHelper alloc] init];

	[result setConditionLock:[[[NSConditionLock alloc] initWithCondition:kNTRunningThreadState] autorelease]];
	[result setLastSentProgressDate:[NSDate date]];
	
	return [result autorelease];
}

- (void)pause;
{
	// pause thread, tell delegate, delegate asks user and restarts this thread
	if ([[self conditionLock] tryLockWhenCondition:kNTRunningThreadState])
		[[self conditionLock] unlockWithCondition:kNTPausedThreadState];	
}

- (void)wait;
{
	// wait until the lock is set to normal (pauses thread)
	[[self conditionLock] lockWhenCondition:kNTRunningThreadState];
	[[self conditionLock] unlockWithCondition:kNTRunningThreadState];
}

- (void)resume;
{
	// if paused, set back to normal
	if ([[self conditionLock] tryLockWhenCondition:kNTPausedThreadState])
		[[self conditionLock] unlockWithCondition:kNTRunningThreadState];
}

// simple queue, adding unlocks thread, thread waits for data
- (void)addToQueue:(id)obj;
{
	[[self conditionLock] lock];
	
	if (![self queue])
		[self setQueue:[NSMutableArray array]];
	
	[[self queue] addObject:obj];
	
	// unlocks waiting thread
	[[self conditionLock] unlockWithCondition:kNTRunningThreadState];
}

// will wait if no data
- (id)nextInQueue;
{
	id result=nil;

	if (![self killed])
	{
		NSInteger newCondition = kNTPausedThreadState;
		
		[[self conditionLock] lockWhenCondition:kNTRunningThreadState];
		{
			if (![self killed])
			{
				NSMutableArray *theQueue = [self queue];
				if ([theQueue count])
				{
					result = [theQueue objectAtIndex:0];
					
					// before we remove, make sure it doesn't go away
					[[result retain] autorelease];
					
					[theQueue removeObjectAtIndex:0];
				}
				
				// continue thread if still more pending requests
				if ([theQueue count])
					newCondition = kNTRunningThreadState;
			}
		}
		[[self conditionLock] unlockWithCondition:newCondition];
	}
	
	return result;
}

- (BOOL)timeHasElapsed;
{
	return [self timeHasElapsed:kThreadTimeElapsedInterval];
}

- (BOOL)timeHasElapsed:(NSTimeInterval)timeInterval;
{
	BOOL result = NO;
	
	@synchronized(self) {
		if (-[[self lastSentProgressDate] timeIntervalSinceNow] >= timeInterval)
		{
			result = YES;
			
			NSDate* newDate = [[NSDate alloc] init];  // avoiding autorelease pool in thread
			[self setLastSentProgressDate:newDate];
			[newDate release];
		}
	}
	
	return result;
}

- (BOOL)killed:(NSUInteger *)count;
{
	BOOL result = NO;
	
	(*count)++; // increment
	if ((*count) > 5)
	{
		(*count) = 0;
		
		result = [self killed];
	}
	
	return result;
}

//---------------------------------------------------------- 
//  killed 
//---------------------------------------------------------- 
- (BOOL)killed
{
	BOOL result=NO;
	
	@synchronized(self) {
		result = mv_killed;
	}
	
	return result;
}

- (void)setKilled:(BOOL)flag
{
	@synchronized(self) {
		mv_killed = flag;
	}
}

//---------------------------------------------------------- 
//  complete 
//---------------------------------------------------------- 
- (BOOL)complete
{
	BOOL result=NO;
	
	@synchronized(self) {
		result = mv_complete;
	}
	
	return result;
}

- (void)setComplete:(BOOL)flag
{
	@synchronized(self) {
		mv_complete = flag;
	}
}

@end


