//
//  NSMutableArray-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/30/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NSMutableArray-NTExtensions.h"
#import "NTProxy.h"

@implementation NSMutableArray (NTExtensions)

- (void)reverseOrder;
{
    NSInteger i, end, cnt = [self count];
    
    end = cnt-1;
    cnt /= 2;
    
    if (cnt)
    {
        for (i=0;i<cnt;i++)
            [self exchangeObjectAtIndex:i withObjectAtIndex:end--];
    }
}

- (void)addObjectIf:(id)anObject;
{
	// avoids exception if nil
	if (anObject)
		[self addObject:anObject];
}

- (void)removeNTProxyObjectIdenticalTo:(id)theObject;
{
	for (NTProxy* obj in self)
	{
		if (obj.object == theObject)
		{
			[self removeObject:obj];
			break;
		}
	}
}

- (void)insertObjectsFromArray:(NSArray *)anArray atIndex:(NSUInteger)anIndex
{
    [self replaceObjectsInRange:NSMakeRange(anIndex, 0) withObjectsFromArray:anArray];
}

typedef NSComparisonResult (*comparisonMethodIMPType)(id rcvr, SEL _cmd, id other);
struct selectorAndIMP {
    SEL selector;
    comparisonMethodIMPType implementation;
};

static NSComparisonResult compareWithSelectorAndIMP(id obj1, id obj2, void *context)
{
    return (((struct selectorAndIMP *)context) -> implementation)(obj1, (((struct selectorAndIMP *)context) -> selector), obj2);
}

- (NSUInteger)indexWhereObjectWouldBelong:(id)anObject inArraySortedUsingFunction:(NSComparisonResult (*)(id, id, void *))comparator context:(void *)context;
{
    NSUInteger low = 0;
    NSUInteger range = 1;
    NSUInteger test = 0;
    NSUInteger count = [self count];
    NSComparisonResult result;
    id compareWith;
    IMP objectAtIndexImp = [self methodForSelector:@selector(objectAtIndex:)];
    
    while (count >= range) /* range is the lowest power of 2 > count */
        range <<= 1;
	
    while (range) {
        test = low + (range >>= 1);
        if (test >= count)
            continue;
		compareWith = objectAtIndexImp(self, @selector(objectAtIndex:), test);
		if (compareWith == anObject) 
            return test;
		result = (NSComparisonResult)comparator(anObject, compareWith, context);
		if (result > 0) /* NSOrderedDescending */
            low = test+1;
		else if (result == NSOrderedSame) 
            return test;
    }
    return low;
}

- (NSUInteger)indexWhereObjectWouldBelong:(id)anObject inArraySortedUsingSelector:(SEL)selector;
{
    struct selectorAndIMP selAndImp;
	
    selAndImp.selector = selector;
    selAndImp.implementation = (comparisonMethodIMPType)[anObject methodForSelector:selector];
    
    return [self indexWhereObjectWouldBelong:anObject inArraySortedUsingFunction:compareWithSelectorAndIMP context:&selAndImp];
}

/* Assumes the array is already sorted to insert the object quickly in the right place */
- (void)insertObject:anObject inArraySortedUsingSelector:(SEL)selector;
{
    NSUInteger objectIndex = [self indexWhereObjectWouldBelong:anObject inArraySortedUsingSelector:selector];
    [self insertObject:anObject atIndex:objectIndex];
}    

@end
