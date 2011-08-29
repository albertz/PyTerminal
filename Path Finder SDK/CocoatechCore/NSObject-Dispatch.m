//
//  NSObject-Dispatch.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/28/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import "NSObject-Dispatch.h"

@interface NSObject (DispatchPrivate)
- (long)priorityForMode:(NSInteger)mode;
- (void)dispatch_private:(long)priority thread:(SEL)thread main:(SEL)main param:(id)param;
- (void)dispatchAfter_private:(dispatch_time_t)time priority:(long)priority thread:(SEL)thread main:(SEL)main param:(id)param;
@end

@implementation NSObject (Dispatch)

// mode: -1, 0, 1 (low, default, high)
- (void)dispatch:(NSInteger)mode thread:(SEL)thread main:(SEL)main param:(id)param;
{
	[self dispatch_private:[self priorityForMode:mode] thread:thread main:main param:param];
}

// mode: -1, 0, 1 (low, default, high)
- (void)dispatchAfter:(NSTimeInterval)after mode:(NSInteger)mode thread:(SEL)thread main:(SEL)main param:(id)param;
{
	dispatch_time_t theTime = dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC);
	
	[self dispatchAfter_private:theTime priority:[self priorityForMode:mode] thread:thread main:main param:param];
}

@end

@implementation NSObject (DispatchPrivate)

- (long)priorityForMode:(NSInteger)mode;
{
	long priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
	
	if (mode == -1)
		priority = DISPATCH_QUEUE_PRIORITY_LOW;
	else if (mode == 1)
		priority = DISPATCH_QUEUE_PRIORITY_HIGH;

	return priority;
}

- (void)dispatch_private:(long)priority thread:(SEL)thread main:(SEL)main param:(id)param;
{	
	dispatch_async(dispatch_get_global_queue(priority, 0), ^{
		@try {
			
			id theResult = [self performSelector:thread withObject:param];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				@try {
					[self performSelector:main withObject:theResult];
				}
				@catch (NSException * e) {
					NSLog(@"%@ exception (main_queue): %@", NSStringFromSelector(_cmd), e);
				}
				@finally {
				}
			});
		}
		@catch (NSException * e) {
			NSLog(@"%@ exception (global_queue): %@", NSStringFromSelector(_cmd), e);
		}
		@finally {
		}
	});
}

- (void)dispatchAfter_private:(dispatch_time_t)time priority:(long)priority thread:(SEL)thread main:(SEL)main param:(id)param;
{	
	dispatch_after(time, dispatch_get_global_queue(priority, 0), ^{
		@try {
			
			id theResult = [self performSelector:thread withObject:param];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				@try {
					[self performSelector:main withObject:theResult];
				}
				@catch (NSException * e) {
					NSLog(@"%@ exception (main_queue): %@", NSStringFromSelector(_cmd), e);
				}
				@finally {
				}
			});
		}
		@catch (NSException * e) {
			NSLog(@"%@ exception (global_queue): %@", NSStringFromSelector(_cmd), e);
		}
		@finally {
		}
	});
}

@end
