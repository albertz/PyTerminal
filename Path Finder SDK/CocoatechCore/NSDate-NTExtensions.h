//
//  NSDate-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NTDateFormatter.h"

@interface NSDate (NTExtensions)

- (NSString*)dateString:(NTDateFormat)format relative:(BOOL)relative;

+ (BOOL)UTCDateTimeIsValid:(UTCDateTime)inTime;

+ (NSDate*)dateFromUTCDateTime:(UTCDateTime)inTime;
+ (UTCDateTime)UTCDateTimeFromNSDate:(NSDate*)date;

+ (BOOL)UTCDateTimeIsEqualTo:(UTCDateTime)inTime1 time:(UTCDateTime)inTime2;

@end
