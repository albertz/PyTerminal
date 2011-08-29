//
//  NSCalendarDate-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSCalendarDate-NTExtensions.h"

@implementation NSCalendarDate (NTExtensions)

+ (NSCalendarDate*)today;
{
	NSCalendarDate* date = [NSCalendarDate date];
	return [NSCalendarDate dateWithYear:[date yearOfCommonEra]
								  month:[date monthOfYear]
									day:[date dayOfMonth] 
								   hour:0
								 minute:0
								 second:0
							   timeZone:[NSTimeZone defaultTimeZone]];
}

// rounds off date to begining of that day
+ (NSCalendarDate*)dayWithDate:(NSDate*)inDate;
{
	NSCalendarDate* date = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[inDate timeIntervalSinceReferenceDate]];
	
	return [NSCalendarDate dateWithYear:[date yearOfCommonEra]
								  month:[date monthOfYear]
									day:[date dayOfMonth] 
								   hour:0
								 minute:0
								 second:0
							   timeZone:[NSTimeZone defaultTimeZone]];
}

+ (NSCalendarDate*)todayAndDays:(NSInteger)days;
{
	NSCalendarDate *date = [self today];
	
	return [date dateByAddingYears:0 
							months:0 
							  days:days 
							 hours:0
						   minutes:0
						   seconds:0];
}	

+ (NSCalendarDate*)week;
{
	NSCalendarDate *date = [self today];
	
	return [date dateByAddingYears:0 
							months:0 
							  days:-[date dayOfWeek] 
							 hours:0
						   minutes:0
						   seconds:0];
}

+ (NSCalendarDate*)weekAndWeeks:(NSInteger)weeks;
{
	NSCalendarDate *date = [self week];
	
	return [date dateByAddingYears:0 
							months:0 
							  days:(weeks * 7)
							 hours:0
						   minutes:0
						   seconds:0];	
}

+ (NSCalendarDate*)month;
{
	NSCalendarDate *date = [self today];
	
	return [date dateByAddingYears:0 
							months:0 
							  days:-[date dayOfMonth] 
							 hours:0
						   minutes:0
						   seconds:0];
}

+ (NSCalendarDate*)monthAndMonths:(NSInteger)months;
{
	NSCalendarDate *date = [self month];
	
	return [date dateByAddingYears:0 
							months:months 
							  days:0 
							 hours:0
						   minutes:0
						   seconds:0];	
}

+ (NSCalendarDate*)year;
{
	NSCalendarDate *date = [self month];
	
	return [date dateByAddingYears:0 
							months:-[date monthOfYear] 
							  days:0 
							 hours:0
						   minutes:0
						   seconds:0];		
}

+ (NSCalendarDate*)yearAndYears:(NSInteger)years;
{
	NSCalendarDate *date = [self year];
	
	return [date dateByAddingYears:years
							months:0 
							  days:0 
							 hours:0
						   minutes:0
						   seconds:0];		
}

@end
