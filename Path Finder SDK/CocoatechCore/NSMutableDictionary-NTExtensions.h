//
//  NSMutableDictionary-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/30/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableDictionary (NTExtensions)

- (void)setObjectIf:(id)obj forKey:(id)key;

- (void)setBool:(BOOL)theBool forKey:(id)key;
- (BOOL)boolForKey:(id)key;

- (void)setInt:(NSInteger)theInt forKey:(id)key;
- (NSInteger)intForKey:(id)key;

- (void)setInteger:(NSInteger)theInt forKey:(id)key;
- (NSInteger)integerForKey:(id)key;

- (void)setObject:(id)anObject forKeys:(NSArray *)keys;
@end
