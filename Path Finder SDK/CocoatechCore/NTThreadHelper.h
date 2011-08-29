//
//  NTThreadHelper.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const NSTimeInterval kThreadTimeElapsedInterval;

@interface NTThreadHelper : NSObject {
	NSConditionLock *conditionLock;
	
	NSDate* lastSentProgressDate;
	NSMutableArray *queue;
	
	BOOL mv_killed;
	BOOL mv_complete;
}

+ (NTThreadHelper*)threadHelper;

- (void)pause;
- (void)wait;
- (void)resume;

- (BOOL)timeHasElapsed;  // kThreadTimeElapsedInterval timeInterval
- (BOOL)timeHasElapsed:(NSTimeInterval)timeInterval;

	// simple queue, adding unlocks thread, thread waits for data
- (void)addToQueue:(id)obj;
- (id)nextInQueue;  // waits if no data

	// just holds the state flag, doesn't actually kill the thread.  Thread loop must call this in it's loop and end naturally when YES
- (BOOL)killed:(NSUInteger *)count;
- (BOOL)killed;
- (void)setKilled:(BOOL)flag;

	// just holds the state flag, the thread must set it if used
- (BOOL)complete;
- (void)setComplete:(BOOL)flag;

@end
