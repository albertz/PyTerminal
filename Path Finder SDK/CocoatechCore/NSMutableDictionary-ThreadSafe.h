//
//  NSMutableDictionary-ThreadSafe.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Sep 12 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSMutableDictionaryThreadSafeProtocol <NSObject>

- (id)threadSafeObjectForKey:(id)aKey;

- (void)threadSafeRemoveObjectForKey:(id)aKey;
- (void)threadSafeRemoveObjectsForKeys:(NSArray*)keys;
- (void)threadSafeRemoveAllObjects;
- (void)threadSafeRemoveObject:(id)anObject;
- (void)threadSafeRemoveObjects:(NSArray*)objects;

- (void)threadSafeSetObject:(id)anObject
					  forKey:(id)aKey;

	// returns a copy of the array
- (NSArray*)threadSafeAllValues;
- (NSArray*)threadSafeAllKeys;

- (NSUInteger)threadSafeCount;

- (NSString*)threadSafeKeyForObjectIdenticalTo:(id)anObject;

@end

@interface NSMutableDictionary (ThreadSafe) <NSMutableDictionaryThreadSafeProtocol>
@end
