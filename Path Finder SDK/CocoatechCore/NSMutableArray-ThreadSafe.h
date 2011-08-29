//
//  NSMutableArray-ThreadSafe.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 10/13/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NSMutableArrayThreadSafeProtocol <NSObject>

- (id)threadSafeObjectAtIndex:(NSUInteger)index;
- (NSInteger)threadSafeIndexOfObjectIdenticalTo:(id)anObject;

- (void)threadSafeRemoveAllObjects;

- (void)threadSafeRemoveObject:(id)anObject;
- (void)threadSafeRemoveObjectIdenticalTo:(id)anObject;

- (void)threadSafeAddObject:(id)anObject;
- (NSArray*)threadSafeAllObjects;
- (NSUInteger)threadSafeCount;

@end

@interface NSMutableArray (ThreadSafe) <NSMutableArrayThreadSafeProtocol>
@end
