//
//  NTUInt64Container.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTUInt64Container.h"

@interface NTUInt64Container (Private)
- (void)resizeMemory:(UInt8)length;
@end

@implementation NTUInt64Container

- (id)init;
{
	self = [self initWithCap:5 mapCap:5];
	
	return self;
}

- (id)initWithCap:(UInt8)capacity mapCap:(UInt8)mapCapacity;
{
	self = [super initWithMapCap:mapCapacity];
	
	if (capacity == 0)
		capacity = 1; 
	
	self->ints = NSZoneCalloc(NSDefaultMallocZone(), capacity, sizeof(UInt64));
	self->memoryLength = capacity;
	
	return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{	
	NSZoneFree(NSDefaultMallocZone(), self->ints);
    self->ints = nil;
	
    [super dealloc];
}

- (UInt64)intAtIndex:(UInt8)theIndex;
{
	UInt8 mappedIndex = [self mappedIndex:theIndex];
	if (mappedIndex != 0xFF)
	{
		if (mappedIndex < self->dataLength)
		{
			UInt64 result = self->ints[mappedIndex];
			
			return result;
		}
	}
	
	return 0;
}

- (void)setInt:(UInt64)theInt atIndex:(UInt8)theIndex;
{	
	UInt8 mappedIndex = [self mappedIndex:theIndex];
	if (mappedIndex == 0xFF)
	{
		// set index in the map
		mappedIndex = [self updateMappedIndex:theIndex];
	}
	
	if (mappedIndex < self->dataLength)
		self->ints[mappedIndex] = theInt;
	else 
	{	
		[self resizeMemory:mappedIndex+1];
		
		self->ints[mappedIndex] = theInt;
	}
}

@end

@implementation NTUInt64Container (Private)

- (void)resizeMemory:(UInt8)length;
{
	if (length > self->memoryLength)
	{		
		UInt8 newMemoryLength = length+1;
		self->ints = NSZoneRealloc(NSDefaultMallocZone(), self->ints, newMemoryLength * sizeof(UInt64));
		self->memoryLength = newMemoryLength;
		
		// zero out added memory
		for (UInt8 i=self->dataLength;i<self->memoryLength;i++)
			self->ints[i] = 0;		
	}
	
	self->dataLength = length;
}

@end

