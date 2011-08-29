//
//  NSSortDescriptor-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NSSortDescriptor-NTExtensions.h"

@implementation NSSortDescriptor (NTExtensions)

+ (BOOL)sortAscending:(NSArray*)sortDescriptors;
{
	BOOL result = NO;
	
	// copy the acending flag out of the current sortDescriptor
	if ([sortDescriptors count])
	{
		NSSortDescriptor* sortDescriptor = [sortDescriptors objectAtIndex:0];
		
		result = [sortDescriptor ascending];
	}
	
	return result;
}

+ (NSArray*)sortDescriptors:(NSArray*)sortDescriptors ascending:(BOOL)ascending;
{
	NSSortDescriptor* oldSD, *newSD;
	NSMutableArray* result = [NSMutableArray array];
	
	// copy the acending flag out of the current sortDescriptor
	
	for (oldSD in sortDescriptors)
	{
		newSD = [[[NSSortDescriptor alloc] initWithKey:[oldSD key] ascending:ascending selector:[oldSD selector]] autorelease];
		
		[result addObject:newSD];
	}
	
	return result;	
}

+ (SEL)sortSelector:(NSArray*)sortDescriptors;
{
	SEL result = 0;
	
	// copy the acending flag out of the current sortDescriptor
	if ([sortDescriptors count])
	{
		NSSortDescriptor* sortDescriptor = [sortDescriptors objectAtIndex:0];
		
		result = [sortDescriptor selector];
	}
	
	return result;
}

+ (NSString*)sortKey:(NSArray*)sortDescriptors;
{
	NSString* result = @"";
	
	// copy the acending flag out of the current sortDescriptor
	if ([sortDescriptors count])
	{
		NSSortDescriptor* sortDescriptor = [sortDescriptors objectAtIndex:0];
		
		result = [sortDescriptor key];
	}
	
	return result;
}


@end
