//
//  NSMutableArray-ThreadSafe.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 10/13/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NSMutableArray-ThreadSafe.h"

@implementation NSMutableArray (ThreadSafe)

- (id)threadSafeObjectAtIndex:(NSUInteger)index;
{
    id result=nil;
	
    @synchronized(self) {
		if ((index >= 0) && (index < [self count]))
		{
			result = [self objectAtIndex:index];
			
			// for thread safety
			result = [[result retain] autorelease];
		}
	}
	
    return result;
}

- (void)threadSafeRemoveAllObjects;
{
    @synchronized(self) {
		[self removeAllObjects];
    }
}

- (void)threadSafeRemoveObject:(id)anObject;
{
	if (anObject)
	{
		@synchronized(self) {
			[self removeObject:anObject];
		}
	}
}

- (void)threadSafeRemoveObjectIdenticalTo:(id)anObject;
{
	if (anObject)
	{
		@synchronized(self) {
			[self removeObjectIdenticalTo:anObject];
		}
	}	
}

- (void)threadSafeAddObject:(id)anObject;
{
	if (anObject)
	{
		@synchronized(self) {
			[self addObject:anObject];
		}
	}
}

- (NSArray*)threadSafeAllObjects;
{
	NSArray* result = nil;
	
    @synchronized(self) {
		result = [NSArray arrayWithArray:self];
    }
	
	return result;
}

- (NSUInteger)threadSafeCount;
{
	NSUInteger result = 0;
	
    @synchronized(self) {
		result = [self count];
    }
	
	return result;
}

- (NSInteger)threadSafeIndexOfObjectIdenticalTo:(id)anObject;
{
	NSInteger result = NSNotFound;
	
	if (anObject)
	{
		@synchronized(self) {
			result = [self indexOfObjectIdenticalTo:anObject];
		}
	}
	
	return result;
}

@end
