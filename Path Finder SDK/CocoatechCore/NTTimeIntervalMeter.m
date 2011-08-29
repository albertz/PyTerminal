//
//  NTTimeIntervalMeter.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/23/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTTimeIntervalMeter.h"

@interface NTTimeIntervalMeter()
@property (assign) NSTimeInterval lastTime;
@property (assign) NSTimeInterval successiveInterval;
@end

@implementation NTTimeIntervalMeter

@synthesize lastTime;
@synthesize successiveInterval;
@synthesize successiveCount;

+ (NTTimeIntervalMeter*)meter:(NSTimeInterval)successiveInterval;
{
	NTTimeIntervalMeter* result = [[NTTimeIntervalMeter alloc] init];
	
	result.successiveInterval = successiveInterval;
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    [super dealloc];
}

- (NSTimeInterval)update;
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval result = now - self.lastTime;

	if (result <= self.successiveInterval)
		self.successiveCount++;
	else
		self.successiveCount = 0;
	
	self.lastTime = now;
	
	//	NSLog(@"interval: %f, count:%d", result, self.successiveCount);
	
	return result;
}

@end
