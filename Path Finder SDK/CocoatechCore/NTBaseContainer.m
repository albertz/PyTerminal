//
//  NTBaseContainer.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTBaseContainer.h"


@implementation NTBaseContainer

- (id)initWithMapCap:(UInt8)mapCapacity;
{
	self = [super init];
	
	if (mapCapacity == 0)
		mapCapacity = 1; 

	self->indexMap = NSZoneCalloc(NSDefaultMallocZone(), mapCapacity, sizeof(UInt8));
	self->indexMapLength = mapCapacity;
	
	for (UInt8 i=0;i<self->indexMapLength;i++)
		self->indexMap[i] = 0xFF;	
	
	return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	NSZoneFree(NSDefaultMallocZone(), self->indexMap);
    self->indexMap = nil;
	
    [super dealloc];
}

- (void)resizeIndexMap:(UInt8)length;
{
	if (length > self->indexMapLength)
	{
		UInt8 newIndexMapLength = length+1;
		self->indexMap = NSZoneRealloc(NSDefaultMallocZone(), self->indexMap, newIndexMapLength * sizeof(UInt8));
		
		// FF out added memory to mark as invalid
		for (UInt8 i=self->indexMapLength;i<newIndexMapLength;i++)
			self->indexMap[i] = 0xFF;		
		
		self->indexMapLength = newIndexMapLength;
	}
}

- (UInt8)mappedIndex:(UInt8)theIndex;
{	
	if (theIndex < self->indexMapLength)
	{
		UInt8 result = self->indexMap[theIndex];
		
		return result;
	}
	
	return 0xFF;
}

- (UInt8)updateMappedIndex:(UInt8)theIndex;
{
	[self resizeIndexMap:theIndex+1];
	
	self->indexMap[theIndex] = self->dataLength;  // set to next index
	
	return self->dataLength;
}

- (NSString*)description;
{
	return [NSString stringWithFormat:@"dataLen:%d, memoryLen:%d, mapLen:%d", self->dataLength, self->memoryLength, self->indexMapLength];
}

@end
