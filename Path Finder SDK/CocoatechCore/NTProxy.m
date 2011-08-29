//
//  NTProxy.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/30/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTProxy.h"

@implementation NTProxy

@synthesize object;

+ (NTProxy*)proxyWithObject:(id)theObject;
{
	NTProxy* result = [[NTProxy alloc] init];
	
	result.object = theObject;
	
	return [result autorelease];
}

- (void)dealloc;
{
	self.object = nil;
	[super dealloc];
}

@end

@implementation NSArray (NTProxy)

- (NSUInteger)indexOfProxyObjectIdenticalTo:(id)theObject;
{
	NSUInteger theIndex = 0;
	for (NTProxy* proxy in self)
	{
		if (theObject == proxy.object)
			return theIndex;
		
		theIndex++;
	}
	
	return NSNotFound;
}

@end

