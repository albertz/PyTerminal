/*
 *  NSArray-NTExtensions.m
 *  CocoatechCore
 *
 *  Created by Steve Gehrman on 10/22/04.
 *  Copyright 2004 __MyCompanyName__. All rights reserved.
 *
 */

#include "NSArray-NTExtensions.h"

@implementation NSArray (NTExtensions)

// not very efficient, but useful when your not dealing with a mutable array and need to make an ocasional change
- (NSArray*)arrayByReplacingObjectAtIndex:(NSInteger)index withObject:(id)newItem;
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:self];
	
	if (index >= 0 && index < [result count])
		[result replaceObjectAtIndex:index withObject:newItem];
	
	return result;
}

- (NSArray *)arrayByRemovingObjectIdenticalTo:(id)anObject;
{
    NSMutableArray *filteredArray;
    
    if (![self containsObject:anObject])
        return [NSArray arrayWithArray:self];
	
    filteredArray = [NSMutableArray arrayWithArray:self];
    [filteredArray removeObjectIdenticalTo:anObject];
	
    return [NSArray arrayWithArray:filteredArray];
}

- (NSArray *)arrayByRemovingObject:(id)anObject;
{
    NSMutableArray *filteredArray;
    
    if (![self containsObject:anObject])
        return [NSArray arrayWithArray:self];
	
    filteredArray = [NSMutableArray arrayWithArray:self];
    [filteredArray removeObject:anObject];
	
    return [NSArray arrayWithArray:filteredArray];
}

- (NSArray*)arrayByRemovingDuplicates;  // returns same pointer if no changes needed
{
	NSMutableSet* set = [NSMutableSet set];
	BOOL foundDuplicates = NO;
	
	for (id obj in self)
	{
		if ([set member:obj] != nil)
			foundDuplicates = YES;
		else
			[set addObject:obj];
	}
	
	if (foundDuplicates)
		return [set allObjects];
	
	return self;
}

- (BOOL)validInsertIndex:(NSUInteger)index;
{
	if (index < 0)
		return NO;
	
	if (index > [self count])  // = count is OK for insert
		return NO;
	
	return YES;	
}

- (BOOL)validIndex:(NSUInteger)index;
{
	if (index < 0)
		return NO;
	
	if (index >= [self count])
		return NO;
	
	return YES;
}

- (id)safeObjectAtIndex:(NSUInteger)index;
{
	if ([self validIndex:index])
		return [self objectAtIndex:index];
	
	return nil;
}

- (NSArray *)arrayByAddingObjectToFront:(id)anObject;
{
	if (anObject)
		return [[NSArray arrayWithObject:anObject] arrayByAddingObjectsFromArray:self];
	
	return self;
}

- (NSMutableArray *)deepMutableCopy;
{
    NSMutableArray *newArray;
    NSUInteger objectIndex, count;
	
    count = [self count];
    newArray = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:count];
    for (objectIndex = 0; objectIndex < count; objectIndex++) {
        id anObject;
		
        anObject = [self objectAtIndex:objectIndex];
        if ([anObject respondsToSelector:@selector(deepMutableCopy)]) {
            anObject = [anObject deepMutableCopy];
            [newArray addObject:anObject];
            [anObject release];
        } else if ([anObject respondsToSelector:@selector(mutableCopy)]) {
            anObject = [anObject mutableCopy];
            [newArray addObject:anObject];
            [anObject release];
        } else {
            [newArray addObject:anObject];
        }
    }
	
    return newArray;
}

- (NSArray *)reversedArray;
{
    NSMutableArray *newArray;
    NSUInteger count;
    
    count = [self count];
    newArray = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:count] autorelease];
    while (count--) {
        [newArray addObject:[self objectAtIndex:count]];
    }
	
    return newArray;
}

- (NSArray *)arrayByPerformingSelector:(SEL)aSelector;
{
    // objc_msgSend won't bother passing the nil argument to the method implementation because of the selector signature.
    return [self arrayByPerformingSelector:aSelector withObject:nil];
}

- (NSArray *)arrayByPerformingSelector:(SEL)aSelector withObject:(id)anObject;
{
    NSMutableArray *result;
    NSUInteger objectIndex, count;
	
    result = [NSMutableArray array];
    for (objectIndex = 0, count = [self count]; objectIndex < count; objectIndex++) {
        id singleObject;
        id selectorResult;
		
        singleObject = [self objectAtIndex:objectIndex];
        selectorResult = [singleObject performSelector:aSelector withObject:anObject];
		
        if (selectorResult)
            [result addObject:selectorResult];
    }
	
    return result;
}

// used in tabView, we want to reorder the "tab array" while preserving the selection
+ (BOOL)moveSource:(NSUInteger*)ioSrcIndex 
			toDest:(NSUInteger*)ioDestIndex
		 selection:(NSUInteger*)ioSelectionIndex;
{
	NSUInteger srcIndex = *ioSrcIndex;
	NSUInteger destIndex = *ioDestIndex;
	NSUInteger selection = *ioSelectionIndex;
	
	// do nothing if same location
	if (srcIndex == destIndex)
		return NO;
	
	if (srcIndex < destIndex)
	{
		if (srcIndex == destIndex-1)
			return NO;
	}
	
	if (selection == srcIndex)
	{
		selection = destIndex;
		
		if (srcIndex < destIndex)
			selection--;
	}
	else
	{
		if (srcIndex > selection && destIndex <= selection)
			selection++;
		else if (srcIndex < selection && destIndex > selection)
			selection--;
	}
	
	// adjust destination if less than source
	if (srcIndex < destIndex)
		destIndex--;
	
	// set all out values
	*ioSrcIndex = srcIndex;
	*ioDestIndex = destIndex;
	*ioSelectionIndex = selection;
	
	return YES;
}	

@end