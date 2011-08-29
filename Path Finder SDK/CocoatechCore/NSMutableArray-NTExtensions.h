//
//  NSMutableArray-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/30/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableArray (NTExtensions)

- (void)reverseOrder;

// avoids exception if nil
- (void)addObjectIf:(id)anObject;

- (void)removeNTProxyObjectIdenticalTo:(id)theObject;

- (void)insertObjectsFromArray:(NSArray *)anArray atIndex:(NSUInteger)anIndex;
- (void)insertObject:anObject inArraySortedUsingSelector:(SEL)selector;
- (NSUInteger)indexWhereObjectWouldBelong:(id)anObject inArraySortedUsingSelector:(SEL)selector;

@end
