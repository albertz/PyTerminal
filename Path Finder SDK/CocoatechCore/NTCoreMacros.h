/*
 *  NTCoreMacros.h
 *  CocoatechCore
 *
 *  Created by Steve Gehrman on 10/6/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

// This macro ensures that we call [super initialize] in our +initialize (since this behavior is necessary for some classes in Cocoa), but it keeps custom class initialization from executing more than once.
#define NTINITIALIZE \
do { \
	static BOOL hasBeenInitialized = NO; \
        [super initialize]; \
			if (hasBeenInitialized) \
				return; \
					hasBeenInitialized = YES;\
} while (0);

// use for method tracing
#define IN_M NSLog(@"in: [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define OUT_M NSLog(@"out: [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

#define NOW_M NSLog(@"%@", [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]);

// window macros

#define DISABLE_FLUSH_WINDOW(window_param) BOOL local_restoreFlushWindow = NO; \
if (![window_param isFlushWindowDisabled]) \
{ \
    [window_param disableFlushWindow]; \
        local_restoreFlushWindow = YES; \
} 

#define ENABLE_FLUSH_WINDOW(window_param) if (local_restoreFlushWindow) { \
	[window_param enableFlushWindow]; }
