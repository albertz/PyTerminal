//
//  NSMutableDictionary-ThreadSafe.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Sep 12 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NSMutableDictionary-ThreadSafe.h"
#import "NSDictionary-NTExtensions.h"

@implementation NSMutableDictionary (ThreadSafe)

- (id)threadSafeObjectForKey:(id)aKey;
{
    id result=nil;
	
	if (aKey)
	{
		@synchronized(self) {
			result = [self objectForKey:aKey];
			
			// for thread safety
			result = [[result retain] autorelease];
		}
	}
	
    return result;
}

- (void)threadSafeRemoveObjectForKey:(id)aKey;
{
	if (aKey)
	{
		@synchronized(self) {
			[self removeObjectForKey:aKey];
		}
	}
}

- (void)threadSafeRemoveObjectsForKeys:(NSArray*)keys;
{
	NSString* key;
	
	@synchronized(self) {	
		NSEnumerator *enumerator = [keys objectEnumerator];

		while (key = [enumerator nextObject])
			[self removeObjectForKey:key];
	}
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
			NSString *key = [self keyForObjectIdenticalTo:anObject];
			
			if (key)
				[self removeObjectForKey:key];
		}
	}
}

- (void)threadSafeRemoveObjects:(NSArray*)objects;
{
	@synchronized(self) {	
		NSEnumerator *enumerator = [objects objectEnumerator];
		id obj;
		
		while (obj = [enumerator nextObject])
		{
			NSString *key = [self keyForObjectIdenticalTo:obj];
			
			if (key)
				[self removeObjectForKey:key];
		}		
	}
}

- (NSString*)threadSafeKeyForObjectIdenticalTo:(id)anObject;
{
	NSString *result=nil;
	
	if (anObject)
	{
		@synchronized(self) {
			result = [self keyForObjectIdenticalTo:anObject];
		}	
	}
	
	return result;
}

- (void)threadSafeSetObject:(id)anObject forKey:(id)aKey;
{
	if (anObject && aKey)
	{
		@synchronized(self) {
			[self setObject:anObject forKey:aKey];
		}
	}
}

- (NSArray*)threadSafeAllValues;
{
	NSArray* result = nil;
	
    @synchronized(self) {
		result = [self allValues];
    }
	
	return result;
}

- (NSArray*)threadSafeAllKeys;
{
	NSArray* result = nil;
	
    @synchronized(self) {
		result = [self allKeys];
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

@end
