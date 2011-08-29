/*
 *  NSArray-NTExtensions.h
 *  CocoatechCore
 *
 *  Created by Steve Gehrman on 10/22/04.
 *  Copyright 2004 __MyCompanyName__. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

@interface NSArray (NTExtensions)

// not very efficient, but useful when your not dealing with a mutable array and need to make an ocasional change
- (NSArray*)arrayByReplacingObjectAtIndex:(NSInteger)index withObject:(id)newItem;

- (id)safeObjectAtIndex:(NSUInteger)index;

- (BOOL)validIndex:(NSUInteger)index;
- (BOOL)validInsertIndex:(NSUInteger)index;

- (NSArray*)arrayByRemovingDuplicates;  // returns same pointer if no changes needed

- (NSArray *)arrayByAddingObjectToFront:(id)anObject;

	// used in tabView, we want to reorder the "tab array" while preserving the selection
+ (BOOL)moveSource:(NSUInteger*)ioSrcIndex 
			toDest:(NSUInteger*)ioDestIndex
		 selection:(NSUInteger*)ioSelectionIndex;

- (NSArray *)arrayByRemovingObjectIdenticalTo:(id)anObject;
- (NSArray *)arrayByRemovingObject:(id)anObject;

- (NSMutableArray *)deepMutableCopy;
- (NSArray *)arrayByPerformingSelector:(SEL)aSelector;
- (NSArray *)arrayByPerformingSelector:(SEL)aSelector withObject:(id)anObject;

- (NSArray *)reversedArray;

@end