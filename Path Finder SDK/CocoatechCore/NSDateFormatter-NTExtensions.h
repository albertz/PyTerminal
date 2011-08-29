//
//  NSDateFormatter-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/24/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSDateFormatter (NTExtensions)

/*
 NSDateFormatterNoStyle  // supresses output
 NSDateFormatterShortStyle
 NSDateFormatterMediumStyle
 NSDateFormatterLongStyle
 NSDateFormatterFullStyle
 
 use: [formatter stringFromDate:date] to get a date string
 */
+ (NSDateFormatter*)dateFormatter:(NSDateFormatterStyle)theDateStyle timeStyle:(NSDateFormatterStyle)theTimeStyle;

@end
