//
//  NTAnimationDelegate.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/23/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTAnimationDelegate.h"

@implementation NTAnimationDelegate

@synthesize animations, delegate;

+ (NTAnimationDelegate*)frameDelegate:(id<NTAnimationDelegateProtocol>)theDelegate;
{
	NTAnimationDelegate* result = [[NTAnimationDelegate alloc] init];
	
	result.delegate = theDelegate;
	
	CATransition* one = [[[[result.delegate animationDelegateView:result] animationForKey:@"frameSize"] copy] autorelease];
	CATransition* two = [[[[result.delegate animationDelegateView:result] animationForKey:@"frameOrigin"] copy] autorelease];
	
	[one setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[two setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[one setDelegate:result];
	[two setDelegate:result];
	[result setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:one, @"frameSize", two, @"frameOrigin", nil]];	
	
	return [result autorelease];
}

+ (NTAnimationDelegate*)boundsDelegate:(id<NTAnimationDelegateProtocol>)theDelegate;
{
	NTAnimationDelegate* result = [[NTAnimationDelegate alloc] init];
	
	result.delegate = theDelegate;
	
	CATransition* one = [[[[result.delegate animationDelegateView:result] animationForKey:@"boundsSize"] copy] autorelease];
	CATransition* two = [[[[result.delegate animationDelegateView:result] animationForKey:@"boundsOrigin"] copy] autorelease];
	
	[one setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[two setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[one setDelegate:result];
	[two setDelegate:result];
	[result setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:one, @"boundsSize", two, @"boundsOrigin", nil]];	
	
	return [result autorelease];
}

- (void)clearDelegate;
{
	self.delegate = nil;
	
	// this array is retaining us since we are animations delegates
	self.animations = nil;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
	if (self.delegate)
		[NSException raise:@"must clearDelegate before releasing" format:@"%@", NSStringFromClass([self class])];
	
    self.animations = nil;
    [super dealloc];
}

- (void)animationDidStart:(CAAnimation *)anim;
{
	[self.delegate animationDelegateDidStart:self];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{
	[self.delegate animationDelegateDidStop:self finished:flag];
}

@end
