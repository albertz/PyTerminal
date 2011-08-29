//
//  NSObject-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Wed Oct 30 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NSObject-NTExtensions.h"

@interface NSObject (NTExtensionsPrivate)
- (NSString*)formattedDescription:(NSInteger)prependTabs prependReturn:(BOOL)prependReturn;
@end

@implementation NSObject (NTExtensions)

+ (id)make;
{	
	return [[[self alloc] init] autorelease];
}

+ (NSBundle *)bundle;
{
    return [NSBundle bundleForClass:self];
}

- (NSBundle *)bundle;
{
    return [isa bundle];
}

- (BOOL)tryToPerform:(SEL)selector outResult:(id*)outResult;
{
    BOOL result = NO;
	
    if ([self respondsToSelector:selector])
    {
        id resultObject = [self performSelector:selector];
		
        if (outResult)
            *outResult = resultObject;
		
        result = YES;
    }
	
    return result;
}

- (NSString*)formattedDescription;
{
	return [self formattedDescription:0];
}

- (NSString*)formattedDescription:(NSInteger)prependTabs;
{
	return [self formattedDescription:prependTabs prependReturn:NO];
}

// surrounds cancelPreviousPerformRequestsWithTarget with retain, autorelease since
// the object retained by the call could be your self, and any calls after this would crash
- (void)safeCancelPreviousPerformRequests;
{
	[self retain];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self autorelease];
}

- (void)safeCancelPreviousPerformRequestsWithSelector:(SEL)aSelector object:(id)anArgument;
{
	[self retain];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:aSelector object:anArgument];
	[self autorelease];
}

@end

@implementation NSObject (NTExtensionsPrivate)

- (NSString*)formattedDescription:(NSInteger)prependTabs prependReturn:(BOOL)prependReturn;
{
	NSString *result=nil;
	NSMutableString *tmp = [NSMutableString string];
	NSEnumerator* enumerator;
	BOOL firstTime=YES;
	
	if (prependReturn)
		[tmp appendString:@"\n"];

	if ([self isKindOfClass:[NSArray class]])
	{
		enumerator = [(NSArray*)self objectEnumerator];
		id obj;
		NSInteger index=0;
		
		while (obj = [enumerator nextObject])
		{
			obj = [obj formattedDescription:prependTabs+1 prependReturn:YES];
			
			if (obj)
			{		
				if (!firstTime)
					[tmp appendString:@"\n"];
				firstTime = NO;
				
				NSInteger tabIndex;
				for (tabIndex=0;tabIndex<prependTabs;tabIndex++)
					[tmp appendString:@"\t"];
				
				[tmp appendString:[NSString stringWithFormat:@"%ld: %@", index++, obj]];
			}
		}
		
		result = [NSString stringWithString:tmp];
	}
	else if ([self isKindOfClass:[NSDictionary class]])
	{
		enumerator = [(NSDictionary*)self keyEnumerator];
		id obj;
		NSString* key;
		
		while (key = [enumerator nextObject])
		{
			obj = [(NSDictionary*)self objectForKey:key];
			
			if (obj)
			{
				obj = [obj formattedDescription:prependTabs+1 prependReturn:YES];
				
				if (obj)
				{				
					if (!firstTime)
						[tmp appendString:@"\n"];
					firstTime = NO;
					
					NSInteger tabIndex;
					for (tabIndex=0;tabIndex<prependTabs;tabIndex++)
						[tmp appendString:@"\t"];
					
					[tmp appendString:[NSString stringWithFormat:@"%@: %@", key, obj]];
				}
			}		
		}
		
		result = [NSString stringWithString:tmp];
	}
	else
	{
		NSInteger tabIndex;
		for (tabIndex=0;tabIndex<prependTabs;tabIndex++)
			[tmp appendString:@"\t"];
		
		result = [self description];
	}
	
	return result;
}

@end
