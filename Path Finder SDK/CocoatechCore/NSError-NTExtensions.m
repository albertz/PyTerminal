//
//  NSError-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSError-NTExtensions.h"

@implementation NSError (NTExtensions)

- (NSString*)formattedDescription;
{
	NSString* description = [self localizedDescription];
 
	NSString* reason = [self localizedFailureReason];
	
	// if NSError returns nil, we add our own local error string (someday NSError will probably add the strings)
	if (!reason)
	{
		NSString* errorString = [NSString stringWithFormat:@"%d", [self code]];
		reason = [NTLocalizedString localize:errorString table:@"macErrors"];
		
		// did it fail to localize?
		if ([reason isEqualToString:errorString])
			reason = nil;
	}
	
	NSString* suggestion = [self localizedRecoverySuggestion];
	
	return [NSString stringWithFormat:@"%@\n%@\n%@", description, reason?reason:@"", suggestion?suggestion:@""];
}

@end
