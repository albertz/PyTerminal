//
//  NSThread-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSThread (NTExtensions)
+ (NSArray*)defaultRunLoopModes;
@end

@interface NSObject (NSThreadNTExtensions)

// the modes are set to all the standard modes so the selector can fire even if in a modal or tracking state

- (void)performSelectorOnMainThread:(SEL)aSelector;
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)object;

- (void)performDelayedSelector:(SEL)sel withObject:(id)obj;  // delay is 0
- (void)performDelayedSelector:(SEL)sel withObject:(id)obj delay:(NSTimeInterval)delay;

@end