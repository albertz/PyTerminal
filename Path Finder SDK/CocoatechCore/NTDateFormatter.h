//
//  NTDateFormatter.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Feb 27 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NTSingletonObject.h"

typedef enum
{
    kShortDate,
    kMediumDate,
    kLongDate,  
    kFullDate,   
} NTDateFormat;

@interface NTDateFormatter : NTSingletonObject
{
    NSDateFormatter* shortFormatter;
    NSDateFormatter* mediumFormatter;
    NSDateFormatter* longFormatter;
    NSDateFormatter* fullFormatter;
    NSDateFormatter* timeFormatter;
	
	NSString* todayString;
	NSString* yesterdayString;
	NSString* tomorrowString;
}

@property (retain) NSDateFormatter* shortFormatter;
@property (retain) NSDateFormatter* mediumFormatter;
@property (retain) NSDateFormatter* longFormatter;
@property (retain) NSDateFormatter* fullFormatter;
@property (retain) NSDateFormatter* timeFormatter;
@property (retain) NSString* todayString;
@property (retain) NSString* yesterdayString;
@property (retain) NSString* tomorrowString;

- (NSString *)dateString:(NSDate*)date format:(NTDateFormat)format relative:(BOOL)relative;

@end

