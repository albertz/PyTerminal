//
//  NSDateFormatter-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/24/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NSDateFormatter-NTExtensions.h"

@interface NSDateFormatter (NTExtensionsPrivate)
+ (void)setupDateFormatter;
@end

@implementation NSDateFormatter (NTExtensions)

+ (NSDateFormatter*)dateFormatter:(NSDateFormatterStyle)theDateStyle timeStyle:(NSDateFormatterStyle)theTimeStyle;
{
	[self setupDateFormatter];
	
	NSDateFormatter *result = [[NSDateFormatter alloc] init];
	[result setDateStyle:theDateStyle];
	[result setTimeStyle:theTimeStyle];
			
	return [result autorelease];
}

@end

@implementation NSDateFormatter (NTExtensionsPrivate)

// assume default behavior set for class using
+ (void)setupDateFormatter;
{
	static BOOL shared=NO;
	
	if (!shared)
	{
		shared = YES;
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	}
}

@end
