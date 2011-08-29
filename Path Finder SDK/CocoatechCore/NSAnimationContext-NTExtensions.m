//
//  NSAnimationContext-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSAnimationContext-NTExtensions.h"

@implementation NSAnimationContext (NTExtensions)

+ (void)begin:(BOOL)animate duration:(CGFloat)duration;
{
	[NSAnimationContext beginGrouping];
	
	// .25 is default
	[[NSAnimationContext currentContext] setDuration:animate ? duration : 0.0]; // Makes value-set operations take effect immediately
}

+ (void)end;
{
	[NSAnimationContext endGrouping];
}

@end
