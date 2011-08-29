//
//  NSDate-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSDate-NTExtensions.h"

@implementation NSDate (NTExtensions)

- (NSString*)dateString:(NTDateFormat)format relative:(BOOL)relative;
{
	return [[NTDateFormatter sharedInstance] dateString:self format:format relative:relative];
}

+ (BOOL)UTCDateTimeIsValid:(UTCDateTime)inTime;
{
	union {
		UTCDateTime local;
		UInt64 shifted;
	} time;
	
	time.local = inTime;
	
	// invalid if not 0
	if (time.shifted)
		return YES;
	
	return NO;
}

+ (NSDate*)dateFromUTCDateTime:(UTCDateTime)inTime;
{
	NSDate *date=nil;
	
	if ([self UTCDateTimeIsValid:inTime])
	{
		CFAbsoluteTime outTime;
		
		OSStatus err = UCConvertUTCDateTimeToCFAbsoluteTime(&inTime, &outTime);
		
		if (!err)
			date = [NSDate dateWithTimeIntervalSinceReferenceDate:outTime];
	}
	
    return date;
}

+ (UTCDateTime)UTCDateTimeFromNSDate:(NSDate*)date;
{
	UTCDateTime result = {0,0,0};
	
	if (date)
	{
		UTCDateTime outTime;
		OSStatus err = UCConvertCFAbsoluteTimeToUTCDateTime([date timeIntervalSinceReferenceDate], &outTime);
		
		if (!err)
			result = outTime;
	}
	
	return result;
}

+ (BOOL)UTCDateTimeIsEqualTo:(UTCDateTime)inTime1 time:(UTCDateTime)inTime2;
{
    union {
        UTCDateTime local;
        UInt64 shifted;
    } time1;
    
    union {
        UTCDateTime local;
        UInt64 shifted;
    } time2;
	
    time1.local = inTime1;
    time2.local = inTime2;
	
    return (time1.shifted == time2.shifted);
}

@end
