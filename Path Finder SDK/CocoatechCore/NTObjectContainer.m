//
//  NTObjectContainer.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTObjectContainer.h"

@interface NTObjectContainer (Private)
- (void)resizeMemory:(UInt8)length;
@end

@implementation NTObjectContainer

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
		
	self->objects = NSZoneCalloc(NSDefaultMallocZone(), capacity, sizeof(id));
	self->memoryLength = capacity;
	
	return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	for (UInt8 i = 0;i<self->dataLength;i++)
		[self->objects[i] release];
	
	NSZoneFree(NSDefaultMallocZone(), self->objects);
    self->objects = nil;

    [super dealloc];
}

- (id)objAtIndex:(UInt8)theIndex;
{
	UInt8 mappedIndex = [self mappedIndex:theIndex];
	if (mappedIndex != 0xFF)
	{
		if (mappedIndex < self->dataLength)
		{
			id result = self->objects[mappedIndex];
			
			return result;
		}
	}
	
	return nil;
}

- (void)setObj:(id)theObject atIndex:(UInt8)theIndex;
{		
	UInt8 mappedIndex = [self mappedIndex:theIndex];
	if (mappedIndex == 0xFF)
	{
		// set index in the map
		mappedIndex = [self updateMappedIndex:theIndex];
	}
	
	if (mappedIndex < self->dataLength)
	{
		id previous = self->objects[mappedIndex];
				
		self->objects[mappedIndex] = [theObject retain];
		
		if (previous)
			[previous release];
	}
	else 
	{	
		[self resizeMemory:mappedIndex+1];
		
		self->objects[mappedIndex] = [theObject retain];
	}
}

@end

@implementation NTObjectContainer (Private)

- (void)resizeMemory:(UInt8)length;
{
	if (length > self->memoryLength)
	{		
		UInt8 newMemoryLength = length+1;
		self->objects = NSZoneRealloc(NSDefaultMallocZone(), self->objects, newMemoryLength * sizeof(id));
		self->memoryLength = newMemoryLength;
		
		// zero out added memory
		for (UInt8 i=self->dataLength;i<self->memoryLength;i++)
			self->objects[i] = nil;		
	}
	
	self->dataLength = length;
}

@end

