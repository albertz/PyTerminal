//
//  NTTime.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/8/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTTime.h"
#import <sys/time.h>

@implementation NTTime

- (id)init;
{
	self = [super init];
	
	return self;
}

+ (NTTime*)time;
{
	NTTime* result = [[NTTime alloc] init];
	
	struct timeval tv;
	struct timezone tz;

	gettimeofday(&tv, &tz);

	result->mv_tv = tv;
	result->mv_tz = tz;
	
	return [result autorelease];
}

+ (NTTime*)timeWithTimespec:(struct timespec*)ts;
{
	NTTime* result = [[NTTime alloc] init];
	
	struct timeval tv;
	struct timezone tz={0,0};
	
	TIMESPEC_TO_TIMEVAL(&tv, ts);
	
	result->mv_tv = tv;
	result->mv_tz = tz;
	
	return [result autorelease];	
}

- (NSComparisonResult)compare:(NTTime *)right;
{
	NSComparisonResult result = [self compareSeconds:right];
	
	if (result == NSOrderedSame)
	{
		if (mv_tv.tv_usec < right->mv_tv.tv_usec)
			return NSOrderedAscending;
		else if (mv_tv.tv_usec > right->mv_tv.tv_usec)
			return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (NSComparisonResult)compareSeconds:(NTTime *)right;  // less accurate compare
{
	if (mv_tv.tv_sec < right->mv_tv.tv_sec)
		return NSOrderedAscending;
	else if (mv_tv.tv_sec > right->mv_tv.tv_sec)
		return NSOrderedDescending;
	
	return NSOrderedSame;
}

- (NSDate*)date;
{
	return [NSDate dateWithTimeIntervalSince1970:mv_tv.tv_sec];
}

- (struct timespec)timespec;
{
	struct timespec ts;
	
	TIMEVAL_TO_TIMESPEC(&mv_tv, &ts);
	
	return ts;
}

@end

