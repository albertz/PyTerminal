//
//  NTIconControlValueTransformer.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/20/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTIconControlValueTransformer.h"

#define kBaseIconSize 12;

@implementation NTIconControlValueTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (double)calcNewValue:(double)dbl reverse:(BOOL)reverse;
{
	double result = dbl;
			
	if (reverse)
	{
		result = floor(result) * 2;
		
		result += kBaseIconSize;		
	}
	else
	{
		result -= kBaseIconSize;

		result = floor(result) / 2;
	}
	
	return result;
}

- (id)transformedValue:(id)value
{	
	NSNumber* result = [NSNumber numberWithInteger:0];
	
    if (value != nil) 
	{
		if ([value isKindOfClass:[NSNumber class]])
		{			
			double dbl = [value doubleValue];
			result = [NSNumber numberWithDouble:[self calcNewValue:dbl reverse:NO]];
		}
	}
		
	return result;
}

- (id)reverseTransformedValue:(id)value;
{
	NSNumber* result = [NSNumber numberWithInteger:0];
	
    if (value != nil) 
	{
		if ([value isKindOfClass:[NSNumber class]])
		{			
			double dbl = [value doubleValue];
			result = [NSNumber numberWithDouble:[self calcNewValue:dbl reverse:YES]];
		}
	}
		
	return result;	
}

@end
