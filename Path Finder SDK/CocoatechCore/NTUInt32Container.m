//
//  NTUInt32Container.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTUInt32Container.h"

@interface NTUInt32Container (Private)
- (void)resizeMemory:(UInt8)length;
@end

@implementation NTUInt32Container

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
	
	self->ints = NSZoneCalloc(NSDefaultMallocZone(), capacity, sizeof(UInt32));
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

- (UInt32)intAtIndex:(UInt8)theIndex;
{
	UInt8 mappedIndex = [self mappedIndex:theIndex];
	if (mappedIndex != 0xFF)
	{
		if (mappedIndex < self->dataLength)
		{
			UInt32 result = self->ints[mappedIndex];
			
			return result;
		}
	}
	
	return 0;
}

- (void)setInt:(UInt32)theInt atIndex:(UInt8)theIndex;
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

@implementation NTUInt32Container (Private)

- (void)resizeMemory:(UInt8)length;
{
	if (length > self->memoryLength)
	{		
		UInt8 newMemoryLength = length+1;
		self->ints = NSZoneRealloc(NSDefaultMallocZone(), self->ints, newMemoryLength * sizeof(UInt32));
		self->memoryLength = newMemoryLength;
		
		// zero out added memory
		for (UInt8 i=self->dataLength;i<self->memoryLength;i++)
			self->ints[i] = 0;		
	}
	
	self->dataLength = length;
}

@end

