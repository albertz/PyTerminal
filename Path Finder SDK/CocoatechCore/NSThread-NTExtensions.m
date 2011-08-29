//
//  NSThread-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSThread-NTExtensions.h"
#import "NSObject-NTExtensions.h"
#import <pthread.h>

@interface NSThread (NTExtensionsPrivate)
@end

@implementation NSThread (NTExtensions)

+ (NSArray*)defaultRunLoopModes;
{
	return [NSArray arrayWithObjects:NSRunLoopCommonModes, nil];
}

@end

@implementation NSThread (NTExtensionsPrivate)

@end

@implementation NSObject (NSThreadNTExtensions)

- (void)performSelectorOnMainThread:(SEL)aSelector;
{
	[self performSelectorOnMainThread:aSelector withObject:nil];
}

- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)object;
{
	[self performSelectorOnMainThread:aSelector withObject:object waitUntilDone:NO modes:[NSThread defaultRunLoopModes]];
}

- (void)performDelayedSelector:(SEL)sel withObject:(id)obj;
{
	[self performDelayedSelector:sel withObject:obj delay:0];
}

- (void)performDelayedSelector:(SEL)sel withObject:(id)obj delay:(NSTimeInterval)delay;
{
	[self performSelector:sel withObject:obj afterDelay:delay inModes:[NSThread defaultRunLoopModes]];	
}

@end

