//
//  NTDateFormatter.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Feb 27 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import "NTDateFormatter.h"
#import "NTGlobalPreferences.h"
#import "NSString-Utilities.h"
#import "NSDateFormatter-NTExtensions.h"

@interface NTDateFormatter (Private)
- (NSString*)shortDateFormatString;
- (NSString*)mediumDateFormatString;
- (NSString*)longDateFormatString;
@end

@implementation NTDateFormatter

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

@synthesize shortFormatter;
@synthesize mediumFormatter;
@synthesize longFormatter;
@synthesize fullFormatter, timeFormatter;
@synthesize todayString;
@synthesize yesterdayString;
@synthesize tomorrowString;

- (id)init
{
    self = [super init];

	self.shortFormatter = [NSDateFormatter dateFormatter:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
	self.mediumFormatter = [NSDateFormatter dateFormatter:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
	self.longFormatter = [NSDateFormatter dateFormatter:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
	self.fullFormatter = [NSDateFormatter dateFormatter:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle];
	self.timeFormatter = [NSDateFormatter dateFormatter:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

	self.todayString = [NTLocalizedString localize:@"Today"];
	self.tomorrowString = [NTLocalizedString localize:@"Tomorrow"];
	self.yesterdayString = [NTLocalizedString localize:@"Yesterday"];
	
    return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.shortFormatter = nil;
    self.mediumFormatter = nil;
    self.longFormatter = nil;
    self.fullFormatter = nil;
    self.timeFormatter = nil;
    self.todayString = nil;
    self.yesterdayString = nil;
    self.tomorrowString = nil;
	
    [super dealloc];
}

- (NSString *)dateString:(NSDate*)date format:(NTDateFormat)format relative:(BOOL)relative;
{
    if (date)
    {
        if (relative)
        {
			NSString *result=nil;
			NSInteger todaysDayOfCommonEra, datesDayOfCommonEra;
			NSCalendarDate* calendardate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]] autorelease];
			
			todaysDayOfCommonEra = [[NSCalendarDate calendarDate] dayOfCommonEra];
			datesDayOfCommonEra = [calendardate dayOfCommonEra];
			
			// if today, yesterday or tomorrow, do the relative string
			if (self.todayString && datesDayOfCommonEra == todaysDayOfCommonEra)
				result = self.todayString;
			else if (self.yesterdayString && datesDayOfCommonEra == (todaysDayOfCommonEra - 1))
				result =  self.yesterdayString;
			else if (self.tomorrowString && datesDayOfCommonEra == (todaysDayOfCommonEra + 1))
				result = self.tomorrowString;
			
			if (result)
			{
				if (format == kShortDate)
					return result;
				else
					return [result stringByAppendingFormat:@", %@", [self.timeFormatter stringFromDate:date]];
			}
        }
		
		if (format == kLongDate)
			return [self.longFormatter stringFromDate:date];
		else if (format == kShortDate)
			return [self.shortFormatter stringFromDate:date];
		else if (format == kMediumDate)
			return [self.mediumFormatter stringFromDate:date];            
		else if (format == kFullDate)
			return [self.fullFormatter stringFromDate:date];            

        // shouldn't get here, but just in case, might as well return something
        return [self.mediumFormatter stringFromDate:date];
    }

    return @"";  // some routines bomb if you return nil for a string
}

@end
