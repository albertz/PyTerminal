//
//  NSValueTransformer-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NTIconControlValueTransformer.h"
#import "NTSizeFormatter.h"

@interface NTNumberValueTransformer : NSValueTransformer{} @end
@interface NTIconSizeValueTransformer : NSValueTransformer{} @end
@interface NTSecondsValueTransformer : NSValueTransformer{} @end
@interface NTByteValueTransformer : NSValueTransformer{} @end
@interface NTFloatToIntValueTransformer : NSValueTransformer{} @end

@implementation NSValueTransformer (NTExtensions)

+ (void)loadStandardTransformers;
{
	id transformer = [[[NTIconSizeValueTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"NTIconSizeValueTransformer"]; 
	
	transformer = [[[NTNumberValueTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"NTNumberValueTransformer"]; 

	transformer = [[[NTSecondsValueTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"NTSecondsValueTransformer"]; 	

	transformer = [[[NTByteValueTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"NTByteValueTransformer"]; 

	transformer = [[[NTFloatToIntValueTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"NTFloatToIntValueTransformer"]; 
	
	transformer = [[[NTIconControlValueTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:transformer forName:@"NTIconControlValueTransformer"]; 
}

@end

// ================================================================================

@implementation NTIconSizeValueTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)iconSizeNumber
{
	NSString* result = @"";
	
    if (iconSizeNumber != nil) 
	{
		if ([iconSizeNumber isKindOfClass:[NSNumber class]])
		{
			NSInteger iconSize = [iconSizeNumber integerValue];
			
			result = [NSString stringWithFormat:@"%ld x %ld", iconSize, iconSize];
		}
	}
	
	return result;
}

@end

// ================================================================================

@implementation NTNumberValueTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)number
{
	NSString* result = @"";
	
    if (number != nil) 
	{
		if ([number isKindOfClass:[NSNumber class]])
		{
			NSUInteger unsignedInt = [number unsignedIntegerValue];
			
			if (unsignedInt == 0)
				return @"";
			else
				result = [[NTSizeFormatter sharedInstance] numberString:unsignedInt];
		}
	}
	
	return result;
}

@end

// ================================================================================

@implementation NTSecondsValueTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)number
{
	NSString* result = @"";
	
    if (number != nil) 
	{
		if ([number isKindOfClass:[NSNumber class]])
		{
			NSInteger seconds = [number integerValue];
			
			if (seconds == 0)
				return @"";
			else
			{
				NSInteger minutes = seconds/60;
				NSInteger hours = minutes/60;
				 
				minutes = minutes%60;
				seconds %= 60;
				
				result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
			}
		}
	}
	
	return result;
}

@end

// ================================================================================

@implementation NTByteValueTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)number
{
	NSString* result = @"";
	
    if (number != nil) 
	{
		if ([number isKindOfClass:[NSNumber class]])
		{
			UInt64 bytes = [number unsignedLongLongValue];
			
			if (bytes == 0)
				result = @"";
			else
				result = [[NTSizeFormatter sharedInstance] fileSize:bytes];
		}
	}
	
	return result;
}

@end

// ================================================================================

// used when I set a text field to the value of a slider, don't want 24.0, just 24
@implementation NTFloatToIntValueTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)number
{
	NSNumber* result = [NSNumber numberWithInteger:0];
	
    if (number != nil) 
	{
		if ([number isKindOfClass:[NSNumber class]])
		{
			NSUInteger unsignedInt = [number unsignedIntegerValue];
			
			result = [NSNumber numberWithInteger:unsignedInt];
		}
	}
	
	return result;
}

@end

