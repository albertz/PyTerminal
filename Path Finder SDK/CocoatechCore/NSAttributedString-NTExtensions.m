//
//  NSAttributedString-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/20/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NSAttributedString-NTExtensions.h"


@implementation NSAttributedString (NTExtensions)

+ (NSAttributedString*)stringWithString:(NSString*)inString attributes:(NSDictionary*)attributes;
{
	if (inString)
	{
		NSAttributedString* result = [[NSAttributedString alloc] initWithString:inString attributes:attributes];
		
		return [result autorelease];
	}
	
	return nil;
}

@end
